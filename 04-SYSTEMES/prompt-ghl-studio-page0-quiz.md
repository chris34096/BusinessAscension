# Prompt GHL Studio AI — Page 0 : Quiz Funnel (lien unique toutes plateformes)
> 1 seul lien → questionnaire rapide → page adaptée au profil
> Version 1.0 — Juin 2026
> URL : businessascension.com/commencer

---

## LOGIQUE DE ROUTAGE

```
/commencer (lien unique — Instagram · LinkedIn · YouTube · DMs)
    │
    Q1 : Revenus mensuels actuels ?
    ├── < 5 000 €/mois ─────────────────────────→ /inner-architecture-starter
    ├── 5 000 € – 10 000 €/mois ──→ Q2
    │       ├── Programme structuré ──────────→ /inner-architecture-starter
    │       ├── Accompagnement individuel ────→ /inner-architecture-program
    │       └── D'abord un diagnostic ────────→ /audit-offert
    └── + de 10 000 €/mois ─────────────────────→ /inner-architecture-program

À tout moment → lien "Audit offert gratuit" disponible comme sortie de sécurité
```

---

## PROMPT COMPLET — À COLLER DANS STUDIO AI

```
Create a dark premium quiz funnel page for Business Ascension™.

This is the SINGLE link shared on all platforms: Instagram bio, LinkedIn featured, YouTube description, DMs. One URL for everyone. The page asks 2 short questions and sends each visitor to the right program page based on their profile. Fast. No friction. No exit paths except the Audit offert safety option.

---

BRAND & DESIGN

Brand: Business Ascension™ | Founder: Christofer Perez
Language: French — tutoiement (tu, pas vous)
Background: #0A0A0F | Selected card / CTA: #C9A84C (gold) | Headlines: #FFFFFF | Subtext: #A8A8A8
Unselected card border: #1E1E2E | Selected card border: #C9A84C | Card bg: #111118
Font: Bold modern sans-serif. No serif. Clean, tight spacing.
Style: Dark luxury. Ultra minimal. Fast load. Zero distractions.
NO navigation menu. NO footer links. NO exit paths except Audit offert.

---

SECTION 1 — MINIMAL NAV

Logo center only: "Business Ascension™" (white, no clickable links)
Thin gold progress bar directly below nav — fills as quiz progresses (Step 1 = 50%, Step 2 = 100%)

---

SECTION 2 — HERO

H1 (large, bold, white, centered):
"Trouve l'accompagnement qui correspond exactement à où tu en es."

Subtitle (gray, centered):
"2 questions. 30 secondes. On te montre le chemin."

[Quiz starts immediately below — no CTA button in hero]

---

SECTION 3 — QUIZ STEP 1

Step label (gold, small, centered): "Question 1 sur 2"

H2 (white, centered):
"Où en sont tes revenus mensuels en ce moment ?"

3 choice cards (clickable, vertical on mobile / horizontal on desktop):
Clicking a card: gold border appears, "Continuer" button reveals below.

CARD A:
Title (white bold): "Moins de 5 000 €/mois"
Text (gray): "Je construis mon business ou mes revenus sont encore irréguliers."
→ On click + Continuer: redirect to /inner-architecture-starter

CARD B:
Title (white bold): "Entre 5 000 € et 10 000 €/mois"
Text (gray): "J'ai des clients et des revenus — mais ça fluctue. Je veux stabiliser et scaler."
→ On click + Continuer: show Step 2 (Q2)

CARD C:
Title (white bold): "Plus de 10 000 €/mois"
Text (gray): "Je génère déjà sérieusement. Je veux accélérer et atteindre le niveau suivant."
→ On click + Continuer: redirect to /inner-architecture-program

Button (hidden until card selected, then appears — solid gold):
"Continuer →"

Text below (always visible, small, gray):
"Tu préfères d'abord un diagnostic gratuit ? → Réserver l'Audit offert" [link to /audit-offert]

---

SECTION 4 — QUIZ STEP 2 (shown only if Card B selected)

[Animated transition — Step 1 fades out, Step 2 fades in]

Progress bar: fills to 100%
Step label (gold): "Question 2 sur 2"

H2 (white, centered):
"Qu'est-ce que tu cherches avant tout ?"

3 choice cards:

CARD D:
Title: "Atteindre mes premiers 10K€/mois réguliers"
Text (gray): "Un programme structuré : groupe, modules, inner work personnalisé, suivi hebdomadaire."
→ redirect to /inner-architecture-starter

CARD E:
Title: "Passer à la vitesse supérieure — jusqu'à 100K€/mois"
Text (gray): "Accompagnement individuel sur-mesure. Accès direct à Chris. Construit autour de moi."
→ redirect to /inner-architecture-program

CARD F:
Title: "D'abord comprendre exactement ce qui me bloque"
Text (gray): "Un diagnostic gratuit de 30 minutes avec Chris avant de décider quoi que ce soit."
→ redirect to /audit-offert

Button (gold, appears on card selection):
"Voir mon programme →"

Text below (gray):
"Tu peux aussi → Réserver l'Audit offert gratuitement" [link to /audit-offert]

---

SECTION 5 — TRUST (below quiz, compact)

3 horizontal cards (dark, no border):

"2 piliers · 1 système" / "Inner Work + Business en simultané. Personne d'autre en France ne fait les deux chaque semaine."

"Accès direct à Chris" / "Je lis personnellement ton intake. Je construis personnellement ton protocole. Ce n'est pas une formation."

"À partir de 997€ · ou candidature" / "Programme groupe accessible. Accompagnement individuel sur candidature. Pas de tarif public."

---

SECTION 6 — STICKY SAFETY NET

Sticky bar at bottom of page (appears after 8 seconds without quiz interaction):
Dark bar (#111118), subtle gold text:
"Tu ne sais pas encore ? → Réserver l'Audit offert gratuit — 30 min avec Chris" [link to /audit-offert]

---

NO FOOTER. Page ends after Section 5.

---

TECHNICAL

URL: /commencer
This is the single link for: Instagram bio link, LinkedIn featured, YouTube description, DMs, all content CTAs.

Quiz logic:
- Card selection: click = gold border appears + Continuer button reveals
- Step transition: smooth CSS fade/slide between Step 1 and Step 2
- Step 2 appears ONLY if Card B (5K-10K€) is selected in Step 1

Redirect map:
Card A (< 5K€) + Continuer → /inner-architecture-starter
Card B (5-10K€) + Continuer → Step 2 appears
  Card D (programme structuré) + Voir → /inner-architecture-starter
  Card E (individuel) + Voir → /inner-architecture-program
  Card F (diagnostic) + Voir → /audit-offert
Card C (10K€+) + Continuer → /inner-architecture-program
All "Audit offert" text links → /audit-offert

GHL implementation options:
Option A (recommended): GHL Survey Builder — multi-step survey with conditional logic + redirect on completion. Embed survey in this page design.
Option B: GHL Funnel multi-step with separate pages + custom JS redirect logic.
Option C: Simple static page — 3 large cards linking directly (no quiz logic, just visual routing).

If Studio AI cannot handle conditional logic natively, build Option C (3 static cards) and note it in the page.

Analytics:
Meta pixel: ViewContent on page load. Lead event on any redirect click (any path).
GA4: custom events per card selected ("starter_path", "program_path", "audit_path").
Track drop-off: time on page without interaction.

Mobile: quiz cards must be full-width and tappable on iPhone. Buttons minimum 48px height.
Speed: under 1.5 seconds. No video. No heavy images. Quiz is the hero.
French. Tutoiement. No "vous" anywhere.
```

