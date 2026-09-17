# Design: QuackDoku MVP

## Technical Approach

Build a portrait, touch-first Godot 4.6 application under `project/`. Static case data drives a deterministic constraint engine; scenes only render state. A separate tutorial teaches the same engine before one guided mansion case. No network-capable SDKs are included.

## Architecture Decisions

| Option | Tradeoff | Decision and rationale |
|---|---|---|
| Godot vs Flutter/React Native | Godot cannot export native iOS here but includes game tooling | Choose Godot 4.6/GDScript for the fixed Android target; alternatives add engine work. |
| Scene rules vs domain modules | Modules add boundaries | Use thin scenes plus `domain/`, `data/`, and `services/` so rules remain UI-independent and testable. |
| Generated vs authored case | Generation complicates narrative | Ship one authored case; a backtracking solver stops after two solutions and permits play only when count is one. |

## Scene and Data Flow

`Bootstrap -> Start/Resume -> Tutorial -> MansionExplore -> CaseBoard -> Accusation -> Ending`

`MansionExplore` reveals dialogue/clues in a guided sequence. `CaseBoard` sends intents to `CaseSession`; accepted changes autosave and invalid changes return narrative feedback. A solved board unlocks accusation. `Ending` resolves the murder, awards a keepsake, then shows an optional sealed invitation; no sequel is required.

`CaseDefinition` contains six values per category (`suspect`, `room`, `time`, `item`), constraints (`equals`, `not_equals`, `before`, `adjacent`), dialogue IDs, and murderer rule. Category-pair cells store `UNKNOWN`, `EXCLUDED`, or `CONFIRMED`; confirmation enforces one-to-one rows/columns. The solver enumerates satisfying bijections and records `solution_count` plus a canonical-solution hash.

## Interfaces / Contracts

```gdscript
class_name CaseSolver
func validate(definition: CaseDefinition) -> ValidationResult
func apply(state: CaseState, move: GridMove) -> MoveResult

class_name SaveRepository
func save(snapshot: ProgressSnapshot) -> Error
func load_valid(case_version: String) -> ProgressSnapshot
func discard() -> void
```

`ProgressSnapshot` is JSON at `user://progress-v1.json`: versions, flow step, revealed clues, matrices, tutorial completion, collectible, and checksum. Writes use temporary-file atomic replacement; invalid or incompatible data is discarded. Save after accepted moves, clue reveals, transitions, and background notification.

## Assets, Provenance, and Expression

Current 1254×1254 PNGs remain byte-identical. An editor-only pipeline creates one immutable `assets/source-baseline/` snapshot, then reads `assets/` and emits nearest-neighbor derivatives into `project/assets/generated/`; source paths are never outputs. `project/assets/manifest.json` records URL/owner, license, modification rights, source/derived SHA-256, pipeline version, and mappings. Audio also retains its verified CC0 page and `LICENSE.txt`; unverified assets fail review.

`project/docs/expression-review.md` requires evidence/sign-off for original art/palette, names, dialogue, clue wording, UI composition, and mansion layout. Recognizable copied expression blocks delivery; abstract grid mechanics do not.

## File Changes

| File | Action | Purpose |
|---|---|---|
| `project/project.godot`, `project/export_presets.cfg` | Create | Engine, portrait scaling, Android APK profile |
| `project/scenes/{bootstrap,tutorial,mansion_explore,case_board,accusation,ending}.tscn` | Create | Runtime flow |
| `project/scripts/domain/{case_definition,case_state,case_solver}.gd` | Create | Data and constraints |
| `project/scripts/services/{case_session,save_repository,scene_router,audio_service}.gd` | Create | Orchestration/autoloads |
| `project/data/cases/mansion_case.json`, `project/data/dialogue/mansion.json` | Create | Authored case/narrative |
| `project/tools/asset_pipeline.gd`, `project/assets/manifest.json` | Create | Non-destructive derivation/provenance |
| `project/docs/{expression-review,reference-device,smoke-test}.md` | Create | Release evidence |
| `project/tests/{unit,integration}/` | Create | Solver/save/scene tests |
| `assets/source-baseline/`, `assets/audio/` | Create | Recovery copies and verified CC0 sources |
| Existing `assets/**/*.png` | Preserve | Immutable source art |

## Testing Strategy

| Layer | Coverage |
|---|---|
| Unit | Row/column propagation, every clue operator, contradiction handling, 0/1/2-solution fixtures, murderer determinism, save checksum/version. |
| Integration | Scene transitions, tutorial gates, autosave/resume, corrupt-save reset, ending/hook, manifest hashes. |
| Device E2E | Full sideloaded APK playthrough, force-quit resume, and evidence checklist on the recorded reference unit. |

`reference-device.md` records model, Android version, RAM, screen, refresh rate, build hash, and tester. Baseline: ARM64 Android 12+, 4 GB RAM, 1080×2400-class 6–7-inch display; 60 FPS target (never sustained below 30), feedback ≤200 ms, cold launch <10 s, mansion load <2 s, ≥48 dp targets, and no-zoom legibility. Record the exact unit before acceptance.

## Threat Matrix

N/A — runtime is local-only and introduces no routing, shell, subprocess, VCS/PR automation, executable classification, or external process-integration boundary; editor tooling uses Godot APIs in-process.

## Migration / Rollout and Rollback

No migration; distribute only a sideloaded test APK. Rollback removes `project/`, generated derivatives, audio additions, and builds while retaining OpenSpec. Restore any changed source byte-for-byte from `assets/source-baseline/`, verify its manifest hash, and never generate over originals. Two failed Android exports return the change to design.

## Open Questions

- [ ] Record the exact physical reference-device model before Android acceptance testing.
