'use client';
import { useEffect, useRef, useState } from 'react';
import Chart from 'chart.js/auto';
import { createClient } from '@/lib/supabase/client';
import {
  AGENTS, SITES, TESTI, COMPETS, VEILLE, SEQ, PLANS, TX,
  WORKFLOWS, FUNNEL, YT, REELS, VA, NAV,
} from './data';

const now = () => new Date().toLocaleTimeString('fr-FR');
const PIPELINE = {
  'Audit booké': ['Yacine B.', 'Camille D.'],
  'Appel fait': ['Sophie M.'],
  Proposition: ['Marc V.'],
  Signé: ['(bêta ×4)'],
};
const SCHEDULE = [
  ['Lundi 08h', 'KPI · brief GRID'], ['Mercredi 08h', 'Analytics · perf'],
  ['Vendredi 15h', 'Check-in clients'], ['Dimanche 18h', 'Veille marché'],
  ['Quotidien', 'Prospection + Setting'],
];
const TODAY = [
  ['☎', 'Appel diagnostic · Marc V.', '14h00 · proposition Porte 2'],
  ['✉', 'Relancer 3 leads quiz tièdes', 'agent Setting prêt'],
  ['▷', 'Connecter VSL Porte 1 (Wistia)', 'script v2.1 validé'],
  ['⌖', 'Lire la veille de dimanche', '6 patterns détectés'],
];

function Console({ lines }) {
  const ref = useRef(null);
  useEffect(() => { if (ref.current) ref.current.scrollTop = ref.current.scrollHeight; }, [lines]);
  return (
    <div className="console" ref={ref}>
      {lines.map((l, i) => (
        <div className="ln" key={i}>
          <span className="ts">[{l.ts}]</span> <span className={l.cls}>{l.msg}</span>
        </div>
      ))}
    </div>
  );
}

