#!/usr/bin/env python3
"""
Transcript-Retention Correlator
Maps retention drops to specific transcript sections for targeted analysis.

Usage:
    python correlate_transcript.py <retention_analysis.json> <transcript_file> [--output <output.json>] [--language fr]
"""

import json
import re
import argparse

SPEAKING_PACE = {'fr': 150, 'en': 160, 'pt': 155, 'es': 155}


def parse_srt(content):
    segments = []
    blocks = re.split(r'\n\n+', content.strip())
    for block in blocks:
        lines = block.strip().split('\n')
        if len(lines) < 3: continue
        time_match = re.match(
            r'(\d{1,2}):(\d{2}):(\d{2})[,.](\d{3})\s*-->\s*(\d{1,2}):(\d{2}):(\d{2})[,.](\d{3})',
            lines[1].strip()
        )
        if not time_match: continue
        start_secs = int(time_match.group(1)) * 3600 + int(time_match.group(2)) * 60 + int(time_match.group(3))
        end_secs   = int(time_match.group(5)) * 3600 + int(time_match.group(6)) * 60 + int(time_match.group(7))
        text = re.sub(r'<[^>]+>', '', ' '.join(lines[2:]).strip())
        segments.append({'start_seconds': start_secs, 'end_seconds': end_secs,
                         'start_timestamp': f"{start_secs // 60:02d}:{start_secs % 60:02d}",
                         'text': text, 'word_count': len(text.split())})
    return segments


def parse_timestamped_text(content):
    segments = []
    pattern = r'[\[\(]?(\d{1,2}:\d{2}(?::\d{2})?)[\]\)]?\s*[-—:]?\s*(.+?)(?=[\[\(]?\d{1,2}:\d{2}(?::\d{2})?[\]\)]?|\Z)'
    matches = re.findall(pattern, content, re.DOTALL)
    for i, (ts, text) in enumerate(matches):
        parts = ts.split(':')
        secs = int(parts[0]) * 3600 + int(parts[1]) * 60 + int(parts[2]) if len(parts) == 3 else int(parts[0]) * 60 + int(parts[1])
        text = text.strip()
        next_secs = None
        if i + 1 < len(matches):
            np = matches[i + 1][0].split(':')
            next_secs = int(np[0]) * 3600 + int(np[1]) * 60 + int(np[2]) if len(np) == 3 else int(np[0]) * 60 + int(np[1])
        segments.append({'start_seconds': secs, 'end_seconds': next_secs or secs + 30,
                         'start_timestamp': f"{secs // 60:02d}:{secs % 60:02d}",
                         'text': text, 'word_count': len(text.split())})
    return segments


def parse_plain_text(content, total_duration, language='fr'):
    paragraphs = [p.strip() for p in re.split(r'\n\n+', content) if p.strip()]
    if len(paragraphs) < 5:
        sentences = re.split(r'(?<=[.!?])\s+', content)
        paragraphs = [' '.join(sentences[i:i+3]).strip() for i in range(0, len(sentences), 3) if ' '.join(sentences[i:i+3]).strip()]
    total_words = sum(len(p.split()) for p in paragraphs)
    spw = total_duration / max(1, total_words)
    segments = []
    cur = 0
    for para in paragraphs:
        wc = len(para.split())
        start = int(cur)
        end = int(cur + wc * spw)
        segments.append({'start_seconds': start, 'end_seconds': end,
                         'start_timestamp': f"{start // 60:02d}:{start % 60:02d}",
                         'text': para, 'word_count': wc})
        cur += wc * spw
    return segments


def detect_format(content):
    if re.search(r'\d+\s*\n\d{1,2}:\d{2}:\d{2}[,.]\d{3}\s*-->', content): return 'srt'
    if re.search(r'[\[\(]\d{1,2}:\d{2}[\]\)]', content): return 'timestamped'
    if re.search(r'\d{1,2}:\d{2}\s*[-—:]', content): return 'timestamped'
    return 'plain'


