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

		// Asegurar que la tabla exchange_rates existe
		async function ensureTable() {
			const exists = await database.schema.hasTable('exchange_rates');
			if (!exists) {
				await database.schema.createTable('exchange_rates', (table) => {
					table.increments('id').primary();
					table.string('currency', 10).notNullable();
					table.decimal('rate', 20, 8).notNullable();
					table.date('rate_date').notNullable();
					table.timestamp('created_at').defaultTo(database.fn.now());
					table.unique(['currency', 'rate_date']);
				});
				console.log('Tabla exchange_rates creada');
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
					// BCV usa coma como separador decimal
					return parseFloat(match[1].replace('.', '').replace(',', '.'));
				}
				return null;
			};

			return {
				usd: parseRate('dolar'),
				eur: parseRate('euro'),
			};
		}

		// GET /bcv-rates
		router.get('/', async (req, res) => {
			try {
				await ensureTable();

				const today = new Date().toISOString().split('T')[0];

				// Buscar tasas de hoy en DB
				let entries = await database('exchange_rates')
					.whereIn('currency', ['USD', 'EUR'])
					.where('rate_date', today);

				// Si no hay de hoy, buscar las más recientes
				if (entries.length < 2) {
					console.log('No rates for today, fetching latest available...');
					const latestUsd = await database('exchange_rates')
						.where('currency', 'USD')
						.orderBy('rate_date', 'desc')
						.first();

					const latestEur = await database('exchange_rates')
						.where('currency', 'EUR')
						.orderBy('rate_date', 'desc')
						.first();

					entries = [];
					if (latestUsd) entries.push(latestUsd);
					if (latestEur) entries.push(latestEur);
				}

				if (entries.length === 0) {
					// No data at all
					return res.status(404).json({
						error: 'No exchange rates found in database',
						provider: 'bcv',
						source: 'database_empty'
					});
				}

				const usd = entries.find((r) => r.currency === 'USD');
				const eur = entries.find((r) => r.currency === 'EUR');

				res.json({
					provider: 'bcv',
					source: 'database',
					rate_date: usd ? usd.rate_date : (eur ? eur.rate_date : null),
					// Retornar null si falta alguna moneda
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

		// GET /bcv-rates/history?days=7
		router.get('/history', async (req, res) => {
			try {
				await ensureTable();

				const days = parseInt(req.query.days) || 7;
				const since = new Date();
				since.setDate(since.getDate() - days);

				const rows = await database('exchange_rates')
					.whereIn('currency', ['USD', 'EUR'])
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
					provider: 'bcv',
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

		// POST /bcv-rates/refresh - Forzar re-scrape
		router.post('/refresh', async (req, res) => {
			try {
				await ensureTable();

				const rates = await scrapeRates();

				if (!rates.usd || !rates.eur) {
					throw new Error('No se pudieron extraer las tasas del HTML del BCV');
				}

				const today = new Date().toISOString().split('T')[0];

				for (const [currency, rate] of [['USD', rates.usd], ['EUR', rates.eur]]) {
					await database('exchange_rates')
						.insert({ currency, rate, rate_date: today })
						.onConflict(['currency', 'rate_date'])
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
	},
};
