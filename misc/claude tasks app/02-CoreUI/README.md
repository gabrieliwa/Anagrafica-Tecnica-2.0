# Phase 2: Core UI

## Overview

The Core UI phase builds the fundamental user interface components and navigation structure. This includes the Projects list screen, the interactive floorplan viewer, reusable UI components, and the app's navigation system.

## Components

### ProjectsList/
The main entry point of the app showing available projects with search, filters, and sync status.

**Key Features:**
- Project cards with name, image, location, stats
- State labels: Online (#F1F1F1), Open (#DCEEFF), Completed (#DFF5E1)
- Search and filter functionality
- Sync status indicators
- Download flow with loading screen
- Read-only warning for completed projects

**Key Files:**
- `ProjectsListView.swift`
- `ProjectCard.swift`
- `ProjectSearchBar.swift`
- `ProjectStateLabel.swift`
- `SyncStatusIndicator.swift`
- `EmptyStateView.swift`
- `ProjectsViewModel.swift`

### FloorplanViewer/
Interactive map-style floorplan with pan/zoom, room selection, and status visualization.

**Key Features:**
- Vector tile rendering
- Pan/zoom gestures
- Room status colors (empty: halftone gray, with items: light blue)
- Room badges: (+) for empty, count for populated
- Level picker (bottom-right drop-up)
- Controls: Exit (top-left), sync status (top-right), Survey Report (bottom-left)

**Key Files:**
- `FloorplanView.swift`
- `VectorTileRenderer.swift`
- `RoomLayer.swift`
- `RoomBadge.swift`
- `LevelPicker.swift`
- `SyncStatusButton.swift`
- `ExitButton.swift`
- `SurveyReportButton.swift`
- `FloorplanViewModel.swift`

### CommonComponents/
Reusable UI components used throughout the app for consistency.

**Key Components:**
- Form fields (text, number, dropdown, toggle, date)
- Photo grid (Type: 1, Instance: up to 5)
- Progress tracker for wizards
- Buttons (primary, secondary, action)
- Alerts and confirmations
- Loading indicators
- Success/error banners

**Key Files:**
- `FormField.swift`, `DropdownField.swift`, `ToggleField.swift`, `DateField.swift`
- `PhotoGrid.swift`
- `ProgressTracker.swift`
- `ActionButton.swift`
- `AlertView.swift`
- `LoadingIndicator.swift`
- `Banner.swift`

### Navigation/
Centralized navigation management and coordination.

**Key Features:**
- App-wide navigation coordinator
- Modal presentation logic
- Deep link handling (future)
- Navigation stack management
- Unsaved changes detection

**Key Files:**
- `AppCoordinator.swift`
- `NavigationManager.swift`
- `DeepLinkHandler.swift`
- `ModalPresenter.swift`

## Dependencies

- **Phase 1:** DataModels, LocalStorage, CoreServices
- **External:** SwiftUI, MapKit (optional for tiles), Combine

## Success Criteria

- [ ] Projects list displays all projects with correct states
- [ ] Search and filter work correctly
- [ ] Floorplan renders vector tiles smoothly
- [ ] Pan/zoom gestures feel natural
- [ ] Room selection is accurate
- [ ] Room status colors update correctly
- [ ] Level picker switches floors
- [ ] All controls positioned correctly
- [ ] Common components reusable across app
- [ ] Navigation flows work smoothly
- [ ] 80%+ unit test coverage for view models
- [ ] Snapshot tests for UI components

## Development Timeline

**Estimated Duration:** 4 weeks (Sprints 3-4)

**Week 5:** CommonComponents + Navigation
**Week 6:** ProjectsList implementation
**Week 7:** FloorplanViewer core
**Week 8:** FloorplanViewer controls + Testing

## UI/UX Guidelines

### Color Palette
- Online state: #F1F1F1 (light gray)
- Open state: #DCEEFF (light blue)
- Completed state: #DFF5E1 (light green)
- Empty room: Halftone gray
- Room with assets: Light blue

### Typography
- Use system font (SF Pro)
- Title: Bold, 20pt
- Body: Regular, 16pt
- Caption: Regular, 14pt

### Spacing
- Card padding: 16pt
- Element spacing: 12pt
- Section spacing: 24pt

### Gestures
- Two-finger pan for floorplan
- Pinch to zoom
- Tap for selection
- Swipe for delete (in lists)

## Testing Requirements

- Unit tests for all view models
- UI tests for critical user flows
- Snapshot tests for visual regression
- Gesture handling tests
- State management tests
- Navigation flow tests

## Notes

- Floorplan should feel like Google Maps (familiar gestures)
- Room boundaries must be precise for tap detection
- Sync status should be non-intrusive but always visible
- Empty state should be helpful, not discouraging
- Loading states should provide feedback
- Error states should suggest solutions
