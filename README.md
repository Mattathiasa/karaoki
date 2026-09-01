# Handoff: Zemaoki — multiplayer karaoke platform

## Overview
Zemaoki is a party karaoke platform made of two connected clients:

1. **Mobile player app** (Flutter Android/iOS, portrait) — each guest's mic, controller, song browser and personal lyric sheet.
2. **Karaoke Board** (Flutter Web, landscape, 1280×720+) — the shared TV screen: room code + QR, queue, synchronised lyrics, live scoring, podium.

Multiple phones join one room, queue songs, take turns singing, and get scored. The board is the stage; the phone is the instrument.

## About the design files
The files in this bundle are **design references authored in HTML** — an interactive prototype of the intended look, layout and behaviour. They are **not production code to copy**.

Your task: **recreate these designs in Flutter** (mobile app + Flutter Web board) using the project's own architecture and widget patterns. If no codebase exists yet, scaffold one: Flutter 3.x, Riverpod or Bloc for state, Firebase (Auth + Firestore + Realtime Database) for rooms/presence, and a pitch-scoring service for audio.

Ignore the prototype's DOM/CSS mechanics (the `<x-dc>` runtime, inline styles, `sc-for`/`sc-if`). Take from it: information architecture, layout proportions, colour, type, copy, states and motion intent.

## Fidelity
**High fidelity.** Colours, type, spacing, radii, shadows and copy are final. Recreate them precisely, then adapt to platform conventions (iOS/Android safe areas, Material ripple vs custom press states).

## What's in this bundle
| File | What it is |
| --- | --- |
| `karaoki-prototype-standalone.html` | Open in any browser, no server. Left rail navigates all 47 screens; the timeline under the board scrubs a performance and drives phone + board together. |
| `Karaoke Prototype v5.dc.html` + `support.js` | The prototype source, if you want to read exact values. |
| `SCREENS.md` | Per-screen implementation spec (layout, components, copy, states). |
| `FLOWS.md` | Navigation flows, state machine, realtime event contract, data models. |
| `README.md` | This file — tokens, component library, conventions. |

## How to read the prototype
- **Left rail** = full screen inventory, grouped: Onboarding, Core, Performance, Modes, Profile, Board screens, Edge states.
- **Centre** = iPhone 17 frame (402×874 logical) running the mobile app.
- **Right** = the Karaoke Board at 1280×720.
- **Timeline** (below the board) scrubs performance time 0–100%. Lyric line, wipe position, pitch bars, combo and live score are all derived from it — that is the single source of truth for a performance, and your implementation should do the same (one clock, everything derived).
- **Realtime event bus** panel (under the phone) shows the phone→board messages each action emits.

## Design tokens

### Colour
`oklch()` values are canonical; hex is an approximation for tools that need it.

| Token | Value | Hex ≈ | Use |
| --- | --- | --- | --- |
| `ink/900` | `#0B0A07` | — | Board background, app shell base |
| `ink/850` | `#0C0B08` | — | Prototype chrome background |
| `ink/800` | `#100E0A` | — | Phone screen background |
| `ink/700` | `#16130E` | — | Panel (low emphasis) |
| `ink/650` | `#17140E` | — | Panel (default card) |
| `ink/600` | `#1C1912` | — | Panel (raised / emphasis) |
| `ink/550` | `#211D15` | — | Panel hover, tertiary button |
| `on-accent` | `#0F0E0A` | — | Text/icon on lime, bone, gold |
| `bone` | `#F5F1E8` | — | Primary text, inverted buttons |
| `bone/55` | `rgba(245,241,232,.55)` | — | Secondary text |
| `bone/45` | `rgba(245,241,232,.45)` | — | Tertiary text, mono labels |
| `bone/28` | `rgba(245,241,232,.28)` | — | Disabled, index numerals |
| `hairline` | `rgba(245,241,232,.09→.16)` | — | Borders (.09 low, .16 high) |
| `lime` (primary) | `oklch(0.87 0.21 128)` | `#C4F53E` | Primary actions, brand, active state |
| `lime/deep` | `oklch(0.62 0.17 128)` | `#7FA52B` | Pressed primary, meter shadow |
| `lime/tint` | `oklch(0.42 0.13 128)` | `#4E6A18` | Tinted panel washes |
| `tangerine` | `oklch(0.79 0.19 48)` | `#FFA149` | Secondary accent, Team Fire |
| `teal` | `oklch(0.83 0.14 196)` | `#5FDCE4` | Tertiary accent, Team Lightning, pitch |
| `mint` | `oklch(0.85 0.15 168)` | `#4CE9AE` | Success, ready, mic OK |
| `gold` | `oklch(0.86 0.17 72)` | `#F7C13B` | Scores, ranks, combo, warnings |
| `red` | `oklch(0.72 0.2 22)` | `#F76242` | Danger, disconnected, invalid |

