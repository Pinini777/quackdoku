# Tasks: QuackDoku MVP

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | 1,200–1,600 |
| 400-line budget risk | High |
| Chained PRs recommended | Yes |
| Chain strategy | stacked-to-main |

Decision needed before apply: Resolved — stacked-to-main, slice 2/4.
Chained PRs recommended: Yes
Chain strategy: stacked-to-main
400-line budget risk: High (slice 1 tracked separately)

### Suggested Work Units

| Unit | Goal | PR | Test | Harness | Rollback boundary |
|------|------|----|------|---------|-------------------|
| 1 | Godot project, domain, save, unit tests | PR 1 | GUT pass + Python harness | Editor play / `python project/harness/validate_domain.py` | `project/project.godot`, `scripts/domain`, `save_repository.gd`, `tests/unit`, `harness/validate_domain.py` |
| 2 | Tutorial, case data, transitions | PR 2 | GUT pass | Editor flow | `data`, `tutorial.tscn`, `mansion_explore.tscn`, `scene_router.gd` |
| 3 | Board UI, touch, accusation, ending | PR 3 | GUT pass | Editor ending | `case_board.tscn`, `accusation.tscn`, `ending.tscn`, `case_session.gd` |
| 4 | Asset pipeline, CC0 audio, provenance, device test | PR 4 | Hashes match | APK playthrough | `source-baseline`, `audio`, `project/assets`, `project/docs` |

## Phase 1: Godot Foundation

- [x] 1.1 Create project/project.godot portrait + autoloads.
- [x] 1.2 Create project/export_presets.cfg Android profiles.
- [x] 1.3 Create scripts/services/scene_router.gd autoload.
- [x] 1.4 Create placeholder scenes for all flow screens.
- [x] 1.5 Add Godot .gitignore for imports, builds, user data.

## Phase 2: Core Domain and Persistence (TDD)

- [x] 2.1 RED: tests for CaseDefinition categories and operators.
- [x] 2.2 GREEN: scripts/domain/case_definition.gd.
- [x] 2.3 RED: tests for solver uniqueness and murderer determinism.
- [x] 2.4 GREEN: scripts/domain/case_solver.gd.
- [x] 2.5 RED: tests for CaseState propagation and undo.
- [x] 2.6 GREEN: scripts/domain/case_state.gd.
- [x] 2.7 RED: tests for SaveRepository.
- [x] 2.8 GREEN: save_repository.gd.

## Phase 3: Tutorial and Case Content

- [x] 3.1 Create data/dialogue/tutorial.json.
- [x] 3.2 Create data/cases/mansion_case.json.
- [x] 3.3 Prove mansion_case.json has exactly one solution.
- [x] 3.4 Create data/dialogue/mansion.json.
- [x] 3.5 Integration test tutorial gates.

## Phase 4: Scenes, UI, and Touch

- [ ] 4.1 Implement bootstrap.tscn.
- [ ] 4.2 Implement start_resume.tscn.
- [ ] 4.3 Implement tutorial.tscn with 5-minute skip.
- [ ] 4.4 Implement mansion_explore.tscn.
- [x] 4.5 Implement case_board.tscn.
- [x] 4.6 Implement accusation.tscn.
- [x] 4.7 Implement ending.tscn.
- [x] 4.8 Wire CaseSession.

## Phase 5: Assets, Audio, and Provenance

- [ ] 5.1 Snapshot source PNGs with SHA-256.
- [ ] 5.2 Create project/tools/asset_pipeline.gd.
- [ ] 5.3 Generate derived sprites and mansion grid slices.
- [ ] 5.4 Create project/assets/manifest.json.
- [ ] 5.5 Add verified CC0 audio with LICENSE.txt.
- [ ] 5.6 Implement scripts/services/audio_service.gd.
- [ ] 5.7 Write expression-review.md.

## Phase 6: Build, Device Test, and Rollback Documentation

- [ ] 6.1 Record reference device.
- [ ] 6.2 Export and install debug APK.
- [ ] 6.3 Run full sideloaded playthrough.
- [ ] 6.4 Run force-quit/resume smoke test.
- [ ] 6.5 Verify performance thresholds.
- [ ] 6.6 Write smoke-test.md.
- [ ] 6.7 Write rollback.md.
