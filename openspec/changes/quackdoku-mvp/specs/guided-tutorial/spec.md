# Guided Tutorial Specification

## Purpose

Teach the core grid interaction and deduction constraints before the mansion case starts, completing in five minutes or less.

## Requirements

### Requirement: Interactive constraint introduction

The tutorial MUST teach one-per-row, one-per-column, and clue-constraint rules through player interaction.

#### Scenario: Row uniqueness taught

- GIVEN the tutorial has started
- WHEN the player places a suspect in a row
- THEN the same row rejects a second suspect of the same type
- AND the tutorial explains the rule in narrative text

#### Scenario: Column uniqueness taught

- GIVEN a suspect is already placed in a column
- WHEN the player tries to place the same suspect type in that column
- THEN the placement is rejected
- AND the tutorial explains the column rule

#### Scenario: Clue constraint taught

- GIVEN a clue is displayed
- WHEN the player applies the clue to eliminate or place a suspect
- THEN the grid reflects the constraint
- AND the tutorial confirms the action

### Requirement: Tutorial completion time

The tutorial MUST be completable in five minutes or less on the reference Android device.

#### Scenario: Timed completion

- GIVEN a new player on the reference device
- WHEN the tutorial is played without interruption
- THEN completion is logged at five minutes or less

#### Scenario: Time boundary

- GIVEN the tutorial runtime reaches five minutes
- WHEN the player has not completed the practice grid
- THEN the tutorial MAY offer to skip the remaining steps

### Requirement: Narrative-only feedback

The tutorial MUST NOT use penalties, locks, or negative scoring.

#### Scenario: Error response

- GIVEN the player makes an invalid placement
- WHEN feedback is shown
- THEN only narrative guidance is displayed

### Requirement: Reach practice grid

The tutorial MUST end with a playable practice grid that demonstrates all three constraints.

#### Scenario: Grid access

- GIVEN the tutorial is completed
- WHEN the player accepts the transition
- THEN the mansion case grid is presented
