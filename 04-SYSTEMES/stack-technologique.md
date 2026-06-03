# Stack Technologique — Business Ascension™
> Version 1.0 — Mai 2026
> Un outil pour chaque fonction. Pas de doublon. Pas d'outil sans usage réel.

---

## PRINCIPE

> "On va mettre en place de l'Agile dans ton business. On va éliminer ce qui est inutile."

Chaque outil doit répondre à 3 questions : à quoi ça sert, qui l'utilise, combien ça coûte. Si un outil n'a pas de réponse claire — il sort du stack.

---

## STACK PAR PÔLE

### MARKETING — Création et diffusion

| Fonction | Outil actuel | Alternative | Coût / mois | Statut |
|---|---|---|---|---|
| Montage vidéo Reels | CapCut | DaVinci Resolve | Gratuit | ✅ En place |
| Planification contenu | Buffer / Later | — | 15-18 € | 🔲 À valider |
| Analyse Instagram | Instagram Insights | — | Gratuit | ✅ Natif |
| Analyse LinkedIn | LinkedIn Analytics | — | Gratuit | ✅ Natif |
| Création visuels | Canva | — | 13 € | 🔲 À valider |
| Enregistrement écran | Loom | OBS | 0-15 € | 🔲 À valider |
| Calendrier éditorial | Notion | Google Sheets | 8-16 € | 🔲 À valider |

---

### SALES — Prospection et closing

| Fonction | Outil actuel | Alternative | Coût / mois | Statut |
|---|---|---|---|---|
| Formulaire candidature Audit | Typeform | Tally (gratuit) | 0-25 € | 🔲 À valider |
| Calendrier de réservation | Calendly | Cal.com (gratuit) | 0-10 € | 🔲 À valider |
| CRM / pipeline prospects | Notion | HubSpot Free | 0-50 € | 🔲 À valider |
| Appels de vente (visio) | Zoom | Google Meet | 0-15 € | 🔲 À valider |
| Suivi relances | Notion / tableur | — | — | 🔲 À valider |

---

### DELIVERY — Sessions et accompagnement

| Fonction | Outil actuel | Alternative | Coût / mois | Statut |
|---|---|---|---|---|
| Sessions individuelles (visio) | Zoom | Google Meet | 0-15 € | 🔲 À valider |
| Enregistrement sessions | Zoom (natif) | Loom | Inclus | ✅ Natif |
| Communication client | WhatsApp | — | Gratuit | ✅ En place |
| Backlog client (sprints) | Notion | Trello | 8-16 € | 🔲 À valider |
| Partage ressources clients | Notion | Google Drive | 8-16 € | 🔲 À valider |
| Formulaire feedback sprint | Typeform | Tally | 0-25 € | 🔲 À valider |
| Sessions de groupe | Zoom | Google Meet | Inclus | 🔲 À valider |

---

### SYSTÈMES — Automatisations et IA

| Fonction | Outil actuel | Alternative | Coût / mois | Statut |
|---|---|---|---|---|
| IA générative (contenu, scripts) | Claude / ChatGPT | — | 20-25 € | ✅ En place |
| Automatisations no-code | Make (ex-Integromat) | Zapier | 9-29 € | 🔲 À valider |
| Emails automatisés | ActiveCampaign | Brevo | 9-50 € | 🔲 À valider |
| Documentation SOPs | Notion | — | 8-16 € | 🔲 À valider |
| Gestion des fichiers | Google Drive | OneDrive | 0-10 € | 🔲 À valider |

---

### FINANCE — Paiements et comptabilité

| Fonction | Outil actuel | Alternative | Coût / mois | Statut |
|---|---|---|---|---|
| Paiements clients | Stripe | PayPal | % sur transaction | 🔲 À valider |
| Facturation | Stripe / Pennylane | — | 0-30 € | 🔲 À valider |
| Comptabilité | Comptable / tableur | Pennylane | — | 🔲 À valider |
| Suivi KPIs | Notion / Google Sheets | — | — | 🔲 À valider |

---

### LEGAL — Contrats et signatures

| Fonction | Outil actuel | Alternative | Coût / mois | Statut |
|---|---|---|---|---|
| Signature électronique | DocuSign | Yousign (FR) | 10-30 € | 🔲 À valider |
| Stockage contrats signés | Google Drive | — | — | 🔲 À valider |

---

## STACK MINIMAL — AVANT LE PREMIER CLIENT BÊTA

| Priorité | Outil | Fonction | Action |
|---|---|---|---|
| 1 | Typeform ou Tally | Formulaire candidature Audit | Créer le formulaire |
| 2 | Calendly ou Cal.com | Booking Audit offert | Connecter au formulaire |
| 3 | Zoom | Sessions + enregistrements | Abonnement actif |
| 4 | WhatsApp | Canal client dédié | Canal créé à chaque signature |
| 5 | Stripe | Paiements | Compte vérifié, lien de paiement prêt |
| 6 | Contrat client | Signature avant démarrage | Template signable (voir 06-LEGAL/) |
| 7 | Notion | Backlog client + partage ressources | Workspace créé |

---

## AUTOMATISATIONS PRIORITAIRES

### 1 — Formulaire → Notification
**Déclencheur :** Candidature Audit soumise
**Action :** Notification immédiate à Christofer (email ou WhatsApp)
**Outil :** Typeform → Make → WhatsApp / Email
**Valeur :** Temps de réponse < 2h, aucune candidature manquée

---

### 2 — Paiement → Onboarding
**Déclencheur :** Paiement Stripe confirmé
**Action :** Email d'onboarding + formulaire de diagnostic envoyés automatiquement
**Outil :** Stripe → Make → Brevo / ActiveCampaign
**Valeur :** Onboarding déclenché sans action manuelle

---

### 3 — Calendly → Rappel Audit
**Déclencheur :** Audit offert réservé
**Action :** Email de confirmation + rappel J-1 automatique
**Outil :** Calendly (natif)
**Valeur :** Réduction des no-shows

---

### 4 — Fin de sprint → Feedback client
**Déclencheur :** Fin de chaque sprint (J14)
**Action :** Formulaire de rétrospective envoyé automatiquement au client
**Outil :** Calendrier → Make → Typeform / Tally
**Valeur :** Données satisfaction systématiques sans action manuelle

---

## RÈGLES DU STACK

1. **Un outil par fonction** — si deux outils font la même chose, supprimer un.
2. **Gratuit tant que possible** — passer au payant uniquement quand la limite bloque un process réel.
3. **Audit du stack tous les 3 mois** — lors de la session de clôture : utilisés / pas utilisés / à remplacer.
4. **Notion comme système central** — documentation, backlogs, KPIs et SOPs vivent dans Notion.
5. **Aucun outil ajouté sans sprint dédié** — chaque nouvel outil = backlog item, pas une décision impulsive.

---

## COÛT TOTAL ESTIMÉ

| Phase | Outils essentiels | Coût mensuel estimé |
|---|---|---|
| Bêta (maintenant) | Zoom + Stripe + WhatsApp + IA + Notion | 50 à 80 € |
| Standard | + Calendly + Typeform + Make + Email auto | 120 à 200 € |
| Scale | + CRM avancé + Ads + Analytics avancés | 300 à 500 € |

---

## JOURNAL DES CHANGEMENTS

| Date | Outil | Action | Raison |
|---|---|---|---|
| Mai 2026 | Stack initial | Défini | — |

---

*Version 1.0 — Mai 2026*
*Business Ascension™ — Stack Technologique*
