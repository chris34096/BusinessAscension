#!/usr/bin/env python3
"""
Agent Veille — Collecte de données concurrentielles
YouTube RSS feeds + Exa web search pour Instagram/LinkedIn.

Usage:
    python search_veille.py --output veille_data.json
    python search_veille.py --output veille_data.json --exa-key EXA_API_KEY

Exa API key (optionnel, pour Instagram/LinkedIn) :
    $env:EXA_API_KEY = "ta_cle"  # PowerShell User scope
"""

import argparse
import json
import os
import sys
from datetime import datetime, timedelta, timezone
from xml.etree import ElementTree as ET

try:
    import requests
except ImportError:
    print("ERROR: pip install requests", file=sys.stderr)
    sys.exit(1)

TODAY    = datetime.now(timezone.utc)
WEEK_AGO = TODAY - timedelta(days=7)

# =========================================================
# CONFIGURATION CONCURRENTS — YouTube Channel IDs
# Pour trouver un channel_id :
#   1. Aller sur la chaîne YouTube
#   2. Clic droit → Afficher le code source
#   3. Ctrl+F → chercher "channelId"
# =========================================================
YOUTUBE_CHANNELS = {
    # ── FR — Concurrents directs ───────────────────────────
    "Julien Musy":          "UCYs27SbvRP4eVc-J0gdjBLw",
    "Mehdi Baer":           "UCbxcxywbstwWjtvNqJ30NEw",
    "Matis Clouet":         "UCkB6qN-IeFNsBSj1aT7yZnQ",
    "Alec Henry":           "UCAl_C8ZlJ94HSt2ckrpMk1Q",
    "Max Piccinini":        "UCTeBtv6Jqe7dZ2UHq8NIaoA",
    "Thibault Didier":      "UC-7PojzK8y_gLGvPZROBPZw",
    "Julien Himself":       "UCaN4Pe5JEsWzAByY2WfxxjQ",
    "Marc MentalBoost":     "UCZ2seMKLYUlPa__cTEylGEw",
    "Franck Nicolas":       "UCOPYmqe_bNzjYErvNEGJ5og",
    "Jody Cavalie":         "UCwkaNM3G0zKfLEtI1XATrUw",
    "Pierre David / AHP":  "UCHmYA0ntftst4bKur9huEIg",
    "Chloe Lem":            "UCMuH8wuJsnCk3gRTGdiGIig",
    "Marvin Ndiaye":        "UChAzlWw8Ku9u37MXDU0Q5ew",
    "TheBBoost":            "UC5Yn4FOHIRuezaC55Dn1yTQ",
    "Christophe Dang":      "UC62o6R4h-WeUkmxAJKC0q3Q",
    "Fabien Delcourt":      "UCEM64Nzk8PeUXXXTZQpXNHw",
    # ── FR Thais Lior : pas de chaîne YouTube — couverte via Exa ──
    # ── Coaching / High-ticket ─────────────────────────────
    "Taki Moore":           "UCyJXKCVPnVftyHnpwElb9aw",
    "Jeremy Kohlmann":      "UCW2AZ_PmdOTJhLvxFVK4RNw",
    "Tanner Chidester":     "UCy5SXueIp6v0wqRDBtJEHbg",
    "Garrett J White":      "UCXlhifpNBwmPtgaX_ItEKZw",
    "Tom Pearson":          "UCBn6dw7ToEpVpoVXANCJXKg",
    "Max Tornow":           "UCqLhQ8t1MK8nkfWTrBh1wYA",
    # ── Références US / internationales ───────────────────
    "Sunny Lenarduzzi":     "UCnBTvMFhuvbE_dhw2mo0NaQ",
    "Ed Lawrence":          "UCb4XiEOeJulWu4WGhwnDqjw",
    "Kallaway":             "UCg5WjzrwxRRUUDf7WHKPzsA",
    "MoreMozi":             "UCrvchO1h6lWZAuGaa1LqX9Q",
    "Alex Hormozi":         "UCctXZhXmG-kf3tlIXgVZUlw",
    "Russell Brunson":      "UC2qUDKqTsz00csykCYgdLuA",
    "Dan Martell":          "UCA-mWX9CvCTVFWRMb9bKc9w",
    "Lewis Howes":          "UCKsP3v2JeT2hWI_HzkxWiMA",
    "Myron Golden":         "UCbaQv8_DS1n8puOnJRzLPzw",
    "Tony Robbins":         "UCJLMboBYME_CLEfwsduI0wQ",
    "Ed Mylett":            "UCIprSPNQOPjALH4P3oIbOhw",
    "Brendon Burchard":     "UCpK8HYcwEJMFaYPFVBWRB4w",
}

# Requêtes Exa pour Instagram/LinkedIn (nécessite clé API)
EXA_QUERIES = [
    'site:instagram.com "Julien Musy" OR "Mehdi Baer" coaching entrepreneur',
    'site:linkedin.com "Julien Musy" OR "Mehdi Baer" coaching entrepreneur semaine',
    '"coaching business" entrepreneur france 2026 programme mindset',
    'entrepreneur france "plafond de verre" OR "vendre son temps" coach scale 2026',
    'solopreneur france "vivoter" OR "décoller" leads entrants vendre par message 2026',
]


