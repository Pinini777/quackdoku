# Exploration: quackdoku-mvp

> SDD exploration phase for the `quackdoku-mvp` change.
> Artifacts of evidence are labeled **(Evidence)** and items that are the author's recommendation or hypothesis are labeled **(Recommendation)**.
> Sources are listed at the bottom with URL and access date 2026-09-16.

## Quick path

- **Stack recommendation (Recommendation):** **Godot 4.6** for an Android-first MVP that must be installed and played on a phone before SDD close. Defer native iOS export unless a macOS host is available; if unavailable, use Godot's HTML5 export for iOS-side smoke testing only. Reasoning in §3 and §6.
- **Mechanics (Evidence + Recommendation):** keep only four Murdoku core mechanics (one-per-row, one-per-column, clue cards as logical constraints, end-of-board murderer identification), and replace all copy, art, and naming with duck-themed originals. No region-specific puzzles in MVP; one scene only.
- **Retention posture (Recommendation):** ethical-only MVP. No daily-login rewards, no countdown timers, no paywall, no loot boxes. Onboarding must be completed in **≤5 minutes** (industry baseline, see §2). Session target: 3–8 minutes per case.
- **Asset reality (Evidence):** `assets/escenarios/` holds six 1254×1254 PNGs and `assets/patos-personajes.png` is also 1254×1254. These need slicing, downscaling, and grid-anchoring before any engine can consume them (see §6).
- **Sound (Recommendation):** start with **OpenGameArt CC0 Chiptune FX** and **CC0 Chiptune Music** collections. CC0 means no attribution required, but the OpenGameArt generator warns that auto-generated credits must be hand-verified.
- **MVP scope (Recommendation):** one playable case, one scene, six characters, one murder mystery, no save system beyond local SQLite/JSON, no networking, no monetization. Explicit non-goals in §5.

## 1. Murdoku core mechanics — what to keep, what to change

**(Evidence)** The mechanics that define Murdoku, as documented by the creator Manuel Garand and corroborated across multiple secondary sources, are:

1. **Spatial placement, not arithmetic.** Each suspect + the victim occupy squares on an illustrated map; numbers are not used (murdoku.fans, *Murdoku Explained* by Shigjeta.net, May 2026).
2. **One person per row, one per column.** Confirmed placement blocks that row and column for every other character (murdoku.com official how-to-play).
3. **Clue cards as logical constraints.** Each suspect has a written card describing rooms, objects, directions, or relationships (beside, north-of, alone-with, etc.). All cards must be true simultaneously.
4. **Murderer identified only after the board is solved.** The killer is the person alone with the victim in the same region. Treating this as an endgame check prevents false shortcuts (murdoku.fans advanced strategy).
5. **Optional per-scene twists.** The creator layers scene-specific rules (locked cells, ordered characters, role restrictions) as difficulty increases.

**(Evidence)** Difficulty variants the original series uses: Courtroom (easy), Preppers (medium), Horse Track / Zoo / Solitary (expert). Puzzles run from "very easy to expert level" and are weekly-updated (murdoku.com; Escape Puzzler interview, Aug 2026).

**(Recommendation)** For QuackDoku MVP we keep the *form* of (1)–(4) and discard (5) until post-MVP. We change every surface element so the game does not inherit Murdoku's identity, characters, scenarios, copy, or art:

- Replace suspect / victim / scene nouns with duck-themed originals (e.g., `mansion.png` becomes "La Mansión del Lago", a duck country house).
- Write fresh clue cards. Do **not** paraphrase Murdoku clues; the goal is a different puzzle experience that shares only the constraint structure.
- Use a smaller grid for MVP (5×4 or 5×5) so a phone form factor remains comfortable.

## 2. Ethical mobile-game retention for the MVP

**(Evidence)** Multiple peer-reviewed and industry sources document that the dominant dark patterns in mobile F2P are: aggressive monetization within the first 15 minutes, daily-login escalation with loss aversion, "playing by appointment" timers, randomized reward boxes, and visual interference during purchase flows (arXiv 2511.17512; arXiv 2412.05039; Theseus 2025).

