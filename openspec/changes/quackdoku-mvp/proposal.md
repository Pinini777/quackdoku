# Proposal: QuackDoku MVP

## Intent

Deliver an Android-first, original duck-detective deduction game: a short, comic mansion mystery that proves the core play loop on a current mid-range phone without dark patterns, copied Murdoku expression, or native iOS delivery.

## Scope

### In Scope
- Separate, guided tutorial followed by one mansion case with a detective duck, six eccentric suspects, brief dialogue, and a classic logic grid.
- Four original mechanics: one-per-row, one-per-column, clue constraints, and murderer identification after a solved board; guided exploration and narrative-only error feedback.
- Completion reward: revelation, collectible, and next-case hook; local resume state; CC0 music/SFX verified before release.
- Godot 4.6 Android build path, asset slicing/downscaling, touch UI, and real-device smoke test.

### Out of Scope
- Native iOS build, App Store release, networking, accounts, cloud save, telemetry, monetization, ads, timers, daily rewards, or loot boxes.
- Additional cases, scenes, difficulty tiers, violent graphic content, and non-CC0 audio.

## Capabilities

### New Capabilities
- `guided-tutorial`: teach the grid interaction before the case in five minutes or less.
- `duck-deduction-case`: run the original mansion puzzle, clue flow, narrative feedback, and ending reward.
- `local-case-progress`: preserve one in-progress case locally across an app restart.
- `android-game-delivery`: export, install, and smoke-test the MVP on the reference Android device.

### Modified Capabilities
None — `openspec/specs/` has no existing capability specifications.

## Approach

**Decision: use Godot 4.6 as the primary Android-first stack.** The exploration's official Godot documentation evidence covers Android export, iOS's macOS/Xcode requirement, nearest-neighbor/integer pixel-art guidance, AudioServer, and size optimization; it does not guarantee device performance, APK size, or iOS availability. Native iOS is not a contingency for this MVP: both Godot and Flutter builds and publication require macOS with Xcode. React Native/Expo is excluded from the game core because the exploration found no engine layer appropriate for this scope.

## Affected Areas

| Area | Impact | Description |
|---|---|---|
| `project/` | New | Godot project and game runtime (apply phase). |
| `assets/escenarios/mansion.png` | Modified | Slice and anchor the mansion grid. |
| `assets/patos-personajes.png` | Modified | Derive six original game sprites. |
| `assets/audio/` | New | CC0 assets with source license records. |

## Risks

| Risk | Likelihood | Mitigation |
|---|---|---|
| Android export or device target fails | Medium | Prove APK install and one full playthrough early; redesign before further scope. |
| Native iOS is later requested without macOS/Xcode | Medium | Keep iOS out of this MVP; schedule native iOS work only after a macOS environment with Xcode is available. |
| Asset slicing delays gameplay | High | Make derived grid/sprites explicit, reviewable tasks. |
| CC0 provenance is incomplete | Low | Hand-verify license pages and retain `LICENSE.txt` per imported asset. |
| Murdoku identity leaks into content | Medium | Require original art, names, clues, and dialogue review. |

## Rollback Plan

Revert the new `project/` and derived asset/audio additions, retain source assets and SDD artifacts, and return to proposal/design. Do not substitute another cross-platform framework as an iOS workaround: native iOS work remains deferred until macOS with Xcode is available.

## Dependencies

- Godot 4.6, a current mid-range Android device, and CC0 assets whose license is manually verified.
- Any future native iOS build or publication—whether using Godot or Flutter—requires a macOS host with Xcode; this is not an Android MVP dependency.

## Success Criteria

- [ ] Android APK installs on the reference device and completes the mansion case without a crash.
- [ ] A new player reaches the first grid in five minutes or less and can resume a force-quit case.
- [ ] The puzzle produces one deterministic murderer with original clues and no graphic violence.
- [ ] All shipped audio has a verified CC0 record; no monetization or dark-pattern mechanism is present.

## Proposal Question Round

Provided approvals resolve the MVP's product choices. Before specs, stakeholders may correct these assumptions or request a second product-question round; no delivery or review judgment has been performed.
