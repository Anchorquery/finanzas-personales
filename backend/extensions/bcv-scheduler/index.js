import https from 'node:https';

function fetchInsecure(url) {
	return new Promise((resolve, reject) => {
		const req = https.get(url, {
			rejectUnauthorized: false,
			headers: {
				'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
				'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
				'Accept-Language': 'es-VE,es;q=0.9',
			}
		}, (res) => {
			let data = '';
			res.on('data', (chunk) => { data += chunk; });
			res.on('end', () => resolve({ status: res.statusCode, body: data }));
		});
		req.on('error', reject);
		req.setTimeout(20000, () => { req.destroy(); reject(new Error('Timeout')); });
	});
}

function scrapeRates(html) {
	const parseRate = (id) => {
		// Patrón 1: id="dolar" ... <strong>36,5000</strong>
		const p1 = new RegExp(`id="${id}"[\\s\\S]{0,500}?<strong>\\s*([\\d.,]+)\\s*</strong>`, 'i');
		// Patrón 2: id="dolar" ... <span class="...">36,5000</span>
		const p2 = new RegExp(`id="${id}"[\\s\\S]{0,500}?<span[^>]*>\\s*([\\d]+[.,][\\d.,]+)\\s*</span>`, 'i');
		// Patrón 3: data-field="dolar" ... número
		const p3 = new RegExp(`data-[a-z]+="${id}"[\\s\\S]{0,300}?([\\d]+[,\\.][\\d]+)`, 'i');
		// Patrón 4: texto "Dólar" seguido de número con formato venezolano
		const p4 = id === 'dolar'
			? /[Dd]ól(?:ar)?[^<]{0,200}([0-9]{1,3}(?:\.[0-9]{3})*,[0-9]+)/
			: /[Ee]uro[^<]{0,200}([0-9]{1,3}(?:\.[0-9]{3})*,[0-9]+)/;

		for (const [i, pattern] of [[1, p1], [2, p2], [3, p3], [4, p4]]) {
			const match = html.match(pattern);
			if (match?.[1]) {
				const cleaned = match[1].replaceAll('.', '').replace(',', '.');
				const rate = parseFloat(cleaned);
				if (!isNaN(rate) && rate > 0) {
					console.log(`[BCV-Scheduler] Patrón ${i} → ${id}: raw="${match[1]}" rate=${rate}`);
					return rate;
				}
			}
		}

		// Debug: mostrar contexto alrededor de "dolar"/"euro" en el HTML
		const ctxMatch = html.match(new RegExp(`.{0,200}${id}.{0,200}`, 'i'));
		if (ctxMatch) {
			console.warn(`[BCV-Scheduler] No extraído "${id}". Contexto HTML:`, ctxMatch[0].replace(/\s+/g, ' '));
		} else {
			console.warn(`[BCV-Scheduler] Palabra "${id}" no encontrada en HTML`);
		}
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
			const hasProvider = await database.schema.hasColumn('exchange_rates', 'provider');
			if (!hasProvider) {
				await database.schema.alterTable('exchange_rates', (table) => {
					table.string('provider', 20).notNullable().defaultTo('bcv');
				});
				try { await database.schema.alterTable('exchange_rates', (t) => t.dropUnique(['currency', 'rate_date'])); } catch (_) {}
				try { await database.schema.alterTable('exchange_rates', (t) => t.unique(['currency', 'rate_date', 'provider'])); } catch (_) {}
				console.log('[BCV-Scheduler] Columna provider migrada');
			}
		}
	} catch (error) {
		console.error('[BCV-Scheduler] Error ensureTable:', error.message);
		throw error;
	}
}

async function refreshBCVRates(database) {
	console.log('[BCV-Scheduler] Iniciando refresh...');
	await ensureTable(database);

	const result = await fetchInsecure('https://www.bcv.org.ve/');
	if (result.status !== 200) throw new Error(`BCV status: ${result.status}`);
	console.log(`[BCV-Scheduler] HTML recibido: ${result.body.length} bytes`);

	const rates = scrapeRates(result.body);

	if (!rates.usd && !rates.eur) {
		// Guardar fragmento HTML para debug manual
		console.error('[BCV-Scheduler] Tasas no encontradas. Primeros 2000 chars del HTML:');
		console.error(result.body.substring(0, 2000).replace(/\s+/g, ' '));
		throw new Error('No se pudieron extraer tasas del BCV');
	}

	const today = new Date().toISOString().split('T')[0];
	const saved = {};

	for (const [currency, rate] of [['USD', rates.usd], ['EUR', rates.eur]]) {
		if (rate == null) continue;
		try {
			const existing = await database('exchange_rates').where({ currency, rate_date: today, provider: 'bcv' }).first();
			if (existing) {
				await database('exchange_rates').where({ id: existing.id }).update({ rate, created_at: database.fn.now() });
				console.log(`[BCV-Scheduler] Actualizado ${currency}=${rate}`);
			} else {
				await database('exchange_rates').insert({ currency, rate, rate_date: today, provider: 'bcv', created_at: database.fn.now() });
				console.log(`[BCV-Scheduler] Insertado ${currency}=${rate}`);
			}
			saved[currency.toLowerCase()] = rate;
		} catch (err) {
			console.error(`[BCV-Scheduler] Error guardando ${currency}:`, err.message);
		}
	}

	console.log(`[BCV-Scheduler] Completado: USD=${saved.usd ?? 'N/A'}, EUR=${saved.eur ?? 'N/A'} (${today})`);
	return saved;
}

export default ({ schedule }, { database }) => {
	schedule('0 */6 * * *', async () => {
		try {
			console.log('[BCV-Scheduler] === CRON ===');
			await refreshBCVRates(database);
		} catch (error) {
			console.error('[BCV-Scheduler] Error cron:', error.message);
		}
	});

	setTimeout(async () => {
		try {
			console.log('[BCV-Scheduler] === ARRANQUE ===');
			await refreshBCVRates(database);
		} catch (error) {
			console.error('[BCV-Scheduler] Error arranque:', error.message);
		}
	}, 8000);
};