**(Evidence)** Specific guidance drawn from the sources:

- A **5–10 minute onboarding** window is the recommended maximum before the player reaches core gameplay (arXiv 2511.17512, citing Bycer 2019).
- **Session length** for casual mobile puzzle play clusters at 3–8 minutes (Theseus 2025 case studies; market data discussed in arXiv 2412.05039). Long sessions are an ethical risk indicator, not a retention win.
- **Healthy engagement signals** identified in workshop research (DTU Orbit, 2024): players report "interested" as the felt experience most worth designing for; "annoyed," "disappointed," and "manipulated" as the unintentional states that should be detected and reduced.
- **Ethical disengagement** interventions (loading-delay, grayscale overlay) measurably reduce playtime and are studied as user-autonomy support (ACM doi 10.1145/3712281, 2025).

**(Recommendation)** The MVP follows an explicit no-dark-pattern policy, recorded in `proposal.md` and enforced in `specs/`:

| Concern | MVP rule |
| --- | --- |
| Onboarding length | Core gameplay reachable in **≤5 minutes** from cold install |
| Session target | 3–8 minutes per case, no forced length |
| Rewards | No daily-login. No loot boxes. No variable-reward chests. |
| Timers | No real-time countdowns or "energy" gates |
| Monetization | **None.** No IAP, no ads, no subscription. Pricing discussion deferred. |
| Push notifications | **None.** Session-end only. |
| Progress loss | Auto-save after each placement so accidental close does not punish |
| Child safety | Photosensitive-safe (no flash >3 Hz; ACMA guidance), parental-consent placeholders for future IAP flows |

**(Evidence)** Regulatory context (boardgames.news, Jan 2026): the Italian AGCM opened probes into Activision Blizzard for "misleading and aggressive" sales practices tied to long-session encouragement and impulse buys. Building without monetization today keeps the regulatory surface near zero.

## 3. Three open-source stacks — comparison

All three candidates can ship to Android and iOS. The comparison is calibrated for a single Android device install + MVP timeline.

### 3.1 Godot 4.6 (MIT-licensed engine, GDScript or C#)

| Capability | Source (verified) | Note for MVP |
| --- | --- | --- |
| Android export | docs.godotengine.org 4.5 Android export guide; developer.android.com Godot export | APK or AAB via Gradle; ARM32/ARM64 selectable. |
| iOS export | docs.godotengine.org 4.5 iOS export guide | **Requires macOS with Xcode.** Cannot be built from Windows or Linux. |
| Pixel-art rendering | projectsettings doc, `rendering/textures/canvas_textures/default_texture_filter` = 0 (nearest) | First-class: integer-scaling viewport recipe documented in `multiple_resolutions.rst`. |
| Audio | `class_audioserver` API; bus routing | Built-in OGG/MP3/WAV playback; no external dependency. |
| Size optimization | `optimizing_for_size.rst`; `optimize=size_extra` since 4.5 | Custom template build can shrink APK/AAB significantly. |
| License | MIT (engine) + AssetLib terms | Engine itself is permissive; AssetLib assets carry their own licenses. |

**(Recommendation)** Godot is the strongest MVP path for Android: it is a real game engine with a pixel-art pipeline that requires no custom code, supports Android export from Windows without macOS, and the engine license is MIT (no surprise GPL contamination). The blocker is iOS, which we address in §6.

### 3.2 Flutter + Flame (Flutter: BSD; Flame engine: MIT)

| Capability | Source (verified) | Note for MVP |
| --- | --- | --- |
| Mobile support | `doc/flame/platforms.md` (Flame docs) | Inherits Flutter cross-platform; iOS and Android supported. |
| Sprite rendering | `sprite_components.md`; `flame_texturepacker`; `flame_fire_atlas` | SpriteComponent + atlas loaders available out of the box. |
| Audio | `flame_audio` README + `audio.md` + `audio_pool.md` | AudioPool pattern documented for repeated SFX; pre-load in `onLoad`. |
| Pixel art | `tutorials/platformer/step_1.md` | Pixel art is documented as the recommended starter asset style; nearest-neighbor filtering is a Flutter configuration choice. |
| Performance | Markaicode guide (Mar 2025) | Flutter "wins on animation-heavy rendering"; ~60 FPS for game-like scenes. |
| License | Flutter BSD-3, Flame MIT | Permissive. |

