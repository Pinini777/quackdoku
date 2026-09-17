# Local Case Progress Specification

## Purpose

Preserve the current in-progress case across an app restart without network or account dependencies.

## Requirements

### Requirement: Save in-progress state

The system MUST persist the current case state locally while the case is active.

#### Scenario: Mid-case save

- GIVEN the player has made placements and clue progress
- WHEN the app moves to background or a save point is reached
- THEN the state is written to local storage

### Requirement: Restore after restart

The system MUST restore the saved case after an app force-quit and restart.

#### Scenario: Force-quit resume

- GIVEN a saved in-progress case exists
- WHEN the app restarts
- THEN the player is offered to continue the case
- AND all prior placements and clue progress are restored

### Requirement: Handle missing save

The system MUST start a new case when no valid save exists.

#### Scenario: Fresh install

- GIVEN no saved case state is present
- WHEN the app launches
- THEN a new case begins without error

### Requirement: Save integrity

The system MUST detect corrupt or incompatible save data and start fresh.

#### Scenario: Corrupt save

- GIVEN local save data is corrupted
- WHEN the app launches
- THEN the corrupt data is discarded
- AND a new case begins
