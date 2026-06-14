---
name: artifacts
description: Génère un projet interactif complet et immédiatement utilisable (jeu, app, dashboard, simulateur, outil) en tant qu'artifact HTML/React unique. Utilise ce skill quand l'utilisateur tape /artifacts, ou demande une app, un jeu, un dashboard, un prototype interactif, un outil visuel, ou "fais-moi quelque chose de jouable / interactif / cliquable".
---

# Artifacts — Mode projet interactif complet

Ton objectif : livrer un **projet interactif fini**, utilisable immédiatement dans la conversation, sans que l'utilisateur ait à installer quoi que ce soit.

## Règles de production

1. **Un seul fichier** — HTML autonome (CSS + JS inline) ou React single-file (.jsx). Aucun fichier externe.
2. **Fonctionnel dès l'ouverture** — pas de setup, pas de config, ça marche au clic.
3. **Visuellement soigné** — design propre, animations fluides, responsive.
4. **Complet, pas une démo** — toutes les fonctionnalités principales sont là, pas de TODO.

## Choix du format

- **React (.jsx)** pour : dashboards, apps avec état complexe, composants interactifs, visualisations de données (recharts, d3)
- **HTML autonome** pour : jeux (canvas/WebGL), landing pages, simulateurs physiques (Three.js), outils créatifs

## Stack disponible

### React
- Tailwind (classes de base uniquement)
- `lucide-react`, `recharts`, `lodash`, `mathjs`, `d3`
- `three`, `papaparse`, `xlsx` (SheetJS)
- shadcn/ui : `Alert`, `Card`, `Button`, etc.

### HTML
- Tout CDN cdnjs.cloudflare.com autorisé
- Three.js r128 (attention : pas de `CapsuleGeometry`)
- Tone.js pour l'audio
- Chart.js pour les graphes simples

## ⚠️ Interdits absolus

- `localStorage` / `sessionStorage` → utilise `useState` ou variables JS en mémoire
- Fichiers externes (pas de `./style.css`, tout inline)
- Dépendances non listées

## Workflow

1. Si la demande est vague, pose **1 seule** question de cadrage (ex: "plutôt jeu arcade ou puzzle ?") puis exécute.
2. Choisis le bon format (React vs HTML) selon la nature du projet.
3. Crée le fichier dans `/sessions/tender-determined-babbage/mnt/outputs/` avec un nom explicite (`snake-game.html`, `expense-dashboard.jsx`, etc.).
4. Partage-le avec un lien `computer://` via `present_files`.
5. Résume en 2 lignes max : ce que ça fait + comment l'utiliser.

## Checklist qualité

- [ ] Interface claire dès le premier coup d'œil (pas besoin de mode d'emploi)
- [ ] Au moins une animation ou feedback visuel au clic
- [ ] Gestion des cas vides (état initial propre)
- [ ] Responsive (fonctionne en mobile)
- [ ] Code commenté aux endroits non triviaux
- [ ] Palette de couleurs cohérente (pas de Tailwind default partout)

## Idées de scope par catégorie

- **Jeu** : score, game over, restart, au moins 1 mécanique qui monte en difficulté
- **Dashboard** : données mockées réalistes, au moins 3 visualisations différentes, filtres
- **Outil** : input → traitement → output → export (copier/télécharger)
- **Simulateur** : paramètres ajustables en live, preview instantanée
