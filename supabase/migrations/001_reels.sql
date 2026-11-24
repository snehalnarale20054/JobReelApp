-- ============================================================
-- Migration 001: reels table + RLS
-- Run this in Supabase SQL editor before running the app
-- ============================================================

create table if not exists reels (
  id            uuid        primary key default gen_random_uuid(),
  uploader_id   uuid        references auth.users(id) not null,
  stream_uid    text        not null,
  playback_url  text        not null,
  thumbnail_url text,
  caption       text,
  skill_tags    text[]      not null default '{}',
  uploader_name text        not null,
  like_count    integer     not null default 0,
  is_active     boolean     not null default true,
  deleted_at    timestamptz,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- Feed query index: active reels, newest first
create index if not exists reels_feed_idx
  on reels (created_at desc)
  where is_active = true and deleted_at is null;

-- RLS
alter table reels enable row level security;

create policy "Public reels readable by all"
  on reels for select
  using (is_active = true and deleted_at is null);

-- PHASE 2: add insert policy once auth exists
-- PHASE 4: add like_count update policy

-- ============================================================
-- Seed data — 20 Pexels job-skill videos
-- NOTE: uploader_id below is a placeholder UUID.
-- After Phase 2 (auth), replace with a real seeded user ID.
-- Videos stream directly from Pexels CDN — no backend upload needed.
-- ============================================================

insert into reels (uploader_id, stream_uid, playback_url, thumbnail_url, caption, skill_tags, uploader_name) values

-- 1. Metalwork / Welding
(
  '00000000-0000-0000-0000-000000000001',
  'pexels-36438777',
  'https://videos.pexels.com/video-files/36438777/36438777-hd_1080_1920_25fps.mp4',
  'https://images.pexels.com/videos/36438777/free-video-36438777.jpg',
  'Welding torch metalwork — precision fabrication on-site 🔥',
  ARRAY['Welder', 'Fabricator', 'Metalwork'],
  'Rajan Metalworks'
),

-- 2. Electrician wiring
(
  '00000000-0000-0000-0000-000000000001',
  'pexels-electrician-01',
  'https://videos.pexels.com/video-files/3195394/3195394-hd_1080_1920_30fps.mp4',
  'https://images.pexels.com/videos/3195394/free-video-3195394.jpg',
  'Panel wiring and cable management — 5 yrs experience ⚡',
  ARRAY['Electrician', 'Wiring', 'Panel Work'],
  'Suresh Electrical'
),

-- 3. Carpenter — circular saw
(
  '00000000-0000-0000-0000-000000000001',
  'pexels-35222303',
  'https://videos.pexels.com/video-files/35222303/35222303-hd_1080_1920_25fps.mp4',
  'https://images.pexels.com/videos/35222303/free-video-35222303.jpg',
  'Skilled carpenter — cutting and fitting wooden frames 🪚',
  ARRAY['Carpenter', 'Woodwork', 'Furniture'],
  'Prakash Carpentry'
),

-- 4. Construction worker — saw machine
(
  '00000000-0000-0000-0000-000000000001',
  'pexels-5972089',
  'https://videos.pexels.com/video-files/5972089/5972089-hd_1080_1920_25fps.mp4',
  'https://images.pexels.com/videos/5972089/free-video-5972089.jpg',
  'Site work — operating heavy cutting equipment safely 🏗️',
  ARRAY['Construction', 'Site Work', 'Power Tools'],
  'Mohan Constructions'
),

-- 5. Auto mechanic — engine repair
(
  '00000000-0000-0000-0000-000000000001',
  'pexels-5875901',
  'https://videos.pexels.com/video-files/5875901/5875901-hd_1080_1920_25fps.mp4',
  'https://images.pexels.com/videos/5875901/free-video-5875901.jpg',
  'Engine overhaul — complete dismantling and rebuild 🔧',
  ARRAY['Mechanic', 'Auto Repair', 'Engine Work'],
  'Vijay Auto Works'
),

-- 6. Two mechanics fixing car
(
  '00000000-0000-0000-0000-000000000001',
  'pexels-4489953',
  'https://videos.pexels.com/video-files/4489953/4489953-hd_1080_1920_25fps.mp4',
  'https://images.pexels.com/videos/4489953/free-video-4489953.jpg',
  'Car lift inspection and brake service — garage ready 🚗',
  ARRAY['Mechanic', 'Auto Repair', 'Brakes'],
  'Ganesh Motors'
),

-- 7. Painter — wall painting
(
  '00000000-0000-0000-0000-000000000001',
  'pexels-5650035',
  'https://videos.pexels.com/video-files/5650035/5650035-hd_1080_1920_25fps.mp4',
  'https://images.pexels.com/videos/5650035/free-video-5650035.jpg',
  'Wall painting — smooth roller finish, clean edges 🖌️',
  ARRAY['Painter', 'Wall Paint', 'Interior'],
  'Ashok Painters'
),

-- 8. Painter — close-up brushwork
(
  '00000000-0000-0000-0000-000000000001',
  'pexels-5374431',
  'https://videos.pexels.com/video-files/5374431/5374431-hd_1080_1920_25fps.mp4',
  'https://images.pexels.com/videos/5374431/free-video-5374431.jpg',
  'Detail brush painting — trim and skirting work 🏠',
  ARRAY['Painter', 'Finishing', 'Trim Work'],
  'Ram Colour Works'
),

-- 9. Bricklayer / Mason
(
  '00000000-0000-0000-0000-000000000001',
  'pexels-30214695',
  'https://videos.pexels.com/video-files/30214695/30214695-hd_1080_1920_25fps.mp4',
  'https://images.pexels.com/videos/30214695/free-video-30214695.jpg',
  'Bricklaying — straight lines and proper mortar joints 🧱',
  ARRAY['Mason', 'Bricklayer', 'Civil Work'],
  'Santosh Masonry'
),

-- 10. Chef — kitchen prep
(
  '00000000-0000-0000-0000-000000000001',
  'pexels-30541785',
  'https://videos.pexels.com/video-files/30541785/30541785-hd_1080_1920_25fps.mp4',
  'https://images.pexels.com/videos/30541785/free-video-30541785.jpg',
  'Professional kitchen — fast prep and clean plating 👨‍🍳',
  ARRAY['Cook', 'Chef', 'Kitchen'],
  'Deepak Kitchen'
),

-- 11. Chef — slicing and prep
(
  '00000000-0000-0000-0000-000000000001',
  'pexels-30325324',
  'https://videos.pexels.com/video-files/30325324/30325324-hd_1080_1920_25fps.mp4',
  'https://images.pexels.com/videos/30325324/free-video-30325324.jpg',
  'Speed chopping and station setup — hotel kitchen ready 🍴',
  ARRAY['Cook', 'Hotel', 'Food Prep'],
  'Nilesh Catering'
),

-- 12. Delivery rider — scooter
(
  '00000000-0000-0000-0000-000000000001',
  'pexels-5844781',
  'https://videos.pexels.com/video-files/5844781/5844781-hd_1080_1920_25fps.mp4',
  'https://images.pexels.com/videos/5844781/free-video-5844781.jpg',
  'On-time every time — 3 years delivery experience 🛵',
  ARRAY['Delivery', 'Rider', 'Logistics'],
  'Rahul Express'
),

-- 13. Blue collar construction crew
(
  '00000000-0000-0000-0000-000000000001',
  'pexels-6474139',
  'https://videos.pexels.com/video-files/6474139/6474139-hd_1080_1920_25fps.mp4',
  'https://images.pexels.com/videos/6474139/free-video-6474139.jpg',
  'Full construction crew — ready for site deployment 👷',
  ARRAY['Construction', 'Labour', 'Site Work'],
  'Maharashtra Builders'
),

-- 14. Cement / plastering
(
  '00000000-0000-0000-0000-000000000001',
  'pexels-30155259',
  'https://videos.pexels.com/video-files/30155259/30155259-hd_1080_1920_25fps.mp4',
  'https://images.pexels.com/videos/30155259/free-video-30155259.jpg',
  'Cement plastering — smooth wall finish, no bubbles 🏛️',
  ARRAY['Plaster', 'Civil Work', 'Mason'],
  'Arvind Civil Works'
),

-- 15. Electrician construction site
(
  '00000000-0000-0000-0000-000000000001',
  'pexels-electrician-02',
  'https://videos.pexels.com/video-files/6474494/6474494-hd_1080_1920_25fps.mp4',
  'https://images.pexels.com/videos/6474494/free-video-6474494.jpg',
  'Conduit laying and circuit testing on new site ⚡🔩',
  ARRAY['Electrician', 'Site Work', 'Conduit'],
  'Power Grid Services'
),

-- 16. Plumbing work
(
  '00000000-0000-0000-0000-000000000001',
  'pexels-plumber-01',
  'https://videos.pexels.com/video-files/6474486/6474486-hd_1080_1920_25fps.mp4',
  'https://images.pexels.com/videos/6474486/free-video-6474486.jpg',
  'Pipe fitting and leak testing — bathroom plumbing 🔧💧',
  ARRAY['Plumber', 'Pipe Fitting', 'Sanitary'],
  'Joshi Plumbing'
),

-- 17. Woodworking — hand tools
(
  '00000000-0000-0000-0000-000000000001',
  'pexels-woodwork-02',
  'https://videos.pexels.com/video-files/3209828/3209828-hd_1080_1920_25fps.mp4',
  'https://images.pexels.com/videos/3209828/free-video-3209828.jpg',
  'Hand tool woodwork — chisel and mallet joinery 🪵',
  ARRAY['Carpenter', 'Joinery', 'Hand Tools'],
  'Ramesh Wood Works'
),

-- 18. Security guard on duty
(
  '00000000-0000-0000-0000-000000000001',
  'pexels-security-01',
  'https://videos.pexels.com/video-files/3195756/3195756-hd_1080_1920_25fps.mp4',
  'https://images.pexels.com/videos/3195756/free-video-3195756.jpg',
  'Security duty — gate check and patrol round 🛡️',
  ARRAY['Security Guard', 'Watchman', 'Guard'],
  'Suraksha Services'
),

-- 19. Warehouse / logistics worker
(
  '00000000-0000-0000-0000-000000000001',
  'pexels-warehouse-01',
  'https://videos.pexels.com/video-files/4481326/4481326-hd_1080_1920_25fps.mp4',
  'https://images.pexels.com/videos/4481326/free-video-4481326.jpg',
  'Warehouse packing and dispatch — fast and accurate 📦',
  ARRAY['Warehouse', 'Packing', 'Logistics'],
  'Logistics Pro'
),

-- 20. Farming / agricultural work
(
  '00000000-0000-0000-0000-000000000001',
  'pexels-farming-01',
  'https://videos.pexels.com/video-files/5280022/5280022-hd_1080_1920_25fps.mp4',
  'https://images.pexels.com/videos/5280022/free-video-5280022.jpg',
  'Agricultural work — harvesting and field maintenance 🌾',
  ARRAY['Farmer', 'Agriculture', 'Field Work'],
  'Kisaan Cooperative'
);
