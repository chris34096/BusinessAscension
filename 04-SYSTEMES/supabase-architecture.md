# Architecture Supabase — Business Ascension™
> Schémas de tables pour remplacer les pipelines markdown par une vraie base de données.
> À créer sur Supabase (free tier) — connecté aux agents et au bot Telegram.
> Version 1.0 — Mai 2026

---

## POURQUOI SUPABASE

Antoine Manco appelle ça la "Data Layer" — la couche qui transforme les agents d'outils ponctuels en système intelligent :
- Les KPIs ne sont plus dans des fichiers texte perdus — ils sont requêtables
- Les prospects ont une vraie historisation avec timestamps
- Les agents peuvent lire ET écrire en base — pas juste dans des markdowns
- Les dashboards peuvent être générés dynamiquement depuis les vraies données

---

## TABLE : `prospects`

```sql
CREATE TABLE prospects (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now(),

  -- Identité
  prenom        TEXT NOT NULL,
  source        TEXT CHECK (source IN (
                  'instagram', 'linkedin', 'youtube',
                  'bouche_a_oreille', 'formulaire'
                )),

  -- Pipeline
  date_entree   DATE NOT NULL DEFAULT CURRENT_DATE,
  statut        TEXT CHECK (statut IN (
                  'entrant', 'audit_booke', 'en_reflexion',
                  'relance_en_cours', 'signe', 'archive'
                )) DEFAULT 'entrant',

  -- Diagnostic
  goulot        TEXT CHECK (goulot IN (
                  'acquisition', 'conversion', 'delivery', 'inner'
                )),
  objection     TEXT CHECK (objection IN (
                  'prix', 'temps', 'engagement', 'legitimite', 'timing'
                )),

  -- Action
  prochaine_action TEXT,
  date_action   DATE,

  -- Archivage
  raison_archivage TEXT,
  potentiel_relance TEXT,

  -- Notes libres
  notes         TEXT
);

-- Trigger auto updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON prospects
FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

**Lecture rapide (agent ou bot Telegram) :**
```sql
-- Pipeline actif (tous sauf archivés)
SELECT prenom, source, statut, goulot, prochaine_action, date_action
FROM prospects
WHERE statut != 'archive'
ORDER BY date_action ASC;

-- Prospects en retard (action dépassée)
SELECT prenom, statut, date_action
FROM prospects
WHERE statut NOT IN ('signe', 'archive')
  AND date_action < CURRENT_DATE;
```

---

## TABLE : `content_pipeline`

```sql
CREATE TABLE content_pipeline (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at    TIMESTAMPTZ DEFAULT now(),

  -- Canal et type
  canal         TEXT CHECK (canal IN ('instagram', 'linkedin', 'youtube')),
  type_contenu  TEXT CHECK (type_contenu IN (
                  'reel', 'post', 'carousel', 'video', 'story'
                )),

  -- Contenu
  titre         TEXT NOT NULL,
  sujet         TEXT,
  angle         TEXT,
  cta           TEXT,

  -- Workflow
  statut        TEXT CHECK (statut IN (
                  'idee', 'brief', 'script', 'pret', 'publie'
                )) DEFAULT 'idee',
  date_prevue   DATE,
  date_publiee  DATE,

  -- Repurposing
  repurposing_prevu TEXT, -- ex: "→ LinkedIn post + YouTube short"
  source_repurposee TEXT  -- ex: "VA03" ou UUID du contenu source
);
```

**Lecture — vérification mix AEC :**
```sql
-- Mix du mois en cours pour Instagram
SELECT type_contenu, COUNT(*) as nb
FROM content_pipeline
WHERE canal = 'instagram'
  AND date_publiee >= date_trunc('month', CURRENT_DATE)
GROUP BY type_contenu;
```

---

## TABLE : `kpis_instagram`

```sql
CREATE TABLE kpis_instagram (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  semaine_du    DATE NOT NULL, -- lundi de la semaine mesurée

  -- Métriques canal (hebdo)
  reels_publies       INT DEFAULT 0,
  vues_totales        INT DEFAULT 0,
  abonnes_gagnes      INT DEFAULT 0,
  dm_recus            INT DEFAULT 0,
  audits_demandes     INT DEFAULT 0,
  taux_completion_moy DECIMAL(5,2),

  -- Lien contenu
  content_id    UUID REFERENCES content_pipeline(id),

  -- Métriques par Reel (si granularité nécessaire)
  reel_vues           INT,
  reel_completion     DECIMAL(5,2),
  reel_partages       INT,
  reel_dm_generes     INT
);
```

---

## TABLE : `kpis_linkedin`

```sql
CREATE TABLE kpis_linkedin (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  semaine_du    DATE NOT NULL,

  -- Métriques canal (hebdo)
  posts_publies        INT DEFAULT 0,
  impressions_totales  INT DEFAULT 0,
  nouveaux_followers   INT DEFAULT 0,
  dm_recus             INT DEFAULT 0,
  audits_demandes      INT DEFAULT 0,

  -- Lien contenu
  content_id    UUID REFERENCES content_pipeline(id),

  -- Métriques par post
  post_impressions  INT,
  post_reactions    INT,
  post_commentaires INT,
  post_partages     INT
);
```

---

## TABLE : `kpis_youtube`

```sql
CREATE TABLE kpis_youtube (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  semaine_du      DATE NOT NULL,

  -- Métriques canal (hebdo)
  videos_publiees     INT DEFAULT 0,
  vues_totales        INT DEFAULT 0,
  abonnes_gagnes      INT DEFAULT 0,
  watch_time_heures   DECIMAL(8,2),

  -- Lien contenu
  content_id    UUID REFERENCES content_pipeline(id),

  -- Métriques par vidéo
  video_vues          INT,
  video_retention     DECIMAL(5,2), -- % moyen vu
  video_ctr           DECIMAL(5,2), -- click-through rate thumbnail
  video_dm_generes    INT,
  video_audits_demandes INT
);
```

---

## ORDRE DE CRÉATION

```
1. prospects
2. content_pipeline
3. kpis_instagram
4. kpis_linkedin
5. kpis_youtube
```

Tables `kpis_*` référencent `content_pipeline` — créer `content_pipeline` en premier.

---

## CONNEXION PYTHON (agents VPS)

```python
from supabase import create_client
import os

url = os.environ["SUPABASE_URL"]
key = os.environ["SUPABASE_KEY"]
sb = create_client(url, key)

# Lire le pipeline prospects
prospects = sb.table("prospects") \
    .select("prenom, statut, prochaine_action, date_action") \
    .neq("statut", "archive") \
    .execute()

# Ajouter un prospect
sb.table("prospects").insert({
    "prenom": "Marie",
    "source": "instagram",
    "statut": "entrant",
    "goulot": "conversion",
    "prochaine_action": "DM de qualification",
    "date_action": "2026-05-28"
}).execute()
```

**Variables d'environnement requises sur le VPS :**
```bash
SUPABASE_URL=https://xxxxxxxxxxxx.supabase.co
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...  # anon key publique
```

---

*Business Ascension™ — Architecture Supabase — Mai 2026*
