# Anagrafica Tecnica Mobile App - Development Strategy

This document outlines the development strategy for the iOS mobile application, broken down into modular tasks organized by folder structure.

## Overview

The development is structured into **7 major phases**, each containing specific tasks. Each task has its own folder within the app directory containing related code, tests, and documentation.

## Folder Structure

```
anagrafica tecnica app/
├── 01-Foundation/
│   ├── DataModels/
│   ├── LocalStorage/
│   ├── NetworkLayer/
│   └── CoreServices/
├── 02-CoreUI/
│   ├── ProjectsList/
│   ├── FloorplanViewer/
│   ├── CommonComponents/
│   └── Navigation/
├── 03-AssetManagement/
│   ├── AddAssetWizard/
│   ├── FamilySelection/
│   ├── TypeSelection/
│   ├── InstanceForm/
│   └── PhotoCapture/
├── 04-RoomManagement/
│   ├── RoomView/
│   ├── InstanceEditor/
│   ├── TypeEditor/
│   └── RoomNotes/
├── 05-SurveyReporting/
│   ├── SurveyReportHub/
│   ├── RoomsList/
│   ├── TypesList/
│   └── ProjectExport/
├── 06-Synchronization/
│   ├── SyncEngine/
│   ├── EventSourcing/
│   ├── PhotoUploadQueue/
│   └── SurveyCompletion/
└── 07-Polish/
    ├── ReadOnlyMode/
    ├── ErrorHandling/
    ├── Testing/
    └── Performance/
```

---

## Phase 1: Foundation (01-Foundation/)

### 1.1 DataModels/
**Purpose:** Define all Swift data models matching the product specification

**Deliverables:**
- `Project.swift` - Project entity with states (DRAFT, READY, ACTIVE, COMPLETED, APPROVED)
- `Level.swift` - Building floors with geometry, north angle
- `Room.swift` - Room entities with boundaries, status, geometry
- `Family.swift` - Asset families with parameter definitions
- `Type.swift` - Asset types with fixed parameters
- `Instance.swift` - Asset instances with room linkage
- `Parameter.swift` - Parameter definitions with validation rules
- `Photo.swift` - Photo metadata (Type vs Instance scope)
- `RoomNote.swift` - Room annotation model
- `SchemaVersion.swift` - Immutable schema snapshot
- `Event.swift` - Event sourcing model for sync

**Key Requirements:**
- UUIDv7 for all internal IDs
- Codable conformance for JSON serialization
- Validation logic embedded in models
- Support for Family → Type → Instance hierarchy
- Parameter scoping (Type vs Instance)

**Dependencies:** None

---

### 1.2 LocalStorage/
**Purpose:** Implement offline-first local persistence layer

**Deliverables:**
- `CoreDataStack.swift` - Core Data setup and configuration
- `ProjectStore.swift` - Project CRUD operations
- `AssetStore.swift` - Instance/Type CRUD operations
- `EventLog.swift` - Local event queue for sync
- `PhotoQueue.swift` - Photo upload queue management
- `TileCache.swift` - Vector tile storage and retrieval
- `SchemaStore.swift` - Schema version storage
- Migration handlers for database updates

**Key Requirements:**
- Complete offline functionality
- Event log for all changes (CRUD operations)
- Photo queue with upload status tracking
- Efficient tile caching strategy
- Data integrity constraints
- Background fetch support

**Dependencies:** DataModels/

---

### 1.3 NetworkLayer/
**Purpose:** REST API client for server communication

**Deliverables:**
- `APIClient.swift` - Base HTTP client with retry logic
- `ProjectAPI.swift` - Project download endpoints
- `SyncAPI.swift` - Event upload endpoints
- `PhotoUploadAPI.swift` - Photo upload with background support
- `SchemaAPI.swift` - Schema version retrieval
- `ExportAPI.swift` - Project export generation
- `NetworkMonitor.swift` - Reachability detection
- `AuthenticationManager.swift` - Future auth placeholder

