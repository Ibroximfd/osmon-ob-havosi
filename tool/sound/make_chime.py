"""Osmon notification chime: a soft rising fifth (A5 -> E6) on a glassy
mallet, short and quiet enough to be recognisable without being shrill."""
import math, struct, sys, wave

RATE = 44100
LENGTH = 1.25            # seconds
NOTES = [                # (start s, frequency Hz, gain)
    (0.00, 880.00, 0.90),   # A5
    (0.15, 1318.51, 1.00),  # E6, a perfect fifth up
]
# (ratio, amplitude, decay seconds): warm fundamental, faint octave, a
# quickly fading inharmonic partial for the "glass" sparkle.
PARTIALS = [(1.0, 1.00, 0.42), (2.0, 0.22, 0.20), (2.76, 0.10, 0.07), (4.07, 0.04, 0.04)]
ATTACK = 0.008
PEAK = 0.50              # about -6 dBFS: present, never harsh

n = int(RATE * LENGTH)
dry = [0.0] * n
for start, freq, gain in NOTES:
    s0 = int(start * RATE)
    for i in range(s0, n):
        t = (i - s0) / RATE
        env_attack = math.sin(min(t / ATTACK, 1.0) * math.pi / 2) ** 2
        v = 0.0
        for ratio, amp, decay in PARTIALS:
            v += amp * math.exp(-t / decay) * math.sin(2 * math.pi * freq * ratio * t)
        dry[i] += gain * env_attack * v

# A little air: two short feedback echoes, mixed low.
wet = dry[:]
for delay_ms, fb in ((41, 0.28), (67, 0.22)):
    d = int(RATE * delay_ms / 1000)
    buf = [0.0] * n
    for i in range(n):
        buf[i] = dry[i] + (fb * buf[i - d] if i >= d else 0.0)
    for i in range(n):
        wet[i] += 0.18 * (buf[i] - dry[i])

fade = int(RATE * 0.12)
for i in range(n - fade, n):
    wet[i] *= (n - i) / fade

peak = max(abs(x) for x in wet)
scale = PEAK / peak
out = sys.argv[1]
with wave.open(out, 'wb') as w:
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(RATE)
    w.writeframes(b''.join(struct.pack('<h', int(max(-1, min(1, x * scale)) * 32767)) for x in wet))
rms = math.sqrt(sum((x * scale) ** 2 for x in wet) / n)
print(f'{out}: {LENGTH}s, peak {20*math.log10(PEAK):.1f} dBFS, rms {20*math.log10(rms):.1f} dBFS')
