-- ============================================================
-- Migration 002: candidate_profiles table + RLS
-- Also creates the avatars Storage bucket for profile photos
-- Run this in Supabase SQL editor
-- ============================================================

-- Profile photos bucket (public read, owner write enforced by RLS)
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict do nothing;

-- Storage RLS: anyone can read, only owner can upload to their own path
create policy "Avatar images are publicly readable"
  on storage.objects for select
  using (bucket_id = 'avatars');

create policy "Users can upload their own avatar"
  on storage.objects for insert
  with check (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "Users can update their own avatar"
  on storage.objects for update
  using (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

-- ── Candidate profiles table ─────────────────────────────────────────────────

create table if not exists candidate_profiles (
  id               uuid        primary key references auth.users(id) on delete cascade,
  full_name        text        not null,
  phone            text        not null,
  photo_url        text,
  work_category    text        not null,
  experience_years text        not null,
  education        text        not null,
  skills           text[]      not null default '{}',
  current_city     text        not null,
  preferred_city   text,
  expected_salary  text        not null,
  about            text,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

alter table candidate_profiles enable row level security;

-- Users can only read and write their own profile row
create policy "Owner can read own profile"
  on candidate_profiles for select
  using (auth.uid() = id);

create policy "Owner can insert own profile"
  on candidate_profiles for insert
  with check (auth.uid() = id);

create policy "Owner can update own profile"
  on candidate_profiles for update
  using (auth.uid() = id);

-- PHASE 3: Employer can read limited fields (name, photo, work_category, skills)
--          when the candidate has applied to their job.
-- PHASE 4: Restrict phone/address exposure in the employer-facing view.
