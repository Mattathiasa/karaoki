# Karaoki — screen-by-screen implementation spec

Screen keys match the prototype's left rail and its `startScreen` tweak, so you can open any screen directly.

Shared mobile conventions:
- Screen frame 402×874 logical. Status band 56px (safe area). Bottom tab bar 5 items, 24px bottom pad, hidden on immersive screens (splash, onboarding, auth, QR, turn, singing, score reveal, battle, blocking states).
- Screen padding 20–22px horizontal. Scroll body, fixed CTA at the bottom where present.
- Section pattern: mono uppercase label (9–11px, tracking .16em, bone/45) + optional lime "See all", then content.
- Every row: 44px min height, hairline-bordered panel card, radius 16–20.

Board conventions:
- 1280×720 base, scale up proportionally. Ink base with two radial washes (lime top-centre, teal bottom-left), 2px scanline veil at .5 opacity, rounded registration marks top-left/top-right.
- Padding 40–50px. Nothing interactive.

---

## MOBILE — ONBOARDING & AUTH

### 1. `splash`
Purpose: brand moment, 1.2s then auto-advance to onboarding.
Layout: centred column. Lime→tangerine rounded-square mic tile 118px (floatY) with a `ringOut` halo; wordmark "KARAOKI" 46px display; tagline `SING · COMPETE · REPEAT` mono 11px tracking .3em; 18-bar equaliser 44px tall; "TAP TO CONTINUE" pinned 52px from bottom.
Background: radial lime wash at 50%/34% over `#1A1509`→`#100E0A`.

### 2–4. `onb1` `onb2` `onb3`
Purpose: explain the loop, the phone-as-mic mechanic, and scoring.
Layout: Skip (top right, bone/50) · illustration block 288px radius 26 · headline 32px display two lines · body 14.5px/1.55 bone/55 · footer row: 3 progress bars (active 26×5 lime, inactive 8×5 bone/18) + Continue pill.
Copy: "Sing. Compete. Have Fun." / "Your Phone Becomes Your Microphone." / "Become the Karaoke Champion." Bodies are in the prototype verbatim.
Illustrations: onb1 = striped placeholder + lime wash (replace with real art); onb2 = a schematic phone → three signal bars → board; onb3 = 🏆 + score 96 + `SUPERSTAR 🔥`.

### 5. `welcome`
62px mic tile · "Welcome to the party." 30px · body · bottom stack: Create account (primary pill), Sign in with email (secondary), Continue with Google (secondary + G disc), "Continue as guest →" (text, bone/55). Guests can sing; scores are session-only.

### 6–7. `signin` `signup`
Back icon button · title 28px · labelled fields (mono 11.5 label, 15px input, panel fill, hairline, radius 14) · "Forgot password?" right-aligned lime · primary pill at bottom · text link to the other screen. Signup adds a mint "Microphone detected — sounds good" strip. Validation: email format on blur, password ≥ 8, inline red hairline + message.

### 8. `setup`
Avatar picker 110px squircle with a 36px edit affordance · Display name + Username fields (username prefixed `@`, availability check) · genre chips (multi-select pills, 8 options) · experience level 2×2 grid (Beginner / Casual / Performer / Karaoke Legend; selected = lime-tinted fill + lime border + ✓) · "Enter Karaoki" primary.

---

## MOBILE — CORE

