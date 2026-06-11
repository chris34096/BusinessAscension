# L'ÉQUIPE D'AGENTS BA™ — Organigramme & Chaînages
> Version 1.0 — 11 juin 2026
> Principe : chaque agent existant prend un RÔLE dans une équipe. Les agents se passent leurs outputs comme des collègues se passent des dossiers.
> Le CEO reste Chris. Les agents préparent, analysent, surveillent. L'humain touche le client.

---

## L'ORGANIGRAMME

```
                        CHRIS (CEO)
                            │
              ┌─────────── ORCHESTRATEUR ───────────┐
              │   "Chef de cabinet" · lun-ven 6h30   │
              │   Lit tous les états → daily-brief   │
              └──────┬──────────┬──────────┬─────────┘
                     │          │          │
         ┌───────────┴──┐  ┌────┴─────┐  ┌─┴──────────────┐
         │ DIR. MARKETING│  │ DIR.     │  │ DIR. PRODUIT / │
         │ (Head of      │  │ COMMERCIAL│ │ DELIVERY       │
         │  Content)     │  │          │  │                │
         └──────┬────────┘  └────┬─────┘  └───────┬────────┘
                │                │                 │
   ┌────────────┼──────────┐     │            ┌────┴────┐
   │            │          │     │            │ Checkin │ vendredi 15h
┌──┴───┐  ┌─────┴────┐ ┌───┴──┐  │            │ clients │ (santé clients,
│VEILLE│→ │ CONTENU  │ │ANALY-│  │            └─────────┘  rétention)
│ Data │  │ Ideator+ │ │TICS  │  │
│Analyst│  │ Scripter │ │ Perf │  ├── PROSPECTION (8h) : ciblage + DMs préparés
│ 7h/j │  │ L/M/V 9h │ │mer 8h│  ├── SETTING (18h) : relances prêtes pour demain
└──────┘  └──────────┘ └──────┘  ├── OBJECTIONS (à la demande) : fiches post-appel
                                 └── KPI (ven 17h) : le tableau de bord du Data Analyst
```

---

## LES RÔLES (mapping demandé par Chris → agents réels)

| Rôle demandé | Agent réel | Cadence | Output |
|---|---|---|---|
| **Chef de cabinet** | Orchestrateur | Lun-Ven 6h30 | `state/daily-brief.md` — lu par TOUS les agents du jour |
| **Data Analyst (marché)** | Veille | **Quotidien 7h** ⬆ | `outputs/veille-DATE.md` — RSS 33 chaînes concurrents + Exa |
| **Data Analyst (interne)** | Analytics + KPI | Mer 8h / Ven 17h | Rapports perf contenus + tableau CA/pipeline |
| **Stratégiste de contenu** | YAP framework + tunnel 4/3/3 | Encodé dans le runner Contenu | Rotation TOFU/MOFU/BOFU garantie mécaniquement |
| **Ideator** | Contenu (étape 1 du run) | L/M/V 9h | Idées issues de : veille du matin + value assets + croyances |
| **Scripter** | Contenu (étape 2 du run) | L/M/V 9h | Post LinkedIn + script Reel ligne par ligne |
| **Publishing manager** | GHL Social Planner (humain assisté) | Hebdo | Chris programme les posts du batch — l'outil publie |
| **Head of Content** | Chris + bilan J7 | Hebdo | Valide, tourne, analyse les KPIs du J7 |
| **Dir. Commercial** | Prospection + Setting + Objections | Quotidien | Ciblage matin → relances soir → fiches post-appel |
| **Dir. Produit/Delivery** | Checkin | Ven 15h | Santé des clients actifs, signaux de churn |
| **Gardien du système** | Watchdog | **Toutes les heures** 🆕 | Bot surveillé + redémarré · outputs du jour vérifiés à 19h · alertes Telegram |

---

## LES CHAÎNAGES ACTIFS (qui parle à qui)

```
1. VEILLE (7h) ──────────────► CONTENU (9h)
   Le rapport concurrents du matin est injecté dans le prompt du Contenu.
   → "Tom a publié X hier, l'angle Y cartonne" → idées inspirées, jamais copiées. 🆕

2. ORCHESTRATEUR (6h30) ─────► TOUS
   daily-brief.md lu par Prospection, Setting, Contenu.
   → La priorité du jour aligne toute l'équipe.

3. /prospect (bot, instantané) ► pipeline-suivi.md ► SETTING (18h)
   Chris loggue un prospect en 1 ligne depuis son téléphone.
   → Le Setting du soir prépare la relance pour demain matin. 🆕

4. SETTING (18h) ────────────► CHRIS (lendemain matin)
   Messages de relance prêts à copier-coller dans IG/LinkedIn.

5. ANALYTICS (mer) + KPI (ven) ► BILAN J7 ► décisions de la semaine suivante
   Les chiffres pilotent, pas les impressions.

6. WATCHDOG (horaire) ───────► TELEGRAM
   Si un agent ne produit pas ou si le bot meurt → alerte immédiate + auto-restart. 🆕
```

---

## CE QUI RESTE HUMAIN (par principe, pas par limite technique)

- **Envoyer les DMs** : automatiser = bannissement + trahison du positionnement anti-guru
- **Tourner les reels/vidéos** : c'est le visage et la voix de Chris qui vendent
- **Les appels** (Audit offert, closing) : le produit EST la proximité humaine
- **Les décisions stratégiques** : les agents informent, Chris tranche

## ÉVOLUTIONS POSSIBLES (quand le volume le justifiera)

- Publishing 100% auto : API LinkedIn pour publier les posts du batch sans GHL
- Hermes (modèle gratuit) en routeur de triage des DMs entrants AVANT le Setting
- Agent "Lead Intelligence" + "Content Engine" (runners présents, non planifiés — cadence à définir par Chris)
- Sous-agents par plateforme (un Scripter IG, un Scripter LinkedIn) si le volume de contenu double

---

*Équipe d'agents BA™ · v1.0 · 11 juin 2026 — Une équipe, pas une collection de scripts.*
