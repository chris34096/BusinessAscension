#!/usr/bin/env python3
"""
VSL Transcriber — Whisper-based local transcription
Generates .srt, _stamped.txt (timestamped), and _plain.txt outputs.

Usage:
    python transcribe_vsl.py --input video.mp4 --output transcript --language fr --model medium
    python transcribe_vsl.py --drive-url "https://drive.google.com/..." --output transcript --language fr
"""

import argparse
import os
import re
import sys
import tempfile
from pathlib import Path


def download_from_drive(url: str, dest_path: str) -> str:
    try:
        import gdown
    except ImportError:
        print("ERROR: gdown not installed. Run: pip install gdown", file=sys.stderr)
        sys.exit(1)

    file_id = None
    patterns = [
        r'/file/d/([a-zA-Z0-9_-]+)',
        r'id=([a-zA-Z0-9_-]+)',
        r'/d/([a-zA-Z0-9_-]+)',
    ]
    for p in patterns:
        m = re.search(p, url)
        if m:
            file_id = m.group(1)
            break

    if not file_id:
        print(f"ERROR: Cannot extract file ID from URL: {url}", file=sys.stderr)
        sys.exit(1)

    download_url = f"https://drive.google.com/uc?id={file_id}"
    print(f"Downloading from Google Drive (id={file_id})...")
    gdown.download(download_url, dest_path, quiet=False)
    return dest_path


def transcribe(video_path: str, model_name: str, language: str):
    try:
        import whisper
    except ImportError:
        print("ERROR: openai-whisper not installed. Run: pip install openai-whisper", file=sys.stderr)
        sys.exit(1)

    print(f"Loading Whisper model '{model_name}'...")
    model = whisper.load_model(model_name)
    print(f"Transcribing '{video_path}' (language={language})...")
    result = model.transcribe(video_path, language=language, verbose=False)
    return result


def format_srt_time(seconds: float) -> str:
    ms = int((seconds % 1) * 1000)
    s = int(seconds) % 60
    m = int(seconds) // 60 % 60
    h = int(seconds) // 3600
    return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"


def write_srt(segments, output_path: str):
    lines = []
    for i, seg in enumerate(segments, 1):
        start = format_srt_time(seg['start'])
        end = format_srt_time(seg['end'])
        text = seg['text'].strip()
        lines.append(f"{i}\n{start} --> {end}\n{text}\n")
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    print(f"SRT written: {output_path}")


def write_stamped(segments, output_path: str):
    lines = []
    for seg in segments:
        start_s = int(seg['start'])
        mm = start_s // 60
        ss = start_s % 60
        text = seg['text'].strip()
        lines.append(f"[{mm:02d}:{ss:02d}] {text}")
        lines.append("")
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    print(f"Stamped written: {output_path}")


def write_plain(segments, output_path: str):
    paragraphs = []
    current = []
    last_end = 0
    for seg in segments:
        gap = seg['start'] - last_end
        if gap > 2.0 and current:
            paragraphs.append(' '.join(current))
            current = []
        current.append(seg['text'].strip())
        last_end = seg['end']
    if current:
        paragraphs.append(' '.join(current))
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write('\n\n'.join(paragraphs))
    print(f"Plain written: {output_path}")


def main():
    parser = argparse.ArgumentParser(description='Transcribe VSL with Whisper')
    parser.add_argument('--input', '-i', help='Local video/audio file path')
    parser.add_argument('--drive-url', help='Google Drive URL to download video from')
    parser.add_argument('--output', '-o', default='transcript', help='Output base name (no extension)')
    parser.add_argument('--model', '-m', default='medium', choices=['tiny', 'base', 'small', 'medium', 'large'])
    parser.add_argument('--language', '-l', default='fr', help='Language code (fr, en, pt, es...)')
    args = parser.parse_args()

    if not args.input and not args.drive_url:
        print("ERROR: Provide --input or --drive-url", file=sys.stderr)
        sys.exit(1)

    video_path = args.input

    if args.drive_url:
        ext = '.mp4'
        tmp = tempfile.NamedTemporaryFile(suffix=ext, delete=False)
        tmp.close()
        video_path = tmp.name
        download_from_drive(args.drive_url, video_path)

    if not os.path.exists(video_path):
        print(f"ERROR: File not found: {video_path}", file=sys.stderr)
        sys.exit(1)

    result = transcribe(video_path, args.model, args.language)
    segments = result.get('segments', [])

    if not segments:
        print("ERROR: No segments returned by Whisper", file=sys.stderr)
        sys.exit(1)

    duration = segments[-1]['end']
    print(f"\nTranscription complete — {len(segments)} segments, duration: {int(duration)//60:02d}:{int(duration)%60:02d}")

    base = args.output
    write_srt(segments, f"{base}.srt")
    write_stamped(segments, f"{base}_stamped.txt")
    write_plain(segments, f"{base}_plain.txt")

    if args.drive_url and video_path != args.input:
        os.unlink(video_path)

    print(f"\nDone. Files: {base}.srt | {base}_stamped.txt | {base}_plain.txt")


if __name__ == '__main__':
    main()