### 9. `home` ★ priority
Purpose: pick an entry: join, host, or solo. Then discovery.
Layout, top to bottom:
1. Lime pill badge `SAT 21:04 / 4 ONLINE` (mono 9px, ink text, dot) + "Ready to / Sing?" 34px display; 50px squircle avatar top-right with a mint presence dot.
2. **Join Room hero** — 184px, full-bleed cover art, 198° ink scrim, 66px mic glass tile top-right, "ROOM LIVE NOW" pill top-left with mint pulse dot, title "Join Room" 31px, sub "Friday Night Fire · 4 singing · KARA-7821".
3. Two tiles side by side: Create Room (lime-tinted 38px icon tile) / Quick Solo (teal-tinted). Each: icon tile, name 15.5px display, caption 10.5px.
4. "Pick up where you stopped" row: cover art 52px, mono kicker, title, 4px progress bar.
5. Recently played: horizontal scroll, 140px cover cards, difficulty bottom-left and duration top-right over the art, title + artist below.
6. Trending tonight: mono heading + red live dot; 4 rows, art 52px + title + "artist · N sung tonight" + difficulty tag.
7. Stats pair: lime-washed "YOUR TOP SCORE 96" (44px display) + "NEW BADGE 🏅 Pitch Perfect" (tappable → achievements).

### 10. `createRoom`
Back + title · Room name field (default "Friday Night Fire") · **Game mode** list of 5 selectable rows (icon tile, name, description, lime ✓ when active) · 2×2 settings grid (Max players 8 · Visibility Private · Category Party · Difficulty Mixed) · "Create room & open board" primary. On submit: create room doc, generate a 4+4 code (`KARA-7821`), open the board URL, go to `lobby`.

### 11. `joinRoom`
Big code input: 20px padding, mono 30px, tracking .14em, centred, uppercase-forced. Helper "Autofill the demo code". Primary Join. Divider "OR". "Scan QR on the board" row → `qr`. Nearby rooms list: mint dot = joinable, gold dot + `FULL` = `roomFull`. Validation: strip non-alphanumeric, compare to room code; failure → `badCode`.

### 12. `qr`
Camera placeholder (striped, near-black) · header "CAMERA PREVIEW" + Cancel · 236px reticle with four lime corner brackets and a teal scan line (floatY) · instruction copy · "Simulate successful scan" primary · link to the permission-blocked state. Real build: request camera permission first; deny → `micPerm`-style explainer.

### 13. `lobby` ★ priority
Header card: lime/tangerine wash, mono `ROOM · HOST MATT`, room name 24px, settings icon; three inline stats (CODE mono 16px · MODE · PLAYERS 4/8).
Roster: one card per player — 42px squircle avatar, name + `HOST` tag (lime outline pill), level, `[ READY ]` mint or `[ PICKING SONG ]` bone/45 on the right. New joiners animate in with `popIn`.
Actions: Browse songs / Queue · N (secondary pair) · "Start game — host only" primary · Ready up + Leave room (danger) pair.
Host-only extras: room settings, remove player (long-press a row), start.

### 14. `library` ★ priority
Title + search icon · tappable search field · category pill row, horizontally scrolling (Pop, Rock, Hip Hop, R&B, Gospel, Classics, Party, Ethiopian) · "All songs" heading with DIFFICULTY ▾ / POPULAR ▾ filter tags · song rows: 56px art, title, artist, three mono meta tags (difficulty · duration · genre), lime **+** button 36px that queues instantly and navigates to `queueScr`.

### 15. `search`
Back + active field (lime focus border) · RECENT SEARCHES pills · "RESULTS · N" · result rows (art 52px, title, "artist · genre", duration right) · link to the empty state.

### 16. `details`
346px full-bleed cover art with an ink gradient to the page, back button, title 28px + artist over the art. Below: meta tag row (difficulty, duration, genre, 🔥 TRENDING) · three stat cards (ROOM BEST / YOUR BEST — lime-washed / PLAYS) · "Add to queue" primary · Preview + Favourite secondary pair · link to the unavailable state.

### 17. `queueScr`
Header with `HOST` tag · Now-playing card (lime wash, art 54px, mono `NOW PLAYING · MATT`, title, elapsed/total, 4-bar equaliser) · "Up next · N" + lime "Reorder" · queue rows (position numeral bone/30, art 46px, title, requester chip = 16px avatar + name, drag ⇅ and remove ✕) · dashed info strip "You sing 3rd — about 8 minutes away" · Add another / Empty state pair.
Host may reorder (drag), remove, skip. Players see position only.

---