def classify_section(start_seconds, total_duration):
    ratio = start_seconds / max(1, total_duration)
    if ratio < 0.025: return 'opening_hook'
    if ratio < 0.1:   return 'problem_identification'
    if ratio < 0.25:  return 'story_credibility'
    if ratio < 0.45:  return 'solution_reveal'
    if ratio < 0.65:  return 'benefits_features'
    if ratio < 0.8:   return 'objection_handling'
    return 'call_to_action'


SECTION_NAMES = {
    'opening_hook': 'Accroche / Hook',
    'problem_identification': 'Identification du problème',
    'story_credibility': 'Histoire / Crédibilité',
    'solution_reveal': 'Révélation de la solution',
    'benefits_features': 'Bénéfices & Fonctionnalités',
    'objection_handling': 'Traitement des objections',
    'call_to_action': "Appel à l'action / CTA"
}


def correlate(retention_analysis, segments, total_duration):
    drops = retention_analysis.get('significant_drops', [])
    correlations = []
    for drop in drops:
        matching = [s for s in segments if s['start_seconds'] < drop['end_seconds'] and s.get('end_seconds', s['start_seconds'] + 30) > drop['start_seconds']]
        ctx_before = ctx_after = None
        if matching:
            fi = segments.index(matching[0])
            li = segments.index(matching[-1])
            if fi > 0: ctx_before = segments[fi - 1]['text']
            if li < len(segments) - 1: ctx_after = segments[li + 1]['text']
        st = classify_section(drop['start_seconds'], total_duration)
        correlations.append({'drop': drop, 'vsl_section': st, 'vsl_section_name': SECTION_NAMES.get(st, st),
                             'transcript_at_drop': [s['text'] for s in matching],
                             'full_segments': matching, 'context_before': ctx_before, 'context_after': ctx_after})
    return correlations


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('retention_file')
    parser.add_argument('transcript_file')
    parser.add_argument('--output', '-o', default='correlation_analysis.json')
    parser.add_argument('--language', '-l', default='fr', choices=['fr', 'en', 'pt', 'es'])
    args = parser.parse_args()

    with open(args.retention_file, 'r') as f:
        retention = json.load(f)
    with open(args.transcript_file, 'r', encoding='utf-8') as f:
        content = f.read()

    total = retention['metrics']['total_duration_seconds']
    fmt = detect_format(content)
    if fmt == 'srt': segments = parse_srt(content)
    elif fmt == 'timestamped': segments = parse_timestamped_text(content)
    else: segments = parse_plain_text(content, total, args.language)

    for seg in segments:
        seg['vsl_section'] = classify_section(seg['start_seconds'], total)
        seg['vsl_section_name'] = SECTION_NAMES.get(seg['vsl_section'], seg['vsl_section'])

    correlations = correlate(retention, segments, total)
    result = {
        'transcript_format_detected': fmt, 'language': args.language,
        'total_segments': len(segments), 'segments': segments, 'correlations': correlations,
        'summary': {
            'total_drops_analyzed': len(correlations),
            'sections_affected': list(set(c['vsl_section'] for c in correlations)),
            'most_critical_section': max(correlations, key=lambda c: c['drop']['drop_magnitude'])['vsl_section_name'] if correlations else None
        }
    }

    with open(args.output, 'w', encoding='utf-8') as f:
        json.dump(result, f, indent=2, ensure_ascii=False)

    print(f"\n{'='*50}\nCORRELATION TRANSCRIPT-RETENTION\n{'='*50}")
    print(f"Format: {fmt} | Segments: {len(segments)} | Drops: {len(correlations)}")
    for i, c in enumerate(correlations, 1):
        d = c['drop']
        print(f"\n[{d['priority']}] Drop #{i} @ {d['start_timestamp']} — {c['vsl_section_name']}")
        print(f"  Retention: {d['start_retention']}% -> {d['end_retention']}%")
        for text in c['transcript_at_drop'][:1]:
            print(f"  \"{text[:100]}{'...' if len(text) > 100 else ''}\"")
    print(f"\nSaved: {args.output}")


if __name__ == '__main__':
    main()
