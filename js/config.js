// Add your own NEW Supabase project URL and publishable key.
// Never place a Supabase service_role key in frontend code.
const SUPABASE_URL = 'YOUR_SUPABASE_PROJECT_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_PUBLISHABLE_KEY';
const db = (window.supabase && SUPABASE_URL.startsWith('https://') && !SUPABASE_ANON_KEY.startsWith('YOUR_'))
  ? window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
  : null;
