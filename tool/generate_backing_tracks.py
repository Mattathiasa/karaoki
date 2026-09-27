#!/usr/bin/env python3
"""Generate synthesized backing tracks for the fixture songs.

Each song gets a short Ogg Vorbis backing track derived from its own
`NoteTrack` (lib/models/note_track.dart) so the audible guide melody matches
the exact frequencies the pitch scorer expects. The track is a simple
chord-pad + guide-melody arrangement with a metronome tick — royalty-free by
construction because it is synthesized here and checked into the repo.

Duration matches each song's declared `duration` in lib/models/song.dart so
the LRC percentages and the audio timeline agree.

Usage:
    uv venv /tmp/audioenv && uv pip install numpy
    /tmp/audioenv/bin/python tool/generate_backing_tracks.py

Requires ffmpeg on PATH (for Ogg encoding). If ffmpeg is missing the script
falls back to writing raw WAV files instead.
"""
from __future__ import annotations

import json
import math
import os
import shutil
import subprocess
import sys
import wave

import numpy as np

SR = 44100

# (id, title, artist, genre, difficulty, duration, key root midi, tempo bpm,
#  scale degrees for the bass line, melody midi notes aligned to lyric lines)
# Melody notes reuse the noteTrack frequencies from lib/models/song.dart.
SONGS: list[dict] = [
    dict(id="neon-midnight", duration=222, tempo=112, root=57,  # A3
         melody=[52, 55, 57, 52, 53, 55, 57, 60, 59]),   # E3 G3 A3 ... from noteTrack /2
    dict(id="concrete-halo", duration=255, tempo=124, root=45,  # A2
         melody=[45, 48, 50, 52, 50, 48, 45, 43]),
    dict(id="loose-change", duration=178, tempo=132, root=50,  # D3
         melody=[50, 52, 50, 48, 50, 52, 53, 52]),
    dict(id="slow-gold", duration=210, tempo=84, root=52,  # E3
         melody=[52, 53, 55, 57, 55, 53, 52, 50]),
    dict(id="higher-ground", duration=312, tempo=96, root=48,  # C3
         melody=[48, 52, 55, 60, 59, 57, 55, 52]),
    dict(id="yene-fikir", duration=245, tempo=90, root=50,  # D3
         melody=[50, 52, 54, 57, 55, 52, 50, 48]),
    dict(id="tequila-sunrise", duration=200, tempo=118, root=52,  # E3
         melody=[52, 53, 55, 57, 55, 53, 52, 50]),
    dict(id="old-sepia", duration=285, tempo=76, root=48,  # C3
         melody=[48, 50, 52, 55, 57, 55, 52, 48]),
]

# Chord pads per song: scale-degree triads cycling over the bar.
def chord_progressions(root: int):
    """A gentle I–V–vi–IV style loop built from the song's major scale."""
    st = [0, 2, 4, 5, 7, 9, 11]  # major scale degrees in semitones
    def tri(deg):  # stacked scale thirds
        return [root + st[deg % 7], root + st[(deg + 2) % 7] + (12 if deg + 2 >= 7 else 0),
                root + st[(deg + 4) % 7] + (12 if deg + 4 >= 7 else 0)]
    return [tri(0), tri(4), tri(5), tri(3)]


def midi_to_hz(m: float) -> float:
    return 440.0 * 2 ** ((m - 69) / 12)


