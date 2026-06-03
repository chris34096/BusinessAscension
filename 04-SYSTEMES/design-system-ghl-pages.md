# Design System + Neuromarketing — Business Ascension™
> Applicable à toutes les pages GHL : /commencer · /starter · /program · /audit-offert
> Version 1.0 — Juin 2026
> Style : 3D · Luxe · Premium · Neuromarketing

---

## 1. DIRECTION ARTISTIQUE

### Ambiance générale

**Références :**
- Framer.com × Linear.app × Stripe.com — dark mode ultra premium
- Apple Event pages × Louis Vuitton digital — cinématique, aéré, impactant
- Awwwards winners 2024 — profondeur 3D, luxe, editorial
- **Ce que ce n'est pas :** un site coaching avec fond dégradé et bouton orange

**Le feeling visé :**
Un visiteur arrive. Il ne voit pas un coach. Il voit une marque.
Sombre. Précis. Raffiné. Avec une gravité — comme si tout avait été pensé.
La 3D n'est pas décorative. Elle dit : ce qui est ici a de la profondeur.

---

### Palette enrichie

```
Background primaire  : #0A0A0F (noir quasi-pur)
Background secondaire: #0F0F1A (nuit profonde — sections alternées)
Surface card         : rgba(255,255,255,0.03) + backdrop-filter: blur(20px)
Gold primaire        : #C9A84C (or chaud — CTAs, accents)
Gold lumineux        : #E8C46A (hover, brillance, gradient)
Gold sombre          : #8B6914 (ombres dorées)
Texte blanc          : #FFFFFF
Texte gris           : #A8A8B3
Grain overlay        : 3-5% opacity noise sur tout le fond
Gradient or          : linear-gradient(135deg, #C9A84C 0%, #E8C46A 50%, #C9A84C 100%)
```

### Typographie

```
Display headline     : Inter Black / Outfit ExtraBold — 72-120px desktop · 40-64px mobile
Section headline     : Inter Bold — 48-64px
Body                 : Inter Regular / Medium — 16-18px · line-height 1.7
Label gold           : Inter SemiBold uppercase · letter-spacing 0.15em · 11-12px
Citations            : Playfair Display Italic — seul usage de serif
```

---

## 2. ÉLÉMENTS 3D

### Outils recommandés pour GHL

**Spline (spline.design) — meilleur choix :**
- Créer la scène sur spline.design (gratuit)
- Exporter comme iframe embed ou code WebGL viewer
- Intégrer dans GHL via bloc "Custom HTML"

**CSS 3D natif — sans librairie :**
- Cards : `transform: perspective(1000px) rotateY(8deg)` au hover
- Glassmorphism : `backdrop-filter: blur(20px)` + fond rgba très transparent
- Sphère dorée : CSS radial-gradient + box-shadow layered

---

### Scène Spline à créer — Sphère dorée hero

**Instructions Spline (30 min max) :**
1. Aller sur spline.design → New Scene
2. Add Object → Sphere → Radius 200
3. Material → PBR Metallic : Metalness 1.0 · Roughness 0.2 · Color #C9A84C
4. Add Environment Light → HDRI warm golden interior
5. Add 2× Torus (anneaux fins) autour de la sphère → material wireframe gold
6. Timeline → Rotation Y : 360° en 15s, loop infini
7. Export → Public Link (iframe)

**Code à coller dans GHL :**
```html
<div style="position:relative;width:100%;height:500px;overflow:hidden;">
  <iframe
    src="https://my.spline.design/[TON-SCENE-ID]/"
    frameborder="0"
    width="100%"
    height="100%"
    style="background:transparent;"
    allow="autoplay">
  </iframe>
</div>
```

**Alternative CSS pure (si Spline pose problème) :**
```css
.sphere-gold {
  width: 400px; height: 400px;
  border-radius: 50%;
  background: radial-gradient(
    circle at 35% 35%,
    #E8C46A 0%, #C9A84C 30%, #8B6914 65%, #3D2C06 100%
  );
  box-shadow:
    inset -20px -20px 60px rgba(0,0,0,0.5),
    inset 10px 10px 30px rgba(232,196,106,0.3),
    0 0 80px rgba(201,168,76,0.25),
    0 0 200px rgba(201,168,76,0.1);
  animation: float 6s ease-in-out infinite;
}
@keyframes float {
  0%,100% { transform: translateY(0); }
  50%      { transform: translateY(-20px); }
}
```

---

