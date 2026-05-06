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

export default {
	id: 'bcv-rates',
	handler: (router, { database }) => {

		// Asegurar que la tabla exchange_rates existe con soporte multi-proveedor
		async function ensureTable() {
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
				console.log('Tabla exchange_rates creada (con provider)');
			} else {
				// Migración: agregar columna provider si no existe
				const hasProvider = await database.schema.hasColumn('exchange_rates', 'provider');
				if (!hasProvider) {
					await database.schema.alterTable('exchange_rates', (table) => {
						table.string('provider', 20).notNullable().defaultTo('bcv');
					});
					// Recrear constraint único
					try {
						await database.schema.alterTable('exchange_rates', (table) => {
							table.dropUnique(['currency', 'rate_date']);
						});
					} catch (_) { /* puede no existir */ }
					try {
						await database.schema.alterTable('exchange_rates', (table) => {
							table.unique(['currency', 'rate_date', 'provider']);
						});
					} catch (_) { /* puede ya existir */ }
					console.log('Migración: columna provider agregada a exchange_rates');
				}
			}
		}

		// Scrape tasas del BCV
		async function scrapeRates() {
			const result = await fetchInsecure('https://www.bcv.org.ve/');

			if (result.status !== 200) {
				throw new Error(`BCV respondio con status: ${result.status}`);
			}

			const html = result.body;

			const parseRate = (id) => {
				const regex = new RegExp(
					`id="${id}"[\\s\\S]*?<strong>\\s*([\\d.,]+)\\s*</strong>`,
					'i'
				);
				const match = html.match(regex);
				if (match && match[1]) {
					// BCV usa punto como separador de miles y coma como decimal
					return parseFloat(match[1].replaceAll('.', '').replace(',', '.'));
				}
				return null;
			};

			return {
				usd: parseRate('dolar'),
				eur: parseRate('euro'),
			};
		}

		// GET /bcv-rates - Tasas actuales (con filtro opcional por proveedor)
		router.get('/', async (req, res) => {
			try {
				await ensureTable();

				const provider = req.query.provider || 'bcv';
				const today = new Date().toISOString().split('T')[0];

				// Buscar tasas de hoy en DB
				let entries = await database('exchange_rates')
					.whereIn('currency', ['USD', 'EUR'])
					.where('rate_date', today)
					.where('provider', provider);

				// Si no hay de hoy, buscar las más recientes
				if (entries.length === 0) {
					const latestUsd = await database('exchange_rates')
						.where('currency', 'USD')
						.where('provider', provider)
						.orderBy('rate_date', 'desc')
						.first();

					const latestEur = await database('exchange_rates')
						.where('currency', 'EUR')
						.where('provider', provider)
						.orderBy('rate_date', 'desc')
						.first();

					entries = [];
					if (latestUsd) entries.push(latestUsd);
					if (latestEur) entries.push(latestEur);
				}

				if (entries.length === 0) {
					return res.status(404).json({
						error: 'No exchange rates found in database',
						provider,
						source: 'database_empty'
					});
				}

				const usd = entries.find((r) => r.currency === 'USD');
				const eur = entries.find((r) => r.currency === 'EUR');

				res.json({
					provider,
					source: 'database',
					rate_date: usd ? usd.rate_date : (eur ? eur.rate_date : null),
					usd: usd ? parseFloat(usd.rate) : null,
					eur: eur ? parseFloat(eur.rate) : null,
					last_updated: usd ? usd.created_at : (eur ? eur.created_at : null)
				});

			} catch (error) {
				console.error('Error en bcv-rates:', error);
				res.status(500).json({
					error: 'Fallo al obtener tasas',
					details: error.message,
				});
			}
		});

		// GET /bcv-rates/providers - Tasas actuales de TODOS los proveedores
		router.get('/providers', async (req, res) => {
			try {
				await ensureTable();

				// Obtener la tasa más reciente de cada proveedor+moneda
				const rows = await database('exchange_rates')
					.select('provider', 'currency', 'rate', 'rate_date', 'created_at')
					.whereIn('currency', ['USD', 'EUR'])
					.orderBy('rate_date', 'desc')
					.orderBy('created_at', 'desc');

				// Agrupar: { bcv: { usd: X, eur: Y, ... }, binance: { usd: X }, ... }
				const providers = {};
				const seen = new Set();

				for (const row of rows) {
					const key = `${row.provider}_${row.currency}`;
					if (seen.has(key)) continue;
					seen.add(key);

					if (!providers[row.provider]) {
						providers[row.provider] = {
							rate_date: row.rate_date,
							last_updated: row.created_at,
						};
					}

					providers[row.provider][row.currency.toLowerCase()] = parseFloat(row.rate);
				}

				res.json({ providers });

			} catch (error) {
				console.error('Error en bcv-rates/providers:', error);
				res.status(500).json({
					error: 'Fallo al obtener tasas por proveedor',
					details: error.message,
				});
			}
		});

		// GET /bcv-rates/history?days=7&provider=bcv
		router.get('/history', async (req, res) => {
			try {
				await ensureTable();

				const days = parseInt(req.query.days) || 7;
				const provider = req.query.provider || 'bcv';
				const since = new Date();
				since.setDate(since.getDate() - days);

				const rows = await database('exchange_rates')
					.whereIn('currency', ['USD', 'EUR'])
					.where('provider', provider)
					.where('rate_date', '>=', since.toISOString().split('T')[0])
					.orderBy('rate_date', 'desc');

				// Agrupar por fecha
				const grouped = {};
				for (const row of rows) {
					if (!grouped[row.rate_date]) {
						grouped[row.rate_date] = {};
					}
					grouped[row.rate_date][row.currency.toLowerCase()] = parseFloat(row.rate);
				}

				res.json({
					provider,
					days,
					rates: grouped,
				});
			} catch (error) {
				console.error('Error en bcv-rates/history:', error);
				res.status(500).json({
					error: 'Fallo al obtener historial',
					details: error.message,
				});
			}
		});

		// POST /bcv-rates/refresh - Forzar re-scrape BCV
		router.post('/refresh', async (req, res) => {
			try {
				await ensureTable();

				const rates = await scrapeRates();

				if (!rates.usd && !rates.eur) {
					throw new Error('No se pudieron extraer las tasas del HTML del BCV');
				}

				const today = new Date().toISOString().split('T')[0];

				for (const [currency, rate] of [['USD', rates.usd], ['EUR', rates.eur]]) {
					if (rate == null) continue;

					await database('exchange_rates')
						.insert({ currency, rate, rate_date: today, provider: 'bcv' })
						.onConflict(['currency', 'rate_date', 'provider'])
						.merge({ rate, created_at: database.fn.now() });
				}

				res.json({
					provider: 'bcv',
					source: 'scrape',
					rate_date: today,
					usd: rates.usd,
					eur: rates.eur,
					refreshed: true,
				});
			} catch (error) {
				console.error('Error en bcv-rates/refresh:', error);
				res.status(500).json({
					error: 'Fallo al refrescar tasas',
					details: error.message,
				});
			}
		});

		// POST /bcv-rates/store - Guardar tasas de proveedor externo (Binance, paralelo, etc.)
		router.post('/store', async (req, res) => {
			try {
				await ensureTable();

				const { provider, currency, rate } = req.body;

				if (!provider || !currency || !rate) {
					return res.status(400).json({
						error: 'Se requieren campos: provider, currency, rate',
					});
				}

				if (provider === 'bcv') {
					return res.status(400).json({
						error: 'Use POST /refresh para tasas BCV',
					});
				}

				const today = new Date().toISOString().split('T')[0];

				await database('exchange_rates')
					.insert({
						currency: currency.toUpperCase(),
						rate: parseFloat(rate),
						rate_date: today,
						provider,
					})
					.onConflict(['currency', 'rate_date', 'provider'])
					.merge({ rate: parseFloat(rate), created_at: database.fn.now() });

				res.json({
					provider,
					currency: currency.toUpperCase(),
					rate: parseFloat(rate),
					rate_date: today,
					stored: true,
				});
			} catch (error) {
				console.error('Error en bcv-rates/store:', error);
				res.status(500).json({
					error: 'Fallo al guardar tasa',
					details: error.message,
				});
			}
		});
	},
};
