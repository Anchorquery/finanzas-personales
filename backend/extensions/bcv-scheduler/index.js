import https from 'node:https';

// Fetch que ignora errores de certificado SSL (BCV tiene cert mal configurado)
function fetchInsecure(url) {
	return new Promise((resolve, reject) => {
		const req = https.get(url, {
			rejectUnauthorized: false,
			headers: {
				'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
			}
		}, (res) => {
			let data = '';
			res.on('data', (chunk) => { data += chunk; });
			res.on('end', () => resolve({ status: res.statusCode, body: data }));
		});
		req.on('error', reject);
		req.setTimeout(15000, () => { req.destroy(); reject(new Error('Timeout')); });
	});
}

// Scrape tasas del BCV
function scrapeRates(html) {
	const parseRate = (id) => {
		const regex = new RegExp(
			`id="${id}"[\\s\\S]*?<strong>\\s*([\\d.,]+)\\s*</strong>`,
			'i'
		);
		const match = html.match(regex);
		if (match && match[1]) {
			// BCV usa punto como separador de miles y coma como decimal
			const cleaned = match[1].replaceAll('.', '').replace(',', '.');
			const rate = parseFloat(cleaned);
			console.log(`[BCV-Scheduler] Parseado ${id}: raw="${match[1]}" → cleaned="${cleaned}" → ${rate}`);
			return rate;
		}
		console.warn(`[BCV-Scheduler] No se encontró tasa para id="${id}"`);
		return null;
	};

	return {
		usd: parseRate('dolar'),
		eur: parseRate('euro'),
	};
}

async function ensureTable(database) {
	try {
		const exists = await database.schema.hasTable('exchange_rates');
		if (!exists) {
			await database.schema.createTable('exchange_rates', (table) => {
				table.increments('id').primary();
				table.string('currency', 10).notNullable();
				table.decimal('rate', 20, 8).notNullable();
				table.date('rate_date').notNullable();
				table.string('provider', 20).notNullable().defaultTo('bcv');
				table.timestamp('created_at').defaultTo(database.fn.now());
				table.unique(['currency', 'rate_date', 'provider']);
			});
			console.log('[BCV-Scheduler] Tabla exchange_rates creada');
		} else {
			// Migración: agregar columna provider si no existe
			const hasProvider = await database.schema.hasColumn('exchange_rates', 'provider');
			if (!hasProvider) {
				await database.schema.alterTable('exchange_rates', (table) => {
					table.string('provider', 20).notNullable().defaultTo('bcv');
				});
				console.log('[BCV-Scheduler] Columna provider agregada a exchange_rates');

				try {
					await database.schema.alterTable('exchange_rates', (table) => {
						table.dropUnique(['currency', 'rate_date']);
					});
				} catch (_) { /* Constraint puede no existir */ }
				try {
					await database.schema.alterTable('exchange_rates', (table) => {
						table.unique(['currency', 'rate_date', 'provider']);
					});
				} catch (_) { /* Constraint puede ya existir */ }
			}
		}
	} catch (error) {
		console.error('[BCV-Scheduler] Error en ensureTable:', error.message);
		throw error;
	}
}

async function refreshBCVRates(database) {
	console.log('[BCV-Scheduler] Iniciando refresh de tasas BCV...');

	await ensureTable(database);

	console.log('[BCV-Scheduler] Fetching https://www.bcv.org.ve/ ...');
	const result = await fetchInsecure('https://www.bcv.org.ve/');

	if (result.status !== 200) {
		throw new Error(`BCV respondió con status: ${result.status}`);
	}

	console.log(`[BCV-Scheduler] HTML recibido: ${result.body.length} bytes`);

	const rates = scrapeRates(result.body);

	if (!rates.usd && !rates.eur) {
		console.error('[BCV-Scheduler] No se encontraron tasas en el HTML. Primeros 500 chars:', result.body.substring(0, 500));
		throw new Error('No se pudieron extraer las tasas del HTML del BCV');
	}

	const today = new Date().toISOString().split('T')[0];
	const saved = {};

	for (const [currency, rate] of [['USD', rates.usd], ['EUR', rates.eur]]) {
		if (rate == null) continue;

		try {
			// Intentar upsert
			const existing = await database('exchange_rates')
				.where({ currency, rate_date: today, provider: 'bcv' })
				.first();

			if (existing) {
				await database('exchange_rates')
					.where({ id: existing.id })
					.update({ rate, created_at: database.fn.now() });
				console.log(`[BCV-Scheduler] Actualizado ${currency}=${rate} (${today})`);
			} else {
				await database('exchange_rates')
					.insert({ currency, rate, rate_date: today, provider: 'bcv', created_at: database.fn.now() });
				console.log(`[BCV-Scheduler] Insertado ${currency}=${rate} (${today})`);
			}
			saved[currency.toLowerCase()] = rate;
		} catch (err) {
			console.error(`[BCV-Scheduler] Error guardando ${currency}:`, err.message);
		}
	}

	console.log(`[BCV-Scheduler] Refresh completado: USD=${saved.usd ?? 'N/A'}, EUR=${saved.eur ?? 'N/A'} (${today})`);
	return saved;
}

export default ({ schedule }, { database }) => {
	// Ejecutar cada 6 horas
	schedule('0 */6 * * *', async () => {
		try {
			console.log('[BCV-Scheduler] === CRON DISPARADO ===');
			await refreshBCVRates(database);
		} catch (error) {
			console.error('[BCV-Scheduler] Error en refresh programado:', error.message);
		}
	});

	// Ejecutar al iniciar el servidor
	setTimeout(async () => {
		try {
			console.log('[BCV-Scheduler] === REFRESH INICIAL AL ARRANCAR ===');
			await refreshBCVRates(database);
		} catch (error) {
			console.error('[BCV-Scheduler] Error en refresh inicial:', error.message);
		}
	}, 5000);
};
