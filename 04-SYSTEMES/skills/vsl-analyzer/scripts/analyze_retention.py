#!/usr/bin/env python3
"""
VSL Retention Analyzer
Parses VTurb retention data (CSV or JSON) and identifies significant drop-off points.

Usage:
    python analyze_retention.py <input_file> [--output <output.json>] [--threshold 3.0] [--window 15]
"""

import csv
import json
import sys
import argparse
from pathlib import Path


def parse_csv(filepath):
    data_points = []
    with open(filepath, 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        headers = reader.fieldnames
        time_col = retention_col = audience_col = None

        for h in headers:
            h_lower = h.lower().strip()
            if any(k in h_lower for k in ['time', 'second', 'timestamp', 'tempo', 'segundo']):
                time_col = h
            elif any(k in h_lower for k in ['retention', 'retencao', '%']):
                retention_col = h
            elif any(k in h_lower for k in ['audience', 'viewers', 'espectadores', 'count']):
                audience_col = h

        if not time_col and len(headers) >= 1: time_col = headers[0]
        if not retention_col and len(headers) >= 2: retention_col = headers[1]
        if not audience_col and len(headers) >= 3: audience_col = headers[2]

        for row in reader:
            try:
                time_val = row.get(time_col, '0')
                if ':' in str(time_val):
                    parts = str(time_val).split(':')
                    seconds = int(parts[0]) * 60 + int(parts[1])
                else:
                    seconds = int(float(time_val))
                retention_pct = float(str(row.get(retention_col, '0')).replace('%', '').replace(',', '.').strip())
                audience_val = 0
                if audience_col and row.get(audience_col):
                    audience_val = int(float(str(row.get(audience_col, '0')).replace(',', '').strip()))
                data_points.append({
                    'seconds': seconds,
                    'timestamp': f"{seconds // 60:02d}:{seconds % 60:02d}",
                    'retention_pct': retention_pct,
                    'audience': audience_val
                })
            except (ValueError, TypeError):
                continue
    return sorted(data_points, key=lambda x: x['seconds'])


def parse_json(filepath):
    with open(filepath, 'r') as f:
        data = json.load(f)
    if isinstance(data, list): return data
    elif isinstance(data, dict) and 'data' in data: return data['data']
    return data


def identify_drops(data_points, threshold=3.0, window=15):
    drops = []
    for i, point in enumerate(data_points):
        for j in range(i + 1, len(data_points)):
            if data_points[j]['seconds'] - point['seconds'] > window: break
            drop_magnitude = point['retention_pct'] - data_points[j]['retention_pct']
            if drop_magnitude >= threshold:
                drops.append({
                    'start_seconds': point['seconds'],
                    'start_timestamp': point['timestamp'],
                    'end_seconds': data_points[j]['seconds'],
                    'end_timestamp': data_points[j]['timestamp'],
                    'start_retention': round(point['retention_pct'], 2),
                    'end_retention': round(data_points[j]['retention_pct'], 2),
                    'drop_magnitude': round(drop_magnitude, 2),
                    'drop_rate_per_second': round(drop_magnitude / max(1, data_points[j]['seconds'] - point['seconds']), 3)
                })
                break
    filtered_drops = []
    for drop in sorted(drops, key=lambda x: x['drop_magnitude'], reverse=True):
        overlaps = any(
            drop['start_seconds'] < ex['end_seconds'] and drop['end_seconds'] > ex['start_seconds']
            for ex in filtered_drops
        )
        if not overlaps: filtered_drops.append(drop)
    return sorted(filtered_drops, key=lambda x: x['start_seconds'])


def classify_curve(data_points):
    if len(data_points) < 5: return "insufficient_data"
    total = data_points[-1]['seconds']
    def avg(pts): return sum(p['retention_pct'] for p in pts) / len(pts) if pts else 0
    q1 = avg([p for p in data_points if p['seconds'] <= total * 0.25])
    q2 = avg([p for p in data_points if total * 0.25 < p['seconds'] <= total * 0.5])
    q3 = avg([p for p in data_points if total * 0.5  < p['seconds'] <= total * 0.75])
    q4 = avg([p for p in data_points if p['seconds'] > total * 0.75])
    if data_points[0]['retention_pct'] - q1 > 20: return "early_cliff"
    if q1 > q2 > q3 > q4 and (q1 - q4) < 40: return "gradual_decline"
    if q1 - q2 > 15: return "strong_start_then_cliff"
    if abs(q1 - q2) < 5 and (q2 - q3) > 15: return "plateau_then_drop"
    if q4 > 40: return "strong_engagement"
    return "mixed_pattern"


def compute_metrics(data_points):
    if not data_points: return {}
    retentions = [p['retention_pct'] for p in data_points]
    half_life = next((p['seconds'] for p in data_points if p['retention_pct'] <= 50), None)
    quarter_life = next((p['seconds'] for p in data_points if p['retention_pct'] <= 25), None)
    return {
        'total_duration_seconds': data_points[-1]['seconds'],
        'total_duration_formatted': data_points[-1].get('timestamp', f"{data_points[-1]['seconds'] // 60:02d}:{data_points[-1]['seconds'] % 60:02d}"),
        'initial_retention': round(retentions[0], 2),
        'final_retention': round(retentions[-1], 2),
        'average_retention': round(sum(retentions) / len(retentions), 2),
        'median_retention': round(sorted(retentions)[len(retentions) // 2], 2),
        'half_life_seconds': half_life,
        'half_life_formatted': f"{half_life // 60:02d}:{half_life % 60:02d}" if half_life else None,
        'quarter_life_seconds': quarter_life,
        'completion_rate': round(retentions[-1], 2),
    }


def assign_priority(drop, total_duration):
    pos = drop['start_seconds'] / max(1, total_duration)
    weight = 1.5 if pos < 0.15 else (1.2 if pos < 0.3 else 1.0)
    score = drop['drop_magnitude'] * weight
    return 'HIGH' if score >= 10 else ('MEDIUM' if score >= 5 else 'LOW')


def analyze(filepath, threshold=3.0, window=15):
    ext = Path(filepath).suffix.lower()
    data_points = parse_csv(filepath) if ext == '.csv' else parse_json(filepath)
    if not data_points:
        print("No data points found.", file=sys.stderr); sys.exit(1)

    drops = identify_drops(data_points, threshold, window)
    metrics = compute_metrics(data_points)
    for drop in drops:
        drop['priority'] = assign_priority(drop, metrics.get('total_duration_seconds', 1))

    curve_type = classify_curve(data_points)
    descriptions = {
        'early_cliff': "Sharp drop in the first quarter — the opening hook isn't holding viewers",
        'gradual_decline': "Steady loss — content isn't boring but lacks re-engagement hooks",
        'strong_start_then_cliff': "Good hook but viewers leave quickly after — transition is weak",
        'plateau_then_drop': "Strong first half but viewers disengage mid-way",
        'strong_engagement': "Above-average retention throughout",
        'mixed_pattern': "Irregular pattern with multiple spikes and drops",
        'insufficient_data': "Not enough data points for reliable classification"
    }
    return {
        'metrics': metrics,
        'curve_type': curve_type,
        'curve_description': descriptions.get(curve_type, "Unknown"),
        'significant_drops': drops,
        'data_points': data_points,
        'analysis_params': {'threshold': threshold, 'window': window, 'total_data_points': len(data_points)}
    }


def main():
    parser = argparse.ArgumentParser(description='Analyze VSL retention data from VTurb')
    parser.add_argument('input_file')
    parser.add_argument('--output', '-o', default='retention_analysis.json')
    parser.add_argument('--threshold', '-t', type=float, default=3.0)
    parser.add_argument('--window', '-w', type=int, default=15)
    args = parser.parse_args()

    result = analyze(args.input_file, args.threshold, args.window)
    with open(args.output, 'w', encoding='utf-8') as f:
        json.dump(result, f, indent=2, ensure_ascii=False)

    print(f"\n{'='*60}\nVSL RETENTION ANALYSIS\n{'='*60}")
    print(f"Duration: {result['metrics']['total_duration_formatted']}")
    print(f"Average retention: {result['metrics']['average_retention']}%")
    print(f"Curve: {result['curve_type']} — {result['curve_description']}")
    print(f"Significant drops: {len(result['significant_drops'])}")
    for i, d in enumerate(result['significant_drops'], 1):
        print(f"  [{d['priority']}] #{i}: {d['start_timestamp']} -> {d['end_timestamp']} (-{d['drop_magnitude']}%)")
    print(f"\nSaved to: {args.output}")


if __name__ == '__main__':
    main()
