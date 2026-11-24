# Free Job + Reels Platform — Master Context

## Project

Free Job + Reels Platform: a 100% free job marketplace for Indian blue-collar and entry-level workers,
built around a short-video feed instead of text listings. Three user types — Candidate/Worker, Employer/HR, Admin.

The audience drives every decision. Users are ordinary workers, often with limited formal education,
limited English and limited smartphone experience, on low-end Android phones and slow networks.
Large buttons, few screens, few form fields, simple words. When in doubt, remove a step.

## Stack — decided, do not re-litigate

- **Flutter**, Android first. Riverpod for state, go_router for navigation.
- **Supabase** — Postgres, Auth (phone OTP), Realtime, Storage, Row Level Security.
- **Cloudflare Stream** for all video.
- **FCM** for push notifications.
- **Postgres full-text search** with proper indexes for job search. No Elasticsearch, no Algolia.
- **Next.js + Tailwind** for the admin and employer web panels (later phase only).
- Languages: Marathi, Hindi, English.

## Hard rules

1. **Build only the current phase.**
2. **No hardcoded user-facing strings.** Every string goes through the `intl`/ARB system from Phase 0 onward.
3. **No video file ever touches our backend.** Upload goes device → Cloudflare Stream direct-upload URL.
4. **Row Level Security on every table from the moment it exists.**
5. **Never expose a candidate's phone number, exact address or email** to another user through the API.
6. **Every list is paginated.** No unbounded `select *`.
7. **Assume a 3G connection and a ₹6,000 phone with 2 GB RAM.**
8. **No payment gateway, no paywall, no premium tier.**

## Data model — core entities

`users`, `candidate_profiles`, `companies`, `jobs`, `applications`, `reels`, `likes`, `comments`,
`saves`, `conversations`, `messages`, `notifications`, `reports`, `interviews`, `skills`, `locations`,
`languages`, `admins`

Conventions: UUID primary keys, `created_at` and `updated_at` as `timestamptz` on every table,
soft delete via `deleted_at`, `snake_case` throughout.

## Phase discipline

- Build only the current phase's done-when list.
- Leave `// PHASE N:` comments at seams for future phases.
- If creating more than ~15 new files, stop and report drift.
- Build vertically: schema → query → UI → running on a device.

## Phases

| Phase | Goal |
|---|---|
| 0 | Foundation — shell, Supabase wired, localisation, design tokens |
| 1 | Reels feed, read-only |
| 2 | Identity: OTP, profile, resume |
| 3 | Jobs: post, search, detail |
| 4 | Apply and track |
| 5 | Chat, interviews, notifications |
| 6 | Reel upload |
| 7 | Admin panel |
| 8 | Trust, polish, launch readiness |
