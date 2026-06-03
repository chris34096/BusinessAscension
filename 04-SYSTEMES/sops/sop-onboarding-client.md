# SOP — Onboarding Client
> Version 1.0 — Mai 2026
> S'active dès confirmation du paiement.
> Durée : 30 minutes.
> Wiki : [[inner-architecture-protocol]] · [[icp-cible]]

---

## DÉCLENCHEUR

Ce SOP s'active dès que le paiement est confirmé sur Stripe (cf. sop-facturation.md Étape 3).

**Objectif :** Le client doit se sentir attendu, pas accueilli. La différence : attendu = on savait qu'il allait arriver. Accueilli = on a fait quelque chose pour lui. On vise attendu.

---

## ÉTAPES

### Étape 1 — Envoyer le Kit de Bienvenue (10 min)

- [ ] Créer un message WhatsApp personnalisé (voir template ci-dessous)
- [ ] Envoyer l'email de bienvenue avec les documents joints
- [ ] Partager le lien d'accès Notion (espace client)
- [ ] Envoyer le lien pour booker la session d'onboarding (Calendly)

**WhatsApp :**
> "Salut [prénom] — paiement bien reçu. Bienvenue dans le programme.
>
> Je t'envoie par email le kit complet : accès Notion, questionnaire de démarrage, et le lien pour qu'on fixe notre première session.
>
> D'ici là, remplis le questionnaire — ça me permettra d'arriver préparé dès la session 1."

**Email de bienvenue :**
> Objet : "Bienvenue dans Construis la Marque™ — voici ton accès"
>
> Salut [prénom],
>
> Bienvenue. Voici ce dont tu as besoin pour démarrer :
>
> **1. Accès Notion** — ton espace dédié : [lien]
> C'est là qu'on stocke tout : notes de session, backlog, sprint en cours, ressources.
>
> **2. Questionnaire de démarrage** — [lien]
> 15 minutes max. Remplis-le avant notre première session.
> Ça me permet d'arriver avec un diagnostic déjà bien orienté.
>
> **3. Première session** — [lien Calendly]
> On a 5 jours pour se voir. Choisis le créneau qui te convient.
>
> Si tu as une question avant qu'on se parle, tu m'envoies un WhatsApp.
>
> À très vite.
> Christofer

---

### Étape 2 — Préparer l'Espace Client Notion (10 min)

- [ ] Dupliquer le template Notion client (voir espace Notion > Templates)
- [ ] Renommer avec le prénom du client
- [ ] Pré-remplir : nom, date de démarrage, offre souscrite, montant, mode de paiement
- [ ] Créer le backlog vide (Sprint 1 en attente du questionnaire)
- [ ] Vérifier que le lien de partage est actif et en lecture/commentaire

**Structure de l'espace client :**
```
[Prénom] — CTM
├── Profil Client (nom, contact, offre, dates)
├── Questionnaire de démarrage (réponses à coller)
├── Backlog (liste des items identifiés)
├── Sprint en cours (objectifs + DoD)
├── Notes de sessions (1 page par session)
└── Ressources (documents partagés)
```

---

### Étape 3 — Questionnaire de Démarrage (à envoyer au client)

Envoyer ce formulaire (Google Form ou Notion form) AVANT la session d'onboarding :

**Section 1 — Ton business aujourd'hui**
1. Ton activité en une phrase (ce que tu fais, pour qui, comment tu gagnes ta vie dessus)
2. CA des 3 derniers mois (rough order — pas besoin d'être exact)
3. D'où viennent tes clients aujourd'hui ?
4. Combien d'heures semaine tu travailles sur ton business (en dehors de tout le reste) ?

**Section 2 — Ce qui bloque**
5. Si tu mets le doigt sur UN seul truc qui t'empêche de passer au prochain niveau — c'est quoi ?
6. Qu'est-ce que tu as déjà essayé pour débloquer ça ?
7. Qu'est-ce qui s'est passé ?

**Section 3 — Ce que tu viens chercher**
8. Dans 3 mois, si ce programme a vraiment marché — à quoi ressemble ta journée type ?
9. Qu'est-ce qui serait différent dans ton business ? Et dans ta façon de le vivre ?
10. Y a-t-il quelque chose d'important que je dois savoir sur toi pour qu'on travaille bien ensemble ?

---

### Étape 4 — Session d'Onboarding (première session — 90 min)

Cette session suit la structure sop-session-hebdo.md avec une ouverture spéciale :

**Au lieu du Sprint Review (inexistant) :**
- Lecture des réponses au questionnaire avec le client
- Identification des 3 goulots prioritaires
- Cartographie rapide du business (revenus, acquisition, delivery, systèmes)
- Identification du premier inner pattern à désactiver

**Sprint Planning session 1 :**
- Définir les 2-3 premiers objectifs du Sprint 1
- Poser la DoD claire
- Donner 1 observation inter-sessions (pas plus)

**Clôture onboarding :**
> "Voilà. On a maintenant une image précise de où tu en es et de ce qu'on va attaquer en premier. Les prochaines semaines, on avance ensemble — moi j'analyse, je diagnostique, je prescris. Toi tu implémentes. Si quelque chose résiste ou que tu bloques, tu m'envoies un message. On règle ça."

---

### Étape 5 — Mise à jour du Suivi (5 min)

- [ ] Passer le client de SIGNÉ à ACTIF dans pipeline-suivi.md
- [ ] Enregistrer la date de démarrage
- [ ] Planifier les 12 sessions sur le calendrier (toutes les 2 semaines)
- [ ] Configurer un rappel J+14 pour le premier Sprint Review

---

## CHECKLIST ONBOARDING COMPLÈTE

- [ ] Paiement confirmé (Stripe)
- [ ] WhatsApp envoyé dans l'heure
- [ ] Email de bienvenue envoyé
- [ ] Espace Notion créé et partagé
- [ ] Questionnaire de démarrage envoyé
- [ ] Session d'onboarding bookée (dans les 5 jours)
- [ ] Questionnaire reçu et lu AVANT la session
- [ ] Session d'onboarding réalisée
- [ ] Sprint 1 planifié
- [ ] Client passé en ACTIF dans le pipeline

---

*Version 1.0 — Mai 2026 — Business Ascension™*
