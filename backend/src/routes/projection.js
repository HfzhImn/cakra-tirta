import { createClient } from '@supabase/supabase-js';
import { Router } from 'express';
import { getDataMode } from '../data/data-mode.js';
import { demoRiskZones, projectDemoZone } from '../data/demo-data.js';

export const projectionRouter = Router();

projectionRouter.get('/', async (request, response, next) => {
  const zoneId = request.query.zoneId;
  const year = Number(request.query.year);
  if (typeof zoneId !== 'string' || !zoneId || zoneId.length > 80 || !Number.isInteger(year) || year < 2026 || year > 2045) {
    return response.status(400).json({ error: 'INVALID_PROJECTION_QUERY', message: 'zoneId wajib diisi dan year harus antara 2026–2045.' });
  }
  if (getDataMode() === 'demo') {
    const zone = demoRiskZones.find((item) => item.id === zoneId);
    if (!zone) return response.status(404).json({ error: 'ZONE_NOT_FOUND', message: 'Zona tidak ditemukan.' });
    return response.json({ data: projectDemoZone(zone, year), source: 'demo', isDemo: true });
  }


  const { SUPABASE_URL: url, SUPABASE_SERVICE_ROLE_KEY: serviceRoleKey } = process.env;
  if (!url || !serviceRoleKey) {
    return response.status(503).json({ error: 'DATABASE_NOT_CONFIGURED', message: 'Mode Supabase aktif tetapi kredensial belum diisi.' });
  }

  try {
    const supabase = createClient(url, serviceRoleKey, { auth: { persistSession: false } });
    const { data, error } = await supabase
      .from('risk_zones')
      .select('id, kelurahan, risk_level, subsidence_rate_cm_year')
      .eq('id', zoneId)
      .maybeSingle();
    if (error) throw error;
    if (!data) return response.status(404).json({ error: 'ZONE_NOT_FOUND', message: 'Zona tidak ditemukan.' });
    return response.status(422).json({
      error: 'PROJECTION_BASELINE_MISSING',
      message: 'Proyeksi memerlukan baseline elevasi tervalidasi yang belum tersedia untuk zona ini.',
    });
  } catch (error) {
    return next(error);
  }
});