**(Recommendation)** A solid second choice. Pros: same codebase covers Android + iOS from one host (Windows or macOS) without a Mac requirement, and Flutter's UI primitives double for menus/HUD. Cons: no first-class tile/puzzle engine; you build the deduction constraint solver yourself on top of Flame components.

### 3.3 React Native + Expo (MIT)

| Capability | Source (verified) | Note for MVP |
| --- | --- | --- |
| Mobile support | `expo/expo` repo; `expo.dev` EAS docs | Builds for Android (AAB/APK) and iOS (IPA) via EAS Build; CI-ready. |
| Game engine layer | **None.** grzegorzotto.dev, "React Native game engine gap in 2026" (May 2026) | RN has no full game engine — only Skia renderer or WebView-hosted Phaser. |
| Performance on Android | Shopify/react-native-skia#2521 (community) | Cheap-Android budget ~300 sprites before frame drops on `useRSXformBuffer`. |
| Animation FPS | Applighter 2026 benchmark | ~56–58 FPS for 60 FPS animations; 51.3 FPS complex transitions. |
| License | MIT (React Native + Expo SDK) | Permissive. |

**(Recommendation)** **Not suitable** for a pixel-art deduction game on mobile. The ecosystem has no credible native game engine in 2026 (confirmed by the grzegorzotto.dev gap analysis). Skia + Reanimated can be coerced into a sprite batcher, but the engine work (scenes, input, audio, asset pipeline, ECS) becomes the project, not the starting point. Expo + RN is correct for content CRUD apps, not for a tile-based puzzle.

### 3.4 Stack decision matrix

| Criterion | Godot 4.6 | Flutter + Flame | Expo + RN |
| --- | --- | --- | --- |
| Time to first playable puzzle on Android (1 dev, 1 phone) | Days | 1–2 weeks | 2–4 weeks (engine work) |
| Pixel-art first-class | **Yes** | Manual config | Manual config + renderer work |
| iOS export from Windows | No (needs macOS) | **Yes** | Yes (EAS cloud) |
| Audio built-in | Yes | Yes (flame_audio) | Reanimated + expo-av, manual sync |
| License | MIT | BSD + MIT | MIT |
| Open source asset ecosystem | Godot AssetLib | Pub.dev | None game-specific |
| Engine layer present | **Yes** | Partial (components) | **No** |
| Recommended for MVP | **Yes (Android-first)** | Yes (if iOS required) | **No** |

**(Recommendation)** **Godot 4.6** as primary. **Flutter + Flame** as a fallback if macOS is unavailable for the iOS path and iOS install is mandatory. **Expo + RN** is rejected.

## 4. Open-source sound and music — license verification

**(Recommendation, with evidence)** Use **CC0** sources for MVP to minimize legal review cost. Attribution is not legally required for CC0 but the OpenGameArt generator explicitly warns the auto-credit file "is in no way guaranteed to be accurate" and that the user must hand-verify before shipping.

| Resource | Type | License | URL | Verified use |
| --- | --- | --- | --- | --- |
| CC0 Chiptune FX | SFX pack | CC0 | opengameart.org/content/cc0-chiptune-fx | UI blips, clue reveal, success/fail |
| CC0 Chiptune Music | Music loops | CC0 | opengameart.org/content/cc0-chiptune-music | Background BGM, end-of-case sting |
| SoundFX Library [CC0] | SFX | CC0 | opengameart.org/content/soundfx-library-cc0 | Generic SFX fallback |
| IgnisForge SFX Sampler | 43 retro SFX | CC0 | opengameart.org/content/ignisforge-free-sfx-sampler | Synthesis-based, deterministic provenance |
| CC0 BGM | Loops + retro boss | CC0 | opengameart.org/content/cc0-bgm | Alternate themes per difficulty |

**Verification rules before integrating any track:**