## MOBILE — PERFORMANCE

### 18. `turnNext`
Radial lime stage wash. `GET READY` mono tracking .28em · "YOU'RE UP NEXT!" 42px display · 150px countdown ring with `ringOut` halo, numeral 62px, "SECONDS" · song card (mono YOUR SONG, title 21px, artist · duration · difficulty) · "I'm ready" primary · "Skip my turn" text.

### 19. `turnNow`
"YOUR TURN!" 46px display with `popIn` · 190px lime/tangerine mic tile, 82px glyph, floatY + ringOut · song title + artist · mint pill "Microphone live · phone connected" · "START SINGING" bone pill, 19px padding.

### 20. `singing` ★ priority
Top: red pill `YOU ARE SINGING` with pulsing dot + pause icon button.
Progress row: elapsed mono · 5px track with lime→teal glow fill · duration.
Centre (flex, dominant): previous line 15px bone/24 · **current line 32px display, wipe-filled** · next line 18px bone/45.
Below: 18-bar input equaliser 52px.
Metrics: three cards — PITCH (mint), TIMING (gold), 🔥 COMBO (lime-washed) — then a wide LIVE SCORE row (mono label + 26px display value). "End performance →" text link.
Rules: lyrics are the largest element; metrics never exceed 20px; no more than 4 metrics on screen.

### 21. `complete` ★ priority
Sequence: `ANALYSING PERFORMANCE… COMPLETE` mono → `FINAL SCORE` → **87** 88px display with a gold bloom (`popIn`) → `/100` → rank pill `SUPERSTAR 🔥` (gold gradient wash) → mint "★ NEW PERSONAL BEST · +9 FROM LAST TIME" → four breakdown bars (Pitch 92% mint · Timing 88% gold · Consistency 81% teal · Energy 95% lime), each a label/value row over a 6px meter → Share / Save pair → "See the leaderboard" primary.
Timing: analysing 900ms, score pop 600ms, bars stagger 80ms apart.

---

## MOBILE — GAME MODES

### 22. `battle` ★ priority
Vertical split: red-tinted top half, teal-tinted bottom. `BATTLE MODE · ROUND 3` mono. Two player cards (56px squircle avatar, name 26px display, "level · N wins", score) with a 52px "VS" between them, pulsing. Battle track card. "Accept the battle" bone pill. "Back to lobby" text.

### 23. `team`
`TEAM BATTLE · SONG 3 OF 6`. Two team cards side by side (🔥 TEAM FIRE tangerine / ⚡ TEAM LIGHTNING teal) with 34px display totals. A single 8px split bar showing share (52% / 48%). "SINGING NOW · TEAM FIRE" card. Two roster columns with per-player scores ("singing" in team colour for the active one). "You sing next for Fire" primary.

### 24. `duet`
Header: `A · MATT` lime pill / `DUET` / `B · SARA` teal pill. Three stacked lyric blocks: Part A (lime left border 3px, lime-tinted fill, 19px), Part B (teal, dimmed to .6 when not yours), BOTH (dual-gradient fill, hairline, centred 22px display). Footer: two live scores split by a hairline. "Finish duet" primary.
Colour is the only cue that matters — never rely on position alone.

### 25. `pass`
`PASS THE MIC · SECTION 3 OF 6`. Big alert card: `GET READY, MATT!` + "2 LINES" 40px + "until the mic passes to you". Section list: done (dimmed, mint `DONE 91`), singing (teal fill + border), you-next (lime fill + border, pulsing `NEXT`), queued (dimmed). "YOUR UPCOMING LINE" card. "Take the mic" primary.
Notify the next singer two lines early — haptic + this screen.

---

## MOBILE — PROFILE

### 26. `leaderboard` ★ priority
Title · segmented control (Room / Friends / Global; active = lime pill, ink text) · **podium**: 2nd (52px avatar, 74px column), 1st (👑, 64px gold avatar with 34px bloom, 104px gold column, rank 30px, score 13px), 3rd (56px column) · full ranking rows below (rank numeral, avatar, name, level, score 19px display).

