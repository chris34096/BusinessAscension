---
name: vsl-analyzer
description: "Analyze and rewrite VSL (Video Sales Letter) scripts at A-player copywriting level. Use this skill when the user provides a VSL script and asks to analyze retention drops, rewrite weak segments, or audit copy quality. Triggers include: 'analyse ma VSL', 'réécris cette partie', 'où est-ce que ça décroche', 'améliore mon script', 'audit VSL', 'VSL', 'video sales letter', 'VTurb', 'retention curve', 'retention drop', 'video analytics', 'transcript optimization', 'A/B test for video', 'viewer drop-off', 'audience retention', or anything about improving a sales video or booking call funnel. This skill is for VSL → booking call format (not direct sale). Claude will diagnose retention issues and rewrite segments at the highest copywriting standard using proven frameworks (PAS, Unique Mechanism, Epiphany Bridge, Cialdini)."
---

# VSL Analyzer & Rewriter — Business Ascension™

Diagnostiquer les chutes de rétention, réécrire les segments faibles au plus haut niveau de copywriting, et générer des plans d'A/B tests — pour des VSL au format booking call.

**IMPORTANT : Avant toute analyse ou réécriture, toujours lire `references/copywriting-mastery.md`.** Ce fichier contient l'architecture obligatoire des 9 blocs, les règles de copy ligne par ligne, le diagnostic par timestamp, et le format de sortie opérationnel.

## Vue d'ensemble

Ce skill est conçu pour des VSL dont l'objectif est de **générer des appels qualifiés** (booking calls). La VSL ne vend pas l'offre — elle vend le désir d'avoir une conversation.

Le skill fait 3 choses :

1. **Diagnostiquer** — analyser la courbe de rétention VTurb, identifier les zones de chute, et les corréler avec le contenu du transcript
2. **Réécrire** — produire des réécritures A-player pour chaque segment faible, en suivant l'architecture obligatoire en 9 blocs
3. **Tester** — proposer des A/B tests structurés avec hypothèse, variantes, et métriques

## Pipeline technique (5 étapes)

```bash
# 1. Transcrire la VSL (local — nécessite Whisper)
python scripts/transcribe_vsl.py --drive-url "URL" --model medium --language fr --output transcript

# 2. Récupérer les données VTurb
python scripts/vturb_api.py --token TOKEN --player-id PLAYER_ID retention --format csv --video-duration SECONDS

# 3. Analyser la rétention
python scripts/analyze_retention.py vturb_data_retention.csv --output analysis.json

# 4. Corréler transcript ↔ rétention
python scripts/correlate_transcript.py analysis.json transcript_stamped.txt --language fr --output correlation.json

# 5. Donner correlation.json + transcript à Claude (ce skill)
```

## Connexion VTurb

**Étape 1 — Générer la clé API :** https://app.vturb.com/settings/analytics-api → "Generate new API key"

**Étape 2 — Trouver le Player ID :** URL du dashboard analytics :
`https://app.vturb.com/players/XXXXXXXXXXXXXXXX/analytics`

**Étape 3 — Stocker le token (Windows) :**
```powershell
[System.Environment]::SetEnvironmentVariable("VTURB_API_TOKEN", "ta_cle_ici", "User")
```

## Installation des dépendances Python

```bash
pip install openai-whisper gdown
# Windows : télécharger ffmpeg depuis ffmpeg.org et ajouter au PATH
```

## Diagnostic par zone de chute

| Zone | Cause probable | Fix prioritaire |
|---|---|---|
| < 25% watch time | Échec du hook | Réécrire le hook en premier |
| ~50% watch time | Mécanisme abstrait / preuves manquantes | Cadence de preuves + simplifier |
| > 75% mais faible booking | Confusion offre/CTA | Recadrer offre + CTA |
| Chute plate partout | Rythme trop lent | Couper chaque phrase inutile |

## Format de sortie — 9 sections

1. Résumé Exécutif
2. Diagnostic Rétention
3. Croyances Limitantes identifiées
4. Points de Chute Critiques (tableau)
5. 5 Alternatives de Hook
6. Réécritures par Segment
7. Reframe Offre + CTA
8. Plan d'A/B Tests (3-5 expériences)
9. Transcript Complet Réécrit

## Fichiers du skill

- `SKILL.md` — Ce fichier
- `references/copywriting-mastery.md` — Base de connaissances copywriting complète (9 blocs)
- `references/vturb-api.md` — Documentation API VTurb (23 endpoints)
- `scripts/vturb_api.py` — Client API VTurb
- `scripts/analyze_retention.py` — Analyse de la courbe de rétention
- `scripts/correlate_transcript.py` — Corrélation transcript vers drops
- `scripts/transcribe_vsl.py` — Transcription locale avec Whisper
