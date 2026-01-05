# Phase 3: Asset Management

## Overview

The Asset Management phase implements the core workflow for creating and capturing assets in the field. This is the most frequently used functionality in the app, so it must be fast, intuitive, and work perfectly offline.

## Components

### AddAssetWizard/
Multi-step wizard with progress tracker guiding operators through asset creation.

**Workflow:**
1. Family selection (including Room Note option)
2. Type selection/creation
3. Instance parameter form

**Key Features:**
- Progress tracker showing current step
- Exit confirmation ("Progress will be lost")
- Return to appropriate context (Floorplan or Room View)

**Key Files:**
- `AddAssetWizardView.swift`
- `WizardProgressTracker.swift`
- `WizardCoordinator.swift`
- `ExitConfirmationAlert.swift`

### FamilySelection/
First step: choose asset Family or Room Note.

**Key Features:**
- Search bar filters both Family names AND Type names
- Room Note option (always available, separated by line)
- Family icons and labels
- Tap Family → Type selection
- Tap Room Note → Room Note form

**Key Files:**
- `FamilySelectionView.swift`
- `FamilyCard.swift`
- `RoomNoteOption.swift`
- `FamilySearchBar.swift`

### TypeSelection/
Second step: select existing Type or create new.

**Key Features:**
- Search existing Types
- "+ New Type" button
- **New Type path:** Camera → Type form → Name Type
- **Existing Type path:** Type form pre-filled
  - Unchanged → skip to Instance form
  - Changed → prompt for new Type name → branch Type
- Fuzzy matching warns of duplicate Types
- Type photo required (exactly 1)

**Key Files:**
- `TypeSelectionView.swift`
- `TypeCard.swift`
- `CreateNewTypeButton.swift`
- `TypeSearchBar.swift`
- `TypeFormView.swift`
- `FuzzyMatchWarning.swift`
- `TypePhotoCapture.swift`

### InstanceForm/
Final step: fill instance parameters and save.

**Key Features:**
- Instance-scoped parameters only
- Pre-filled read-only: Level, Room
- Optional Instance photos (up to 5)
- Required field validation before save
- "Asset saved" banner on success

**Key Files:**
- `InstanceFormView.swift`
- `InstancePhotoGrid.swift`
- `ReadOnlyFields.swift`
- `SaveAssetButton.swift`
- `InstanceFormViewModel.swift`

### PhotoCapture/
Camera integration and photo management service.

**Key Features:**
- Launch camera for capture
- Compress to JPEG (1280px longest edge, 0.8 quality)
- Generate globally unique filename
- Store locally with upload queue
- Type: exactly 1 required
- Instance: up to 5 optional
- Full-screen photo viewer

**Key Files:**
- `CameraService.swift`
- `PhotoCompressor.swift`
- `PhotoStorage.swift`
- `PhotoUploadQueue.swift`
- `PhotoPicker.swift`
- `PhotoViewer.swift`

## Asset Hierarchy: Family → Type → Instance

### Family
- Category with shared parameter structure
- Examples: Lights, Radiators, Access Points
- Created by admins only
- Defines Type and Instance parameters

### Type
- Specific product within a Family
- Examples: "Philips 30W LED Panel", "Carrier 12000 BTU Split AC"
- Can be created by operators in field
- Has exactly 1 required photo
- Parameters fixed for all instances

### Instance
- Single physical asset in a room
- Belongs to one Type
- Has instance-specific data (serial, condition, notes)
- Optional photos (up to 5)
- Positioned at room centroid

## Type Creation Priority

1. **Use existing Type** (preferred) — Fastest, maintains consistency
2. **Duplicate and modify** — When similar Type exists but one parameter differs
3. **Create new Type** — Only when no similar Type exists

Fuzzy matching helps prevent duplicates by suggesting similar existing Types.

## Photo Requirements

### Type Photos
- **Required:** Exactly 1 per Type
- **Shared:** Across all instances of that Type
- **Captured:** When creating new Type (camera launches immediately)
- **Format:** JPEG, 1280px longest edge, 0.8 quality

### Instance Photos
- **Optional:** 0-5 per Instance
- **Instance-specific:** Not shared
- **Captured:** During Instance form or later in editor
- **Format:** Same as Type photos

### Photo Naming
Format: `{project_short}_{operator_id}_{timestamp}_{sequence}.jpg`

Example: `PRJ001_OP42_20251215143022_001.jpg`

This ensures:
- Globally unique names
- Traceability to project and operator
- Consistent naming from capture to export

## Dependencies

- **Phase 1:** DataModels, LocalStorage, CoreServices
- **Phase 2:** CommonComponents, Navigation
- **External:** AVFoundation (camera), Photos framework

## Success Criteria

- [ ] Wizard flow is intuitive and fast
- [ ] Progress tracker clearly shows current step
- [ ] Family search filters both families and types
- [ ] Type creation launches camera immediately
- [ ] Fuzzy matching suggests similar Types
- [ ] Type branching doesn't modify original
- [ ] Photo compression works correctly
- [ ] Photo naming follows specification
- [ ] Required field validation prevents incomplete saves
- [ ] Exit confirmation prevents accidental data loss
- [ ] "Asset saved" feedback is clear
- [ ] Works perfectly offline
- [ ] 80%+ unit test coverage

## Development Timeline

**Estimated Duration:** 6 weeks (Sprints 5-7)

**Week 9:** PhotoCapture service
**Week 10:** AddAssetWizard framework
**Week 11:** FamilySelection
**Week 12:** TypeSelection (existing Type path)
**Week 13:** TypeSelection (new Type path + fuzzy matching)
**Week 14:** InstanceForm + Testing

## Testing Requirements

- Unit tests for all view models
- UI tests for complete wizard flows
- Photo capture and compression tests
- Fuzzy matching accuracy tests
- Validation logic tests
- Offline operation tests
- Type branching tests

## UI/UX Guidelines

### Wizard Flow
- Always show progress tracker
- Clear visual feedback for current step
- Disable "Next" until required fields filled
- Exit confirmation protects against data loss

### Form Fields
- Required fields marked clearly
- Inline validation as user types
- Red border on empty required field when trying to save
- Helpful error messages

### Photo Capture
- Immediate camera launch for new Type
- Clear photo preview after capture
- Easy retake option
- Photo count indicator (e.g., "3/5" for Instance photos)

### Performance
- Wizard steps should transition instantly
- Photo compression should be fast (<1 second)
- Form validation should be instant
- Search should feel responsive

## Common Pitfalls

- Don't modify original Type when branching
- Don't allow incomplete assets to save
- Don't lose wizard progress on accidental exit
- Don't allow duplicate Type names
- Don't skip photo compression
- Don't generate non-unique photo names
- Don't block UI during photo compression

## Notes

- This is the most critical user flow in the app
- Operators will use this dozens of times per survey
- Every second saved multiplies across hundreds of assets
- Offline reliability is non-negotiable
- Photo quality vs file size must be balanced
- Fuzzy matching threshold needs tuning based on field testing
