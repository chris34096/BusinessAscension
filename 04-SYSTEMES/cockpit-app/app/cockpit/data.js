export const AGENTS = [
  { id: 'prospection', nm: 'Prospection', role: 'Détecte et qualifie les leads sortants', sched: 'Quotidien · 09h00', status: 'ok', last: '62 profils scannés, 11 qualifiés' },
  { id: 'setting', nm: 'Setting', role: 'Engage la conversation en DM', sched: 'Quotidien · 10h00', status: 'ok', last: '18 conversations ouvertes' },
  { id: 'contenu', nm: 'Contenu', role: 'Génère posts, reels, scripts (voix Chris)', sched: 'À la demande', status: 'ok', last: '3 reels + 1 carousel' },
  { id: 'kpi', nm: 'KPI', role: 'Brief GRID hebdo des chiffres', sched: 'Lundi · 08h00', status: 'ok', last: 'MRR +18%, show-up 82%' },
  { id: 'analytics', nm: 'Analytics', role: 'Rapport de performance', sched: 'Mercredi · 08h00', status: 'ok', last: 'CTR pages +0.4pt' },
  { id: 'checkin', nm: 'Check-in', role: 'Suivi clients Construis la Marque™', sched: 'Vendredi · 15h00', status: 'ok', last: '4 clients, 0 signal churn' },
  { id: 'objections', nm: 'Objections', role: 'Fiche post-appel échoué', sched: '/objection [notes]', status: 'warn', last: "En attente d'un appel" },
  { id: 'vsl', nm: 'VSL Analyzer', role: 'Analyse rétention VSL', sched: '/vsl [player] [durée]', status: 'warn', last: 'Aucune VSL connectée' },
  { id: 'veille', nm: 'Veille', role: 'Veille marché + concurrents', sched: 'Dimanche · 18h00', status: 'ok', last: '34 titres, 6 patterns' },
  { id: 'lead-intel', nm: 'Lead Intelligence', role: 'Score et enrichit les leads', sched: 'Continu', status: 'ok', last: '73 leads scorés' },
];
export const SITES = [
  { nm: "Deviens l'Entrepreneur™", desc: 'Page Porte 1 · MRR public, 3 plans, garantie 30j.', url: 'https://www.businessascension.fr/', tag: 'Porte 1' },
  { nm: 'Construis la Marque™', desc: 'Page Porte 2 · scale, candidature, prix par appel.', url: 'https://scale.businessascension.fr/', tag: 'Porte 2' },
  { nm: 'Audit offert', desc: 'Booking 30 min + témoignages + FAQ.', url: 'https://audit.businessascension.fr/', tag: 'Appel' },
  { nm: 'Quiz Entrepreneur', desc: 'Test archétype → porte → plateforme. Capture Supabase.', url: 'https://quiz.businessascension.fr/', tag: 'Lead magnet' },
  { nm: 'Plan Décollage', desc: 'Plan 3 mouvements interactif. Capture + nurture.', url: 'https://plan.businessascension.fr/', tag: 'Lead magnet' },
];
export const TESTI = [
  { id: '4hlujiu0vh', nm: 'Élodie Rozoy', role: 'Coach en relation harmonieuse' },
  { id: '7hjg9wvzup', nm: 'Yanis', role: 'Coach pour musiciens' },
  { id: 'q9d8hwqua3', nm: 'Mariel Quiroga', role: 'Coach en image holistique' },
  { id: 'zy7jxmz90n', nm: 'Houssem « Ari Harden »', role: 'Coach en séduction' },
];
export const COMPETS = [
  { nm: 'Tom Pearson', area: 'Body · Mind · Brand · MRR', note: 'Modèle de référence 2 portes', dot: 'ok' },
  { nm: 'Taki Moore', area: 'Vendre par message · salesless', note: 'Inspiration Porte 2', dot: 'ok' },
  { nm: 'Sunny Lenarduzzi', area: 'Angle WITHOUT · YouTube', note: 'Inspiration scripts long-form', dot: 'ok' },
  { nm: 'Julien Musy', area: 'Organique pur → scale', note: 'Empowerment / Infinity', dot: 'warn' },
  { nm: 'Mehdi Baer', area: 'Mindset + business FR', note: 'Trop gros pour cloner', dot: 'off' },
  { nm: 'Matis Clouet', area: 'Show-up / setting', note: 'S.H.O.W. framework', dot: 'off' },
];
export const VEILLE = [
  'Tom Pearson — "Why most coaches stay broke (the brand gap)"',
  'Taki Moore — "Sell high-ticket without sales calls"',
  'Sunny L. — "How I hit 10K/mo WITHOUT a big audience"',
  'Julien Musy — "Le funnel organique qui tourne tout seul"',
  'Matis Clouet — "80% de show-up sur tes appels"',
  'Pattern détecté : hooks identitaires > hooks douleur (x2.3 rétention)',
];
export const LEADS = [
  { n: 'Camille D.', src: 'Quiz', stage: 'Nurture', score: 84, when: 'il y a 2h' },
  { n: 'Yacine B.', src: 'Plan Décollage', stage: 'Audit booké', score: 91, when: 'il y a 5h' },
  { n: 'Sophie M.', src: 'Audit', stage: 'Appel fait', score: 88, when: 'hier' },
  { n: 'Thomas R.', src: 'Quiz', stage: 'Froid', score: 42, when: 'hier' },
  { n: 'Inès K.', src: 'Plan Décollage', stage: 'Nurture', score: 77, when: 'il y a 2j' },
  { n: 'Marc V.', src: 'Audit', stage: 'Proposition', score: 95, when: 'il y a 2j' },
  { n: 'Léa P.', src: 'Quiz', stage: 'Nurture', score: 69, when: 'il y a 3j' },
];
export const SEQ = [
  { d: 'Immédiat', h: 'Ton Plan Décollage est là', p: 'Livraison + première micro-action ce soir.' },
  { d: '+1 jour', h: "Le vrai blocage (ce n'est pas l'info)", p: "Belief : le problème n'a jamais été la connaissance." },
  { d: '+2 jours', h: 'Mois à 12 000€, mois à zéro', p: 'Story Chris · le système qui rend le CA prévisible.' },
  { d: '+4 jours', h: "Pourquoi l'IA tue 90% des coachs", p: 'Belief : identité + business en simultané.' },
  { d: '+6 jours', h: 'On regarde ton cas ? (Audit offert)', p: 'CTA principal : réserver 30 min avec Chris.' },
];
export const PLANS = [
  { dur: '3 mois', pif: '997 €', mens: '3 × 367 €', url: 'https://buy.stripe.com/7sY5kD5G20iF0h9h2a7AI00', feat: false },
  { dur: '6 mois', pif: '1 497 €', mens: '6 × 297 €', url: 'https://buy.stripe.com/14A4gz1pM7L70h9fY67AI01', feat: true },
  { dur: '12 mois', pif: '2 497 €', mens: '12 × 247 €', url: 'https://buy.stripe.com/3cIdR96K6e9vd3V8vE7AI02', feat: false },
];
export const TX = [
  { c: 'Yacine B.', p: 'Porte 1 · 6 mois PIF', a: '1 497 €', d: '14 juin', s: 'Payé' },
  { c: 'Inès K.', p: 'Porte 1 · 12 × 247€', a: '247 €', d: '12 juin', s: 'Récurrent' },
  { c: 'Sophie M.', p: 'Porte 1 · 6 × 297€', a: '297 €', d: '10 juin', s: 'Récurrent' },
  { c: 'Marc V.', p: 'Porte 1 · 3 × 367€', a: '367 €', d: '08 juin', s: 'Récurrent' },
];
export const WORKFLOWS = [
  { nm: 'Capture → Nurture → Audit', steps: ['Lead magnet (quiz/plan)', 'Capture Supabase', 'Séquence 5 emails', 'CTA Audit offert', 'Booking GHL'] },
  { nm: 'Audit → Closing', steps: ['Audit réservé', 'Speed-to-lead <5min', 'Appel diagnostic', 'Proposition', 'Stripe Porte 1/2'] },
  { nm: 'Contenu → Leads entrants', steps: ['Agent Contenu', 'LinkedIn / IG / YouTube', 'Pré-vente (belief)', 'DM entrant', 'Vente par message'] },
  { nm: 'Onboarding client', steps: ['Paiement Stripe', 'Protocole 48h', 'Accès modules', 'Session identité', 'Check-in hebdo'] },
];
export const FUNNEL = ['Contenu organique', 'Lead magnet', 'Capture email', 'Nurture', 'Audit offert', 'Porte 1 / Porte 2'];
export const YT = ["L'IA va tuer 90% des coachs", 'Les réseaux détruisent ton business', 'Les plus intelligents, moins payés', 'Checklist 4 points', 'Les 5 niveaux pour décoller', 'Plan 90 jours', 'P2 · Closer par message', 'P2 · Jamais deux mois pareils', 'P2 · Contenu machine à clients'];
export const REELS = ['Format 1 · Déclaration choc (×6)', 'Format 2 · Les X signes (×6)', 'Format 3 · Les X erreurs (×6)', 'Format 4 · Les X mensonges (×6)', 'Format 5 · Mon histoire (×6)'];
export const VA = ['La vraie raison de la stagnation', 'Pourquoi les formations ne suffisent pas', 'Mois à 12 000€, mois à zéro', 'Business Operating System 6 pôles', 'Le Don Quichotte entrepreneur', "Le switch du chiffre d'affaires"];
export const NAV = [
  { id: 'overview', ic: '◎', label: "Vue d'ensemble" },
  { id: 'agents', ic: '⬡', label: 'Agents IA', badge: '10' },
  { id: 'funnel', ic: '▤', label: 'Funnel & Sites' },
  { id: 'video', ic: '▷', label: 'VSL & Vidéos' },
  { id: 'concurrence', ic: '⌖', label: 'Concurrence' },
  { id: 'leads', ic: '✉', label: 'Leads & Nurturing' },
  { id: 'appels', ic: '☎', label: 'Appels' },
  { id: 'revenus', ic: '€', label: 'Revenus / Stripe' },
  { id: 'workflows', ic: '⟿', label: 'Workflows' },
  { id: 'contenu', ic: '✎', label: 'Contenu' },
];