### CSS Glassmorphism Cards — à injecter dans GHL Custom CSS

```css
/* Glassmorphism card */
.glass-card {
  background: rgba(255,255,255,0.03);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid rgba(201,168,76,0.15);
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(0,0,0,0.4),
              inset 0 1px 0 rgba(255,255,255,0.05);
  transition: all 0.3s cubic-bezier(0.16,1,0.3,1);
}
.glass-card:hover {
  border-color: rgba(201,168,76,0.4);
  transform: translateY(-4px) perspective(800px) rotateY(3deg);
  box-shadow: 0 16px 48px rgba(201,168,76,0.1),
              inset 0 1px 0 rgba(255,255,255,0.08);
}
/* Selected state */
.glass-card.selected {
  border-color: #C9A84C;
  box-shadow: 0 0 32px rgba(201,168,76,0.2);
  transform: scale(1.02);
}

/* Gold gradient text */
.gold-text {
  background: linear-gradient(135deg,#C9A84C,#E8C46A,#C9A84C);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

/* Gold CTA button */
.btn-gold {
  background: linear-gradient(135deg,#C9A84C,#E8C46A);
  color: #0A0A0F;
  font-weight: 700;
  letter-spacing: 0.05em;
  border-radius: 8px;
  padding: 16px 40px;
  box-shadow: 0 0 24px rgba(201,168,76,0.35);
  transition: all 0.2s ease;
  border: none;
}
.btn-gold:hover {
  box-shadow: 0 0 48px rgba(201,168,76,0.55);
  transform: translateY(-2px);
}

/* Grain texture overlay */
body::after {
  content: "";
  position: fixed;
  top:0;left:0;width:100%;height:100%;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)' opacity='1'/%3E%3C/svg%3E");
  opacity: 0.04;
  pointer-events: none;
  z-index: 9999;
}
```

---

## 3. SYSTÈME NEUROMARKETING — 10 PRINCIPES APPLIQUÉS À BA™

### Principe 1 — PATTERN INTERRUPT
Ne jamais commencer par ce qu'ils attendent.

❌ "J'aide les entrepreneurs à stabiliser leurs revenus"
✅ **"Tu sais exactement ce que tu dois faire. Alors pourquoi tu ne le fais pas encore ?"**

---

### Principe 2 — BOUCLE OUVERTE (Zeigarnik Effect)
Poser une question qui reste ouverte. Le cerveau doit défiler pour la fermer.

> *"La raison pour laquelle tu n'exécutes pas n'est pas ce que tu crois."*

---

### Principe 3 — FUTURE PACING (Mirror neurons)
Les faire vivre le "après" avant qu'on parle de l'offre. Si concrètement qu'ils le ressentent.

> *"Dans 90 jours, tu te lèves le lundi. Tu regardes ton agenda. Le pipeline est là. Tu n'as rien forcé. Ton business a avancé pendant que tu levais le pied."*

---

### Principe 4 — LOSS AVERSION
Les gens sont 2× plus motivés par la peur de perdre que par le gain.

> *"Chaque mois sans système = un client à 5 000 € que tu n'as pas eu. Sur un an — 60 000 € laissés sur la table. Pas parce que tu n'as pas travaillé. Parce que rien ne travaillait à ta place."*

---

### Principe 5 — MIROIR (VOC exact)
Décrire leur réalité avec leurs mots exacts. Créer le moment "c'est exactement ça".

> *"Tu refais ton offre pour la troisième fois ce mois-ci. Pas parce qu'elle est mauvaise. Pour éviter de prospecter."*

---

### Principe 6 — ANCRAGE DE VALEUR
Toujours montrer la valeur totale avant le prix. Le prix semble petit après.

> *"Valeur totale des livrables : 9 100 €. Ton investissement : 997 €."*

---

### Principe 7 — PREUVE SOCIALE SPÉCIFIQUE
"Des centaines d'entrepreneurs" = rien. Une personne réelle avec un détail = tout.

> *"Antoine avait une main invisible. Il allait dans des hôtels de luxe sans avoir l'argent. Il empruntait pour paraître. Il savait qu'il devait prospecter. Et il ne le faisait pas."*

---

### Principe 8 — AUTORITÉ PRÉCISE
Pas "j'ai de l'expérience". Des faits mesurables.

> *"350 personnes accompagnées en transformation profonde. Formé à l'hypnose, la PNL, le breathwork, les neurosciences. Accompagné par des coachs qui font plusieurs millions par an."*

