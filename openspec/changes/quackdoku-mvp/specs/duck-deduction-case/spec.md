# Duck Deduction Case Specification

## Purpose

Run the original mansion puzzle with clue flow, narrative feedback, a unique logical solution, and a self-contained ending reward.

## Requirements

### Requirement: Unique consistent solution

The puzzle MUST have exactly one logically consistent solution covering suspect placement and murderer identity.

#### Scenario: Generated solution uniqueness

- GIVEN a new case is started
- WHEN the board is generated
- THEN a uniqueness proof is produced before the case is playable

#### Scenario: Murderer determinism

- GIVEN the player has correctly filled the grid
- WHEN the accusation phase begins
- THEN only one suspect can be the murderer

### Requirement: Original expressive content

All art, names, dialogue, clues, and presentation MUST differ recognizably from Murdoku.

#### Scenario: Expressive review

- GIVEN all case content is assembled
- WHEN a differentiation review is run
- THEN a verifiable record confirms no Murdoku expression is copied

### Requirement: Character coverage

The case MUST include a detective representation and six distinct suspect representations.

#### Scenario: Roster check

- GIVEN the case is loaded
- WHEN the character screen is opened
- THEN one detective and six distinct suspects are visible

### Requirement: Clue-driven deduction

The case MUST provide clues that constrain the logic grid until the murderer is identifiable.

#### Scenario: Clue sufficiency

- GIVEN the player has applied all clues correctly
- WHEN the grid is complete
- THEN the murderer is the only remaining suspect

### Requirement: Narrative-only error feedback

Invalid placements or accusations MUST produce narrative feedback, not penalties.

#### Scenario: Incorrect placement

- GIVEN the player places a suspect that violates a clue
- WHEN the placement occurs
- THEN a duck-character remark explains the contradiction

### Requirement: Ending reward

Completing the case MUST show a revelation, award a collectible, and present a next-case hook.

#### Scenario: Case completion

- GIVEN the grid is solved and the murderer is accused
- WHEN the ending sequence starts
- THEN the revelation, collectible, and hook are shown
- AND the hook does not require additional cases to be satisfying
