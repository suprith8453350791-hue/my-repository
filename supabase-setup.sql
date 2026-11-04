-- Portfolio CMS schema. Run once in Supabase Dashboard > SQL Editor. Safe to re-run.

create extension if not exists pgcrypto;

-- ---------- admins ----------
create table if not exists public.admins (user_id uuid primary key references auth.users(id) on delete cascade);
alter table public.admins enable row level security;
drop policy if exists "admins read own row" on public.admins;
create policy "admins read own row" on public.admins for select to authenticated using (user_id = auth.uid());

create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as
$$ select exists (select 1 from public.admins where user_id = auth.uid()) $$;
revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to anon, authenticated;

create or replace function public.touch_updated_at() returns trigger language plpgsql as
$$ begin new.updated_at = now(); return new; end $$;

-- ---------- tables ----------
create table if not exists public.languages (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  prefix text not null unique check (prefix ~ '^[A-Z][A-Z0-9]{0,9}$'),
  description text,
  logo_path text,
  sort_order int not null default 0,
  published boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.skills (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  level int not null default 50 check (level between 0 and 100),
  sort_order int not null default 0,
  published boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text,
  description text,
  tech text[] not null default '{}',
  url text,
  image_path text,
  sort_order int not null default 0,
  published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.programs (
  id uuid primary key default gen_random_uuid(),
  code_id text not null unique,
  language_id uuid not null references public.languages(id) on delete restrict,
  title text not null,
  description text,
  difficulty text not null default 'easy' check (difficulty in ('easy','medium','hard')),
  code text,
  output text,
  attachments jsonb not null default '[]'::jsonb,   -- [{ "path": "...", "name": "..." }] in bucket program-files
  published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------- unique program IDs (CPP-001, PY-001, ...) ----------
create or replace function public.set_program_code() returns trigger
language plpgsql security definer set search_path = public as $$
declare pfx text; n int;
begin
  select prefix into pfx from public.languages where id = new.language_id;
  if pfx is null then raise exception 'Unknown language'; end if;
  perform pg_advisory_xact_lock(hashtext('program_code_' || pfx));
  select coalesce(max((substring(code_id from '-(\d+)$'))::int), 0) + 1 into n
    from public.programs where code_id like pfx || '-%';
  new.code_id := pfx || '-' || lpad(n::text, 3, '0');
  return new;
end $$;
drop trigger if exists programs_set_code on public.programs;
create trigger programs_set_code before insert on public.programs for each row execute function public.set_program_code();

-- code_id can never be edited after creation
create or replace function public.lock_program_code() returns trigger language plpgsql as
$$ begin new.code_id := old.code_id; return new; end $$;
drop trigger if exists programs_lock_code on public.programs;
create trigger programs_lock_code before update on public.programs for each row execute function public.lock_program_code();

do $$ declare t text; begin
  foreach t in array array['languages','skills','projects','programs'] loop
    execute format('drop trigger if exists %I_touch on public.%I', t, t);
    execute format('create trigger %I_touch before update on public.%I for each row execute function public.touch_updated_at()', t, t);
  end loop;
end $$;

-- ---------- row level security ----------
do $$ declare t text; begin
  foreach t in array array['languages','skills','projects','programs'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists "public read published" on public.%I', t);
    execute format('create policy "public read published" on public.%I for select to anon, authenticated using (published = true)', t);
    execute format('drop policy if exists "admin full access" on public.%I', t);
    execute format('create policy "admin full access" on public.%I for all to authenticated using (public.is_admin()) with check (public.is_admin())', t);
  end loop;
end $$;

-- ---------- storage buckets (public read, admin-only write) ----------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types) values
  ('project-images', 'project-images', true, 5242880,  array['image/jpeg','image/png','image/webp','image/gif']),
  ('language-logos', 'language-logos', true, 1048576,  array['image/jpeg','image/png','image/webp','image/svg+xml']),
  ('program-files',  'program-files',  true, 10485760, null)
on conflict (id) do update set public = excluded.public, file_size_limit = excluded.file_size_limit, allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "admin insert portfolio files" on storage.objects;
drop policy if exists "admin update portfolio files" on storage.objects;
drop policy if exists "admin delete portfolio files" on storage.objects;
drop policy if exists "admin list portfolio files"   on storage.objects;
create policy "admin insert portfolio files" on storage.objects for insert to authenticated
  with check (bucket_id in ('project-images','language-logos','program-files') and public.is_admin());
create policy "admin update portfolio files" on storage.objects for update to authenticated
  using (bucket_id in ('project-images','language-logos','program-files') and public.is_admin());
create policy "admin delete portfolio files" on storage.objects for delete to authenticated
  using (bucket_id in ('project-images','language-logos','program-files') and public.is_admin());
create policy "admin list portfolio files" on storage.objects for select to authenticated
  using (bucket_id in ('project-images','language-logos','program-files') and public.is_admin());
-- Public files are served through the public bucket URL, so no anonymous storage policy is needed.

-- ---------- starter languages (IDs like CPP-001, PY-001, JAVA-001, HTML-001) ----------
insert into public.languages (name, prefix, sort_order) values
  ('C++','CPP',1), ('Python','PY',2), ('Java','JAVA',3), ('HTML','HTML',4)
on conflict do nothing;

-- ---------- AFTER creating your admin user in Authentication > Users, run (edit the email): ----------
-- insert into public.admins (user_id) select id from auth.users where email = 'YOUR_ADMIN_EMAIL';