---

### Principe 9 — SCARCITÉ RÉELLE
Jamais de fausse urgence. Justifier la scarcité.

> *"5 places bêta. Chris construit chaque protocole personnellement. La capacité est réelle. L'accès est limité."*

---

### Principe 10 — IDENTITÉ (le niveau le plus fort)
Ne pas vendre ce qu'ils font. Vendre qui ils deviennent.

> *"Ce n'est pas un programme. C'est l'architecture de l'entrepreneur que tu sais être."*

---

## 4. COPY NEUROMARKETING PAR PAGE

### /commencer — Hero pattern interrupt

```
[GOLD LABEL] BUSINESS ASCENSION™

[H1 DISPLAY — gradient or]
"Tu sais ce que tu dois faire.
Alors pourquoi tu ne le fais pas encore ?"

[BODY]
Ce n'est pas un manque de compétences.
Ce n'est pas un manque de stratégie.
La réponse est à 2 questions d'ici.

[SOUS-TEXTE GRIS]
2 questions · 30 secondes · Le chemin exact pour toi
```

### /commencer — Cards quiz (miroir)

```
CARD A — "Je construis. Pas encore régulier."
"Tu travailles. Tu produis. Mais chaque mois, tu recommences de zéro.
Ce n'est pas un problème d'effort. C'est un problème de système."

CARD B — "Je génère — mais c'est instable."
"Tu as prouvé que tu pouvais faire de l'argent. Mais un mois fort. Un mois creux.
Ce pattern. Et tu ne comprends toujours pas pourquoi."

CARD C — "Je fais du chiffre sérieux. Je veux accélérer."
"Tu sais performer. Tu veux que le système performe à ta place.
De 10K€ à 100K€ — avec plus de levier, moins de friction."
```

### /commencer — Section future pacing

```
[H2] "Dans 90 jours."

Tu te lèves le lundi.
Tu regardes ton pipeline.
Il est là.

Tu n'as rien forcé cette semaine.
Ton contenu a travaillé.
Ton système a converti.
Tu as levé le pied — le business a continué.

C'est ce qu'on construit ensemble.
```

### /commencer — Section loss aversion

```
[CHIFFRE GÉANT DORÉ] 5 000 €
que tu n'as pas eu. Par client. Par mois.

[DIVIDER]

Sur un an :

[CHIFFRE GÉANT DORÉ] 60 000 €
laissés sur la table.

Pas parce que tu n'as pas travaillé.
Parce que rien ne travaillait à ta place.
```

---

## 5. PROMPT QUIZ PAGE MISE À JOUR — AVEC 3D + NEUROMARKETING

Coller dans GHL Studio AI à la place de la version précédente :