1. Open the asset's license page. Confirm CC0 1.0 wording (no "non-commercial" or "no-derivatives" clause).
2. Download the credits metadata from OpenGameArt and **hand-edit** the generated credits file before shipping. The site tells you to do this explicitly.
3. Mirror every imported file in `assets/audio/<source>/LICENSE.txt` so attribution is preserved if the upstream asset is later deleted.
4. Keep the **original OGG/MP3** and a **16-bit WAV** backup so format conversion never costs audio quality.

**(Open question, surfaced for proposal phase)** Whether to commission an original BGM under work-for-hire. For MVP, CC0 only.

## 5. MVP scope — what is in, what is out

### 5.1 In scope (must ship to claim MVP)

| Item | Specification | Acceptance signal |
| --- | --- | --- |
| One playable case | Duck-themed original; no Murdoku copy | Player completes a 5×4 grid with one clue set |
| One scene | Single illustrated background (e.g., `mansion.png` after re-slice) | Scene loads in <2 s on a mid-tier Android |
| Six characters | Duck sprites with clue cards | All six placed on the grid; murderer identified |
| Clue solver | Pure-logic solver with no guessing | A second pass of the same puzzle always yields the same murderer |
| Touch UI | Tap-to-place, tap-to-remove, X-mark for impossible cells | Matches documented Murdoku mobile UX patterns |
| Feedback | Haptic-safe particle blip on placement; chiptune success/fail stings | No flash >3 Hz |
| Local save | Single-slot JSON or SQLite; survives kill | App force-quit during play → restart resumes mid-case |
| Install + smoke test | APK installs on a real Android phone | `adb install` succeeds; full case played end-to-end without crash |

### 5.2 Out of scope (explicit non-goals)

- iOS App Store submission (only smoke-tested via HTML5 export or skipped if no macOS host).
- Multiple scenes, multiple cases, difficulty tiers.
- Daily-rewards, login bonuses, energy systems, any timer.
- Ads, IAP, subscriptions, monetization of any kind.
- Multiplayer, leaderboards, social sharing.
- Account systems, cloud save, telemetry beyond crash logs.
- Localization beyond `es-AR` and `en-US`.
- Accessibility beyond photosensitive-safe defaults and large hit targets (≥48 dp).
- Performance optimization beyond "runs at 60 FPS on a mid-tier Android".

### 5.3 Success criteria (Evidence-based)

- **Install** on a real Android device in <60 s.
- **First case completed** by the developer within ≤5 minutes of first launch (matches the §2 onboarding rule).
- **Zero crash** during a 30-minute play session of the single case.
- **Single APK size** target ≤40 MB after `optimize=size_extra` export.

### 5.4 Rollback criteria

- If the engine cannot export a working APK after two full attempts within the planned apply window, the change reverts to proposal redesign.
- If the asset pipeline cannot ingest the existing `assets/escenarios/*.png` without manual pixel-by-pixel re-drawing, the proposal revisits asset strategy.

## 6. Current state and asset needs

### 6.1 Repository state (Evidence)

- `openspec/config.yaml` exists; `strict_tdd: false`; project marked "no application scaffold detected".
- `openspec/specs/` and `openspec/changes/` exist but contain only `.gitkeep`. No prior exploration, proposal, specs, design, or tasks artifacts.
- **No Git repository** at the project root (verified by `Is directory a git repo: no` from environment). Version control is deferred per the user's instructions.
- `.atl/skill-registry.md` lists installed user-level skills.
- Assets present (verified dimensions):
  - `assets/escenarios/baño.png` 1254×1254
  - `assets/escenarios/cine.png` 1254×1254
  - `assets/escenarios/gimnasio.png` 1254×1254
  - `assets/escenarios/mansion.png` 1254×1254
  - `assets/escenarios/patio.png` 1254×1254
  - `assets/escenarios/salonprincipal.png` 1254×1254
  - `assets/patos-personajes.png` 1254×1254

### 6.2 Asset gaps for the MVP

**(Evidence)** 1254×1254 PNGs are too large to load directly as pixel-art tiles. They must be sliced into logical regions and downscaled to a tile grid before any engine consumes them.