Rules: **one accent leads per screen.** Lime = action. Gold = achievement. Mint = status OK. Red = failure only. Tangerine/teal are reserved for team and duet identity — never decorative.

### Typography
| Role | Family | Weight | Notes |
| --- | --- | --- | --- |
| Display | **Bricolage Grotesque** | 700 / 800 | Headlines, scores, lyrics, player names. Tracking −1.2px at 34px → −9px at 206px |
| UI | **Instrument Sans** | 400 / 600 / 700 | Body, buttons, list rows |
| Data | **Space Mono** | 400 / 700 | Micro-labels, codes, timers, tags. Always uppercase, letter-spacing .12–.2em |

Mobile scale: 34 (screen hero) / 26 / 22 (section hero) / 15.5 (button) / 13.5 (row title) / 12.5 (body) / 11 (meta) / 9–9.5 (mono label).
Board scale: 206 (final score) / 94 (room code) / 58 (current lyric) / 33 (next lyric) / 48 / 26 / 22 (names) / 13–16 (mono).
Minimum board text: 13px mono, 16px UI — readable at 3 m.

### Radius
`999px` buttons, chips, pills, tickers · `28px` hero cards · `20px` cards / cover art · `16px` tiles, small art · `34%` avatars (squircle) · `54px` phone screen · `50%` status dots and rings.

### Elevation
- Panel: `0 20px 38px -26px rgba(0,0,0,.95)` + `inset 0 1px 0 rgba(245,241,232,.08)`
- Raised: `0 22px 44px -26px rgba(0,0,0,.95)` + `inset 0 1px 0 rgba(245,241,232,.09)`
- Accent (lime button): `0 14px 30px -12px oklch(0.87 0.21 128/.5)` + `inset 0 1px 0 rgba(255,255,255,.35)`
- Cover art: `0 20px 40px -22px rgba(0,0,0,.95)`
- Glow (meter fill, active avatar): `0 0 18px 1px oklch(0.87 0.21 128/.65)`

### Spacing
4 · 6 · 8 · 11 · 14 · 20 · 22 · 26 · 44. Mobile screen padding 20–22px. Board padding 40–50px. Card inner padding 14–18px.

## Component library
Build these once, reuse everywhere.

**Buttons** — Primary: lime gradient pill (`oklch(0.87 0.21 128)`→`oklch(0.84 0.2 96)`), ink text, 15.5px/700, 17px vertical padding, accent shadow, hover `brightness(1.08)`. Secondary: `rgba(245,241,232,.07)` pill, 1px hairline, bone text. Danger: `red/20` fill, `red/40` border, red text. Icon button: 34–38px square, radius 12, panel fill.

**Cards** — Song card (cover art 52–56px radius 16 + title 13.5/700 + artist 11 + trailing difficulty tag). Player card (squircle avatar + name + level + `[ STATUS ]` mono tag). Achievement card (emoji 26px, name 13/700, description 10.5, unlocked/locked treatment). Leaderboard row (rank numeral bone/28 + avatar + name + score display 19px).

**Status** — mono uppercase tags in brackets: `READY` mint · `SINGING` teal · `PICKING SONG` bone/45 · `DISCONNECTED` red. Live dot: 7–8px circle + `pulseGlow 1.2–1.8s` + coloured 10px halo.

