import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import Cockpit from './Cockpit';

export const dynamic = 'force-dynamic';

function rel(ts) {
  const s = (Date.now() - new Date(ts).getTime()) / 1000;
  if (s < 3600) return 'il y a ' + Math.max(1, Math.round(s / 60)) + ' min';
  if (s < 86400) return 'il y a ' + Math.round(s / 3600) + 'h';
  return 'il y a ' + Math.round(s / 86400) + 'j';
}
const nameOf = (r) => r.prenom || (r.email ? r.email.split('@')[0] : 'Lead');

export default async function CockpitPage() {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  // Lecture réelle des leads (policy select réservée aux utilisateurs authentifiés)
  const [quizRes, planRes] = await Promise.all([
    supabase.from('quiz_resultats').select('id,created_at,prenom,email,archetype,porte').order('created_at', { ascending: false }).limit(100),
    supabase.from('plan_decollage').select('id,created_at,prenom,email').order('created_at', { ascending: false }).limit(100),
  ]);

  const quiz = quizRes.data || [];
  const plan = planRes.data || [];
  const dbError = quizRes.error?.message || planRes.error?.message || null;

  const leads = [
    ...quiz.map((r) => ({ n: nameOf(r), email: r.email, src: 'Quiz', stage: r.archetype || 'Quiz complété', score: '—', when: rel(r.created_at), ts: r.created_at })),
    ...plan.map((r) => ({ n: nameOf(r), email: r.email, src: 'Plan Décollage', stage: 'Inscrit', score: '—', when: rel(r.created_at), ts: r.created_at })),
  ].sort((a, b) => new Date(b.ts) - new Date(a.ts));

  const counts = { quiz: quiz.length, plan: plan.length, total: quiz.length + plan.length };

  return <Cockpit userEmail={user.email} leads={leads} counts={counts} dbError={dbError} />;
}
