-- ============================================================
-- Migration 003: companies & jobs tables + FTS + RLS + Seed Data
-- ============================================================

-- 1. Companies Table
create table if not exists companies (
  id           uuid primary key references auth.users(id) on delete cascade,
  name         text not null,
  logo_url     text,
  city         text not null,
  district     text,
  state        text not null default 'Maharashtra',
  industry     text not null,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

-- 2. Jobs Table
create table if not exists jobs (
  id                  uuid primary key default gen_random_uuid(),
  company_id          uuid references companies(id) on delete cascade not null,
  title               text not null,
  category            text not null,
  job_type            text not null default 'Full-time',
  vacancies           integer not null default 1,
  city                text not null,
  district            text,
  state               text not null default 'Maharashtra',
  min_salary          integer not null,
  max_salary          integer not null,
  salary_type         text not null default 'Monthly',
  min_experience      text not null,
  min_education       text not null,
  skills_required     text[] not null default '{}',
  description         text not null,
  benefits            text[] not null default '{}',
  contact_person      text not null,
  is_active           boolean not null default true,
  deleted_at          timestamptz,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),

  search_tsv          tsvector generated always as (
    to_tsvector('english', coalesce(title, '') || ' ' || 
                           coalesce(category, '') || ' ' || 
                           coalesce(city, '') || ' ' || 
                           coalesce(district, '') || ' ' || 
                           coalesce(description, ''))
  ) stored
);

-- 3. Indexes
create index if not exists jobs_fts_idx on jobs using gin(search_tsv);
create index if not exists jobs_city_idx on jobs (city);
create index if not exists jobs_category_idx on jobs (category);
create index if not exists jobs_created_idx on jobs (created_at desc) where is_active = true and deleted_at is null;

-- 4. RLS
alter table companies enable row level security;
alter table jobs enable row level security;

create policy "Companies readable by public" on companies for select using (true);
create policy "Active jobs readable by public" on jobs for select using (is_active = true and deleted_at is null);

create policy "Employers can manage own company" on companies for all using (auth.uid() = id);
create policy "Employers can manage own jobs" on jobs for all using (auth.uid() = company_id);

-- 5. Seed Demo Employer & Jobs
-- Note: Uses sample UUID for demonstration. If needed, insert matching auth user or update company_id.
do $$
declare
  demo_company_id uuid := '00000000-0000-0000-0000-000000000002';
begin
  -- Insert dummy user into auth.users if not exists
  insert into auth.users (id, email, phone, role)
  values (demo_company_id, 'demo_employer@jobreels.com', '+919876543210', 'authenticated')
  on conflict (id) do nothing;

  -- Insert dummy company
  insert into companies (id, name, city, district, state, industry)
  values (demo_company_id, 'Tata AutoComp Systems', 'Pune', 'Pune', 'Maharashtra', 'Automotive & Manufacturing')
  on conflict (id) do nothing;

  -- Insert Seed Jobs
  insert into jobs (
    company_id, title, category, job_type, vacancies, city, district, state,
    min_salary, max_salary, min_experience, min_education, skills_required,
    description, benefits, contact_person
  ) values
  (
    demo_company_id,
    'Industrial Maintenance Electrician',
    'Electrician',
    'Full-time',
    5,
    'Pune',
    'Pune',
    'Maharashtra',
    18000,
    24000,
    '1–2 yrs',
    'ITI / Diploma',
    ARRAY['Wiring', '3-Phase Motor', 'PLC Troubleshooting', 'Safety Gear'],
    'Urgent requirement for plant maintenance electricians. Shift duty with overtime allowance and PF/ESIC.',
    ARRAY['PF & ESIC', 'Canteen', 'Overtime Pay', 'Transport'],
    'Sunil Patil (HR)'
  ),
  (
    demo_company_id,
    'MIG / TIG Welder & Fabricator',
    'Welder/Fabricator',
    'Full-time',
    8,
    'Pune',
    'Pune',
    'Maharashtra',
    20000,
    28000,
    '2–5 yrs',
    '10th Pass (SSC)',
    ARRAY['MIG Welding', 'TIG Welding', 'Sheet Metal', 'Blueprint Reading'],
    'Looking for experienced MIG/TIG welders for automotive body frame manufacturing. Immediate joining.',
    ARRAY['PF & ESIC', 'Accommodation Support', 'Overtime Pay'],
    'Mahesh Kadam (Site Supervisor)'
  ),
  (
    demo_company_id,
    'CNC Machine Operator & Helper',
    'Mechanic',
    'Full-time',
    10,
    'Mumbai',
    'Thane',
    'Maharashtra',
    16000,
    22000,
    'Less than 1 yr',
    '12th Pass (HSC)',
    ARRAY['CNC Turning', 'Vernier Caliper', 'Loading/Unloading'],
    'CNC machine operator position for manufacturing plant in Thane industrial area.',
    ARRAY['PF & ESIC', 'Tea & Snacks', 'Attendance Bonus'],
    'Ramesh Nair'
  ),
  (
    demo_company_id,
    'Commercial Plumber & Pipe Fitter',
    'Plumber',
    'Contract',
    4,
    'Nashik',
    'Nashik',
    'Maharashtra',
    17000,
    23000,
    '1–2 yrs',
    '10th Pass (SSC)',
    ARRAY['PVC Piping', 'Leakage Repair', 'Drainage', 'Sanitary Fitting'],
    'Commercial plumbing contract work for new residential township project.',
    ARRAY['Free Accommodation', 'Tools Provided'],
    'Anil Shinde'
  ),
  (
    demo_company_id,
    'Site Carpenter & Shuttering Specialist',
    'Carpenter',
    'Full-time',
    6,
    'Nagpur',
    'Nagpur',
    'Maharashtra',
    19000,
    25000,
    '2–5 yrs',
    '8th Pass',
    ARRAY['Shuttering', 'Formwork', 'Wood Cutting', 'Safety'],
    'Construction shuttering and woodwork for multi-story residential towers in Nagpur.',
    ARRAY['Site Mess (Food)', 'Accommodation', 'Medical Insurance'],
    'Vikram Gaikwad'
  ),
  (
    demo_company_id,
    'Heavy Vehicle & Delivery Driver',
    'Driver',
    'Full-time',
    3,
    'Aurangabad',
    'Chhatrapati Sambhajinagar',
    'Maharashtra',
    22000,
    30000,
    '5–10 yrs',
    '10th Pass (SSC)',
    ARRAY['Heavy Commercial Vehicle License', 'Route Navigation', 'Vehicle Care'],
    'Intercity goods transport driver needed. Valid commercial heavy vehicle driving license required.',
    ARRAY['Daily Trip Allowance', 'Accidental Insurance'],
    'Gopal Rathod'
  );
end $$;
