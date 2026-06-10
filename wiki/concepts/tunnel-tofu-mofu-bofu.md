---
wiki_type: concept
name: Tunnel TOFU / MOFU / BOFU (répartition 4/3/3)
slug: tunnel-tofu-mofu-bofu
created: 2026-06-10
updated: 2026-06-10
confidence: high
sources:
  - 01-MARKETING/_fondations/yap-framework.md
  - 04-SYSTEMES/agents/agent-contenu-prompt.md
related:
  - [[yap-framework]]
  - [[funnel-acquisition]]
  - [[audit-offert]]
  - [[business-ascension]]
---

# Tunnel TOFU / MOFU / BOFU (répartition 4/3/3)
Modèle de distribution du contenu organique qui donne à chaque pièce un **rôle dans la conversion**. Complémentaire de [[yap-framework]] : YAP donne la *profondeur* d'une idée, le tunnel donne sa *fonction*. Chaque contenu est à la fois un style YAP ET un étage du tunnel.

## Mécanisme
Trois étages, chacun une intention unique :

| Étage | Rôle | Ce qu'on fait | Ce qu'on ne fait PAS |
|---|---|---|---|
| **TOFU** (top) | Attirer | Faire des vues, capter l'inconnu, frapper une croyance large | On ne vend pas. Aucune offre. |
| **MOFU** (middle) | Créer le lien | Montrer le parcours, l'énergie, le message. Inspirer confiance | Pas de vues creuses sans direction |
| **BOFU** (bottom) | Convertir | Preuve, cas, mécanisme, offre claire | Rester vague sans proposer |

**Répartition cible : 4 / 3 / 3 sur 10 contenus** — 4× TOFU (attraction), 3× MOFU (relation), 3× BOFU (conversion).

L'erreur classique = le déséquilibre : vendre trop tôt (pas d'audience pour acheter) OU ne jamais vendre (audience qui ne convertit jamais). L'équation finale : **attention + offre = ventes**.

## Manifestations BA™
Mapping étage → style YAP → CTA :

| Étage | Styles YAP | Angle BA™ | CTA |
|---|---|---|---|
| **TOFU** | Contrarian · Rant | "Plus de formations ≠ plus de CA" · "Ton problème c'est pas l'exécution" | Aucune offre — commente/enregistre |
| **MOFU** | Story · Rabbit Hole | 12K→0, le pivot, le [[goulot-etranglement]], "change la racine pas le fruit" | Suis / DM un mot-clé |
| **BOFU** | Breakdown | Machine à leads, vendre par message, 8 étapes, cas client | **[[audit-offert]]** |

Le carburant du tunnel = la confiance : *les gens n'achètent pas le produit, ils achètent toi* (vision, énergie, message). Authenticité > perfection. Répondre aux commentaires / lives / impliquer l'audience.

### Câblage opérationnel (autonome)
- `01-MARKETING/_fondations/yap-framework.md` §7 (tunnel) + §8 (exécution virale : hook 3s / rétention / valeur · discipline quotidienne · analyse des flops).
- `04-SYSTEMES/agents/agent-contenu-prompt.md` : ÉTAPE 0 choisit l'étage + verrouille la cohérence étage→CTA, sortie taggée `Tunnel:`.
- `04-SYSTEMES/scripts/run-agent-contenu.ps1` : rotation déterministe persistée (`agents/state/tunnel-counter.txt`, cycle 5 runs × 2 pièces) garantissant mécaniquement le 4/3/3.

## Ce que ça n'est pas
- Ce n'est pas un calendrier rigide : c'est un **ratio** sur 10 contenus, pas un ordre fixe.
- Ce n'est pas en contradiction avec belief-first : même un TOFU pose UNE croyance — il ne *vend* simplement pas.
- Ce n'est pas la pub payante : ici on parle d'organique (actif durable, audience qui t'appartient), pas d'achat de trafic.

## Liens
- [[yap-framework]] — la profondeur de l'idée (les 5 styles s'ancrent sur les étages)
- [[funnel-acquisition]] — le flux contenu → leads → Porte 1 / Porte 2
- [[audit-offert]] — la seule offre proposée (étage BOFU)
- [[goulot-etranglement]] — angle MOFU/BOFU récurrent