### 27. `history`
Title · filter pills (Recent active / Highest / By artist) · rows: art 48px, title, artist, date mono 8.5px, right column = score 21px display + rank mono in its colour (SUPERSTAR gold, GREAT mint, SOLID teal) · link to the empty state.

### 28. `achievements`
"JUST UNLOCKED" card (lime wash, 30px floating emoji, name, one-line proof: "92% on Neon Midnight — nice.") · "All badges" + "3 / 6 UNLOCKED" mono · 2-column grid: emoji 26px, name 13px, description 10.5px, then `✓ UNLOCKED` mint or progress `12 / 20` mono. Six badges: First Song, Pitch Perfect, Unstoppable, Karaoke Champion, Party Starter, Room Royalty.

### 29. `profile`
Header: 74px squircle avatar, name 23px, @handle, gold level chip `KARAOKE LEGEND · LV 24`, settings icon. Stats grid: SONGS 142 · AVG 84 · BEST 96 (lime-washed) · WINS 7 · FAVOURITE GENRE (2-wide). Tabs: Performances / Badges / Stats. Then the performance list (compact rows).

### 30. `settings`
MICROPHONE card: "Input level" + mint `GOOD` + live 30px meter. Rows: Audio quality (High · 256kbps) · Turn notifications (lime switch) · Appearance (Dark) · Privacy (Friends only) · Account (email) · Help & feedback. Sign out = danger button.

---

## MOBILE — EDGE STATES (all 12 are specified; build them)

| Key | Trigger | Treatment |
| --- | --- | --- |
| `emptyQueue` | Queue length 0 | 96px dashed ♫ tile, "Nothing queued yet", "The board is waiting. Whoever adds the first song sings first.", primary "Add the first song" |
| `noResults` | Search returns 0 | red-bordered field, 40px ⌕, "No songs match "zzqqx"", spelling hint, "TRY INSTEAD" genre pills |
| `micPerm` | Permission not granted | Bottom sheet over 90% scrim: 56px mic tile, "Karaoki needs your microphone", plain-language privacy line ("We listen only while you are singing… nothing is recorded or uploaded"), Allow primary + "Not now — I'll just watch" |
| `micLost` | Input drops mid-song | Red banner "Microphone disconnected / Scoring paused — the board is holding your slot", lyrics dimmed to 35%, "RECONNECTING" 3-dot indicator, bone "Reconnect microphone" |
| `weak` | RTT > 500ms | Gold banner "Weak connection — lyrics running locally, score syncs when you're back", lyrics stay full brightness, LATENCY 840ms + SCORE "syncing…" cards, "Keep singing anyway". Status bar also shows `◔ WEAK` |
| `dropped` | Peer presence lost | Red card "Dawit dropped out / Holding their queue slot for 0:47" with a live countdown, roster below, Skip their slot / Wait for them |
| `roomFull` | capacity reached | 88px 🚪 tile, "This room is full", "10 of 10 singers", Spectate on the board / Notify me when free |
| `badCode` | code not found | Red field + shake, "No room with that code. Codes look like KARA-7821.", Autofill / Try again / Scan instead |
| `unavailable` | licence gap | Desaturated cover art with 🚫, "Not available in your region", 3 alternates the room has sung before |
| `noHistory` | new user | 100px dashed mic tile, "No performances yet", primary "Pick your first song" |
| `noBadges` | new user | Dashed 🔒 card naming the closest badge ("First Song — one performance away"), full grid greyscaled at .45 |
| `waiting` | host idle / not all ready | "Waiting for the room", "2 players still picking songs", tappable roster that toggles ready, three pulsing dots, "Start anyway" |

---

## KARAOKE BOARD

