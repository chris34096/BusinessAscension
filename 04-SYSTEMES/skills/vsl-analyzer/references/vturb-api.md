# VTurb Analytics API — Documentation
> Base URL : `https://analytics.vturb.net`
> Auth : Headers `X-Api-Token: <token>` + `X-Api-Version: v1`

---

## Authentification

**Générer une clé API :** https://app.vturb.com/settings/analytics-api

**Stocker le token (Windows) :**
```powershell
[System.Environment]::SetEnvironmentVariable("VTURB_API_TOKEN", "ta_cle_ici", "User")
```

**Headers obligatoires :**
```
X-Api-Token: <token>
X-Api-Version: v1
Content-Type: application/json
```

---

## ENDPOINT PRINCIPAL — POST /times/user_engagement

Rétention par seconde pour un player.

**Request body :**
```json
{ "player_id": "abc123def456", "video_duration": 900 }
```

**Response :**
```json
{
  "player_id": "abc123def456",
  "grouped_timed": [
    { "timed": 0,   "total_users": 1250 },
    { "timed": 1,   "total_users": 1248 },
    { "timed": 30,  "total_users": 980  },
    { "timed": 900, "total_users": 125  }
  ]
}
```

*`timed` = seconde, `total_users` = viewers absolus. Rétention % = `(total_users[t] / total_users[0]) * 100`.*

---

## SESSIONS

**GET /players/{id}/sessions** — Liste avec filtres `start_date`, `end_date`, `per_page`

**Response :**
```json
{
  "total": 1250,
  "data": [{
    "id": "sess_xyz",
    "watch_time_seconds": 342,
    "completion_rate": 0.38,
    "device_type": "mobile",
    "converted": false
  }]
}
```

**GET /players/{id}/sessions/{session_id}** — Détail : segments_watched, replays, events (pause, cta_shown)

---

## CONVERSIONS

**GET /players/{id}/conversions** — Params : `start_date`, `end_date`, `type` (cta_click|form_submit|all)

**GET /players/{id}/conversion_rate** — Taux agrégé + breakdown par device

**Response :**
```json
{
  "total_sessions": 1250,
  "total_conversions": 48,
  "conversion_rate": 0.038,
  "by_device": { "mobile": {"rate": 0.029}, "desktop": {"rate": 0.052} }
}
```

---

## CLICS

**GET /players/{id}/clicks** — Clics CTA avec `clicked_at_second` + distribution par seconde

**GET /players/{id}/click_heatmap** — Heatmap `{second, clicks, click_rate}` pour toute la vidéo

---

## TRAFIC

**GET /players/{id}/traffic** — Vues par `day|week|month` + sources (direct, social, email)

**GET /players/{id}/traffic_sources** — `[{source, views, percentage}]` trié par volume

---

## PLAYERS

**GET /players** — Liste tous les players du compte

**GET /players/{id}** — Détail : name, video_duration, status, embed_code

**GET /players/{id}/summary** — KPIs globaux : total_views, avg_watch_time, conversion_rate, half_life_second

---

## RÉTENTION AVANCÉE

**GET /players/{id}/retention_curve** — Courbe en % pré-calculée `{second, retention}` + half_life, quarter_life

**GET /players/{id}/drop_points** — Points de chute détectés `{second, drop_magnitude, severity}`

**GET /players/{id}/replay_segments** — Segments rejoués `{start_second, end_second, replay_count, replay_rate}`

---

## A/B TESTS

**GET /players/{id}/ab_tests** — Liste les tests (statut, variantes, conversion par variante)

**POST /players/{id}/ab_tests** — Créer un test avec variants `[{id, player_id, weight}]` et goal

**GET/PATCH/DELETE /players/{id}/ab_tests/{test_id}** — CRUD sur un test

---

## EXPORT

**POST /players/{id}/export** — Lancer export `{type: sessions, format: csv, start_date, end_date}`

**GET /exports/{id}** — Statut + `download_url` quand `status: ready`

**DELETE /exports/{id}** — Supprimer un export

---

## RÉSUMÉ — 23 ENDPOINTS

| # | Méthode | Endpoint |
|---|---------|----------|
| 1 | POST | /times/user_engagement ← principal |
| 2 | GET | /players |
| 3 | GET | /players/{id} |
| 4 | GET | /players/{id}/summary |
| 5 | GET | /players/{id}/sessions |
| 6 | GET | /players/{id}/sessions/{id} |
| 7 | GET | /players/{id}/conversions |
| 8 | GET | /players/{id}/conversion_rate |
| 9 | GET | /players/{id}/clicks |
| 10 | GET | /players/{id}/click_heatmap |
| 11 | GET | /players/{id}/traffic |
| 12 | GET | /players/{id}/traffic_sources |
| 13 | GET | /players/{id}/retention_curve |
| 14 | GET | /players/{id}/drop_points |
| 15 | GET | /players/{id}/replay_segments |
| 16 | GET | /players/{id}/ab_tests |
| 17 | POST | /players/{id}/ab_tests |
| 18 | GET | /players/{id}/ab_tests/{id} |
| 19 | PATCH | /players/{id}/ab_tests/{id} |
| 20 | DELETE | /players/{id}/ab_tests/{id} |
| 21 | POST | /players/{id}/export |
| 22 | GET | /exports/{id} |
| 23 | DELETE | /exports/{id} |

## CODES D'ERREUR

| Code | Signification |
|------|---------------|
| 200 | OK |
| 401 | Token absent ou invalide |
| 403 | Accès refusé à ce player |
| 404 | Player ou session introuvable |
| 429 | Rate limit — 60 req/min par token |
| 500 | Erreur serveur — réessayer après 30s |

---

*Business Ascension™ — Mai 2026*
