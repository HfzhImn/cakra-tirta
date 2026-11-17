export function getDataMode() {
  return process.env.DATA_MODE || (process.env.NODE_ENV === 'production' ? 'supabase' : 'demo');
}
