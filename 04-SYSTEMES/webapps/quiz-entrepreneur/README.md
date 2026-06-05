# Quiz "Quel Entrepreneur es-tu ?" — Lead magnet webapp

> Test de personnalité entrepreneur → route vers **Porte 1 / Porte 2** + **plateforme prioritaire** (LinkedIn/Instagram/YouTube).
> Stack : HTML statique + Tailwind (CDN) + Supabase (capture) → déploiement Vercel.

---

## Ce que fait le quiz

8 questions → 3 résultats :
1. **Archétype** : Don Quichotte · Introspectif·ve · Bâtisseur · Visionnaire
2. **Porte** : Porte 1 (0→10K, organique) ou Porte 2 (10K→100K, scale) — selon revenus + maturité offre
3. **Plateforme prioritaire** : LinkedIn / Instagram / YouTube — selon style d'expression

Capture **prénom + email** avant le résultat → enregistré dans Supabase → CTA vers la bonne porte / l'Audit offert.

---

## 1. Supabase — créer la table

Dans le SQL Editor du projet Supabase :

```sql
create table public.quiz_resultats (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz default now(),
  prenom text,
  email text,
  archetype text,
  porte text,          -- 'p1' | 'p2'
  plateforme text,     -- 'LinkedIn' | 'Instagram' | 'YouTube'
  reponses jsonb
);

-- RLS : autoriser uniquement l'insertion publique (anon), pas la lecture
alter table public.quiz_resultats enable row level security;

create policy "insert public" on public.quiz_resultats
  for insert to anon with check (true);
```

> La lecture reste fermée : seul toi (service_role / dashboard) vois les leads. L'app n'a besoin que d'insérer.

---

## 2. Brancher l'app

Dans `index.html`, bloc CONFIG en haut :

```js
const SUPABASE_URL  = "https://TON-PROJET.supabase.co";
const SUPABASE_ANON = "ta_cle_anon_publishable";
const LINKS = {
  porte1: "https://.../deviens-entrepreneur",
  porte2: "https://.../construis-la-marque",
  audit:  "https://.../audit-offert"
};
```

> La clé **anon** est publique par design (c'est une app client) — elle est protégée par la policy RLS ci-dessus. Ne jamais mettre la clé **service_role** ici.

---

## 3. Déployer sur Vercel

**Option simple (drag & drop)** : déposer le dossier `quiz-entrepreneur/` sur vercel.com → déploiement statique instantané.

**Option Git** : connecter le repo, root directory = `04-SYSTEMES/webapps/quiz-entrepreneur`, framework = "Other" (static).

**Option MCP** : Claude peut déployer via le MCP Vercel (`deploy_to_vercel`) — demande-le.

---

## 4. Domaine

Pointer un sous-domaine type `quiz.businessascension.fr` → mettre ce lien unique en bio Instagram/LinkedIn/YouTube. C'est le point d'entrée du funnel.

---

## Personnalisation

- **Questions / archétypes / textes** : objets `QUESTIONS`, `ARCHE`, `PORTE`, `PLAT` dans `index.html`.
- **Couleurs** : variables CSS `--gold`, `--bg` en haut.
- **Logique de routing porte** : fonction `compute()` (p2 si revenus 10K+ ou offre qui scale).

---

*Business Ascension™ · Lead magnet webapp v1.0 · Juin 2026*