### B1. `bwait` ★ priority — room waiting
Two columns (1.15fr / 0.85fr).
Left: logo tile + `KARAOKI BOARD` mono · room name 54px display · `ROOM CODE` mono · **code 94px display** with an animated bone→lime→bone gradient sweep (5s) · instruction 24px "Scan the QR code or enter the room code on your phone." · pill marquee ticker (42px, 20s loop: SCAN TO JOIN / KARA-7821 / 4 SINGERS CONNECTED / TEAM BATTLE TONIGHT) · three meta pills (mode, MAX 8 PLAYERS, PRIVATE ROOM mint).
Right (hairline-separated, subtle fill): QR on a bone card, 13×13 modules at 12px with 2px gaps, radius 24 (use a real QR encoding the join URL) · "CONNECTED 4 / 8" · player cards that `popIn` as phones join.

### B2. `bqueue` — song queue
Left: `NOW PLAYING` mono lime · 196px cover art + title 48px + artist 24px + requester chip with a 4-bar equaliser · elapsed / 8px progress / duration · host-control chips (Pause, Skip, Reorder) plus a caption noting control lives on the host's phone.
Right: `UP NEXT` + count · queue rows (position 26px, art 58px, title 21px, artist 16px, requester avatar + name) · dashed footer "Add songs from your phone — they appear here instantly".

### B3. `bcount` — countdown
Full-bleed radial lime. `MATT · NEON MIDNIGHT` mono tracking .32em · 420px ring stack with `ringOut` · numeral 200px display (`3` → `2` → `1` → `SING!`, each with `popIn`) · footer hint. Drive from the same clock as the song.

### B4. `bperf` ★ priority — performance
Header: cover art 62px + title 25px + artist/genre · right: red `LIVE` pill, mode pill, elapsed/duration pill.
5px progress bar with lime bloom, 44px side margins.
Centre (flex-1, the star): previous 30px bone/20 · **current 58px display with the wipe** (max-width 1120px, drop-shadow lime glow) · next 33px bone/42.
Bottom rail, 4 columns (1 / 1 / 1.15 / 1): `01 / NOW SINGING` (50px avatar with ringOut + name 26px) · `02 / LIVE SCORE` (44px display, lime-washed panel) · `03 / PITCH TRACK` (mono pitch% · timing% + 18-bar 50px equaliser) · `04 / COMBO` (🔥 34px + `x{n}` 40px gold).
Footer strip: `UP NEXT` + queue pills (30px art + title + requester).

### B5. Live performance view
Same as B4 — the score/pitch/combo rail *is* the live view. Keep it below the lyrics; never let it exceed ~22% of screen height.

### B6. `bvs` — multiplayer / team
105° split background (red left, teal right). Header `BATTLE MODE · FINAL ROUND · {song}`. Three columns: player A (150px avatar with a 70px colour bloom, name 64px display, score 96px display, 12px meter, mono `PITCH n% · 🔥 xN`) · `VS` 96px display pulsing · player B mirrored. Footer: team aggregate pills (TEAM FIRE 184 / TEAM LIGHTNING 167).

### B7. `breveal` — score reveal
Two columns. Left: avatar + name 66px display · `FINAL SCORE` mono tracking .3em · **206px display score** with a gold bloom and `popIn` · rank pill 34px `SUPERSTAR 🔥` · mint "★ NEW ROOM RECORD FOR {song}".
Right (hairline-separated): `BREAKDOWN` — four label/value rows (20px) over 12px meters, staggered in · then a `ROOM RANKING` panel listing every player with rank, avatar, name, score.

### B8. `blead` — podium
Header: `ROOM LEADERBOARD` mono + room name 46px display; right "AFTER 6 PERFORMANCES · {mode}".
Podium: 2nd (96px avatar, 196px column) · 1st (👑 42px, 120px gold avatar with an 80px bloom, name 40px, 290px gold column, rank 96px, score 40px, `SUPERSTAR 🔥` mono) · 3rd (148px column). Footer: 4th-place row + "Next up: {song} — {player}" dashed strip.
Re-render after every performance with the new ordering animated (400ms position transition).
