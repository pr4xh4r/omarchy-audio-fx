<div align="center">

# 🎛️ omarchy-audio-fx

**Cinematic audio modes for Linux — EasyEffects presets + intelligent auto-switching**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![EasyEffects](https://img.shields.io/badge/EasyEffects-8.x-blue)](https://github.com/wwmm/easyeffects)
[![PipeWire](https://img.shields.io/badge/PipeWire-ready-green)](https://pipewire.org)
[![Omarchy](https://img.shields.io/badge/Omarchy-plugin-purple)](https://omarchy.dev)

*Marshall warmth. Dolby Atmos width. Harman science. All on Linux. Free.*

</div>

---

## ✨ What Is This?

`omarchy-audio-fx` gives you **one-click cinematic audio modes** for any device — headphones, earphones, earbuds, or speakers — using 100% open-source DSP via EasyEffects + PipeWire.

The modes are named after real audio brands (Marshall, Dolby, Harman, Sony, Bose, JBL, Sennheiser) because they trigger the right psychological expectation — and the presets are engineered to *actually deliver* that signature sound.

No proprietary code. No subscription. Just great sound.

---

## 🎧 The 3-Layer System

```
DEVICE PROFILE   → what hardware do you have?
      +
SOUND SIGNATURE  → what character do you want?
      +
EXPERIENCE MODE  → what are you doing right now?
```

Pick any combination. Each produces a fully tuned EasyEffects preset chain.

---

## 🎵 Sound Signatures

| Name | Inspired By | Sound Character |
|------|------------|-----------------|
| **Marshall** 🎸 | Marshall Amplification | Warm bass · Punchy mids · Guitar-amp feel |
| **Dolby-Atmos** 🎬 | Dolby Laboratories | Wide · Immersive · Spatial cinema |
| **Harman** 📐 | Harman International | Research-backed · Most humans prefer this |
| **Sony-Clear** 🎧 | Sony WH-1000XM | Deep bass · Crystal vocals · ANC-inspired |
| **Bose-Comfort** 🎧 | Bose QuietComfort | Balanced · Warm · Zero fatigue |
| **JBL-Loud** 🔊 | JBL | V-shaped · Energetic · Party-ready |
| **Sennheiser-Detail** 🔬 | Sennheiser HD | Analytical · Flat · Wide soundstage |
| **Bass-Beast** 💥 | Club systems | Sub-heavy · Psychoacoustic bass |
| **Vocal-Clarity** 🎙️ | Podcast setups | Speech-forward · Removes rumble |
| **Lo-Fi** 📻 | Lofi aesthetic | Vintage · Tape warmth · Rolled highs |
| **Crystal-Air** 💎 | Audiophile IEMs | Airy · Detailed · Open soundstage |

---

## 🎧 Device Profiles

| Profile | For | Key Feature |
|---------|-----|------------|
| **Headphones** | Over-ear headphones | **Crossfeed** — removes in-head feeling |
| **IEM** | Wired in-ear monitors | Resonance correction + treble smoothing |
| **Earbuds** | TWS earbuds (Bluetooth) | Psychoacoustic bass virtualization |
| **Laptop-Speakers** | Laptop built-in speakers | Bass virtualization + stereo widening |
| **Desktop-Speakers** | Bookshelf/desktop speakers | Reference balance + gentle warmth |

---

## 🌍 Experience Modes

| Mode | When | What It Does |
|------|------|--------------|
| **Cinema** 🎬 | Movies | Wide stage + dialogue boost + depth |
| **Gaming** 🎮 | Gaming | Positional cues (2–8kHz) + fast transients |
| **Party** 🎉 | Loud sessions | Max bass + protected hard limiter |
| **Focus** 📚 | Work / study | Flat + crossfeed + non-fatiguing |

---

## 🔬 The Science Behind The Features

### Crossfeed (Headphones)
Normal stereo headphones send left audio only to your left ear. On real speakers, sound crosses between ears. Crossfeed simulates this, making headphones sound natural and reducing listening fatigue significantly.

### Psychoacoustic Bass Virtualization (Earbuds)
Small earbud drivers can't physically produce deep bass (40Hz). But the human brain uses the **missing fundamental principle** — if you play the 2nd and 3rd harmonics (80Hz + 120Hz), the brain reconstructs the 40Hz that was never played. The result: perceived deep bass from a 6mm driver.

### Harman Target Curve
Harman International (owns JBL, AKG) spent years testing thousands of listeners. The Harman curve is the EQ profile most humans prefer. It's now open research. The Harman preset implements this curve precisely.

### Loudness Compensation
At low volume, human ears lose bass and treble sensitivity (Fletcher-Munson effect). Music sounds thin at night. Device profiles compensate dynamically.

---

## ⚡ Install

```bash
git clone https://github.com/pr4xh4r/omarchy-audio-fx
cd omarchy-audio-fx
chmod +x install.sh && ./install.sh
```

**Requirements:** EasyEffects 8.x, PipeWire, `pactl`

---

## 🖥️ Usage

### CLI
```bash
audiofx list                     # all presets
audiofx status                   # current state
audiofx set Marshall             # apply Marshall signature
audiofx set Dolby-Atmos          # apply Dolby Atmos
audiofx profile Headphones       # device-specific tuning
audiofx mode Cinema              # set experience context
audiofx apply headphones+marshall # combine profiles
audiofx auto                     # auto-detect device
audiofx off                      # bypass all effects
```

### EasyEffects GUI
Open EasyEffects → Presets → select any preset from the list.

### Omarchy Bar Plugin
Install via Omarchy menu → Plugins → `pr4xh4r.audiofx`

---

## 🤝 Contributing

Want to add a preset? See [CONTRIBUTING.md](docs/CONTRIBUTING.md).

Every preset needs:
- The `.json` EasyEffects file
- A description of the sound character
- The target device(s) it's tuned for

---

## 📄 License

MIT — free to use, modify, share.

> Brand names (Marshall, Dolby, Harman, Sony, Bose, JBL, Sennheiser) are trademarks of their respective owners. This project is not affiliated with any of these companies. Presets are independently engineered to achieve similar sound signatures using open-source DSP.
