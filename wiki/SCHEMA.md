# Wiki LLM — Business Ascension™ · Schéma d'exploitation
> Version 1.0 — Mai 2026
> Ce fichier définit les règles d'exploitation du wiki par l'agent LLM.
> L'agent LIT ce fichier à chaque démarrage de session wiki.

---

## 1. POURQUOI UN WIKI SÉPARÉ DES FICHIERS BA™

Les fichiers du projet (`CLAUDE.md`, `01-MARKETING/`, `02-SALES/`…) sont des **artefacts de production** — docs opérationnels, scripts, SOPs. Ils changent quand le business change.

Le wiki est la **mémoire cumulative** — il ne remplace pas les fichiers BA™, il synthétise leur contenu en unités navigables et le complète avec des observations, des liens et des inférences que les fichiers opérationnels ne peuvent pas contenir.

**Règle absolue :** si l'information est déjà dans un fichier BA™, le wiki pointe vers elle. Il ne la duplique pas.

---

## 2. STRUCTURE DU RÉPERTOIRE

```
wiki/
├── SCHEMA.md            ← Ce fichier — règles d'exploitation
├── index.md             ← Catalogue de toutes les pages wiki
├── log.md               ← Journal chronologique des sessions
│
├── entities/            ← Personnes, organisations, produits
│   ├── christofer-perez.md
│   ├── business-ascension.md
│   └── icp-cible.md
│
├── concepts/            ← Mécanismes, frameworks, terminologie BA™
│   ├── inner-architecture-protocol.md
│   ├── dents-de-scie.md
│   └── bos-6-poles.md
│
├── sources/             ← Notes sur des ressources externes ingérées
│   └── [source-name].md
│
└── syntheses/           ← Analyses croisées, comparaisons, tendances
    └── concurrence-francophone.md
```

---

## 3. FORMAT YAML FRONTMATTER (obligatoire pour toutes les pages)

```yaml
---
wiki_type: entity | concept | source | synthesis
name: Nom lisible
slug: kebab-case-unique
created: YYYY-MM-DD
updated: YYYY-MM-DD
confidence: high | medium | low
sources:
  - chemin/vers/fichier-source.md
related:
  - [[slug-page-liée]]
---
```

**Règles frontmatter :**
- `confidence: low` → information non vérifiée ou inférée, à valider
- `confidence: medium` → issue d'un seul fichier source, non croisée
- `confidence: high` → issue de plusieurs sources ou validée par Chris

---

## 4. CONVENTIONS D'ÉCRITURE

### 4.1 Nommage des fichiers
- Kebab-case uniquement : `inner-architecture-protocol.md`, `dents-de-scie.md`
- Jamais d'espaces, jamais de majuscules dans le nom de fichier

### 4.2 Liens internes
- Format Obsidian : `[[slug-de-la-page]]`
- Exemple : `[[christofer-perez]]`, `[[inner-architecture-protocol]]`
- Un lien vers une page qui n'existe pas encore est permis — c'est un signal de création future

### 4.3 Marqueurs spéciaux
| Marqueur | Usage |
|---|---|
| `⚠️ CONFLIT` | Information contredite ailleurs — préciser la source |
| `❓ À VÉRIFIER` | Inféré, non confirmé — nécessite validation Chris |
| `🔗 REF EXTERNE` | Donnée issue d'une source extérieure au projet BA™ |
| `⏱️ PÉRIMÉ` | Information probablement obsolète — vérifier avant usage |

### 4.4 Structure type d'une page entity
```
# [Nom]
[Une phrase — définition ou rôle]

## Faits clés
[Liste concise des faits fondamentaux]

## Contexte
[Background, histoire, liens avec d'autres entités]

## Observations
[Ce que les fichiers BA™ révèlent mais ne disent pas explicitement]

## Liens
[Relations vers d'autres pages wiki]
```

### 4.5 Structure type d'une page concept
```
# [Concept]
[Définition courte — ce que c'est et ce que ce n'est pas]

## Mécanisme
[Comment ça fonctionne]

## Manifestations BA™
[Comment ce concept s'exprime dans le contexte Business Ascension™]

## Ce que ça n'est pas
[Frontières — ce avec quoi on confond souvent]

## Liens
```

---

## 5. WORKFLOW INGEST

Quand Chris partage un nouveau document, une conversation, un article, un témoignage client :