**Key Requirements:**
- Automatic retry with exponential backoff
- Network availability detection
- Background URL sessions for photo uploads
- Request/response logging
- Error handling and mapping
- JSON encoding/decoding

**Dependencies:** DataModels/

---

### 1.4 CoreServices/
**Purpose:** Shared business logic services

**Deliverables:**
- `ValidationService.swift` - Field validation logic
- `FuzzyMatchingService.swift` - Type duplicate detection
- `CoordinateService.swift` - Plan space coordinate conversions
- `IDGenerator.swift` - UUIDv7 generation
- `PhotoNamingService.swift` - Photo filename generation
- `StateManager.swift` - Project lifecycle state transitions
- `PermissionsManager.swift` - Camera/photo library permissions

**Key Requirements:**
- Fuzzy matching algorithm for Type suggestions
- Coordinate system utilities (Plan Space)
- Photo naming: `{project_short}_{operator_id}_{timestamp}_{sequence}.jpg`
- State machine for project states
- Validation rules from schema enforcement

**Dependencies:** DataModels/, LocalStorage/

---

## Phase 2: Core UI (02-CoreUI/)

### 2.1 ProjectsList/
**Purpose:** Projects home screen with search, filters, sync status

**Deliverables:**
- `ProjectsListView.swift` - Main projects screen
- `ProjectCard.swift` - Project card component
- `ProjectSearchBar.swift` - Search and filter UI
- `ProjectStateLabel.swift` - State badge (Online/Open/Completed)
- `SyncStatusIndicator.swift` - Sync status icon and message
- `EmptyStateView.swift` - "No project assigned" placeholder
- `ProjectsViewModel.swift` - View model with search/filter logic

