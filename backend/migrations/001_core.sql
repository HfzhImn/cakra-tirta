create extension if not exists pgcrypto;

create table public.risk_zones (
  id uuid primary key default gen_random_uuid(),
  kelurahan text not null,
  kecamatan text,
  geom jsonb not null,
  risk_level text check (risk_level in ('aman', 'waspada', 'bahaya')),
  subsidence_rate_cm_year numeric,
  updated_at timestamptz not null default now()
);

create table public.subsidence_records (
  id uuid primary key default gen_random_uuid(),
  risk_zone_id uuid not null references public.risk_zones(id) on delete cascade,
  year integer not null,
  rate_cm_year numeric not null,
  source text check (source in ('akademik', 'satelit')),
  created_at timestamptz not null default now(),
  unique (risk_zone_id, year, source)
);

create table public.tide_predictions (
  id uuid primary key default gen_random_uuid(),
  location text not null,
  predicted_at timestamptz not null,
  tide_height_cm numeric not null,
  source text not null default 'BMKG',
  created_at timestamptz not null default now()
);

create table public.flood_reports (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  latitude double precision not null check (latitude between -90 and 90),
  longitude double precision not null check (longitude between -180 and 180),
  photo_url text,
  water_depth_estimate_cm numeric check (water_depth_estimate_cm >= 0),
  verified_count integer not null default 1 check (verified_count >= 1),
  status text not null default 'pending' check (status in ('pending', 'verified', 'expired')),
  created_at timestamptz not null default now()
);

create index risk_zones_kelurahan_idx on public.risk_zones (kelurahan);
create index subsidence_zone_year_idx on public.subsidence_records (risk_zone_id, year);
create index tide_predictions_location_time_idx on public.tide_predictions (location, predicted_at desc);
create index flood_reports_location_idx on public.flood_reports (latitude, longitude);

alter table public.risk_zones enable row level security;
alter table public.subsidence_records enable row level security;
alter table public.tide_predictions enable row level security;
alter table public.flood_reports enable row level security;

create policy "Risk zones are readable"
  on public.risk_zones for select to anon, authenticated using (true);
create policy "Subsidence records are readable"
  on public.subsidence_records for select to anon, authenticated using (true);
create policy "Tide predictions are readable"
  on public.tide_predictions for select to anon, authenticated using (true);

-- Flood reports remain private until authenticated submission and moderation policies exist.
