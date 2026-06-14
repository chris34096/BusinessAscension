import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import Cockpit from './Cockpit';

export default async function CockpitPage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect('/login');
  return <Cockpit userEmail={user.email} />;
}