export default function Cockpit({ userEmail, leads: realLeads = [], counts = { quiz: 0, plan: 0, total: 0 }, dbError = null }) {
  const [page, setPage] = useState('overview');
  const [feed, setFeed] = useState([]);
  const [agentLines, setAgentLines] = useState([]);
  const [veilleLines, setVeilleLines] = useState([]);
  const [agentSel, setAgentSel] = useState(AGENTS[0].id);
  const [leadFilter, setLeadFilter] = useState('');
  const [modal, setModal] = useState(false);

  const mrrRef = useRef(null);
  const funnelRef = useRef(null);
  const sourceRef = useRef(null);

  // Charts
  useEffect(() => {
    const charts = [];
    const gold = '#E8C46A', goldD = '#CA8A04', grid = 'rgba(201,168,76,.08)', muted = '#A99B7C';
    Chart.defaults.color = muted;
    Chart.defaults.font.family = "'Hanken Grotesk',sans-serif";
    if (mrrRef.current) charts.push(new Chart(mrrRef.current, {
      type: 'line',
      data: { labels: ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin'], datasets: [
        { label: 'MRR €', data: [800, 1400, 2100, 3100, 4030, 4760], borderColor: gold, backgroundColor: 'rgba(232,196,106,.12)', fill: true, tension: .4, borderWidth: 2, pointRadius: 3 },
        { label: 'Leads', data: [12, 21, 30, 44, 58, 73], borderColor: '#9aa0d0', tension: .4, borderWidth: 2, pointRadius: 2, yAxisID: 'y1' },
      ] },
      options: { plugins: { legend: { labels: { boxWidth: 12, font: { size: 11 } } } }, scales: { x: { grid: { color: grid } }, y: { grid: { color: grid } }, y1: { position: 'right', grid: { display: false } } } },
    }));
    if (funnelRef.current) charts.push(new Chart(funnelRef.current, {
      type: 'bar',
      data: { labels: ['Vues', 'Leads', 'Nurture', 'Audit', 'Client'], datasets: [{ data: [5200, 73, 48, 11, 4], backgroundColor: [goldD, '#caa14c', gold, '#f0d9a0', '#5fbf7a'], borderRadius: 6 }] },
      options: { indexAxis: 'y', plugins: { legend: { display: false } }, scales: { x: { type: 'logarithmic', grid: { color: grid } }, y: { grid: { display: false } } } },
    }));
    const srcData = (counts.quiz + counts.plan) > 0 ? [counts.quiz, counts.plan] : [1, 1];
    if (sourceRef.current) charts.push(new Chart(sourceRef.current, {
      type: 'doughnut',
      data: { labels: ['Quiz', 'Plan Décollage'], datasets: [{ data: srcData, backgroundColor: [gold, goldD], borderColor: '#16130C', borderWidth: 3 }] },
      options: { plugins: { legend: { position: 'bottom', labels: { boxWidth: 12, font: { size: 11 } } } }, cutout: '62%' },
    }));
    return () => charts.forEach((c) => c.destroy());
  }, []);

  // Feed live
  useEffect(() => {
    const msgs = [
      ['ev', 'Prospection · 7 nouveaux profils qualifiés'],
      ['ok', 'Setting · 2 réponses positives en DM'],
      ['ev', 'Lead Intelligence · lead « Marc V. » scoré 95'],
      ['ok', 'KPI · MRR mis à jour : 4 760 €'],
      ['ev', 'Veille · nouveau pattern hook détecté'],
    ];
    let i = 0;
    const tick = () => { const m = msgs[i % msgs.length]; setFeed((f) => [...f, { ts: now(), cls: m[0], msg: m[1] }].slice(-40)); i++; };
    tick(); tick();
    const id = setInterval(tick, 4200);
    return () => clearInterval(id);
  }, []);

  // Ligne d'accueil de la console agents (après montage, évite le mismatch d'hydratation)
  useEffect(() => {
    setAgentLines([{ ts: now(), msg: 'Console agents prête. Sélectionne un agent et exécute.', cls: 'muted' }]);
  }, []);

  // Veille au montage
  useEffect(() => { scanVeille(); /* eslint-disable-next-line */ }, []);

  function scanVeille() {
    setVeilleLines([{ ts: now(), cls: 'ev', msg: '⟳ Scan veille en cours · 33 chaînes YouTube + Exa…' }]);
    VEILLE.forEach((v, i) => setTimeout(() => setVeilleLines((l) => [...l, { ts: now(), cls: '', msg: '• ' + v }]), 450 + i * 350));
  }
  function runAgent() {
    const a = AGENTS.find((x) => x.id === agentSel);
    const push = (msg, cls = '') => setAgentLines((l) => [...l, { ts: now(), cls, msg }]);
    push(`▶ Lancement agent « ${a.nm} »…`, 'ev');
    setTimeout(() => push(`  connexion VPS · runner ${a.id}.ps1`), 500);
    setTimeout(() => push(`  ${a.role}`), 1100);
    setTimeout(() => push(`✓ Terminé · ${a.last}`, 'ok'), 1900);
    setTimeout(() => push(`  output → 04-SYSTEMES/agents/outputs/${a.id}-2026-06-14.md`), 2100);
  }
  async function logout() {
    const supabase = createClient();
    await supabase.auth.signOut();
    window.location.href = '/login';
  }

  const leads = realLeads.filter((l) => {
    const q = leadFilter.toLowerCase();
    return l.n.toLowerCase().includes(q) || l.src.toLowerCase().includes(q) || (l.stage || '').toLowerCase().includes(q);
  });
  const title = NAV.find((n) => n.id === page)?.label ?? '';
  const on = (id) => 'page' + (page === id ? ' on' : '');

  return (
    <div className="app">
      <aside className="side">
        <div className="logo">
          <div className="mark">B</div>
          <div className="t">Business Ascension<span>Operating System</span></div>
        </div>
        {NAV.map((n) => (
          <button key={n.id} className={'navlink' + (page === n.id ? ' active' : '')} onClick={() => setPage(n.id)}>
            <span className="ic">{n.ic}</span> {n.label}
            {n.badge && <span className="badge">{n.badge}</span>}
          </button>
        ))}
        <div className="foot">
          Connecté à <b>Supabase</b> · <b>GHL</b> · <b>Stripe</b> · <b>VPS</b><br />
          {userEmail} · <a onClick={logout} style={{ color: 'var(--gold-lt)', cursor: 'pointer' }}>Déconnexion</a>
        </div>
      </aside>

      <main className="main">
        <div className="topbar">
          <div className="hl">
            <div className="eyebrow">Business Ascension™</div>
            <h1>{title}</h1>
          </div>
          <div className="cmd"><span>⌘</span><input placeholder="Commander un agent, chercher…" onKeyDown={(e) => { if (e.key === 'Enter') { alert('Démo · commande : "' + e.target.value + '"\nEn prod : routage vers l\'agent ou la ressource.'); e.target.value = ''; } }} /></div>
          <span className="pill"><span className="dot ok" /> 8 agents actifs</span>
        </div>

        {/* OVERVIEW */}
        <section className={on('overview')}>
          <div className="grid g4 mb16">
            <div className="glass kpi"><div className="lab">MRR (récurrent)</div><div className="val">4 760 €</div><div className="delta up">▲ +18% vs mois dernier</div></div>
            <div className="glass kpi"><div className="lab">Leads (réels)</div><div className="val">{counts.total}</div><div className="delta up">● Supabase · quiz + plan</div></div>
            <div className="glass kpi"><div className="lab">Audits réservés</div><div className="val">11</div><div className="delta up">▲ show-up 82%</div></div>
            <div className="glass kpi"><div className="lab">Clients bêta</div><div className="val">4</div><div className="delta">Construis la Marque™</div></div>
          </div>
          <div className="grid g3">
            <div className="card span2">
              <div className="sec-h"><div><div className="eyebrow2">Croissance</div><h2 style={{ fontSize: '1.2rem' }}>MRR + leads · 6 mois</h2></div></div>
              <canvas ref={mrrRef} height="120" />
            </div>
            <div className="card">
              <div className="eyebrow2">Flux d'activité agents</div>
              <div className="mt16"><Console lines={feed} /></div>
            </div>
          </div>
          <div className="grid g3 mt16">
            <div className="card">
              <div className="eyebrow2">Funnel d'acquisition</div>
              <div className="mt16"><canvas ref={funnelRef} height="170" /></div>
            </div>
            <div className="card span2">
              <div className="sec-h"><div><div className="eyebrow2">Aujourd'hui</div><h2 style={{ fontSize: '1.2rem' }}>Ce qui t'attend</h2></div><span className="pill">vendredi 14 juin</span></div>
              {TODAY.map((t, i) => (
                <div className="list-item" key={i}><span className="ix">{t[0]}</span><div className="gr"><div className="t">{t[1]}</div><div className="m">{t[2]}</div></div><button className="btn btn-ghost sm">Faire</button></div>
              ))}
            </div>
          </div>
        </section>

        {/* AGENTS */}
        <section className={on('agents')}>
          <div className="demo-banner"><span>⬡</span><div>Les <b>10 agents</b> tournent sur ton VPS. Ici tu les pilotes. <b>En prod</b>, branché sur le bot Telegram et les runners PowerShell.</div></div>
          <div className="grid g2 mb16">
            <div className="card">
              <div className="sec-h"><div><div className="eyebrow2">Console</div><h2 style={{ fontSize: '1.2rem' }}>Déclencher un agent</h2></div></div>
              <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 12 }}>
                <select value={agentSel} onChange={(e) => setAgentSel(e.target.value)} style={{ flex: 1, minWidth: 180, background: 'var(--panel)', border: '1px solid var(--line)', borderRadius: 11, padding: '11px 13px', color: 'var(--ink)' }}>
                  {AGENTS.map((a) => <option key={a.id} value={a.id}>{a.nm}</option>)}
                </select>
                <button className="btn btn-gold" onClick={runAgent}>▶ Exécuter</button>
              </div>
              <Console lines={agentLines} />
            </div>
            <div className="card">
              <div className="eyebrow2">Planning de la semaine</div>
              <div className="mt16">
                {SCHEDULE.map((s, i) => (
                  <div className="list-item" key={i}><span className="ix">◷</span><div className="gr"><div className="t">{s[1]}</div><div className="m">{s[0]}</div></div><span className="dot ok" /></div>
                ))}
              </div>
            </div>
          </div>
          <div className="sec-h"><div><div className="eyebrow2">La flotte</div><h2>Les agents qui vivent dans le système</h2><div className="sub">Chacun a son prompt master, son runner et ses outputs datés.</div></div></div>
          <div className="grid g3">
            {AGENTS.map((a) => (
              <div className="card agent" key={a.id}>
                <div className="top"><span className={'dot ' + a.status} /><div><div className="nm">{a.nm}</div><div className="role">{a.role}</div></div></div>
                <div className="meta"><span>⏱ <b>{a.sched}</b></span></div>
                <div className="last">Dernier run : {a.last}</div>
              </div>
            ))}
          </div>
        </section>

        {/* FUNNEL */}
        <section className={on('funnel')}>
          <div className="demo-banner"><span>▤</span><div>Tes <b>5 webapps</b> en ligne. Aperçu live, édition du copy, et le chemin du prospect.</div></div>
          <div className="sec-h"><div><div className="eyebrow2">Le tunnel</div><h2>Le chemin du prospect</h2></div></div>
          <div className="card mb22"><div className="flow">
            {FUNNEL.map((f, i) => (
              <span key={i} style={{ display: 'contents' }}>
                <div className="node"><h4>0{i + 1}</h4><p>{f}</p></div>
                {i < FUNNEL.length - 1 && <div className="arrow">→</div>}
              </span>
            ))}
          </div></div>
          <div className="sec-h"><div><div className="eyebrow2">Tes pages</div><h2>Sites & lead magnets</h2></div></div>
          <div className="grid g3">
            {SITES.map((s) => (
              <div className="card site" key={s.url}>
                <div className="frame"><div className="ph">aperçu · {s.tag}</div><iframe loading="lazy" src={s.url} title={s.nm} /></div>
                <div className="body"><h3>{s.nm}</h3><p>{s.desc}</p><div className="row">
                  <a className="btn btn-gold sm" href={s.url} target="_blank" rel="noopener noreferrer">Ouvrir ↗</a>
                  <button className="btn btn-ghost sm" onClick={() => alert('Démo : éditeur de copy « ' + s.nm + ' ». En prod, push Vercel.')}>Éditer le copy</button>
                </div></div>
              </div>
            ))}
          </div>
        </section>

        {/* VIDEO */}
        <section className={on('video')}>
          <div className="demo-banner"><span>▷</span><div>Tes <b>VSL</b> et <b>témoignages Wistia</b> centralisés. Les témoignages sont tes vrais players.</div></div>
          <div className="sec-h"><div><div className="eyebrow2">Vidéos de vente</div><h2>VSL Porte 1 & Porte 2</h2></div></div>
          <div className="grid g2 mb22">
            <div className="card"><div className="eyebrow2">Porte 1 · Deviens l'Entrepreneur™</div><div className="vslslot mt16">▷ VSL Porte 1<br /><small>ID Wistia à connecter (script v2.1 prêt)</small></div></div>
            <div className="card"><div className="eyebrow2">Porte 2 · Construis la Marque™</div><div className="vslslot mt16">▷ VSL Porte 2<br /><small>ID Wistia à connecter (script v2.1 prêt)</small></div></div>
          </div>
          <div className="sec-h"><div><div className="eyebrow2">Preuve sociale</div><h2>Témoignages clients</h2></div></div>
          <div className="grid g4">
            {TESTI.map((t) => (
              <div className="card vid" key={t.id}>
                <wistia-player media-id={t.id} aspect="1.7777777777777777"></wistia-player>
                <div className="nm">{t.nm}<span>{t.role}</span></div>
              </div>
            ))}
          </div>
        </section>

        {/* CONCURRENCE */}
        <section className={on('concurrence')}>
          <div className="demo-banner"><span>⌖</span><div>Veille marché. L'<b>agent Veille</b> scanne 33 chaînes + Exa. <button className="btn btn-ghost sm" style={{ marginLeft: 6 }} onClick={scanVeille}>⟳ Lancer un scan</button></div></div>
          <div className="sec-h"><div><div className="eyebrow2">Sous surveillance</div><h2>Concurrents suivis</h2></div></div>
          <div className="grid g3 mb22">
            {COMPETS.map((c) => (
              <div className="card" key={c.nm}>
                <div className="top" style={{ display: 'flex', alignItems: 'center', gap: 9, marginBottom: 8 }}><span className={'dot ' + c.dot} /><div className="nm" style={{ fontFamily: 'var(--serif)', fontSize: '1.05rem' }}>{c.nm}</div></div>
                <div style={{ fontSize: '.82rem', color: 'var(--gold-lt)', marginBottom: 4 }}>{c.area}</div>
                <div style={{ fontSize: '.8rem', color: 'var(--muted)' }}>{c.note}</div>
              </div>
            ))}
          </div>
          <div className="card">
            <div className="sec-h"><div><div className="eyebrow2">Derniers signaux</div><h2 style={{ fontSize: '1.2rem' }}>Veille · titres scrappés</h2></div><span className="pill"><span className="dot ok" /> agent veille</span></div>
            <Console lines={veilleLines} />
          </div>
        </section>

        {/* LEADS */}
        <section className={on('leads')}>
          <div className="demo-banner"><span>✉</span><div><b style={{ color: 'var(--ok)' }}>● Données réelles</b> — leads lus en direct depuis <b>Supabase</b> (quiz + plan décollage). Le nurturing reste simulé pour l'instant (suite Phase 1 : GHL).{dbError ? ' · ⚠ ' + dbError : ''}</div></div>
          <div className="grid g2" style={{ marginBottom: 20 }}>
            <div className="card">
              <div className="sec-h"><div><div className="eyebrow2">Nurturing</div><h2 style={{ fontSize: '1.2rem' }}>Séquence SOAP Opera · Plan Décollage</h2></div><button className="btn btn-ghost sm" onClick={() => setModal(true)}>+ Email</button></div>
              <div className="seq mt16">
                {SEQ.map((s, i) => (<div className="item" key={i}><div className="d">{s.d}</div><h4>{s.h}</h4><p>{s.p}</p></div>))}
              </div>
            </div>
            <div className="card">
              <div className="eyebrow2">Capture par source</div>
              <div className="mt16"><canvas ref={sourceRef} height="150" /></div>
              <div style={{ marginTop: 14, fontSize: '.82rem', color: 'var(--muted)' }}>Ouverture séquence : <b style={{ color: 'var(--gold-lt)' }}>61%</b> · clic Audit : <b style={{ color: 'var(--gold-lt)' }}>14%</b></div>
            </div>
          </div>
          <div className="card">
            <div className="sec-h"><div><div className="eyebrow2">Base</div><h2 style={{ fontSize: '1.2rem' }}>Leads récents</h2></div><div className="cmd" style={{ minWidth: 200 }}><span>⌕</span><input placeholder="Filtrer un lead…" value={leadFilter} onChange={(e) => setLeadFilter(e.target.value)} /></div></div>
            <div style={{ overflow: 'auto', marginTop: 10 }}>
              <table>
                <thead><tr><th>Lead</th><th>Source</th><th>Étape</th><th>Score</th><th>Quand</th></tr></thead>
                <tbody>
                  {leads.length === 0 && (<tr><td colSpan={5} className="muted" style={{ textAlign: 'center', padding: 24 }}>{realLeads.length === 0 ? "Aucun lead pour l'instant. Dès que quelqu'un remplit le quiz ou le plan, il apparaît ici en direct." : 'Aucun résultat pour ce filtre.'}</td></tr>)}
                  {leads.map((l, i) => (<tr key={i}><td>{l.n}</td><td><span className="tag">{l.src}</span></td><td>{l.stage}</td><td><b style={{ color: 'var(--gold-lt)' }}>{l.score}</b></td><td className="muted">{l.when}</td></tr>))}
                </tbody>
              </table>
            </div>
          </div>
        </section>

        {/* APPELS */}
        <section className={on('appels')}>
          <div className="demo-banner"><span>☎</span><div>Réservation d'<b>Audit offert</b> (calendrier GHL live) + pipeline de closing.</div></div>
          <div className="grid g2">
            <div className="card" style={{ padding: 14 }}>
              <div className="eyebrow2" style={{ padding: '8px 8px 12px' }}>Réserver · calendrier live (GHL)</div>
              <iframe src="https://api.leadconnectorhq.com/widget/booking/dtcNGNfaqpOhzPKUJmh4" style={{ width: '100%', minHeight: 560, border: 0, borderRadius: 12, background: '#fff' }} title="Audit offert" />
            </div>
            <div className="card">
              <div className="sec-h"><div><div className="eyebrow2">Closing</div><h2 style={{ fontSize: '1.2rem' }}>Pipeline</h2></div></div>
              <div className="kanban mt16">
                {Object.entries(PIPELINE).map(([k, v]) => (
                  <div className="col" key={k}><h4>{k}<span>{v.length}</span></h4>
                    {v.map((n, i) => (<div className="lead" key={i}><div className="n">{n}</div><div className="s"><span>Porte 1</span><span>●</span></div></div>))}
                  </div>
                ))}
              </div>
            </div>
          </div>
        </section>

        {/* REVENUS */}
        <section className={on('revenus')}>
          <div className="demo-banner"><span>€</span><div>Tes <b>plans Stripe</b> Porte 1 + suivi du récurrent. Liens d'achat = tes vrais liens Stripe.</div></div>
          <div className="grid g3 mb16">
            <div className="glass kpi"><div className="lab">MRR</div><div className="val">4 760 €</div><div className="delta up">▲ +18%</div></div>
            <div className="glass kpi"><div className="lab">Encaissé ce mois</div><div className="val">8 491 €</div><div className="delta up">▲ 1 PIF + MRR</div></div>
            <div className="glass kpi"><div className="lab">Churn</div><div className="val">0%</div><div className="delta">phase bêta</div></div>
          </div>
          <div className="sec-h"><div><div className="eyebrow2">Offre Porte 1</div><h2>Plans MRR · Deviens l'Entrepreneur™</h2></div></div>
          <div className="grid g3 mb22">
            {PLANS.map((p) => (
              <div className="card" key={p.dur} style={p.feat ? { borderColor: 'var(--gold)' } : undefined}>
                <div className="eyebrow2">{p.feat ? 'Le plus choisi' : 'Plan'}</div>
                <div style={{ fontFamily: 'var(--serif)', fontSize: '1.4rem', margin: '6px 0' }}>{p.dur}</div>
                <div style={{ fontFamily: 'var(--serif)', fontSize: '2rem', color: 'var(--gold-lt)' }}>{p.pif}</div>
                <div className="muted" style={{ fontSize: '.84rem', margin: '4px 0 14px' }}>ou {p.mens}</div>
                <a className={'btn sm ' + (p.feat ? 'btn-gold' : 'btn-ghost')} href={p.url} target="_blank" rel="noopener noreferrer" style={{ width: '100%', justifyContent: 'center' }}>Lien Stripe ↗</a>
              </div>
            ))}
          </div>
          <div className="card">
            <div className="eyebrow2">Transactions récentes</div>
            <div style={{ overflow: 'auto', marginTop: 10 }}>
              <table>
                <thead><tr><th>Client</th><th>Plan</th><th>Montant</th><th>Date</th><th>Statut</th></tr></thead>
                <tbody>
                  {TX.map((x, i) => (<tr key={i}><td>{x.c}</td><td>{x.p}</td><td><b style={{ color: 'var(--gold-lt)' }}>{x.a}</b></td><td className="muted">{x.d}</td><td><span className="tag">{x.s}</span></td></tr>))}
                </tbody>
              </table>
            </div>
          </div>
        </section>

        {/* WORKFLOWS */}
        <section className={on('workflows')}>
          <div className="demo-banner"><span>⟿</span><div>Tes <b>automatisations</b> de bout en bout. <b>En prod</b>, orchestre Supabase + GHL + agents + Stripe.</div></div>
          {WORKFLOWS.map((w) => (
            <div className="card mb16" key={w.nm}>
              <div className="sec-h" style={{ margin: '0 0 14px' }}><div><div className="eyebrow2">Automatisation</div><h2 style={{ fontSize: '1.15rem' }}>{w.nm}</h2></div><span className="pill"><span className="dot ok" /> actif</span></div>
              <div className="flow">
                {w.steps.map((s, i) => (
                  <span key={i} style={{ display: 'contents' }}>
                    <div className="node"><h4>0{i + 1}</h4><p>{s}</p></div>
                    {i < w.steps.length - 1 && <div className="arrow">→</div>}
                  </span>
                ))}
              </div>
            </div>
          ))}
        </section>

        {/* CONTENU */}
        <section className={on('contenu')}>
          <div className="demo-banner"><span>✎</span><div>Ta <b>bibliothèque de contenu</b> : scripts YouTube, reels, value assets.</div></div>
          <div className="grid g3">
            <div className="card"><div className="sec-h"><div><div className="eyebrow2">YouTube</div><h2 style={{ fontSize: '1.2rem' }}>9 scripts long-form</h2></div></div>
              {YT.map((x, i) => (<div className="list-item" key={i}><span className="ix">{String(i + 1).padStart(2, '0')}</span><div className="gr"><div className="t">{x}</div></div><button className="btn btn-ghost sm" onClick={() => alert('Démo : ouvrir dans l\'agent Contenu.')}>→</button></div>))}
            </div>
            <div className="card"><div className="sec-h"><div><div className="eyebrow2">Instagram</div><h2 style={{ fontSize: '1.2rem' }}>Reels 5-6-30</h2></div></div>
              {REELS.map((x, i) => (<div className="list-item" key={i}><span className="ix">{String(i + 1).padStart(2, '0')}</span><div className="gr"><div className="t">{x}</div></div><button className="btn btn-ghost sm" onClick={() => alert('Démo : ouvrir dans l\'agent Contenu.')}>→</button></div>))}
            </div>
            <div className="card"><div className="sec-h"><div><div className="eyebrow2">Value assets</div><h2 style={{ fontSize: '1.2rem' }}>6 piliers</h2></div></div>
              {VA.map((x, i) => (<div className="list-item" key={i}><span className="ix">{String(i + 1).padStart(2, '0')}</span><div className="gr"><div className="t">{x}</div></div><button className="btn btn-ghost sm" onClick={() => alert('Démo : ouvrir dans l\'agent Contenu.')}>→</button></div>))}
            </div>
          </div>
        </section>
      </main>

      {modal && (
        <div onClick={(e) => { if (e.target === e.currentTarget) setModal(false); }} style={{ position: 'fixed', inset: 0, background: 'rgba(5,4,3,.7)', backdropFilter: 'blur(4px)', zIndex: 50, display: 'grid', placeItems: 'center', padding: 24 }}>
          <div className="login-card" style={{ maxWidth: 540 }}>
            <h2 style={{ fontSize: '1.3rem' }}>Ajouter un email à la séquence</h2>
            <p>Démo : en prod, l'email s'ajoute à la séquence GHL et part selon le délai.</p>
            <input placeholder="Objet de l'email" />
            <input placeholder="Délai (ex : +2 jours)" />
            <div style={{ display: 'flex', gap: 8, marginTop: 14, justifyContent: 'flex-end' }}>
              <button className="btn btn-ghost" onClick={() => setModal(false)}>Annuler</button>
              <button className="btn btn-gold" onClick={() => setModal(false)}>Ajouter</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