def tone(freq: float, dur: float, amp: float, sr: int = SR,
         attack=0.02, release=0.08, harmonics=((1, 1.0), (2, 0.35), (3, 0.12))) -> np.ndarray:
    n = int(dur * sr)
    t = np.arange(n) / sr
    wavef = np.zeros(n)
    for mult, gain in harmonics:
        wavef += gain * np.sin(2 * math.pi * freq * mult * t)
    env = np.ones(n)
    a = min(max(1, int(attack * sr)), n // 2 or 1)
    r = min(max(1, int(release * sr)), n // 2 or 1)
    env[:a] = np.linspace(0, 1, a)
    env[-r:] *= np.linspace(1, 0, r)
    return (wavef * env * amp).astype(np.float32)


def metronome_click(dur_pos: int, sr: int = SR) -> np.ndarray:
    n = 600  # ~14ms tick
    t = np.arange(n) / sr
    click = np.sin(2 * math.pi * 1800 * t) * np.exp(-t * 90)
    out = np.zeros(dur_pos, dtype=np.float32)
    out[:min(n, dur_pos)] += click[:min(n, dur_pos)].astype(np.float32)
    return out * 0.18


def build_song(spec: dict) -> np.ndarray:
    sr = SR
    total = int(spec["duration"] * sr)
    mix = np.zeros(total, dtype=np.float32)
    bpm = spec["tempo"]
    beat = 60.0 / bpm

    # ── Chord pad: one chord per bar (4 beats), I–V–vi–IV loop ──
    bar = beat * 4
    chords = chord_progressions(spec["root"])
    pos = 0.0
    ci = 0
    while pos < spec["duration"]:
        seg = min(bar, spec["duration"] - pos)
        start = int(pos * sr)
        n = int(seg * sr)
        pad = np.zeros(n, dtype=np.float32)
        for midi in chords[ci % len(chords)]:
            pad += tone(midi_to_hz(midi - 12), seg, 0.045, attack=0.25, release=0.5,
                        harmonics=((1, 1.0), (2, 0.18)))
        mix[start:start + n] += pad[:n]
        pos += seg
        ci += 1

    # ── Bass: root of each chord, one note per beat pair ──
    pos = 0.0
    ci = 0
    while pos < spec["duration"]:
        seg = min(beat * 2, spec["duration"] - pos)
        start = int(pos * sr)
        n = int(seg * sr)
        midi = chords[ci % len(chords)][0] - 12
        bass = tone(midi_to_hz(midi), seg, 0.09, attack=0.01, release=0.12,
                    harmonics=((1, 1.0), (2, 0.4)))
        mix[start:start + n] += bass[:n]
        pos += seg
        ci += 1

    # ── Guide melody: the singer's target notes, one per lyric-ish phrase ──
    melody = spec["melody"]
    phrase = max(beat * 2, (spec["duration"] - 8) / len(melody))
    for i, midi in enumerate(melody):
        start_s = 6 + i * phrase  # small intro before the first line
        seg = min(phrase * 0.92, spec["duration"] - start_s)
        if seg <= 0:
            break
        start = int(start_s * sr)
        n = int(seg * sr)
        lead = tone(midi_to_hz(midi + 12), seg, 0.055, attack=0.04, release=0.18,
                    harmonics=((1, 1.0), (2, 0.3), (3, 0.1), (4, 0.05)))
        mix[start:start + n] += lead[:n]

    # ── Metronome ticks on every beat ──
    tick_pos = 0
    while tick_pos < spec["duration"]:
        idx = int(tick_pos * sr)
        mix[idx:idx + 2000] += metronome_click(min(2000, total - idx))[:min(2000, total - idx)]
        tick_pos += beat

    # Gentle fade in/out and light limiting.
    fade = int(1.0 * sr)
    mix[:fade] *= np.linspace(0, 1, fade)
    mix[-fade:] *= np.linspace(1, 0, fade)
    peak = np.max(np.abs(mix)) or 1.0
    if peak > 0.85:
        mix *= 0.85 / peak
    return mix


def write_ogg(path: str, samples: np.ndarray) -> bool:
    if shutil.which("ffmpeg") is None:
        return False
    tmp = path + ".wav"
    with wave.open(tmp, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes((samples * 32767).astype(np.int16).tobytes())
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", tmp,
                    "-c:a", "libvorbis", "-qscale:a", "4", path], check=True)
    os.remove(tmp)
    return True


def main() -> int:
    out_dir = os.path.join(os.path.dirname(__file__), "..", "assets", "audio")
    out_dir = os.path.abspath(out_dir)
    os.makedirs(out_dir, exist_ok=True)
    manifest = {}
    for spec in SONGS:
        samples = build_song(spec)
        ogg = os.path.join(out_dir, f"{spec['id']}.ogg")
        if write_ogg(ogg, samples):
            fmt = "ogg"
        else:  # pragma: no cover - ffmpeg missing
            fmt = "wav"
            with wave.open(os.path.join(out_dir, f"{spec['id']}.wav"), "wb") as w:
                w.setnchannels(1)
                w.setsampwidth(2)
                w.setframerate(SR)
                w.writeframes((samples * 32767).astype(np.int16).tobytes())
        size_kb = os.path.getsize(os.path.join(out_dir, f"{spec['id']}.{fmt}")) // 1024
        manifest[spec["id"]] = {"file": f"assets/audio/{spec['id']}.{fmt}",
                                "durationSec": spec["duration"], "tempo": spec["tempo"],
                                "sizeKb": size_kb}
        print(f"  {spec['id']}.{fmt}  {size_kb} KB  ({spec['duration']}s @ {spec['tempo']} bpm)")
    with open(os.path.join(out_dir, "manifest.json"), "w") as f:
        json.dump(manifest, f, indent=2)
    print("done")
    return 0


if __name__ == "__main__":
    sys.exit(main())
