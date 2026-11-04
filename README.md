# Portfolio admin setup

Files: supabase-setup.sql, admin.html, index-integration-snippet.html (paste into your index.html), this README.

## 1. Create the Supabase project
supabase.com > New project. Wait until it finishes starting.

## 2. Run the SQL
Dashboard > SQL Editor > New query > paste all of supabase-setup.sql > Run.
(It creates tables, RLS policies, 3 storage buckets, unique program IDs, and starter languages CPP/PY/JAVA/HTML. Safe to re-run.)

## 3. Create the administrator
1. Authentication > Users > Add user > Create new user. Enter your email + a strong password, tick Auto Confirm.
2. SQL Editor, run (use your email):
   insert into public.admins (user_id) select id from auth.users where email = 'YOUR_ADMIN_EMAIL';
3. Recommended: Authentication > Sign In / Providers > turn OFF "Allow new users to sign up".
   (Even if left on, strangers cannot write anything: RLS only allows rows listed in public.admins.)

## 4. Paste URL and anon key
Dashboard > Project Settings > API. Copy "Project URL" and the "anon public" key. NEVER use service_role.
Paste them in TWO places, replacing YOUR_SUPABASE_URL and YOUR_SUPABASE_ANON_KEY:
- admin.html: the two constants at the top of the <script> block
- the snippet block you add to index.html (same two constants at the top)

## 5. Add the loader to your portfolio
Open your index.html. Right before the final </body>, paste the entire contents of index-integration-snippet.html. Do not change anything else.

## 6. Open the sites
- Public: open index.html (visitors never log in).
- Admin: open admin.html and sign in. Add content, then tick Published. Reload index.html to see it.
Projects, skills, languages and Code Vault appear inside your existing chapters: Skills -> chapter III, Languages -> the grid in chapter II (About), Projects + Code Vault -> chapter IV.
If Supabase is not configured or has no published rows for a section, your static content stays as is.
