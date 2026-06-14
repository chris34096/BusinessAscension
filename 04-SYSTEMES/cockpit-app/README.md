# Business Ascension OS — Cockpit (Phase 0)

App Next.js (App Router) + Supabase Auth (magic link). Port React du cockpit
`04-SYSTEMES/webapps/cockpit/index.html`, derrière un login.

## Lancer en local

```bash
cd 04-SYSTEMES/cockpit-app
cp .env.local.example .env.local      # ajuste si besoin
npm install
npm run dev
```

Ouvre http://localhost:3000 → redirigé vers `/login`. Entre ton email, clique
le lien reçu, tu arrives sur le cockpit.

## Pré-requis Supabase (une fois)

Dans le projet Supabase (`mrjlfdqtcfxyontgltab`) → Authentication :
1. Activer le provider **Email** (magic link).
2. Ajouter l'URL de redirection : `http://localhost:3000/auth/callback`
   (et l'URL Vercel en prod : `https://<ton-app>.vercel.app/auth/callback`).

## Déploiement Vercel

1. Importer ce dossier comme projet Vercel.
2. Variables d'env : `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`,
   `NEXT_PUBLIC_OWNER_EMAIL`.
3. Ajouter l'URL de prod dans les redirect URLs Supabase.

## Sécurité

La clé `anon` est publique par design (protégée par RLS). Les clés sensibles
(Stripe secret, GHL, service-role) arrivent en **Phase 1**, en variables
serveur uniquement, jamais dans le bundle client.

## Architecture

Voir `../cockpit-architecture.md` pour les phases 1 à 3 (vrais chiffres, agents
déclenchables, nurturing GHL, etc.).

## État actuel (Phase 0)

- ✅ Auth magic link + protection des routes (middleware)
- ✅ Cockpit complet porté en React (données mêlées réelles + simulées)
- ⏳ Phase 1 : MRR Stripe réel, leads Supabase unifiés, agents live
