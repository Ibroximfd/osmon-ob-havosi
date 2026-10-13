"""Soundtrack for the 16 s promo: a soft ambient pad that changes chord on
every beat of the video, light rain under the opening, a quiet pluck on
each scene change, and the Osmon notification chime on the logo.

Synthesised from scratch (no samples), so it is free to use anywhere.
Usage: python3 tool/promo/make_music.py build/promo/music.wav
"""
import math
import random
import struct
import sys
import wave

RATE = 44100
LENGTH = 16.0
N = int(RATE * LENGTH)
TAU = 2 * math.pi


def hz(midi):
    return 440.0 * 2 ** ((midi - 69) / 12)


# (start s, end s, MIDI notes) — follows the video's beats.
CHORDS = [
    (0.0, 3.0, [45, 57, 60, 64]),     # Am
    (3.0, 5.8, [41, 57, 60, 65]),     # F
    (5.8, 8.4, [48, 55, 60, 64]),     # C
    (8.4, 11.0, [43, 55, 59, 62]),    # G
    (11.0, 13.2, [45, 57, 60, 64]),   # Am
    (13.2, 14.6, [41, 57, 60, 65]),   # F
    (14.6, 16.0, [48, 55, 60, 64]),   # C — resolves under the logo
]
BEATS = [3.0, 5.8, 8.4, 11.0]
CHIME_AT = 13.35
XFADE = 0.7

left = [0.0] * N
right = [0.0] * N


def env(t, start, end):
    """Slow pad envelope with overlapping crossfades between chords."""
    if t < start - XFADE / 2 or t > end + XFADE / 2:
        return 0.0
    a = min(1.0, (t - (start - XFADE / 2)) / XFADE)
    r = min(1.0, ((end + XFADE / 2) - t) / XFADE)
    return math.sin(min(a, r) * math.pi / 2) ** 2


# Pad: each note a sine plus a faint octave, detuned slightly per channel.
for start, end, notes in CHORDS:
    s0 = max(0, int((start - XFADE / 2) * RATE))
    s1 = min(N, int((end + XFADE / 2) * RATE))
    for k, note in enumerate(notes):
        f = hz(note)
        gain = 0.16 if k == 0 else 0.10
        for i in range(s0, s1):
            t = i / RATE
            e = env(t, start, end) * gain
            if e == 0.0:
                continue
            wobble = 1 + 0.06 * math.sin(TAU * 0.23 * t + k)
            fl, fr = f * 0.9985, f * 1.0015
            vl = math.sin(TAU * fl * t) + 0.18 * math.sin(TAU * 2 * fl * t)
            vr = math.sin(TAU * fr * t) + 0.18 * math.sin(TAU * 2 * fr * t)
            left[i] += e * wobble * vl
            right[i] += e * wobble * vr


def pluck(at, midi, gain):
    """A soft glassy pluck (fast attack, short exponential decay)."""
    f = hz(midi)
    s0 = int(at * RATE)
    for i in range(s0, min(N, s0 + int(1.2 * RATE))):
        t = (i - s0) / RATE
        a = min(1.0, t / 0.004)
        v = (math.exp(-t / 0.35) * math.sin(TAU * f * t)
             + 0.25 * math.exp(-t / 0.12) * math.sin(TAU * 2.76 * f * t))
        left[i] += gain * a * v
        right[i] += gain * a * v


for beat, root in zip(BEATS, [77, 79, 74, 76]):
    pluck(beat, root, 0.10)

# The app's notification chime: A5 then E6, a fifth up.
pluck(CHIME_AT, 81, 0.22)
pluck(CHIME_AT + 0.15, 88, 0.24)

# Light rain under the opening: low-passed noise, fading out by 4 s.
rng = random.Random(7)
lp_l = lp_r = 0.0
for i in range(int(4.0 * RATE)):
    t = i / RATE
    g = 0.05 * min(1.0, t / 0.4) * max(0.0, 1 - max(0.0, t - 2.6) / 1.4)
    lp_l += 0.12 * (rng.uniform(-1, 1) - lp_l)
    lp_r += 0.12 * (rng.uniform(-1, 1) - lp_r)
    left[i] += g * lp_l
    right[i] += g * lp_r

# Master: fade in/out, normalise to -3 dBFS.
fade_in, fade_out = int(0.2 * RATE), int(1.2 * RATE)
for i in range(N):
    g = min(1.0, i / fade_in, (N - i) / fade_out)
    left[i] *= g
    right[i] *= g
peak = max(max(abs(x) for x in left), max(abs(x) for x in right))
scale = 10 ** (-3 / 20) / peak

with wave.open(sys.argv[1], 'wb') as w:
    w.setnchannels(2)
    w.setsampwidth(2)
    w.setframerate(RATE)
    w.writeframes(b''.join(
        struct.pack('<hh', int(l * scale * 32767), int(r * scale * 32767))
        for l, r in zip(left, right)))
print(f'{sys.argv[1]}: {LENGTH}s stereo, peak -3 dBFS')