**(Recommendation)** Required asset derivations, ordered by priority:

| Asset | Source | Action | Suggested output |
| --- | --- | --- | --- |
| Tile grid overlay | `mansion.png` (MVP scene) | Slice to a 5×4 grid; mark "wall" cells (non-walkable) and "object" cells (chair, table, plant) | `assets/scenes/mansion_tiles.png` 320×256 + `mansion_meta.json` listing blocked cells and object anchors |
| Character sprites | `patos-personajes.png` | Slice into 6 character portraits + 6 tile-sized sprites (one per character) | `assets/characters/<name>_portrait.png` 64×64 and `<name>_sprite.png` 32×32 |
| Victim marker | New asset | A single 32×32 sprite, distinctly colored (e.g., red X) | `assets/characters/victim_marker.png` |
| Cursor / UI icons | New asset | X-mark, undo, submit, hint | `assets/ui/icon_*.png` 32×32 each |
| Audio | External CC0 | As listed in §4 | `assets/audio/sfx/` and `assets/audio/bgm/` |

**Format conventions** (Recommendation):

- Sprite sheets in PNG with no alpha on the background tile (clean blit).
- JSON metadata next to each sheet: `{ "frame_w": 32, "frame_h": 32, "frames": ["duck_red_idle", "duck_red_blink"] }`.
- Pixel art uses nearest-neighbor filtering. Sprite coordinates are integer multiples of the tile size.

### 6.3 Open questions to surface in proposal

1. Is a macOS host available for iOS export, or do we treat iOS as deferred / smoke-tested via HTML5?
2. What is the target Android device tier (mid-range Pixel 6-class vs budget A16-class)? Drives the `optimize=size_extra` decision.
3. Do we want the mansion scene as the MVP scene, or pick one based on visual narrative fit after the duck sprites are sliced?
4. Are original chiptune tracks desired, or is CC0 acceptable for MVP?

## 7. Affected areas (no code changes in this phase)

This phase creates no source files. The files that *will* be touched in later phases, based on this exploration:

- `openspec/changes/quackdoku-mvp/exploration.md` — **this file**.
- `openspec/changes/quackdoku-mvp/proposal.md` — next phase (sdd-propose).
- `openspec/changes/quackdoku-mvp/specs/<domain>/spec.md` — sdd-spec.
- `openspec/changes/quackdoku-mvp/design.md` — sdd-design.
- `openspec/changes/quackdoku-mvp/tasks.md` — sdd-tasks.
- (apply phase, future) Godot project files under a new `project/` directory; `assets/` reorganized per §6.2.

No file outside the `openspec/` tree is to be modified during exploration. The assets/ tree is read-only during this phase.

## 8. Risks

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| iOS export blocked by lack of macOS | High (Windows host confirmed) | iOS install goal at SDD close is unmet | Use Godot HTML5 export for iOS-side UX smoke test; defer native iOS to post-MVP. |
| 1254×1254 PNGs require non-trivial slicing | High | Adds 1–2 days to asset pipeline | Slice in apply phase as a documented task with verifiable output PNGs. |
| Engine chosen (Godot) requires the developer to learn GDScript or C# | Medium | Schedule slip | GDScript is intentionally Python-like; C# option exists if the developer prefers. Plan a 30-minute spike task in `tasks.md`. |
| CC0 asset provenance changes upstream | Low | License review rework | Local mirror of every imported file with LICENSE.txt. |
| Murdoku's identity leaks through accidentally (clue wording, art style) | Medium | Brand/IP risk | Write fresh duck-themed clues in proposal/spec. Reviewer checklist: every clue and sprite inspected for originality. |
| Onboarding overshoots 5-minute budget | Medium | Ethical posture violation | Onboarding is a spec'd scenario with a measurable timing test. |
| Android phone is too old to run Godot 4.6 | Low | Cannot demo MVP | Confirm device tier in proposal Q2. |

## 9. Ready for proposal

**Yes.** The orchestrator can advance to `sdd-propose` for `quackdoku-mvp`. The proposal should:

