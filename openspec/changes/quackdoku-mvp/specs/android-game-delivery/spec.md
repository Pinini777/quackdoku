# Android Game Delivery Specification

## Purpose

Export the Godot 4.6 project as an Android APK, install it on a reference device, and verify playability, asset provenance, and distribution boundaries.

## Requirements

### Requirement: Reference device definition

The team MUST define a reference Android device and minimum playability criteria.

#### Scenario: Reference device recorded

- GIVEN the delivery plan is documented
- WHEN the reference device model, OS version, RAM, and screen size are listed
- THEN the device is approved for smoke testing

### Requirement: Playability criteria

The APK MUST meet response, load, and legibility thresholds on the reference device.

#### Scenario: Touch response

- GIVEN the case is running on the reference device
- WHEN the player taps a grid cell or clue
- THEN the UI responds within 200 ms

#### Scenario: Load time

- GIVEN the app is launched from the home screen
- WHEN the mansion case is ready to play
- THEN the total load time is under 10 seconds

#### Scenario: Legibility

- GIVEN the device is held at typical playing distance
- WHEN text and sprites are displayed
- THEN all labels and grid elements are readable without zoom

### Requirement: Godot 4.6 Android export

The project MUST export an installable APK from Godot 4.6.

#### Scenario: Export success

- GIVEN the Godot project is open in Godot 4.6
- WHEN Android export is executed
- THEN an APK file is produced without errors

### Requirement: Installation and smoke test

The APK MUST install on the reference device and complete the mansion case without a crash.

#### Scenario: Smoke test

- GIVEN the APK is installed on the reference device
- WHEN a full playthrough from tutorial start to case ending is performed
- THEN the app does not crash
- AND the ending reward is reached

### Requirement: Distribution boundary

The MVP MUST be distributed as a direct test APK only; Google Play release is out of scope.

#### Scenario: Delivery check

- GIVEN the build is ready for sharing
- WHEN distribution options are reviewed
- THEN only direct APK sideloading is permitted

### Requirement: Asset provenance

Every visual asset and audio asset MUST have verifiable license, source, and modification rights.

#### Scenario: Audio provenance

- GIVEN an audio asset is imported
- WHEN its license is checked
- THEN a CC0 record and source URL are present

#### Scenario: Visual provenance

- GIVEN a visual asset is imported or derived
- WHEN its license is checked
- THEN the source, license, and right-to-modify are documented

### Requirement: Source asset preservation

Source PNGs MUST remain unchanged; derived assets MUST be created as new files.

#### Scenario: Derivative creation

- GIVEN a source PNG exists
- WHEN a game sprite is produced
- THEN the derivative is saved as a new file
- AND the source PNG bytes are unmodified

#### Scenario: Source modification rollback

- GIVEN a source PNG was accidentally modified
- WHEN the rollback command is run
- THEN the original source PNG is restored