def fetch_youtube_rss(channel_id: str, channel_name: str) -> list:
    if not channel_id:
        return []
    url = f"https://www.youtube.com/feeds/videos.xml?channel_id={channel_id}"
    try:
        resp = requests.get(url, timeout=10)
        if resp.status_code != 200:
            return []
        root = ET.fromstring(resp.content)
        ns = {
            'atom':  'http://www.w3.org/2005/Atom',
            'media': 'http://search.yahoo.com/mrss/',
        }
        items = []
        for entry in root.findall('atom:entry', ns)[:5]:
            pub_str = entry.findtext('atom:published', default='', namespaces=ns)
            try:
                pub = datetime.fromisoformat(pub_str.replace('Z', '+00:00'))
            except Exception:
                continue
            if pub < WEEK_AGO:
                continue
            title = entry.findtext('atom:title', default='', namespaces=ns)
            link  = entry.find('atom:link', ns)
            url_v = link.get('href', '') if link is not None else ''
            desc  = entry.findtext('media:group/media:description', default='', namespaces=ns) or ''
            items.append({
                'title':     title,
                'url':       url_v,
                'published': pub.strftime('%Y-%m-%d'),
                'platform':  'youtube',
                'snippet':   desc[:300],
            })
        return items
    except Exception as e:
        print(f"WARNING: YouTube RSS {channel_name}: {e}", file=sys.stderr)
        return []


def fetch_exa(query: str, exa_key: str, num: int = 5) -> list:
    url     = "https://api.exa.ai/search"
    headers = {"x-api-key": exa_key, "Content-Type": "application/json"}
    payload = {
        "query": query,
        "numResults": num,
        "startPublishedDate": WEEK_AGO.strftime("%Y-%m-%dT%H:%M:%SZ"),
        "contents": {"text": {"maxCharacters": 400}},
    }
    try:
        resp = requests.post(url, headers=headers, json=payload, timeout=15)
        if resp.status_code != 200:
            return []
        return [{
            'title':     r.get('title', ''),
            'url':       r.get('url', ''),
            'published': (r.get('publishedDate') or '')[:10],
            'platform':  'web/social',
            'snippet':   (r.get('text') or '')[:400],
        } for r in resp.json().get('results', [])]
    except Exception as e:
        print(f"WARNING: Exa '{query[:40]}...': {e}", file=sys.stderr)
        return []


def main():
    parser = argparse.ArgumentParser(description='Collecte veille concurrentielle BA™')
    parser.add_argument('--output', '-o', default='veille_data.json')
    parser.add_argument('--exa-key', default=os.environ.get('EXA_API_KEY', ''))
    args = parser.parse_args()

    print(f"\n=== COLLECTE VEILLE — {TODAY.strftime('%Y-%m-%d')} ===")

    competitors = []

    # YouTube — flux RSS publics (aucune clé nécessaire)
    configured = {k: v for k, v in YOUTUBE_CHANNELS.items() if v}
    missing    = [k for k, v in YOUTUBE_CHANNELS.items() if not v]
    for name, cid in configured.items():
        items = fetch_youtube_rss(cid, name)
        if items:
            competitors.append({'name': name, 'platform': 'youtube', 'items': items})
            print(f"  YouTube {name}: {len(items)} vidéo(s)")

    # Instagram + LinkedIn via Exa (optionnel)
    if args.exa_key:
        exa_items = []
        for q in EXA_QUERIES:
            exa_items.extend(fetch_exa(q, args.exa_key))
        if exa_items:
            competitors.append({
                'name': 'Instagram + LinkedIn + Web (Exa)',
                'platform': 'instagram+linkedin+web',
                'items': exa_items,
            })
            print(f"  Exa: {len(exa_items)} résultats")
    else:
        print("  INFO: EXA_API_KEY non configurée → Instagram/LinkedIn ignorés")
        print("        Pour activer : $env:EXA_API_KEY = 'ta_cle'  (powershell)")

    result = {
        'date':   TODAY.strftime('%Y-%m-%d'),
        'period': {'start': WEEK_AGO.strftime('%Y-%m-%d'), 'end': TODAY.strftime('%Y-%m-%d')},
        'competitors': competitors,
        'collection_notes': {
            'youtube_configured': len(configured),
            'youtube_missing_ids': missing,
            'exa_enabled': bool(args.exa_key),
            'total_items': sum(len(c['items']) for c in competitors),
        }
    }

    with open(args.output, 'w', encoding='utf-8') as f:
        json.dump(result, f, indent=2, ensure_ascii=False)

    print(f"  Total : {result['collection_notes']['total_items']} éléments → {args.output}")

    if missing:
        print(f"\n  Canaux YouTube à configurer dans search_veille.py :")
        for m in missing:
            print(f"    - {m}")


if __name__ == '__main__':
    main()