- Adopt the four-mechanic core from §1 (one-per-row, one-per-column, clue cards, end-game murderer check).
- Adopt the no-dark-pattern retention policy from §2.
- Recommend Godot 4.6 as the primary stack per §3.
- Adopt the CC0 audio sourcing rule from §4.
- Bind the MVP scope to §5 with the explicit non-goals.
- Address the open questions in §6.3.

## 10. Sources consulted

**Murdoku mechanics**

- murdoku.com — official site, how-to-play and free weekly puzzles. (Accessed 2026-09-16.)
- murdoku.fans/en/murder-mystery-sudoku/ — comparison to Sudoku.
- murdoku.fans/en/how-to-play/ — UI mechanics (X-mark, long-press to lock, hold-and-drag).
- murdoku.fans/en/murdoku-advanced-strategy/ — no-guess solving methodology.
- murdoku.fans/en/murdoku-vs-murdle/ — contrast with Murdle.
- Shigjeta.net, "Murdoku Explained" (2026-05-31) — creator attribution, mechanics, difficulty tiers.
- Escape Puzzler interview with Manuel Garand (2026-08-06) — creator intent, future volumes.
- Moyens.net, "Murder Mystery Sudoku" (2026-06-02) — secondary review.

**Ethical retention**

- arXiv 2511.17512 — "First Contact with Dark Patterns and Deceptive Designs in Chinese and Japanese Free-to-Play Mobile Games."
- arXiv 2412.05039 — "Level Up or Game Over: Exploring How Dark Patterns Shape Mobile Games."
- Theseus.fi 2025 — "Dark Patterns in Free to Play Mobile Gaming" (Dimache).
- DTU Orbit 2024 — "A Game of Dark Patterns: Designing Healthy, Highly-Engaging Mobile Games."
- boardgames.news 2026-01-22 — "Dark Patterns in Mobile Games: Designer Guide," AGCM regulatory context.
- ACM doi 10.1145/3712281 (2025-03-03) — "Ethical Disengagement in Mobile Games."

**Stacks — Godot**

- godotengine/godot-docs repo — exporting_for_ios.rst, exporting_for_android.rst, multiple_resolutions.rst, projectsettings.rst (texture_filter default), optimizing_for_size.rst.
- developer.android.com/games/engines/godot — official Android export documentation.

**Stacks — Flutter + Flame**

- flame-engine/flame repo — sprite_components.md, platforms.md, flame_audio README, audio.md, audio_pool.md, flame_texturepacker, flame_fire_atlas.
- flame-engine.org "Getting Started" docs.
- Markaicode guide (2025-03-21) — Flutter + Flame 3.0 cross-platform guide.

**Stacks — React Native + Expo**

- expo/expo repo — submit/testflight.mdx, submit/android.mdx, tutorial/eas/android-production-build.mdx.
- grzegorzotto.dev (2026-05-11) — "The React Native game engine gap in 2026."
- grzegorzotto.dev (2026-06-01) — "Skia Atlas in React Native: batching 2,000 sprites."
- Shopify/react-native-skia issue #2521 — "Low Atlas performance on cheap Androids."
- Applighter 2026-05-09 — "React Native Performance Benchmarks: Expo vs Bare vs Flutter vs Native."

**Open-source audio**

- opengameart.org/content/cc0-chiptune-fx.
- opengameart.org/content/cc0-chiptune-music.
- opengameart.org/content/soundfx-library-cc0.
- opengameart.org/content/ignisforge-free-sfx-sampler-43-synthesized-retro-sound-effects.
- opengameart.org/content/cc0-bgm.

**OpenSpec convention**

- openspec.dev/docs/schemas/spec-driven — artifact order and folder shape.
- openspec.dev/docs/getting-started — change folder layout.
- Fission-AI/OpenSpec `docs/getting-started.md` — change folder structure.
- gentleman-programming-agent-teams-lite / sub-agents / openspec-convention — `exploration.md` placement under `openspec/changes/{change-name}/`.

---

*End of exploration. No code or assets were modified in this phase. All recommendations require user confirmation before they bind into a proposal.*
