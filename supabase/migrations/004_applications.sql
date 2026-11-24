-- ============================================================
-- Migration 004: applications table + status enum + RLS
-- ============================================================

-- 1. Status enum type
do $$
begin
  if not exists (select 1 from pg_type where typname = 'application_status') then
    create type application_status as enum (
      'applied',
      'viewed',
      'shortlisted',
      'interview',
      'selected',
      'rejected'
    );
  end if;
end $$;

-- 2. Applications Table
create table if not exists applications (
  id            uuid primary key default gen_random_uuid(),
  job_id        uuid references jobs(id) on delete cascade not null,
  candidate_id  uuid references auth.users(id) on delete cascade not null,
  status        application_status not null default 'applied',
  notes         text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  unique(job_id, candidate_id)
);

-- 3. Indexes
create index if not exists applications_candidate_idx on applications (candidate_id, created_at desc);
create index if not exists applications_job_idx on applications (job_id, created_at desc);

-- 4. RLS on applications
alter table applications enable row level security;

-- Candidates can view their own applications
create policy "Candidates can read own applications"
  on applications for select
  using (auth.uid() = candidate_id);

-- Candidates can insert their own applications
create policy "Candidates can apply"
  on applications for insert
  with check (auth.uid() = candidate_id);

-- Employers can view applications for jobs they posted
create policy "Employers can view applicants for their jobs"
  on applications for select
  using (
    exists (
      select 1 from jobs
      where jobs.id = applications.job_id
      and jobs.company_id = auth.uid()
    )
  );

-- Employers can update applicant status
create policy "Employers can update applicant status"
  on applications for update
  using (
    exists (
      select 1 from jobs
      where jobs.id = applications.job_id
      and jobs.company_id = auth.uid()
    )
  );

-- 5. RLS Policy on candidate_profiles so employers can view applicant profiles
create policy "Employers can read candidate profiles of applicants"
  on candidate_profiles for select
  using (
    exists (
      select 1 from applications
      join jobs on jobs.id = applications.job_id
      where applications.candidate_id = candidate_profiles.id
      and jobs.company_id = auth.uid()
    )
  );