---

## VERSION SIMPLE SI QUIZ DYNAMIQUE IMPOSSIBLE

Si GHL Studio AI ne gère pas le conditionnel, construire cette version statique :

```
Page /commencer — 3 CHEMINS VISUELS (version sans quiz dynamique)

H1: "Quel accompagnement correspond à où tu en es ?"
Subtitle: "Choisis le chemin qui te ressemble. 3 options. 10 secondes."

CHEMIN 1 — gold left border:
Label gold small: "0 → 10K€/mois"
Title white: "Deviens l'Entrepreneur™"
Text gray: "Tes revenus sont irréguliers. Tu veux un programme structuré — inner work personnalisé + Business Operating System — pour atteindre tes premiers 10K€ réguliers. Groupe + modules + accès à Chris."
CTA gold button: "Voir le programme →" [/inner-architecture-starter]

CHEMIN 2 — gold border full (highlighted card):
Badge: "ACCOMPAGNEMENT INDIVIDUEL"
Label gold small: "10K€ → 100K€/mois"
Title white: "Construis la Marque™"
Text gray: "Tu fais déjà des revenus sérieux. Tu veux accélérer avec Chris en 1-to-1. Accompagnement sur-mesure. 3 niveaux. Accès direct."
CTA gold button solid: "Candidater →" [/inner-architecture-program]

CHEMIN 3 — outline gold border:
Label gold small: "Tu veux d'abord comprendre"
Title white: "L'Audit offert"
Text gray: "30 minutes. Gratuit. Je regarde ton business et je nomme exactement ce qui bloque. Tu repars avec une direction concrète — quelle que soit la suite. Pas de pitch."
CTA outline button: "Réserver gratuitement →" [/audit-offert]
```

---

## ARCHITECTURE COMPLÈTE DU SITE BA™

```
businessascension.com/commencer ← LIEN UNIQUE TOUTES PLATEFORMES
        ↓
    ┌───────────────────────────────────────┐
    │                                       │
    ↓                                       ↓                    ↓
/inner-architecture-starter     /inner-architecture-program    /audit-offert
(Prompt page1-starter.md ✅)    (Prompt page2-iap.md ✅)       (Prompt page3-audit.md ✅)
    │                                       │                    │
    └───────────────────────────────────────┘                    │
                        ↓                                        │
              /inner-architecture-starter                        │
              /inner-architecture-program ←──────────────────────┘
```

---

## CHECKLIST APRÈS GÉNÉRATION

- [ ] Tester les 5 chemins de redirection (A, B→D, B→E, B→F, C)
- [ ] Vérifier que /audit-offert est accessible à tout moment
- [ ] Remplacer tous les liens dans bios par /commencer
- [ ] Meta pixel ViewContent + Lead configurés
- [ ] GA4 events par chemin configurés
- [ ] Tester sur iPhone Safari (tap, select, redirect)
- [ ] Speed test < 1.5 secondes
- [ ] Publier et tester en réel avant de changer les bios

---

*Prompt GHL Studio AI — Page Quiz Funnel /commencer · v1.0 · Juin 2026 · Business Ascension™*
