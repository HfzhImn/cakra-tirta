import { createClient } from '@supabase/supabase-js';
import { Router } from 'express';
import { getDataMode } from '../data/data-mode.js';
import { demoRiskZones } from '../data/demo-data.js';

export const riskZonesRouter = Router();

riskZonesRouter.get('/', async (request, response, next) => {
  const { kelurahan } = request.query;
  if (kelurahan !== undefined && (typeof kelurahan !== 'string' || kelurahan.trim().length === 0 || kelurahan.length > 100)) {
    return response.status(400).json({ error: 'INVALID_KELURAHAN', message: 'Parameter kelurahan tidak valid.' });
  }

  if (getDataMode() === 'demo') {
    const data = demoRiskZones.filter((zone) => !kelurahan || zone.kelurahan.toLowerCase().includes(kelurahan.trim().toLowerCase()));
    return response.json({ data, source: 'demo', isDemo: true });
  }


  const { SUPABASE_URL: url, SUPABASE_SERVICE_ROLE_KEY: serviceRoleKey } = process.env;
  if (!url || !serviceRoleKey) {
    return response.status(503).json({ error: 'DATABASE_NOT_CONFIGURED', message: 'Mode Supabase aktif tetapi kredensial belum diisi.' });
  }

  try {
    const supabase = createClient(url, serviceRoleKey, { auth: { persistSession: false } });
    let query = supabase
      .from('risk_zones')
      .select('id, kelurahan, kecamatan, geom, risk_level, subsidence_rate_cm_year, updated_at')
      .order('kelurahan');
    if (kelurahan) query = query.ilike('kelurahan', `%${kelurahan.trim()}%`);

    const { data, error } = await query;
    if (error) throw error;
    return response.json({ data, source: 'supabase', isDemo: false });
  } catch (error) {
    return next(error);
  }
});
