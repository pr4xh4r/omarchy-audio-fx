<div align="center">

# omarchy-audio-fx

**21 audio presets for Linux — Marshall, Dolby Atmos, Harman, Sony and more**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![EasyEffects](https://img.shields.io/badge/EasyEffects-8.x-blue)](https://github.com/wwmm/easyeffects)
[![PipeWire](https://img.shields.io/badge/PipeWire-ready-green)](https://pipewire.org)
[![Omarchy](https://img.shields.io/badge/Omarchy-plugin-purple)](https://omarchy.dev)

</div>

---

I was using [Omarchy](https://omarchy.dev) on Linux and got annoyed that I had to either deal with flat boring audio or manually open EasyEffects every time I wanted to change how music sounds. So I built this — a collection of audio presets you can switch with a single keypress, and a small CLI to manage them from the terminal.

The presets are named after real audio brands like Marshall, Dolby, Bose, Sony etc. because that's exactly the kind of sound they're trying to deliver. Marshall feels warm and bassy like a guitar amp. Dolby Atmos makes things feel wide and spatial. Harman is based on actual research about what most people prefer. You get the idea.

---

## What's inside

**21 presets split into 3 categories:**

**Sound signatures** — these change the character of your audio
| Preset | What it sounds like |
|--------|-------------------|
| Marshall | Warm, bassy, punchy mids — like a guitar amp |
| Dolby-Atmos | Wide, spacious, cinematic |
| Harman | Balanced and natural — backed by actual research |
| Sony-Clear | Deep bass + clear vocals, inspired by WH-1000XM |
| Bose-Comfort | Smooth and easy on the ears for long sessions |
| JBL-Loud | Boosted bass and highs, great for parties |
| Sennheiser-Detail | Flat and accurate, for when you want to hear everything |
| Bass-Beast | Pure bass. That's it. |
| Vocal-Clarity | Makes voices and podcasts sound crisp and clear |
| Lo-Fi | Warm, vintage, rolled-off highs — cozy vibes |
| Crystal-Air | Airy and detailed, works really well with IEMs |
| Night-Mode | Quieter, compressed — good for late night listening |

**Device profiles** — tuned for specific hardware
| Preset | For |
|--------|-----|
| Headphones | Enables crossfeed so music doesn't feel stuck inside your head |
| IEM | Fixes the harsh treble peaks common in wired IEMs |
| Earbuds | Adds psychoacoustic bass so tiny drivers sound bigger |
| Laptop-Speakers | Widens the stereo and adds perceived bass for tiny laptop speakers |
| Desktop-Speakers | Clean reference tuning for bookshelf/desktop setups |

**Experience modes** — for what you're actually doing
| Preset | When to use |
|--------|------------|
| Cinema | Watching movies — wider stage, boosted dialogue |
| Gaming | Boosts the frequencies where footsteps and details live |
| Party | Maximum bass, loud, with a limiter to protect your speakers |
| Focus | Flat and fatigue-free — good for long work sessions |

---

## Install

```bash
git clone https://github.com/pr4xh4r/omarchy-audio-fx
cd omarchy-audio-fx
chmod +x install.sh && ./install.sh
```

That's it. The installer copies all presets to EasyEffects, installs the `audiofx` CLI, drops the `audio-mode` script in your local bin, and if you're on Omarchy/Hyprland it auto-registers the `Super+M` keybinding.

**You need:** EasyEffects 8.x, PipeWire

---

## Super+M keybinding

If you're on Omarchy, press `Super+M` to cycle through every preset one by one. You'll get a notification each time so you know which one is active.

The full cycle goes:

```
Off → Marshall → Dolby Atmos → Harman → Sony Clear → Bose Comfort
    → JBL Loud → Sennheiser Detail → Bass Beast → Vocal Clarity
    → Lo-Fi → Crystal Air → Night Mode → Headphones → IEM
    → Earbuds → Laptop Speakers → Desktop Speakers → Cinema
    → Gaming → Party → Focus → Off
```

If you're not on Omarchy but still use Hyprland, add this to your config:

```
bind = SUPER, M, exec, audio-mode
```

---

## CLI usage

```bash
audiofx list                          # see everything available
audiofx status                        # what's currently active
audiofx set Marshall                  # apply a sound signature
audiofx profile Headphones            # apply a device profile
audiofx mode Cinema                   # apply an experience mode
audiofx auto                          # detect your device and apply the right profile
audiofx off                           # turn off all effects
```

You can also just type a preset name directly as a shortcut:

```bash
audiofx Marshall
audiofx Dolby-Atmos
audiofx Headphones
```

---

## Without the CLI

Open EasyEffects, go to Presets, and load any preset from the list. Everything installed by this project shows up there. No CLI required.

---

## Omarchy bar plugin

If you're on Omarchy there's also a bar indicator plugin (`pr4xh4r.audiofx`) that shows the current mode and lets you click to cycle through all of them. Install it through the Omarchy plugin menu.

---

## How some of the presets actually work

**Crossfeed (Headphones preset)**
When you listen to stereo on headphones, your left ear only hears the left channel and your right ear only hears the right. That's not how speakers work — on speakers, sound from both sides reaches both ears. The brain is used to that. Crossfeed simulates it, so headphone listening feels more natural and less tiring after a few hours.

**Psychoacoustic bass (Earbuds preset)**
A 6mm earbud driver physically can't produce 40Hz bass — the cone is too small. But your brain does something interesting: if it hears the 2nd and 3rd harmonics of a note (80Hz and 120Hz), it fills in the missing 40Hz on its own. This preset uses that trick to make earbuds sound much bassier than they actually are.

**Harman curve**
Harman International (the company behind JBL, AKG, and others) ran a big study where they tested thousands of listeners to find what EQ profile people actually prefer. The answer turned out to be a specific curve with a slight bass boost and a controlled high end. The Harman preset is based on that research. Turns out there's a reason AirPods sound good to most people out of the box.

---

## Contributing

If you want to add a preset, just open a PR with:
- The `.json` EasyEffects file in the right folder (`presets/signature/`, `presets/device/`, or `presets/mode/`)
- A short description of what it sounds like and what device it's for

No formal template needed, just make sure the JSON is valid and it actually sounds good.

---

## License

MIT. Do whatever you want with it.

> Marshall, Dolby, Harman, Sony, Bose, JBL, and Sennheiser are trademarks of their respective companies. This project has no affiliation with any of them. The presets just try to capture similar sound signatures using open-source tools.