1. **Identifier le type** : entity, concept, source, synthesis, ou mise à jour d'une page existante
2. **Vérifier si une page existe** : lire `index.md` — si oui, enrichir ; si non, créer
3. **Extraire les faits bruts** : ce que le document dit explicitement
4. **Extraire les inférences** : ce que le document révèle implicitement (taguer `❓ À VÉRIFIER` si non certain)
5. **Mettre à jour les liens** : identifier quelles pages existantes doivent pointer vers la nouvelle
6. **Mettre à jour `index.md`** : ajouter la nouvelle page avec sa description
7. **Logger dans `log.md`** : entrée avec date, source ingérée, pages créées/modifiées
8. **Vérifier les conflits** : si une info contredit une page existante → taguer `⚠️ CONFLIT` sur les deux pages

**Format log INGEST :**
```
## [DATE] — INGEST : [nom source]
- Pages créées : [[slug1]], [[slug2]]
- Pages modifiées : [[slug3]] (section X mise à jour)
- Conflits détectés : aucun | [description]
- Observations : [ce qui est notable dans cette ingestion]
```

---

## 6. WORKFLOW QUERY

Quand Chris pose une question ou demande une analyse :

1. **Lire `index.md`** pour identifier les pages pertinentes
2. **Lire les 5 dernières entrées de `log.md`** pour le contexte récent
3. **Lire les pages wiki pertinentes** (pas les fichiers BA™ entiers — le wiki est le premier niveau)
4. **Naviguer vers les fichiers BA™ source** uniquement si le wiki est insuffisant
5. **Répondre avec les sources citées** : `[[page-wiki]]` ou `chemin/fichier-ba.md`
6. **Si la réponse révèle un manque** dans le wiki → proposer une mise à jour INGEST

---

## 7. WORKFLOW LINT (maintenance hebdomadaire)

1. Vérifier que toutes les pages dans `index.md` existent
2. Vérifier que toutes les pages wiki ont un frontmatter valide
3. Identifier les marqueurs `❓ À VÉRIFIER` anciens de plus de 2 semaines → signaler à Chris
4. Identifier les marqueurs `⏱️ PÉRIMÉ` → proposer suppression ou mise à jour
5. Vérifier les liens `[[slug]]` brisés (page référencée mais non créée)
6. Logger dans `log.md`

**Format log LINT :**
```
## [DATE] — LINT
- Pages vérifiées : [N]
- Liens brisés : aucun | [liste]
- À valider : [[slug]] section X — raison
- Action prise : [description]
```

---

## 8. FORMAT DE INDEX.MD

```markdown
# Wiki BA™ — Index
> Mis à jour : [DATE]

## Entities
- [[christofer-perez]] — Fondateur BA™, background, style, vision
- [[business-ascension]] — La marque, l'offre, le funnel, la nomenclature
- [[icp-cible]] — Profil ICP, archétypes, objections, triggers d'achat

## Concepts
- [[inner-architecture-protocol]] — Mécanisme central du programme, 4 phases, SAFe
- [[dents-de-scie]] — Entry point BA™, définition, expressions cousines
- [[bos-6-poles]] — Business Operating System, 6 pôles, livrables

## Sources
[vide au démarrage]

## Syntheses
- [[concurrence-francophone]] — 4 zones, menaces clés, angle unique BA™
```

---

## 9. RELATION AVEC CLAUDE.MD

`CLAUDE.md` = instructions d'exploitation du projet BA™ pour Claude Code
`wiki/SCHEMA.md` = règles du wiki LLM

**Pas de conflit.** CLAUDE.md dit *comment travailler avec Chris*. SCHEMA.md dit *comment gérer la mémoire cumulative*.

Si une information est dans CLAUDE.md et dans le wiki → le wiki pointe vers CLAUDE.md comme source de vérité.

---

## 10. RÈGLES DE COMPORTEMENT AGENT

À chaque session où le wiki est activé :

1. **Lire `wiki/index.md`** en entier — c'est la carte
2. **Lire les 5 dernières entrées de `wiki/log.md`** — c'est le contexte récent
3. **Ne pas re-dériver depuis zéro** ce qui est déjà dans le wiki — consulter d'abord
4. **Toujours logger** chaque opération wiki dans `log.md`
5. **Proposer proactivement** des mises à jour wiki si une conversation révèle de nouvelles informations

---

*Wiki LLM — Business Ascension™ · v1.0 — Mai 2026*
