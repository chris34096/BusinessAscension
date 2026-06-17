# Emails du Funnel — Business Ascension™
> Version 1.0 — Juin 2026
> Les emails transactionnels/automatiques du funnel, dans l'ordre du parcours.
> Voix : Chris (direct, oral, tutoiement, zéro tiret cadratin). Wiki : [[funnel-acquisition]] · [[voix-chris]]

> **Carte du funnel (validée 2026-06-17) :**
> Contenu → Lead magnet (capture email, montre l'expertise, fait lever la main) → Email bienvenue → DM.
> En DM, Chris qualifie le revenu : **< 10K = Porte 1 (close par message)** · **≥ 10K = Porte 2 (envoi en appel)**.
> L'Audit offert générique est retiré du funnel.

---

## EMAIL 1 — Bienvenue (lead magnet "Les 4 goulots")

- **Déclencheur :** automatique, à l'inscription sur `goulots.businessascension.fr` (insert Supabase `lead_goulots` → trigger → Resend).
- **But :** continuer la conversation du guide + faire venir en DM. Pas de vente.
- **Expéditeur :** `Chris <chris@businessascension.fr>` · réponse possible directement.
- **Statut :** ✅ branché et live (déclencheur `trg_send_welcome_goulots`).

**Objet :** Alors, ton goulot c'est lequel ?

```
Salut [prénom],

T'as ouvert le guide des 4 goulots. Déjà, bien joué. La plupart téléchargent et oublient dans l'heure.

Bon. La vraie question maintenant. T'as coché lequel ?

Parce que le piège, c'est de traiter le mauvais. Tu bosses ton offre alors que ton vrai problème c'est l'acquisition. Tu cherches plus de leads alors que c'est ton exécution qui bloque. Du coup ça bouge un peu. Puis ça revient.

Quand tu traites le bon, le reste se débloque derrière. C'est mécanique, pas magique.

Si tu veux qu'on le regarde ensemble, réponds direct à ce mail avec le goulot que t'as identifié. Ou écris-moi en DM. Je te réponds, on regarde ton cas, et je te dis où ça coince vraiment. Pas de pitch, promis.

[Bouton] M'écrire en DM  →  https://ig.me/m/chris.businessascension

Chris
Business Ascension™
```

---

## EMAIL 2 — Onboarding Porte 1 (post-paiement)

- **Déclencheur :** après le paiement de Deviens l'Entrepreneur™ (Stripe).
- **But :** donner les accès à la formation + faire réserver l'appel d'onboarding (livraison, pas vente).
- **Statut :** ⏳ à brancher. Tant que le volume est faible (bêta), Chris peut l'envoyer à la main après chaque vente (il est déjà en conversation DM avec le client). Automatisation possible plus tard via webhook Stripe → Supabase → Resend.
- **À remplir :** `[LIEN ACCÈS FORMATION]` et `[LIEN CALENDRIER ONBOARDING]`.

**Objet :** Bienvenue dans Deviens l'Entrepreneur™ (tes accès + ton premier RDV)

```
Salut [prénom],

Ça y est, t'es dedans. Et franchement bien joué, parce que la plupart des gens restent des mois à "réfléchir" pendant que toi t'as décidé.

Deux trucs à faire maintenant, dans l'ordre.

1. Tes accès à la formation. C'est ici : [LIEN ACCÈS FORMATION]
Tu te connectes, tu regardes le module de démarrage en premier. Le reste découle de là.

2. On cale ton appel d'onboarding. C'est pas un cours. C'est 30 minutes où on pose TON plan : ton offre, ton positionnement, et par où tu commences pour aller chercher tes premiers clients. Réserve ton créneau ici : [LIEN CALENDRIER ONBOARDING]

Fais les deux aujourd'hui si tu peux. L'élan, c'est maintenant qu'il est là, pas dans trois jours.

Une question, un souci d'accès, tu réponds à ce mail ou tu m'écris en DM. Je suis là.

On construit.

Chris
Business Ascension™
```

---

## EMAIL 3 — Confirmation appel Porte 2 (post-réservation)

- **Déclencheur :** après réservation d'un appel sur `scale.businessascension.fr` (formulaire GHL).
- **But :** sécuriser le show-up. Le vrai message est déjà sur la page de remerciement (`merci.html` Porte 2) ; cet email la double par écrit.
- **Statut :** la page merci P2 existe ✅. Email de confirmation à brancher côté outil de booking.

**Objet :** C'est noté, on se parle bientôt

```
Salut [prénom],

Ton appel est réservé. Tu as bloqué un créneau en direct avec moi pour regarder ton business et voir, concrètement, comment on te fait passer le cap.

Une seule chose compte maintenant : que tu sois là.

Avant l'appel :
- Bloque le créneau pour de vrai dans ton agenda (c'est un temps que je réserve rien que pour toi).
- Mets-toi au calme, au bon moment, prêt à parler franchement de ton business et de là où tu veux aller.
- Sois là 2 minutes en avance.

On regarde où t'en es, ton plafond actuel, et je te montre le chemin exact pour le faire sauter. Tu repars avec de la clarté, qu'on bosse ensemble ensuite ou pas.

Une question d'ici là ? Réponds à ce mail ou écris-moi en DM.

À très vite,

Chris
Business Ascension™
```

---

*Business Ascension™ — Emails du funnel v1.0 — Juin 2026*