**Key Requirements:**
- Display: name, image, location, room count, asset count, state
- State colors: Online (#F1F1F1), Open (#DCEEFF), Completed (#DFF5E1)
- Tap Online project → download with loading screen → open floorplan
- Tap Open project → open floorplan immediately
- Tap Completed → warning + read-only mode
- Search and filter (location, status)
- Settings and Import buttons (placeholders)

**Dependencies:** CoreServices/, LocalStorage/

---

### 2.2 FloorplanViewer/
**Purpose:** Interactive floorplan with pan/zoom, room selection

**Deliverables:**
- `FloorplanView.swift` - Main map view with gestures
- `VectorTileRenderer.swift` - Tile rendering engine
- `RoomLayer.swift` - Room boundaries with status colors
- `RoomBadge.swift` - Empty (+) or count badge rendering
- `LevelPicker.swift` - Bottom-right drop-up level selector
- `SyncStatusButton.swift` - Top-right sync status with tap message
- `ExitButton.swift` - Top-left exit with pause/complete popup
- `SurveyReportButton.swift` - Bottom-left (☰) button
- `FloorplanViewModel.swift` - Map state, zoom, pan, room selection

**Key Requirements:**
- Pan/zoom gestures (map-style)
- Room status colors: empty (halftone gray), with items (light blue)
- Room names and numbers visible on plan
- Tap room → open Room View or Add Asset wizard
- Level switching with drop-up picker
- Sync status indicator with tap-to-view message
- Exit button with pause/complete options

**Dependencies:** DataModels/, LocalStorage/, CoreServices/

---

### 2.3 CommonComponents/
**Purpose:** Reusable UI components across the app

**Deliverables:**
- `FormField.swift` - Text/number input with validation
- `DropdownField.swift` - Enum parameter selector
- `ToggleField.swift` - Boolean parameter
- `DateField.swift` - Date picker
- `PhotoGrid.swift` - Photo display grid (Type: 1, Instance: up to 5)
- `ProgressTracker.swift` - Wizard step indicator
- `ActionButton.swift` - Primary/secondary button styles
- `AlertView.swift` - Custom alerts and confirmations
- `LoadingIndicator.swift` - Loading states
- `Banner.swift` - Success/error banners

**Key Requirements:**
- Consistent styling across app
- Inline validation error display
- Required field indicators (red when empty on save)
- Photo grid with add/view/delete actions
- Progress tracker states: not-yet, current, completed
- Accessibility support

**Dependencies:** None

---

### 2.4 Navigation/
**Purpose:** App-wide navigation coordinator

**Deliverables:**
- `AppCoordinator.swift` - Main navigation coordinator
- `NavigationManager.swift` - Navigation state management
- `DeepLinkHandler.swift` - Handle deep links (future)
- `ModalPresenter.swift` - Modal presentation logic

**Key Requirements:**
- Centralized navigation logic
- Support for modal presentations
- Navigation stack management
- Exit confirmations with unsaved changes

**Dependencies:** CoreUI components

---

## Phase 3: Asset Management (03-AssetManagement/)

### 3.1 AddAssetWizard/
**Purpose:** Multi-step asset creation flow with progress tracker

**Deliverables:**
- `AddAssetWizardView.swift` - Main wizard container
- `WizardProgressTracker.swift` - Step indicator UI
- `WizardCoordinator.swift` - Step navigation logic
- `ExitConfirmationAlert.swift` - "Progress will be lost" warning

**Key Requirements:**
- Steps: Family → Type → Instance
- Progress tracker showing current step
- Exit confirmation when closing mid-wizard
- Return to Floorplan or Room View based on entry point
- Support for Room Note path

**Dependencies:** CommonComponents/

---

### 3.2 FamilySelection/
**Purpose:** Family selection step in Add Asset wizard

**Deliverables:**
- `FamilySelectionView.swift` - Family list with search
- `FamilyCard.swift` - Family item with icon and name
- `RoomNoteOption.swift` - Special Room Note entry
- `FamilySearchBar.swift` - Search both Family and Type names

**Key Requirements:**
- Search filters Family names AND Type names within families
- Room Note appears below search, above families, separated by line
- Room Note always available
- Icons + labels for each family
- Tap family → proceed to Type selection
- Tap Room Note → open Room Note form

**Dependencies:** DataModels/, CommonComponents/

---

### 3.3 TypeSelection/
**Purpose:** Type selection/creation step in Add Asset wizard

**Deliverables:**
- `TypeSelectionView.swift` - Type list with search and create
- `TypeCard.swift` - Type item with summary
- `CreateNewTypeButton.swift` - "+ New Type" action
- `TypeSearchBar.swift` - Search existing types
- `TypeFormView.swift` - Type parameter form
- `FuzzyMatchWarning.swift` - Duplicate Type suggestion
- `TypePhotoCapture.swift` - Single required Type photo

**Key Requirements:**
- List all Types for selected Family
- Search/filter Types
- "+ New Type" → launch camera → Type form
- Existing Type path: show pre-filled Type form
  - If unchanged → skip to Instance form
  - If changed → prompt for new Type name → branch Type
- New Type path: camera → Type form → name Type
- Fuzzy matching warns of similar Types
- Type photo required (exactly 1)
- Branched Types don't modify original

**Dependencies:** DataModels/, PhotoCapture/, CommonComponents/

---

### 3.4 InstanceForm/
**Purpose:** Instance parameter form (final step in wizard)

**Deliverables:**
- `InstanceFormView.swift` - Instance parameter form
- `InstancePhotoGrid.swift` - Up to 5 optional photos
- `ReadOnlyFields.swift` - Pre-filled Level, Room display
- `SaveAssetButton.swift` - Save with validation
- `InstanceFormViewModel.swift` - Form state and validation

**Key Requirements:**
- Display all instance-scoped parameters
- Pre-filled read-only: Level, Room
- Optional Instance photos (up to 5)
- Required field validation before save
- "Asset saved" banner on success
- Return to Room View with new asset visible

**Dependencies:** DataModels/, PhotoCapture/, CommonComponents/

---

### 3.5 PhotoCapture/
**Purpose:** Camera integration and photo management

**Deliverables:**
- `CameraService.swift` - Camera capture interface
- `PhotoCompressor.swift` - JPEG compression (1280px, 0.8 quality)
- `PhotoStorage.swift` - Local photo file management
- `PhotoUploadQueue.swift` - Queue management
- `PhotoPicker.swift` - Photo library picker (future)
- `PhotoViewer.swift` - Full-screen photo viewer

**Key Requirements:**
- Launch camera for Type (mandatory) and Instance (optional) photos
- Compress to JPEG: longest edge 1280px, quality 0.8
- Generate globally unique filename at capture
- Store locally with upload queue status
- Type: exactly 1 required
- Instance: up to 5 optional
- View captured photos full-screen

**Dependencies:** CoreServices/, LocalStorage/

---

## Phase 4: Room Management (04-RoomManagement/)

### 4.1 RoomView/
**Purpose:** Room detail screen showing assets and room notes

**Deliverables:**
- `RoomView.swift` - Main room screen
- `AssetListItem.swift` - Asset row in list
- `RoomNoteListItem.swift` - Room Note row with icon
- `AddAssetButton.swift` - Bottom "+ Add Asset" action
- `BackToFloorplanButton.swift` - Back arrow
- `RoomHeaderView.swift` - Level, room number, sync status
- `RoomViewModel.swift` - Room state management

**Key Requirements:**
- Floorplan fixed on current room (no pan/zoom)
- List ordered by: Family → Type → creation time
- Room Notes appear in list with distinct icon
- Tap asset → open Instance Editor Widget
- Tap Room Note → open Room Note Editor
- Swipe delete with confirmation
- Bottom: hamburger (Survey Report) + Add Asset button
- Header: back arrow, level/room label, sync status

**Dependencies:** DataModels/, CommonComponents/, FloorplanViewer/

---

### 4.2 InstanceEditor/
**Purpose:** Edit existing asset instances

**Deliverables:**
- `InstanceEditorWidget.swift` - Modal instance editor
- `TypeSummaryView.swift` - Read-only Type info display
- `EditTypeButton.swift` - Button to open Type editor
- `InstanceParameterFields.swift` - Editable instance fields
- `InstancePhotoEditor.swift` - Add/remove instance photos
- `SaveResetButtons.swift` - Save/Reset actions
- `UnsavedChangesAlert.swift` - Discard/Save prompt

**Key Requirements:**
- Show Type summary (read-only)
- Edit instance parameters only
- Edit instance photos (up to 5)
- "Edit Type" button → opens Type Editor
- Reset button reverts to original values
- Save button validates and saves
- Close with unsaved changes → Discard/Save prompt

**Dependencies:** DataModels/, PhotoCapture/, CommonComponents/

---

### 4.3 TypeEditor/
**Purpose:** Edit Type-level parameters (affects all instances)

**Deliverables:**
- `TypeEditorWidget.swift` - Modal Type editor
- `TypeParameterFields.swift` - Editable Type fields
- `TypePhotoViewer.swift` - View/replace Type photo
- `TypeSaveButton.swift` - Save Type changes
- `TypeUnsavedAlert.swift` - Discard/Save prompt

**Key Requirements:**
- Edit Type parameters (affects all instances of this Type)
- View Type photo (single required photo)
- Changes from Survey Report → update existing Type (no duplication)
- Changes from Instance Editor → update existing Type within project
- Close with unsaved changes → prompt
- Save applies to all linked instances

**Dependencies:** DataModels/, PhotoCapture/, CommonComponents/

---

### 4.4 RoomNotes/
**Purpose:** Room Note creation and editing

**Deliverables:**
- `RoomNoteFormView.swift` - Room Note form
- `RoomNotePhotoGrid.swift` - 1 mandatory + 4 optional photos
- `RoomNoteFlagsView.swift` - Mutually exclusive boolean toggles
- `RoomNoteDescriptionField.swift` - Text description
- `SaveRoomNoteButton.swift` - Save with validation

**Key Requirements:**
- Read-only: Level, Host Room
- Photos: 1 mandatory main + up to 4 optional
- Boolean flags: "Empty room", "Room is blocked" (mutually exclusive, both can be "no")
- If room has assets, both flags are disabled (grayed out)
- Description field for notes
- "Save Note" → return to Room View with note added
- Progress tracker in wizard context

**Dependencies:** DataModels/, PhotoCapture/, CommonComponents/

---

## Phase 5: Survey Reporting (05-SurveyReporting/)

### 5.1 SurveyReportHub/
**Purpose:** Main Survey Report screen with tabs and search

**Deliverables:**
- `SurveyReportView.swift` - Main container with tabs
- `SurveyReportHeader.swift` - Title, search bar, back button
- `TabBar.swift` - Rooms / Types / Export tabs
- `SurveyReportViewModel.swift` - State management

**Key Requirements:**
- Three tabs: Rooms list, Types list, Project Export
- Global search bar
- Bottom fixed tab bar
- Opens from floorplan or room view (☰ button)
- Back to previous screen

**Dependencies:** CommonComponents/

---

### 5.2 RoomsList/
**Purpose:** Searchable, filterable rooms list in Survey Report

**Deliverables:**
- `RoomsListView.swift` - Rooms list with grouping
- `RoomListItem.swift` - Room row (number, name, count)
- `RoomListFilter.swift` - Filter modal
- `AddAssetFromListButton.swift` - (+) for empty rooms
- `RoomsListViewModel.swift` - Search, filter, sort logic

**Key Requirements:**
- Grouped by level
- Show: room number, name, asset + room note count
- Tap room → open Room View
- Empty rooms show (+) → Add Asset wizard
- Filter button opens filter modal:
  - Room Type: All, Without assets, With assets
  - Asset Type: multi-select list of asset Types
  - Show only rooms containing selected Types
  - Reset/Save controls
- Applied filters show indicator in search bar

**Dependencies:** DataModels/, RoomView/, CommonComponents/

---

### 5.3 TypesList/
**Purpose:** Searchable, filterable Types list in Survey Report

**Deliverables:**
- `TypesListView.swift` - Types list with grouping
- `TypeListItem.swift` - Type row (name, summary, count)
- `TypeListFilter.swift` - Filter modal with parameter filters
- `TypesListViewModel.swift` - Search, filter logic

**Key Requirements:**
- Grouped by Family
- Show: Type name, parameter summary, instance count
- Tap Type → Edit Type widget
- Filter button opens filter modal:
  - Family selector (required first step)
  - After Family selected, show all parameters for that Family
  - Each parameter: dropdown of existing values
  - Multi-select across parameter values
  - Types must match ALL selected parameters (AND)
  - Types must match ANY value within each parameter (OR)
  - Reset/Save controls
- Applied filters show indicator in search bar

**Dependencies:** DataModels/, TypeEditor/, CommonComponents/

---

### 5.4 ProjectExport/
**Purpose:** Generate and share project export package

**Deliverables:**
- `ProjectExportView.swift` - Export tab UI
- `ExportProgressView.swift` - "Building export..." progress
- `ShareSheetPresenter.swift` - iOS share sheet integration
- `ExportGenerator.swift` - Local export file creation
- `ExportViewModel.swift` - Export state management

**Key Requirements:**
- Show progress: "Building project export file..."
- Generate local export package (backup if sync fails)
- When ready, present iOS share sheet
- Export includes: asset data, photos, metadata
- Acts as fallback if sync fails

**Dependencies:** DataModels/, LocalStorage/, NetworkLayer/

---

## Phase 6: Synchronization (06-Synchronization/)

### 6.1 SyncEngine/
**Purpose:** Automatic event and photo synchronization

**Deliverables:**
- `SyncManager.swift` - Main sync orchestrator
- `EventUploader.swift` - Upload pending events in order
- `PhotoUploader.swift` - Background photo upload
- `SyncStatusTracker.swift` - Track sync state
- `RetryScheduler.swift` - Exponential backoff retry logic
- `ConflictResolver.swift` - Future conflict handling

**Key Requirements:**
- Automatic sync trigger on create/update/delete
- Upload events in timestamp order
- Background photo upload queue
- Retry logic:
  - Failed sync → retry every 30 seconds
  - After 10 failures → retry every 5 minutes indefinitely
- No manual sync trigger
- Sync states: syncing, synced, failed to sync
- Tap sync status for detailed message

**Dependencies:** NetworkLayer/, LocalStorage/, EventSourcing/

---

### 6.2 EventSourcing/
**Purpose:** Event log pattern for change tracking

**Deliverables:**
- `Event.swift` - Base event model (from DataModels)
- `EventLogger.swift` - Log all changes as events
- `EventTypes.swift` - Event type definitions
- `EventSerializer.swift` - JSON encoding/decoding
- `EventCompactor.swift` - Future event compaction

**Key Requirements:**
- Event types:
  - INSTANCE_CREATED
  - INSTANCE_UPDATED
  - INSTANCE_DELETED
  - TYPE_CREATED
  - TYPE_UPDATED
  - PHOTO_ATTACHED
  - ROOM_NOTE_CREATED
  - ROOM_NOTE_UPDATED
  - ROOM_NOTE_DELETED
- Event structure: event_id (UUIDv7), type, timestamp, project_id, payload, device_id, operator_id
- All changes logged locally
- Events uploaded in order when online
- Audit trail for all operations

**Dependencies:** DataModels/, LocalStorage/

---

### 6.3 PhotoUploadQueue/
**Purpose:** Background photo upload with retry

**Deliverables:**
- `PhotoQueueManager.swift` - Upload queue management
- `BackgroundUploadSession.swift` - Background URL session
- `PhotoUploadTask.swift` - Individual upload task
- `UploadRetryPolicy.swift` - Retry logic for failed uploads
- `PhotoCompletionHandler.swift` - Background completion handling

**Key Requirements:**
- Background upload when app is suspended
- Upload Type and Instance photos
- Track upload status per photo
- Retry failed uploads with backoff
- Update local status on success/failure
- Resume interrupted uploads

**Dependencies:** NetworkLayer/, LocalStorage/, PhotoCapture/

---

### 6.4 SurveyCompletion/
**Purpose:** Survey completion validation and state management

**Deliverables:**
- `SurveyCompletionValidator.swift` - Validate all rooms addressed
- `ExitPopupView.swift` - Pause/Complete options
- `EmptyRoomsReportView.swift` - List of incomplete rooms
- `SlideToCompleteControl.swift` - Completion confirmation
- `ReadOnlyModeActivator.swift` - Lock project after completion

**Key Requirements:**
- Exit button opens popup: "Pause Survey" or "Complete Survey"
- Pause → return to Projects page (can resume later)
- Complete → validate all rooms have ≥1 asset or Room Note
- If validation fails → show empty rooms report + "View Empty Rooms" link
- Link opens Survey Report > Rooms filtered to empty rooms
- If validation passes → "Slide to complete" control
- On complete → project state → COMPLETED, becomes read-only
- Completed projects cannot be edited

**Dependencies:** DataModels/, SurveyReporting/, CoreServices/

---

## Phase 7: Polish (07-Polish/)

### 7.1 ReadOnlyMode/
**Purpose:** Read-only mode for completed projects

**Deliverables:**
- `ReadOnlyModeManager.swift` - Enable/disable read-only state
- `ReadOnlyWarningAlert.swift` - Warning popup on open
- `ReadOnlyOverlay.swift` - Visual halftone treatment
- `DisabledControls.swift` - Disable edit actions

**Key Requirements:**
- Trigger: opening Completed project
- Warning popup: "Project is read-only"
- Visual treatment: halftone assets/room notes in badges and lists
- Disabled interactions:
  - "+ Add Asset"
  - "Save Asset", "Save Note"
  - "Save" in Instance/Type editors
  - "Edit Type" button
  - Delete actions (swipe delete)
  - Reset actions
- Forms/lists remain visible but non-editable

**Dependencies:** All UI components

---

### 7.2 ErrorHandling/
**Purpose:** Comprehensive error handling and user feedback

**Deliverables:**
- `ErrorHandler.swift` - Centralized error handling
- `ErrorAlertPresenter.swift` - User-friendly error messages
- `LoggingService.swift` - Error and debug logging
- `CrashReporter.swift` - Crash reporting integration
- `NetworkErrorHandler.swift` - Network-specific errors
- `ValidationErrorHandler.swift` - Form validation errors

**Key Requirements:**
- User-friendly error messages
- Network error handling (offline, timeout, server errors)
- Validation error display (inline + summary)
- Crash reporting and analytics
- Debug logging for troubleshooting
- Graceful degradation

**Dependencies:** All components

---

### 7.3 Testing/
**Purpose:** Comprehensive test coverage

**Deliverables:**
- Unit tests for all services and view models
- UI tests for critical flows
- Integration tests for sync engine
- Mock data generators
- Test fixtures and helpers
- Snapshot tests for UI components
- Performance tests

**Key Requirements:**
- Test coverage ≥80%
- Critical path testing: Add Asset, Sync, Completion
- Mock network responses
- Offline scenario testing
- Photo capture/upload testing
- State transition testing
- Error scenario testing

**Dependencies:** All components

---

### 7.4 Performance/
**Purpose:** Optimize app performance and resource usage

**Deliverables:**
- `PerformanceMonitor.swift` - Performance metrics tracking
- Tile caching optimization
- Memory management improvements
- Battery usage optimization
- Network efficiency tuning
- Database query optimization
- Image loading/caching improvements

**Key Requirements:**
- Smooth scrolling in large asset lists
- Fast floorplan rendering
- Efficient photo compression
- Background task optimization
- Memory footprint monitoring
- Launch time optimization
- Battery impact minimization

**Dependencies:** All components

---

## Development Order

### Sprint 1-2: Foundation (Weeks 1-4)
1. DataModels
2. LocalStorage
3. NetworkLayer
4. CoreServices

### Sprint 3-4: Core UI (Weeks 5-8)
5. CommonComponents
6. Navigation
7. ProjectsList
8. FloorplanViewer

### Sprint 5-7: Asset Management (Weeks 9-14)
9. PhotoCapture
10. AddAssetWizard
11. FamilySelection
12. TypeSelection
13. InstanceForm

### Sprint 8-9: Room Management (Weeks 15-18)
14. RoomView
15. InstanceEditor
16. TypeEditor
17. RoomNotes

### Sprint 10-11: Survey Reporting (Weeks 19-22)
18. SurveyReportHub
19. RoomsList
20. TypesList
21. ProjectExport

### Sprint 12-13: Synchronization (Weeks 23-26)
22. EventSourcing
23. PhotoUploadQueue
24. SyncEngine
25. SurveyCompletion

### Sprint 14: Polish (Weeks 27-28)
26. ReadOnlyMode
27. ErrorHandling
28. Testing
29. Performance

---

## Key Dependencies

### External Dependencies
- SwiftUI (iOS 15+)
- Core Data or Realm for local storage
- MapKit or custom tile renderer
- Background task framework
- Network framework
- Camera/Photo library APIs

### Internal Dependencies Flow
```
DataModels → LocalStorage → CoreServices
                ↓              ↓
          NetworkLayer → SyncEngine
                ↓              ↓
        CommonComponents → All UI Views
                ↓
        Complete App
```

---

## Success Criteria

Each task folder should contain:
1. **Source Code** - Swift files for that component
2. **Tests** - Unit tests with ≥80% coverage
3. **README.md** - Component documentation
4. **CHANGELOG.md** - Version history
5. **Assets** - Component-specific resources

Each component must:
1. Follow SOLID principles
2. Have clear interfaces/protocols
3. Include comprehensive error handling
4. Support offline-first operation
5. Be testable in isolation
6. Include inline documentation

---

## Next Steps

1. Review this strategy with the team
2. Set up the folder structure
3. Create README templates for each folder
4. Begin Sprint 1 with Foundation phase
5. Schedule regular reviews at sprint boundaries
6. Maintain continuous integration and testing

---

**Document Version:** 1.0
**Last Updated:** 2026-01-05
**Status:** Draft - Pending Review
