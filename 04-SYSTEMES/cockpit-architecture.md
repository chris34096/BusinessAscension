# Business Ascension OS — Architecture du cockpit
> Du prototype (`04-SYSTEMES/webapps/cockpit/index.html`) au SaaS connecté.
> Version 1.0 · Juin 2026

---

## Principe directeur

Ne pas construire un SaaS multi-tenant from scratch. Construire une **console d'ops perso** (un seul utilisateur : Chris) qui sert de **vitre unique** par-dessus les briques déjà en place. 80% de l'infra existe déjà.

Le prototype `webapps/cockpit/index.html` = la maquette du front. On le porte dans Next.js.

---

## Stack cible (réutilise l'existant)

| Couche | Outil | Statut |
|---|---|---|
| Front + auth | Next.js sur Vercel + Supabase Auth (login unique) | Vercel déjà utilisé |
| Base de données | Supabase — tables `leads`, `deals`, `agent_runs`, `agent_jobs`, `kpi_snapshots` | déjà là (quiz + plan écrivent dedans) |
| Booking + emails | GHL API (contacts, calendriers, workflows) | déjà configuré |
| Paiements | Stripe API (abonnements → MRR réel) | liens déjà live |
| Agents | VPS inchangé, écrit ses résultats dans Supabase | runners déjà là |
| Vidéos | Wistia (embeds + API stats) | déjà là |

---

## Séquencement (du plus rentable au plus cher)

### Phase 0 — Fondation (S, ~1-2 j)
Next.js + Supabase Auth, login unique, cockpit porté. Résultat : même chose qu'aujourd'hui mais protégé par login et déployable.

### Phase 1 — Lire le réel (M, le gros de la valeur)
- **Leads unifiés** : table `leads` Supabase. Quiz et plan y écrivent déjà ; ajouter l'audit via webhook GHL → Supabase.
- **MRR réel** : route serveur qui lit les abonnements Stripe (clé secrète côté serveur uniquement).
- **Agents live** : modifier les runners PowerShell pour écrire une ligne dans `agent_runs` après chaque run. Le cockpit lit ça (fini les outputs `.md` invisibles).

### Phase 2 — Agir depuis le cockpit (M/L)
- **Déclencher un agent au clic** : table `agent_jobs` que le VPS poll en cron. Le cockpit insère un job, le VPS l'exécute. Aucun port ouvert sur le VPS.
- **Nurturing** : un bouton enrôle un lead dans un workflow GHL via l'API.

### Phase 3 — Le reste (L, optionnel)
- **Veille live** : clé Exa/RSS, scan planifié → table `competitors`.
- **Stats VSL** : API Wistia → rétention réelle (agent VSL Analyzer existe déjà).
- **Édition copy des sites depuis le cockpit** : le plus cher (sites HTML statiques). Reporter, ou rendre le copy data-driven plus tard.

---

## Sécurité — non négociable

Clé secrète Stripe, clé API GHL, service-role Supabase → **uniquement côté serveur** (env vars Vercel), jamais dans le front. C'est la raison d'être de Next.js (routes serveur) vs le HTML statique actuel qui exposerait tout.

---

## Première tranche recommandée

Phase 0 + le bout "MRR réel + leads unifiés" de la Phase 1. En une passe : maquette → cockpit qui affiche les vrais chiffres derrière un login. Le reste est bonus.

---

## Schéma Supabase cible (Phase 1+)

```
leads(id, created_at, prenom, email, source, archetype, porte, plateforme,
      score, stage, reponses jsonb)
deals(id, lead_id, offre, montant, stage, created_at, closed_at)
agent_runs(id, agent_id, started_at, finished_at, status, summary, output_path)
agent_jobs(id, agent_id, payload jsonb, status, created_at, picked_at)  -- file de jobs
kpi_snapshots(id, date, mrr, leads_count, audits, clients)
competitors(id, name, area, last_signal, updated_at)
```

(`quiz_resultats` et `plan_decollage` existent déjà — à fusionner/aliaser vers `leads`.)

---

*Business Ascension™ · Cockpit architecture v1.0 · Juin 2026*