**Gamification** — Score badge (display numeral + `/100`). Rank badge (pill, gradient gold/lime wash, uppercase display: SOLID / GREAT / SUPERSTAR). Combo (🔥 + `x{n}` gold display, pulse). Level chip (gold pill, mono, e.g. `KARAOKE LEGEND · LV 24`).

**Music** — Cover art: generative duotone (two radial gradients in the song's hue + hue+46, 2px scanline overlay, ink base). Ship real artwork in production; keep the scanline overlay as the house treatment. Progress: 5–8px track `bone/12`, lime→teal fill with bloom. Equaliser: 18 bars, 3px gap, heights from a sine of the clock. Lyrics component: see below. Mic status: pill + live dot + level meter.

**Lyric component (the signature)** — Three stacked lines: previous (bone/20, 30px), current (58px display), next (bone/42, 33px). The current line renders **twice**: a bone/24 base and a gradient-filled copy (`#FFFDF5`→lime→teal) clipped left-to-right by `clip-path: inset(0 X% 0 0)` where `X = (1 - lineProgress) * 100`. In Flutter: `ShaderMask` + `ClipRect` with an `Align(widthFactor: lineProgress)`. Phone uses the same at 32px.

## Motion
| Name | Spec | Where |
| --- | --- | --- |
| `pulseGlow` | 1.2–2.2s ease-in-out infinite, opacity .55→1, scale 1→1.06 | live dots, VS, combo |
| `ringOut` | 1.6–2.2s infinite, scale .7→1.6, opacity .7→0 | active singer avatar, mic, countdown |
| `popIn` | .4–.6s ease-out, scale .6→1.08→1, opacity 0→1 | score reveal, player joining, YOUR TURN |
| `floatY` | 3–3.4s ease-in-out infinite, ±10px | splash mic, badges |
| `marquee` | 20s linear infinite, translateX 0→−50% | board ticker |
| Lyric wipe | linear, driven by the song clock (no easing) | current lyric |
| Screen transition | 220ms ease-out, 12px slide + fade | mobile navigation |

Never animate the lyric wipe with easing — it must track audio time exactly.

## Accessibility & platform
- Touch targets ≥ 44×44.
- Board contrast: all text ≥ 4.5:1 on ink; lyrics are effectively 12:1.
- Respect `reduce motion`: drop pulse/float/marquee, keep the lyric wipe (it is functional).
- Mobile: safe-area insets top/bottom; the prototype's 56px status band and 24px bottom pad approximate iPhone 17 insets.
- Board: assume no input device. Everything is driven from phones; nothing on the board is clickable except optional host controls.

## Assets
No third-party assets. Cover art, avatars and QR are generated placeholders (gradients, initials, a deterministic 13×13 dot matrix). Replace with: real cover art from your catalogue, user avatars from Storage, and a real QR encoding the room join URL. Icons in the prototype are Unicode glyphs — swap for your icon set (Lucide/Material Symbols).

## Song catalogue in the prototype
Fictional titles/artists, safe to keep in tests: Neon Midnight (Vela Cruz, Pop), Concrete Halo (The Static Kings, Rock), Loose Change (Kobi Blaze, Hip Hop), Slow Gold (Amara Reign, R&B), Higher Ground Hallelujah (Sunday Choir Union, Gospel), Yene Fikir Tizita (Selam Tadesse, Ethiopian), Tequila Sunrise Radio (Marisol Vane, Party), Old Sepia Letters (Frank Delacroix, Classics).

## Suggested build order
1. Design system: tokens, typography, buttons, cards, tags, avatars (day 1–2).
2. Firebase room model + join by code/QR + presence → Board waiting screen and Room lobby working together (this proves the whole product).
3. Song library/search/details + queue with attribution.
4. Performance pipeline: one clock → countdown → lyrics + wipe on both clients → scoring stream.
5. Score reveal, leaderboard, history, achievements.
6. Game modes on top of the classic loop.
7. Edge states — budget real time for these; there are 12 and they are specified.
