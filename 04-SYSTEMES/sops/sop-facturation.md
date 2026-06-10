# SOP — Facturation
> Version 1.0 — Mai 2026
> S'applique à chaque signature de contrat client.
> Durée : 15 minutes par client.
> Wiki : [[business-ascension]]

---

## DÉCLENCHEUR

Ce SOP s'active dès qu'un prospect dit oui verbalement en fin d'appel.

**Règle absolue : facturer dans l'heure qui suit l'accord verbal.** Jamais le lendemain.

---

## ÉTAPES

### Étape 1 — Créer la facture (5 min)

- [ ] Ouvrir l'outil de facturation (Stripe / Pennylane / autre selon stack)
- [ ] Créer une nouvelle facture au nom du client
- [ ] Montant : 4 997 € (phase bêta) ou 7 000 € (phase standard)
- [ ] Description : "Construis la Marque™ — 12 semaines — Business Ascension™"
- [ ] Échéance : immédiate ou selon accord (2x ou 3x)
- [ ] Vérifier les coordonnées client (nom, email, adresse si nécessaire)

### Étape 2 — Envoyer le lien de paiement (2 min)

- [ ] Copier le lien de paiement Stripe
- [ ] Envoyer par WhatsApp ET par email

**WhatsApp :**
> "Super, je suis vraiment content qu'on travaille ensemble. Voilà le lien pour finaliser : [lien]. Dès que c'est fait, je t'envoie le kit d'onboarding et on fixe la première session."

**Email :**
> Objet : "Construis la Marque™ — Votre lien de paiement"
>
> Salut [prénom],
>
> Ravi qu'on avance ensemble. Voici le lien pour finaliser ton inscription : [lien]
> Montant : [X €]
>
> Dès réception, je t'envoie le kit de bienvenue et on fixe notre première session.
>
> Christofer

### Étape 3 — Confirmer le paiement

- [ ] Vérifier la réception sur Stripe
- [ ] Archiver la facture payée (PDF)
- [ ] Déclencher le SOP onboarding (onboarding-client.md)
- [ ] Ajouter le client dans le suivi clients actifs

### Étape 4 — Mettre à jour la comptabilité (J+1 max)

- [ ] Renseigner dans comptabilite-mensuelle.md
- [ ] Passer le prospect en statut SIGNÉ dans pipeline-suivi.md
- [ ] Mettre à jour le KPIs Dashboard

---

## PAIEMENTS EN PLUSIEURS FOIS

| Formule | Échéance 1 | Échéance 2 | Échéance 3 |
|---|---|---|---|
| 2x | 50% à la signature | 50% à J+30 | — |
| 3x | 40% à la signature | 30% à J+30 | 30% à J+60 |

**Si échéance non reçue à J+3 :**
> "Salut [prénom], je vois que le paiement de [montant €] prévu le [date] n'est pas encore passé. Peut-être un problème technique ? Voici à nouveau le lien : [lien]."

---

## ARCHIVAGE

- Dossier : `Factures/2026/[Mois]/[Nom client]`
- Nom fichier : `FACTURE-[AAAAMM]-[NomClient].pdf`

---

*Version 1.0 — Mai 2026 — Business Ascension™*
