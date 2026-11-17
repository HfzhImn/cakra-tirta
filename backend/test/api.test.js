import assert from 'node:assert/strict';
import { after, before, test } from 'node:test';
import { createApp } from '../src/app.js';

process.env.DATA_MODE = 'demo';
const server = createApp().listen(0);
let baseUrl;

before(async () => {
  await new Promise((resolve) => server.once('listening', resolve));
  baseUrl = `http://127.0.0.1:${server.address().port}`;
});

after(async () => {
  await new Promise((resolve, reject) => server.close((error) => error ? reject(error) : resolve()));
});

test('health declares demo data mode', async () => {
  const response = await fetch(`${baseUrl}/health`);
  const result = await response.json();
  assert.equal(response.status, 200);
  assert.equal(result.dataMode, 'demo');
});

test('risk zones are returned with demo provenance and filter correctly', async () => {
  const all = await fetch(`${baseUrl}/api/risk-zones`);
  const result = await all.json();
  assert.equal(result.isDemo, true);
  assert.equal(result.source, 'demo');
  assert.equal(result.data.length, 3);

  const filtered = await fetch(`${baseUrl}/api/risk-zones?kelurahan=timur`);
  const filteredResult = await filtered.json();
  assert.equal(filteredResult.data.length, 1);
  assert.equal(filteredResult.data[0].id, 'demo-zone-03');
});

test('projection calculates year-dependent demo output and validates range', async () => {
  const first = await fetch(`${baseUrl}/api/subsidence/projection?zoneId=demo-zone-01&year=2026`);
  const firstResult = await first.json();
  const later = await fetch(`${baseUrl}/api/subsidence/projection?zoneId=demo-zone-01&year=2036`);
  const laterResult = await later.json();
  assert.equal(first.status, 200);
  assert.equal(firstResult.data.projectedElevationCm, 12);
  assert.equal(laterResult.data.projectedElevationCm, -72);
  assert.equal(laterResult.isDemo, true);

  const invalid = await fetch(`${baseUrl}/api/subsidence/projection?zoneId=demo-zone-01&year=2046`);
  assert.equal(invalid.status, 400);
});
