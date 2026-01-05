# Phase 4: Room Management

## Overview

Room Management provides detailed views and editing capabilities for rooms and their contents. This includes viewing all assets in a room, editing individual instances, modifying Types, and creating Room Notes for empty or blocked rooms.

## Components

### RoomView/
Detailed view of a single room showing all assets and room notes.

**Key Features:**
- Floorplan fixed on current room (no pan/zoom)
- List of assets ordered by: Family → Type → creation time
- Room Notes appear in list with distinct icon
- Tap asset → Instance Editor Widget
- Tap Room Note → Room Note Editor
- Swipe to delete with confirmation
- Header: back arrow, level/room label, sync status
- Bottom: hamburger (Survey Report) + Add Asset button

**Key Files:**
- `RoomView.swift`
- `AssetListItem.swift`
- `RoomNoteListItem.swift`
- `AddAssetButton.swift`
- `BackToFloorplanButton.swift`
- `RoomHeaderView.swift`
- `RoomViewModel.swift`

### InstanceEditor/
Modal widget for editing existing asset instances.

**Key Features:**
- Type summary (read-only)
- Edit instance parameters only
- Edit instance photos (up to 5)
- "Edit Type" button → Type Editor
- Reset button reverts to original values
- Save validates and persists changes
- Close with unsaved changes → Discard/Save prompt

**Key Files:**
- `InstanceEditorWidget.swift`
- `TypeSummaryView.swift`
- `EditTypeButton.swift`
- `InstanceParameterFields.swift`
- `InstancePhotoEditor.swift`
- `SaveResetButtons.swift`
- `UnsavedChangesAlert.swift`

### TypeEditor/
Modal widget for editing Type-level parameters (affects all instances).

**Key Features:**
- Edit Type parameters
- View/replace Type photo (single required photo)
- Changes from Survey Report → update existing Type (no duplication)
- Changes from Instance Editor → update existing Type within project
- Close with unsaved changes → Discard/Save prompt
- Save applies to ALL linked instances

**Key Files:**
- `TypeEditorWidget.swift`
- `TypeParameterFields.swift`
- `TypePhotoViewer.swift`
- `TypeSaveButton.swift`
- `TypeUnsavedAlert.swift`

### RoomNotes/
Room Note creation and editing for empty or blocked rooms.

**Key Features:**
- Read-only: Level, Host Room
- Photos: 1 mandatory main + up to 4 optional
- Boolean flags: "Empty room", "Room is blocked"
  - Mutually exclusive (select one deselects the other)
  - Both can be "no" (for general notes)
  - If room has assets, both flags disabled (grayed out)
- Description field for notes
- "Save Note" → return to Room View

**Key Files:**
- `RoomNoteFormView.swift`
- `RoomNotePhotoGrid.swift`
- `RoomNoteFlagsView.swift`
- `RoomNoteDescriptionField.swift`
- `SaveRoomNoteButton.swift`

## Room Note Use Cases

### Empty Room
- Situation: Room legitimately has no assets to register
- Action: Add Room Note + set "Empty room" = yes + optional description
- Example: "Storage closet - no technical equipment"

### Blocked Room
- Situation: Room is physically inaccessible
- Action: Add Room Note + set "Room is blocked" = yes + required description
- Example: "Door locked - no key available"

### General Note
- Situation: Need to add information about room
- Action: Add Room Note + both flags = no + description
- Example: "Ceiling under renovation - assets covered"

## Editing Workflows

### Edit Instance
1. From Room View, tap asset row
2. Instance Editor opens
3. Edit instance parameters and/or photos
4. Save → updates instance
5. Return to Room View

### Edit Type (from Instance Editor)
1. From Instance Editor, tap "Edit Type"
2. Type Editor opens
3. Edit Type parameters (affects ALL instances)
4. Save → updates Type and all its instances
5. Return to Instance Editor

### Edit Type (from Survey Report Types List)
1. From Survey Report > Types tab, tap Type row
2. Type Editor opens
3. Edit Type parameters
4. Save → updates existing Type (no duplication)
5. Return to Types list

### Delete Asset
1. From Room View, swipe asset row left
2. Delete button appears
3. Tap Delete
4. Confirmation modal: "Are you sure?"
5. Confirm → asset deleted from room
6. List updates, room badge updates

## Data Flow

```
Room View
    │
    ├─► Asset List Item (tap) ──► Instance Editor Widget
    │                                     │
    │                                     └─► Edit Type button ──► Type Editor Widget
    │
    ├─► Room Note List Item (tap) ──► Room Note Editor
    │
    └─► Add Asset button ──► Add Asset Wizard
```

## Dependencies

- **Phase 1:** DataModels, LocalStorage, CoreServices
- **Phase 2:** CommonComponents, Navigation, FloorplanViewer
- **Phase 3:** PhotoCapture
- **External:** SwiftUI, Combine

## Success Criteria

- [ ] Room View displays all assets and room notes correctly
- [ ] Assets ordered by Family → Type → creation time
- [ ] Instance Editor edits instance without affecting Type
- [ ] Type Editor updates all instances of that Type
- [ ] Room Note flags are mutually exclusive
- [ ] Room Note flags disabled when room has assets
- [ ] Swipe delete works with confirmation
- [ ] Unsaved changes prompt works correctly
- [ ] Reset button reverts to original values
- [ ] Save validates before persisting
- [ ] All changes logged for sync
- [ ] Works perfectly offline
- [ ] 80%+ unit test coverage

## Development Timeline

**Estimated Duration:** 4 weeks (Sprints 8-9)

**Week 15:** RoomView implementation
**Week 16:** InstanceEditor widget
**Week 17:** TypeEditor widget
**Week 18:** RoomNotes + Testing

## Testing Requirements

- Unit tests for all view models
- UI tests for editing workflows
- State management tests
- Validation logic tests
- Delete confirmation tests
- Unsaved changes prompt tests
- Offline operation tests

## UI/UX Guidelines

### Room View
- List should scroll smoothly even with 100+ assets
- Room Notes should be visually distinct from assets
- Swipe delete should feel natural (iOS standard)
- Add Asset button should be prominent

### Instance Editor
- Modal presentation (sheet or fullscreen)
- Type summary clearly separated from instance fields
- Edit Type button should be secondary action
- Save/Reset buttons clearly labeled

### Type Editor
- Warning: "Changes affect all instances of this Type"
- Type photo prominently displayed
- Changes should be clearly indicated
- Confirmation required for save

### Room Notes
- Flags should be clearly mutually exclusive
- Photo requirement (1 mandatory) clearly indicated
- Disabled flags should be obviously grayed out
- Description field should be spacious

## Common Pitfalls

- Don't let Instance Editor modify Type parameters directly
- Don't forget to update room badge count after delete
- Don't allow save without required Room Note main photo
- Don't lose unsaved changes without warning
- Don't update Type from Instance Editor in Add Asset wizard (branch instead)
- Don't allow both Room Note flags to be "yes" simultaneously
- Don't enable Room Note flags when room has assets

## Notes

- Type Editor changes are project-scoped, not global
- Deleting all assets from a room requires a Room Note for completion
- Room Note with "Empty room" = yes allows survey completion
- Room Note with "Room is blocked" = yes marks room as inaccessible
- Instance photos are optional and instance-specific
- Type photo is required and shared across all instances
- All edits must be logged as events for sync
