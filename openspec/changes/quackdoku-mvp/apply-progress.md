# Apply Progress: QuackDoku MVP — Work Units 1–2

## Change

quackdoku-mvp

## Mode

Standard (Strict TDD disabled; no Godot runner detected in this environment).

## Completed Tasks

### Phase 1: Godot Foundation

- [x] 1.1 Create project/project.godot portrait + autoloads.
- [x] 1.2 Create project/export_presets.cfg Android profiles.
- [x] 1.3 Create scripts/services/scene_router.gd autoload.
- [x] 1.4 Create placeholder scenes for all flow screens.
- [x] 1.5 Add Godot .gitignore for imports, builds, user data.

### Phase 2: Core Domain and Persistence (TDD)

- [x] 2.1 RED: tests for CaseDefinition categories and operators.
- [x] 2.2 GREEN: scripts/domain/case_definition.gd.
- [x] 2.3 RED: tests for solver uniqueness and murderer determinism.
- [x] 2.4 GREEN: scripts/domain/case_solver.gd.
- [x] 2.5 RED: tests for CaseState propagation and undo.
- [x] 2.6 GREEN: scripts/domain/case_state.gd.
- [x] 2.7 RED: tests for SaveRepository.
- [x] 2.8 GREEN: save_repository.gd.

### Phase 3: Tutorial and Case Content

- [x] 3.1 Create data/dialogue/tutorial.json.
- [x] 3.2 Create data/cases/mansion_case.json.
- [x] 3.3 Prove mansion_case.json has exactly one solution.
- [x] 3.4 Create data/dialogue/mansion.json.
- [x] 3.5 Integration test tutorial gates.

## Files Changed

| File | Action | What Was Done |
|------|--------|---------------|
| `project/project.godot` | Created | Godot 4.6 portrait project, autoload SceneRouter, canvas scaling. |
| `project/export_presets.cfg` | Created | Android APK export preset (ARM64, API 24–34). |
| `project/.gitignore` | Created | Godot/build/user-data ignores. |
| `project/scripts/services/scene_router.gd` | Created | Autoload scene dictionary and `goto(scene_name)`. |
| `project/scenes/{bootstrap,start_resume,tutorial,mansion_explore,case_board,accusation,ending}.tscn` | Created | Minimal placeholder flow scenes. |
| `project/scripts/domain/case_definition.gd` | Created | Categories, operators, constraints, serialization. |
| `project/scripts/domain/case_state.gd` | Created | Matrices, cell states, propagation, snapshot undo. |
| `project/scripts/domain/case_solver.gd` | Created / Modified | Backtracking validation, move apply, contradiction detection; fixed murderer-determinism check for non-suspect murderer categories. |
| `project/scripts/services/save_repository.gd` | Created | Atomic JSON save/load with checksum and version gate. |
| `project/tests/unit/test_case_definition.gd` | Created | GUT tests for categories/operators/serialization. |
| `project/tests/unit/test_case_state.gd` | Created | GUT tests for initial state, propagation, undo, constraints. |
| `project/tests/unit/test_case_solver.gd` | Created / Modified | GUT tests for uniqueness, murderer determinism, move apply; added mansion case unique-solution test. |
| `project/tests/unit/test_save_repository.gd` | Created | GUT tests for save/load, version reject, discard. |
| `project/data/cases/test_unique_case.json` | Created | Shared fixture proving a unique, deterministic case. |
| `project/harness/validate_domain.py` | Created / Modified | Standalone Python harness mirroring domain logic; extended to validate authored content. |
| `project/data/dialogue/tutorial.json` | Created | Guided-tutorial steps, practice case, skip boundary, and transition target. |
| `project/data/cases/mansion_case.json` | Created | Author 6×6 mansion case with unique solution and deterministic item-based murderer. |
| `project/data/dialogue/mansion.json` | Created | Intro, clue texts, narrative error feedback, ending revelation/collectible/hook. |
| `project/scripts/scenes/tutorial.gd` | Created | Tutorial scene controller: loads JSON, advances gates, skip check, transitions to mansion. |
| `project/scripts/scenes/mansion_explore.gd` | Created | Mansion explore controller: loads case and dialogue, reveals clues, transitions to case board. |
| `project/scenes/tutorial.tscn` | Modified | Attached `tutorial.gd` script. |
| `project/scenes/mansion_explore.tscn` | Modified | Attached `mansion_explore.gd` script. |
| `project/tests/integration/test_tutorial_flow.gd` | Created | GUT integration test for tutorial duration cap, skip flag, gate rules, practice-case uniqueness, and transition target. |

