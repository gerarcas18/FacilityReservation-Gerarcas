// Supabase project configuration. The publishable key is safe for browser use
// when Row Level Security (RLS) is correctly enabled on all exposed tables.
// Never put a Supabase secret/service_role key in frontend code.
const SUPABASE_URL = 'https://wuoyrrahemvnvuymjrwu.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_blU-oryS6tVOG4lylTe19w_S4TcUCmb';
const db = (window.supabase && SUPABASE_URL.startsWith('https://') && !SUPABASE_ANON_KEY.startsWith('YOUR_'))
  ? window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
  : null;
