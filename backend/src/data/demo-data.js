export const demoRiskZones = [
  {
    id: 'demo-zone-01',
    kelurahan: 'Zona Contoh Utara',
    kecamatan: 'Wilayah ilustrasi',
    risk_level: 'waspada',
    subsidence_rate_cm_year: 8.4,
    baseline_elevation_cm: 12,
    center: { latitude: -6.95, longitude: 110.42 },
    data_source: 'illustrative',
  },
  {
    id: 'demo-zone-02',
    kelurahan: 'Zona Contoh Pesisir',
    kecamatan: 'Wilayah ilustrasi',
    risk_level: 'bahaya',
    subsidence_rate_cm_year: 14.2,
    baseline_elevation_cm: 8,
    center: { latitude: -6.97, longitude: 110.45 },
    data_source: 'illustrative',
  },
  {
    id: 'demo-zone-03',
    kelurahan: 'Zona Contoh Timur',
    kecamatan: 'Wilayah ilustrasi',
    risk_level: 'aman',
    subsidence_rate_cm_year: 3.1,
    baseline_elevation_cm: 18,
    center: { latitude: -6.94, longitude: 110.47 },
    data_source: 'illustrative',
  },
];

export function projectDemoZone(zone, year) {
  const years = year - 2026;
  const projectedElevationCm = Number((zone.baseline_elevation_cm - zone.subsidence_rate_cm_year * years).toFixed(1));
  const estimatedFloodDaysPerYear = Math.max(0, Math.min(120, Math.round(Math.max(0, -projectedElevationCm) * 1.2)));
  const riskLevel = projectedElevationCm < 0 ? 'bahaya' : projectedElevationCm < 8 ? 'waspada' : 'aman';

  return {
    zoneId: zone.id,
    kelurahan: zone.kelurahan,
    year,
    riskLevel,
    projectedElevationCm,
    estimatedFloodDaysPerYear,
    method: 'illustrative_linear',
    isDemo: true,
    notice: 'Angka ilustrasi untuk demo; bukan hasil pengukuran atau prediksi operasional.',
  };
}