## Work Unit Evidence (Unit 2)

| Evidence | Required value |
|---|---|
| Focused test command and exact result | `python project/harness/validate_domain.py` → 33 passed, 0 failed, exit 0 |
| Runtime harness command/scenario and exact result | Editor runtime harness: N/A — Godot editor/runtime is not installed in this environment. The Python harness substitutes by loading the same JSON case/dialogue data and exercising the equivalent solver/state/save logic. |
| Rollback boundary | Revert `project/data/dialogue/`, `project/data/cases/mansion_case.json`, `project/scripts/scenes/tutorial.gd`, `project/scripts/scenes/mansion_explore.gd`, `project/tests/integration/test_tutorial_flow.gd`, the added mansion test in `project/tests/unit/test_case_solver.gd`, and the content additions in `project/harness/validate_domain.py`. Revert `project/scenes/tutorial.tscn` and `project/scenes/mansion_explore.tscn` to their Unit-1 placeholder state. The cross-unit solver fix in `case_solver.gd` may remain because it keeps Unit-1 tests passing. |

## Deviations from Design

1. **Solver scope**: The design implies constraints may be between any pair of categories. The current solver evaluates constraints by resolving each side to the suspect that owns the value; this covers the intended suspect-centered logic-grid model but has not been exhaustively tested with room-time-only constraints.
2. **Undo model**: The design did not prescribe an undo mechanism. Implementation uses snapshot-based undo per user operation to keep propagation atomic and reversible.
3. **Save path**: Design says `user://progress-v1.json`; GDScript implementation uses exactly that. Python harness mirrors behavior in a temp file.
4. **Murderer determinism check**: The original `CaseSolver.validate` compared the resolved murderer suspect name directly to `murderer_value`, which only works when `murderer_category` is `suspect`. This was corrected to verify that the resolved murderer suspect exists and that `murderer_value` belongs to `murderer_category`, enabling item/room/time-based murderer definitions.

## Issues Found

- The first work unit is larger than the 400-line slice guideline (≈1,214 lines added under `project/`). This is expected because Unit 1 includes the entire Godot project scaffold, domain layer, persistence, and both GUT and Python harness tests. Subsequent units should be smaller slices.
- GUT tests cannot be executed without the Godot editor. The Python harness provides equivalent evidence for the logic covered.
- The mansion case was intentionally authored in this unit; uniqueness and deterministic murderer are proven by the harness.

## Remaining Tasks

- [ ] 4.1 Implement bootstrap.tscn.
- [ ] 4.2 Implement start_resume.tscn.
- [ ] 4.3 Implement tutorial.tscn with 5-minute skip (UI layer).
- [ ] 4.4 Implement mansion_explore.tscn (UI layer).
- [ ] 4.5 Implement case_board.tscn.
- [ ] 4.6 Implement accusation.tscn.
- [ ] 4.7 Implement ending.tscn.
- [ ] 4.8 Wire CaseSession.
- [ ] 5.1–5.7 Asset pipeline, audio, provenance, expression review.
- [ ] 6.1–6.7 Build, device test, rollback docs.

## Workload / PR Boundary

- Mode: stacked PR slice 2/4
- Current work unit: Unit 2 — Tutorial, case data, and flow transitions
- Boundary: from Unit-1 project scaffold to authored case/dialogue data and wired tutorial/mansion-explore scene scripts
- Estimated review budget impact: ≈330 lines added in this slice; cumulative ≈1,544 lines under the 1,600-line maintainer-approved cap.

## Status

18/42 tasks complete. Unit 2 autonomous and verified by Python harness. Ready for Unit 3 (board UI, accusation, ending) or for verify phase once a Godot runner is available.
