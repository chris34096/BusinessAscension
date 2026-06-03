#!/usr/bin/env python3
"""
VTurb Analytics API Client
Fetches retention, sessions, conversions, clicks, and traffic data from VTurb.

Usage:
    python vturb_api.py --token TOKEN --player-id PLAYER_ID retention --format csv --video-duration 900
    python vturb_api.py --token TOKEN --player-id PLAYER_ID sessions --days 30
    python vturb_api.py --token TOKEN --player-id PLAYER_ID conversions --days 30

Token via env var (recommended):
    $env:VTURB_API_TOKEN = "your_token"   # PowerShell
    export VTURB_API_TOKEN="your_token"   # Bash
"""

import argparse
import csv
import json
import os
import sys
from datetime import datetime, timedelta

try:
    import requests
except ImportError:
    print("ERROR: requests not installed. Run: pip install requests", file=sys.stderr)
    sys.exit(1)

BASE_URL = "https://analytics.vturb.net"
API_VERSION = "v1"


def get_headers(token: str) -> dict:
    return {
        "X-Api-Token": token,
        "X-Api-Version": API_VERSION,
        "Content-Type": "application/json",
        "Accept": "application/json",
    }


def date_range(days: int) -> tuple:
    end = datetime.utcnow()
    start = end - timedelta(days=days)
    return start.strftime("%Y-%m-%d"), end.strftime("%Y-%m-%d")


def fetch_retention(token: str, player_id: str, video_duration: int, output_format: str, output_file: str):
    url = f"{BASE_URL}/times/user_engagement"
    payload = {"player_id": player_id, "video_duration": video_duration}
    print(f"Fetching retention data for player {player_id} (duration={video_duration}s)...")
    resp = requests.post(url, headers=get_headers(token), json=payload, timeout=30)

    if resp.status_code != 200:
        print(f"ERROR {resp.status_code}: {resp.text}", file=sys.stderr)
        sys.exit(1)

    grouped = resp.json().get("grouped_timed", [])
    if not grouped:
        print("WARNING: No retention data returned", file=sys.stderr)
        sys.exit(1)

    max_viewers = grouped[0].get("total_users", 1) if grouped else 1
    points = []
    for item in sorted(grouped, key=lambda x: x.get("timed", 0)):
        second = item.get("timed", 0)
        viewers = item.get("total_users", 0)
        retention = round(viewers / max(1, max_viewers) * 100, 2)
        mm = second // 60
        ss = second % 60
        points.append({
            "timestamp": f"{mm:02d}:{ss:02d}",
            "retention_pct": retention,
            "audience": viewers,
        })

    if output_format == "csv":
        with open(output_file, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=["timestamp", "retention_pct", "audience"])
            writer.writeheader()
            writer.writerows(points)
        print(f"Retention CSV saved: {output_file} ({len(points)} data points)")
    else:
        with open(output_file, "w", encoding="utf-8") as f:
            json.dump({"player_id": player_id, "data": points}, f, indent=2, ensure_ascii=False)
        print(f"Retention JSON saved: {output_file} ({len(points)} data points)")

    return points


def fetch_sessions(token: str, player_id: str, days: int, output_file: str):
    start_date, end_date = date_range(days)
    url = f"{BASE_URL}/players/{player_id}/sessions"
    params = {"start_date": start_date, "end_date": end_date, "per_page": 100}
    print(f"Fetching sessions ({start_date} → {end_date})...")
    resp = requests.get(url, headers=get_headers(token), params=params, timeout=30)
    if resp.status_code != 200:
        print(f"ERROR {resp.status_code}: {resp.text}", file=sys.stderr)
        sys.exit(1)
    data = resp.json()
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    print(f"Sessions saved: {output_file}")
    return data


def fetch_conversions(token: str, player_id: str, days: int, output_file: str):
    start_date, end_date = date_range(days)
    url = f"{BASE_URL}/players/{player_id}/conversions"
    params = {"start_date": start_date, "end_date": end_date}
    print(f"Fetching conversions ({start_date} → {end_date})...")
    resp = requests.get(url, headers=get_headers(token), params=params, timeout=30)
    if resp.status_code != 200:
        print(f"ERROR {resp.status_code}: {resp.text}", file=sys.stderr)
        sys.exit(1)
    data = resp.json()
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    print(f"Conversions saved: {output_file}")
    return data


