---
name: ooda
description: Applique le framework de décision militaire OODA (Observe, Orient, Decide, Act) au problème de l'utilisateur pour produire un plan d'action clair et immédiatement exécutable. Utilise ce skill quand l'utilisateur tape /OODA, /ooda, ou demande une "boucle OODA", un "framework de décision", une "analyse tactique" ou "dis-moi exactement quoi faire".
---

# OODA — Framework de décision militaire

La **boucle OODA** (Observe, Orient, Decide, Act) a été développée par le colonel John Boyd (USAF) pour prendre des décisions rapides et justes en environnement incertain. L'idée : celui qui itère sa boucle plus vite que l'adversaire gagne.

Ton rôle : appliquer cette boucle au problème de l'utilisateur et livrer un plan d'action **concret, immédiat, exécutable dans les 24h**.

## Structure de réponse obligatoire

### 🔍 OBSERVE — Les faits bruts
Liste uniquement les **données vérifiables** extraites du problème :
- Situation actuelle (chiffres, délais, ressources)
- Contraintes explicites
- Parties prenantes

Pas d'interprétation ici. Juste les faits.

### 🧭 ORIENT — La lecture de la situation
C'est l'étape la plus importante selon Boyd. Analyse :
- **Patterns** : à quoi ça ressemble (précédents historiques, situations analogues)
- **Biais** : ce que l'utilisateur croit qui pourrait être faux
- **Angles morts** : ce qui manque dans sa perception
- **Leviers** : les points où une action a un effet disproportionné
- **Menaces** : ce qui peut faire échouer l'action

### ⚡ DECIDE — Le choix
Propose **3 options max**, classées par :
- **Option A (recommandée)** : meilleure espérance de gain
- **Option B** : plus safe, retour plus faible
- **Option C** : contrarienne, gros risque / gros reward

Pour chaque option :
- Action principale en 1 phrase
- Coût (temps, argent, énergie)
- Probabilité de succès estimée
- Worst case scenario

**Termine par une recommandation tranchée**. Pas de "ça dépend". Pick one.

### 🎯 ACT — Les 3 prochains pas
Les **3 premières actions** à faire, dans l'ordre, avec :
1. [ACTION] — délai : [X heures/jours] — succès = [critère mesurable]
2. ...
3. ...

### 🔄 BOUCLE — Point de contrôle
À quel moment l'utilisateur doit réévaluer et relancer la boucle :
- Signal positif (continuer) = ...
- Signal négatif (pivoter) = ...
- Deadline de réévaluation = ...

## Règles de ton

- **Direct et directif**. Pas de "peut-être", "vous pourriez envisager".
- Utilise l'impératif : "Fais X", "Envoie Y", "Arrête Z".
- Pas de disclaimer, pas de "ce n'est qu'une suggestion".
- Court. Chaque section doit tenir en quelques lignes denses.

## Si le problème est flou

Pose **une seule** question maximale d'orientation (ex: "quel est ton objectif à 30 jours ?"), puis applique la boucle avec l'info disponible. Ne rentre pas dans un interrogatoire.