```
Create an ultra-premium dark luxury 3D sales funnel quiz page for Business Ascension™.

Single entry link for all platforms. Visual direction: Linear.app × high-end agency × luxury brand. Dark, cinematic, 3D depth, gold metallic. The most premium coaching site in France.

DESIGN: Background #0A0A0F + 4% grain overlay. Cards: glassmorphism (rgba(255,255,255,0.03) + backdrop-filter blur(20px) + gold border). CTAs: gold gradient buttons with glow. Typography: Inter ExtraBold headlines, gradient gold on display text. Micro-animations: cubic-bezier(0.16,1,0.3,1). NO nav. NO footer links.

3D HERO: Right side — large rotating golden metallic sphere (Spline embed OR CSS radial-gradient sphere with float animation + gold glow box-shadow). Surrounded by thin gold orbital rings. Transparent background. Layered BEHIND headline text. Float animation 6s ease-in-out.

SECTION 1 — NAV
Logo center: "Business Ascension™" white. Thin gold progress bar below.

SECTION 2 — HERO
[3D sphere right, headline left — split layout desktop, stacked mobile]

Gold label (uppercase tracked): "BUSINESS ASCENSION™"

H1 display (gradient gold text, very large):
"Tu sais ce que tu dois faire.
Alors pourquoi tu ne le fais pas encore ?"

Body (white 18px):
"Ce n'est pas un manque de compétences.
Ce n'est pas un manque de stratégie.
La réponse est à 2 questions d'ici."

Subtext (gray small):
"2 questions · 30 secondes · Le chemin exact pour toi"

SECTION 3 — QUIZ STEP 1
Step label gold: "Question 1 sur 2"
H2 white: "Où en sont tes revenus mensuels ?"

3 glassmorphism cards (hover: 3D tilt + gold glow, selected: gold border + scale 1.02):

CARD A — Title: "Je construis. Pas encore régulier."
Text: "Tu travailles. Tu produis. Mais chaque mois, tu recommences de zéro. C'est pas un problème d'effort. C'est un problème de système."
Tag gold small: "0 – 5 000 €/mois"
On click → /inner-architecture-starter

CARD B — Title: "Je génère — mais c'est instable."
Text: "Tu as prouvé que tu pouvais faire de l'argent. Mais un mois fort. Un mois creux. Ce pattern. Et tu ne comprends toujours pas pourquoi."
Tag: "5 000 – 10 000 €/mois"
On click → Show Step 2

CARD C — Title: "Je fais du chiffre sérieux. Je veux accélérer."
Text: "Tu sais performer. Tu veux que le système performe à ta place. De 10K€ à 100K€ — plus de levier, moins de friction."
Tag: "+ de 10 000 €/mois"
On click → /inner-architecture-program

Gold button (hidden until card selected, then fades in with glow):
"Continuer →" [glow: box-shadow 0 0 32px rgba(201,168,76,0.4)]

Safety link gray: "Tu préfères d'abord un diagnostic gratuit ? → Réserver l'Audit offert" → /audit-offert

SECTION 4 — QUIZ STEP 2 (only if Card B selected, smooth fade transition)
Progress fills to 100%.
H2: "Qu'est-ce que tu cherches avant tout ?"

Card D: "Atteindre mes premiers 10K€/mois réguliers"
"Un programme structuré. Inner work personnalisé. BOS. Groupe + accès direct à Chris."
→ /inner-architecture-starter

Card E: "Passer à la vitesse supérieure avec Chris en 1-to-1"
"Accompagnement individuel sur-mesure. 3 niveaux d'intensité. Accès direct."
→ /inner-architecture-program

Card F: "D'abord comprendre exactement ce qui me bloque"
"30 min. Gratuit. Chris nomme le goulot. Direction concrète quelle que soit la suite."
→ /audit-offert

Gold button: "Voir mon programme →"

SECTION 5 — FUTURE PACING
[Section darker background shift]
H2 white large centered: "Dans 90 jours."

Text white large generous spacing:
"Tu te lèves le lundi.
Tu regardes ton pipeline.
Il est là.

Tu n'as rien forcé cette semaine.
Ton contenu a travaillé.
Ton système a converti.
Tu as levé le pied — le business a continué.

C'est ce qu'on construit ensemble."

[Cinematic photo Chris — full bleed, direct eye contact]

SECTION 6 — AUTHORITY
3 glassmorphism cards horizontal:
"3 entreprises ouvertes à l'étranger" / "J'ai vu ce qui tient — pas depuis un livre."
"350 personnes accompagnées" / "Breathwork. Hypnose. MAP. PNL. Neurosciences. À la racine."
"Identité + Business · Simultané" / "Pas l'un après l'autre. Les deux chaque semaine."

SECTION 7 — LOSS AVERSION
[High contrast dark section]
Large gold number: "5 000 €" / "que tu n'as pas eu. Par client. Par mois."
Divider
Large gold: "60 000 €" / "laissés sur la table. Sur un an."
Gray centered: "Pas parce que tu n'as pas travaillé. Parce que rien ne travaillait à ta place."

SECTION 8 — SCARCITY + FINAL CTA
Gold small text: "PHASE BÊTA · 5 PLACES DISPONIBLES"
White: "Chris construit chaque protocole personnellement. La capacité est réelle."
Gold CTA large glowing: "Trouver mon programme →"
[Subtle pulse animation on CTA glow]

SECTION 9 — STICKY BAR
After 8s without action:
Dark bar gold border-top: "Tu ne sais pas encore ? → Réserver l'Audit offert gratuit — 30 min" → /audit-offert

TECHNICAL
URL: /commencer. NO nav. NO footer. Single conversion goal.
Routing: A→/starter · B→Step2(D→/starter, E→/program, F→/audit) · C→/program
3D: Spline iframe OR CSS sphere. Cards: CSS perspective tilt hover. Animations: reduced-motion safe.
Mobile: cards full width, sphere 60% size, tap 48px minimum.
Speed: < 2s. Lazy load 3D. Meta pixel + GA4 events per path.
French. Tutoiement.
```

---

*Design System + Neuromarketing · v1.0 · Juin 2026 · Business Ascension™*
