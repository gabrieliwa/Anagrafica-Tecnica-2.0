# Changelog

All notable changes to the Anagrafica Tecnica mobile app.

## [Unreleased]

### Added

- **MapController abstraction** (`Packages/Features/Floorplan/Sources/MapController.swift`)
  - `PlanMode` enum - single source of truth for UI mode (`.browse` / `.room(roomID:)`)
  - `MapController` class - handles hit-testing, room bounds calculation, camera animations, and viewport management
  - `RoomSheetLayout` struct - helper for calculating sheet heights and insets

- **BrowseOverlay components** (`Packages/Features/Floorplan/Sources/BrowseOverlay.swift`)
  - `BrowseOverlay` - browse mode overlay with top bar and bottom controls
  - `BrowseTopBar` - project title, back button, sync indicator
  - `ReadOnlyBadge` - read-only mode indicator
  - `LevelPicker` - floor/level selection menu

- **UI Architecture documentation** in `README.md`
  - New "UI Architecture: Two-Flow System" section
  - Documents PlanimetricFlow and ReportsFlow separation
  - Explains why no nested NavigationStacks

### Changed

- **FloorplanView refactored into PlanimetricFlow container** (`Packages/Features/Floorplan/Sources/FloorplanView.swift`)
  - Uses `MapController` for viewport management instead of inline logic
  - Single `ZStack` with persistent `FloorplanCanvas` + mode-switching overlays
  - Centralized sheet presentation to avoid nested sheet issues
  - Floor plan is never recreated during mode transitions - only overlays change
  - Added detailed documentation explaining the architecture

- **SurveyReportView enhanced as ReportsFlow** (`Packages/Features/SurveyReport/Sources/SurveyReportView.swift`)
  - Standalone full-screen view (no floor plan background)
  - Custom top bar matching app style
  - Placeholder cards for Rooms, Types, and Export sections
  - Documentation explaining why floor plan is not needed here

- **ContentView updated** (`AnagraficaTecnica/AnagraficaTecnica/ContentView.swift`)
  - Added documentation explaining the two-flow architecture
  - Single `NavigationStack` at root (no nested stacks)

- **Package.swift platform requirements**
  - Updated macOS platform from v12 to v13 for API compatibility

### Fixed

- **Platform compatibility** - Added `#if os(iOS)` conditionals for iOS-only APIs:
  - `ProjectsListView.swift` - `textInputAutocapitalization`
  - `RoomDetailViews.swift` - `navigationBarTitleDisplayMode`
  - `AddAssetWizardStepViews.swift` - `keyboardType`
  - `FloorplanView.swift` - `navigationBarBackButtonHidden`, `toolbar(.hidden, for: .navigationBar)`
  - `SurveyReportView.swift` - `navigationBarBackButtonHidden`, `toolbar(.hidden, for: .navigationBar)`

## Architecture Overview

### Two-Flow System

The app uses two top-level navigation flows:

#### 1. PlanimetricFlow (FloorplanView)

The floor plan is the root surface with overlay UI that swaps based on mode:

- **Browse Mode** (default): Pan/zoom the floor plan, browse chrome visible
- **Room Mode**: Room selected, room overlay visible, camera animates to room

Key decisions:
- Floor plan (`FloorplanCanvas`) is always the same view instance
- Overlays switch based on `PlanMode` enum (single source of truth)
- Preserves zoom/pan state and enables smooth camera animations
- Avoids "deck of cards" view hierarchy issues

#### 2. ReportsFlow (SurveyReportView)

Standard full-screen navigation for "server report" screens:

- List of all rooms (grouped by level)
- List of all asset types (grouped by family)
- Export functionality

Key decisions:
- No floor plan visible - full-screen layouts maximize content space
- Standard push navigation for detail screens
- Accessed via hamburger menu from PlanimetricFlow

### File Structure

```
Packages/Features/Floorplan/Sources/
├── FloorplanView.swift      # PlanimetricFlow container
├── FloorplanCanvas.swift    # Persistent map rendering
├── FloorplanViewModel.swift # Data loading and room counts
├── MapController.swift      # Camera/viewport management + PlanMode enum
├── BrowseOverlay.swift      # Browse mode UI components
└── Floorplan.swift          # Module exports

Packages/Features/Room/Sources/
├── RoomOverlayView.swift    # Room mode UI components
├── RoomViewModel.swift      # Room data fetching
├── RoomDetailViews.swift    # Asset/RoomNote detail views
└── Room.swift               # Module exports

Packages/Features/SurveyReport/Sources/
├── SurveyReportView.swift   # ReportsFlow main view
└── SurveyReport.swift       # Module exports
```