def fetch_clicks(token: str, player_id: str, days: int, output_file: str):
    start_date, end_date = date_range(days)
    url = f"{BASE_URL}/players/{player_id}/clicks"
    params = {"start_date": start_date, "end_date": end_date}
    print(f"Fetching clicks ({start_date} → {end_date})...")
    resp = requests.get(url, headers=get_headers(token), params=params, timeout=30)
    if resp.status_code != 200:
        print(f"ERROR {resp.status_code}: {resp.text}", file=sys.stderr)
        sys.exit(1)
    data = resp.json()
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    print(f"Clicks saved: {output_file}")
    return data


def fetch_traffic(token: str, player_id: str, days: int, output_file: str):
    start_date, end_date = date_range(days)
    url = f"{BASE_URL}/players/{player_id}/traffic"
    params = {"start_date": start_date, "end_date": end_date, "group_by": "day"}
    print(f"Fetching traffic ({start_date} → {end_date})...")
    resp = requests.get(url, headers=get_headers(token), params=params, timeout=30)
    if resp.status_code != 200:
        print(f"ERROR {resp.status_code}: {resp.text}", file=sys.stderr)
        sys.exit(1)
    data = resp.json()
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    print(f"Traffic saved: {output_file}")
    return data


def test_connection(token: str):
    url = f"{BASE_URL}/players"
    print("Testing VTurb API connection...")
    resp = requests.get(url, headers=get_headers(token), timeout=10)
    if resp.status_code == 200:
        data = resp.json()
        count = len(data) if isinstance(data, list) else data.get("total", "?")
        print(f"OK — Connected. Players: {count}")
    else:
        print(f"FAIL — {resp.status_code}: {resp.text}", file=sys.stderr)
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(description='VTurb Analytics API Client')
    parser.add_argument('--token', '-t', default=os.environ.get('VTURB_API_TOKEN'),
                        help='API token (or set VTURB_API_TOKEN env var)')
    parser.add_argument('--player-id', '-p', help='VTurb Player ID')
    parser.add_argument('--output', '-o', help='Output file (auto-named if omitted)')
    parser.add_argument('--format', '-f', default='csv', choices=['csv', 'json'])
    parser.add_argument('--days', '-d', type=int, default=30)

    sub = parser.add_subparsers(dest='command')
    ret_p = sub.add_parser('retention')
    ret_p.add_argument('--video-duration', '-D', type=int, required=True)
    sub.add_parser('sessions')
    sub.add_parser('conversions')
    sub.add_parser('clicks')
    sub.add_parser('traffic')
    sub.add_parser('test')

    args = parser.parse_args()

    if not args.token:
        print("ERROR: No API token. Set VTURB_API_TOKEN or use --token", file=sys.stderr)
        sys.exit(1)

    if args.command == 'test':
        test_connection(args.token)
        return

    if not args.player_id:
        print("ERROR: --player-id required", file=sys.stderr)
        sys.exit(1)

    fmt = getattr(args, 'format', 'csv')
    ext = 'csv' if fmt == 'csv' else 'json'

    if args.command == 'retention':
        out = args.output or f"vturb_data_retention.{ext}"
        fetch_retention(args.token, args.player_id, args.video_duration, fmt, out)
    elif args.command == 'sessions':
        fetch_sessions(args.token, args.player_id, args.days, args.output or "vturb_data_sessions.json")
    elif args.command == 'conversions':
        fetch_conversions(args.token, args.player_id, args.days, args.output or "vturb_data_conversions.json")
    elif args.command == 'clicks':
        fetch_clicks(args.token, args.player_id, args.days, args.output or "vturb_data_clicks.json")
    elif args.command == 'traffic':
        fetch_traffic(args.token, args.player_id, args.days, args.output or "vturb_data_traffic.json")
    else:
        parser.print_help()


if __name__ == '__main__':
    main()
