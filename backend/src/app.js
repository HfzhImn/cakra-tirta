import cors from 'cors';
import express from 'express';
import { getDataMode } from './data/data-mode.js';
import { projectionRouter } from './routes/projection.js';
import { riskZonesRouter } from './routes/risk-zones.js';

export function createApp() {
  const app = express();
  const allowedOrigin = process.env.CORS_ORIGIN;

  app.use(cors(allowedOrigin ? { origin: allowedOrigin } : undefined));
  app.use(express.json({ limit: '1mb' }));

  app.get('/health', (_request, response) => {
    const mode = getDataMode();
    response.json({
      status: 'ok',
      service: 'cakra-tirta-api',
      dataMode: mode,
      database: mode === 'supabase' && process.env.SUPABASE_URL && process.env.SUPABASE_SERVICE_ROLE_KEY ? 'configured' : 'not_configured',
    });
  });

  app.use('/api/risk-zones', riskZonesRouter);
  app.use('/api/subsidence/projection', projectionRouter);
  app.use((error, _request, response, _next) => {
    console.error(error);
    response.status(500).json({ error: 'INTERNAL_ERROR', message: 'Terjadi kesalahan pada server.' });
  });

  return app;
}
