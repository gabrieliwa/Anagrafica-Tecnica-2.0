# Mobile UI Specifications

## Scope

- Source: UI Moodboard 4 (mobile app)
- Coverage: Projects page, survey workflow, asset creation/editing, and export
- Platform: iOS (single-hand usage, offline-first)

## Global Navigation and Patterns

- Top bar (floorplan/room/wizard): Exit or Back on left, screen title centered, sync status icon on right
- Bottom actions: fixed hamburger for Survey Report and context-specific primary action ("+ Add Asset")
- Progress tracker: dots show not-yet/current/completed step states
- Sync status indicator: three states (syncing, synced, failed to sync) with tap-to-view message
- Prompts: unsaved edits modal with Discard/Save, delete confirmation modal with Delete/No

## Screens

### Projects Page (Home)

- Purpose: list and open available projects
- UI elements:
  - Search bar
  - Filter button (location/status)
  - Project list cards with per-project sync status
  - Settings and Import buttons fixed at bottom (placeholders for future implementation)
  - Empty state: "No project assigned" when no projects are available
- Project card content:
  - Project name
  - Project image
  - Location
  - Number of rooms
  - Number of assets
  - State label
- Project states (visual differentiation):
  - Online: label "Online" with light gray background (#F1F1F1)
  - Open: label "Open" with light blue background (#DCEEFF)
  - Completed: label "Completed" with light green background (#DFF5E1)
- Interactions:
  - Tap Online project: show loading screen while downloading, then open floorplan
  - Tap Open project: open floorplan
  - Tap Completed project: opens floorplan (read-only warning and lock behavior planned for sync phase)

### Read-Only Mode (Completed Projects, planned for sync phase)

- Trigger: opening a Completed project
- Implement after sync is functional (Phase 6)
- Warning popup informs the operator that the project is read-only
- Visual treatment:
  - Assets and room notes are halftoned in floorplan badges and room lists
  - Forms and lists remain visible but are non-editable
- Disabled interactions (halftoned and non-interactive):
  - "+ Add Asset"
  - "Save Asset" and "Save Note"
  - "Save" in Instance Editor and Edit Type widgets
  - "Edit Type" button
  - Delete actions (swipe delete and delete confirmations)
  - Reset actions in editors
  - Search filters visible list; filter updates list state

### Interactive Floorplan

- Purpose: navigate rooms via floorplan
- UI elements:
  - Exit button (top left)
  - Project name (top center)
  - Sync status icon (top right)
  - Level picker (bottom right, drop-up)
  - Survey Report hamburger (bottom left)
- Floorplan canvas renders edge-to-edge behind UI chrome
- Room states:
- Rooms with assets or room notes show a light blue fill with a count badge (assets + room notes)
  - Empty rooms show a halftone gray fill with a (+) button inside
  - Room names and numbers are visible on the floorplan
  - Room badges (+ and counts) keep a constant on-screen size when zooming
- Interactions:
  - Tap room with assets or room notes: open Room View
  - Tap empty room: open Add Asset Wizard
  - Operator can freely zoom and pan in this view
  - Zoom out is limited to the full-plan fit; zoom in is limited to the smallest room size
  - Zoom is centered on the view (not the top-left)
  - First open starts at the lowest floor level
  - Switching levels resets zoom/pan to full-plan fit and centered

### Exit Pop-up (Before Exiting)

- Options: Pause Survey, Complete Survey
- Completion logic:
  - If empty rooms exist, show warning and "View Empty Rooms"
  - If no empty rooms, show "Slide to complete" confirmation
- Navigation:
  - Pause Survey returns to Projects page
  - "View Empty Rooms" opens Survey Report > Rooms list with "only empty rooms" filter

### Room View

- Purpose: view assets and room notes in the selected room
- UI elements:
  - Back arrow to floorplan
  - Title: "Level X - Room ####"
  - Sync status icon
  - Room plan background
  - Scrollable list of assets and room notes
  - Bottom actions: Survey Report (hamburger) and "+ Add Asset"
- Interactions:
  - Tap list item: open Instance Editor Widget
  - Swipe list item: reveal Delete; confirm deletion
  - After save: "Asset saved" or "Note created" banner
- Behavior:
  - Zoom and pan are disabled; the floorplan is fixed on the current room
  - Room names and numbers remain visible
  - List order: family, then type, then creation time
  - Room Notes use a distinct icon in the list

### Instance Editor Widget

- Purpose: edit instance-level data
- UI elements:
  - Type summary and key image
  - Instance parameters only (Level/Room read-only)
  - Optional Instance photos (up to 5)
  - Reset and Save buttons
  - "Edit Type" button
- Behavior:
  - Closing with unsaved edits triggers Discard/Save prompt
  - "Edit Type" opens the Edit Type widget (separate modal, edits in place)

### Survey Report

- Purpose: lists hub for rooms and types, plus export
- Navigation:
  - Bottom fixed buttons for Rooms, Types, Export
- Rooms list:
  - Grouped by level
  - Search bar and filter button
  - Row content: room number, room name, asset count (assets + room notes)
  - Rooms with no items show a "+" action
- Room list filter:
  - Room type (All / Without assets / With assets)
  - Asset types (multi-select; only rooms containing selected types are shown)
  - Reset/Save
  - Applied filter indicator in search bar
- Types list:
  - Grouped by family
  - Search bar and filter button
  - Row content: type name, parameter summary, instance count
- Type list filter:
  - Family selector (required)
  - After family selection, all parameters for that family appear
  - Each parameter has a drop-down list of existing values
  - Multi-select across values and parameters; types must match all selected parameters, and any selected value within each parameter
  - Reset/Save
  - Applied filter indicator in search bar
- Edit Type widget:
  - Type parameters and the required single Type photo
  - "View photo" opens the Type photo
  - Save and unsaved changes prompt (Discard/Save)
  - Changes apply only within the current project
- Project Export:
  - Progress pop-up: "Building project export file..."
  - iOS share sheet when ready
  - Export serves as a backup mechanism if sync fails

### Add Asset Wizard

- Purpose: create assets or room notes in a guided flow
- Common UI:
  - Progress tracker dots
  - Close (X) at top left
- Step 1: Choose Family
  - Search bar filters both Family names and Type names within families
  - Room Note option sits below the search bar and above the families list, separated by a horizontal line
  - List of families, plus the Room Note option
  - Room Note is always available
- Step 2a: Room Note Form (if Room Note selected)
  - Special progress tracker for room notes
  - Photos: 1 mandatory main photo plus up to 4 optional photos
  - Read-only Level and Host Room
  - Boolean flags: "Empty room" and "Room is blocked"
  - Flags are mutually exclusive, but both can be "no"
  - If the room already contains assets, both flags are disabled (grayed out)
  - Description field
  - "Save Note" returns to Room View
- Step 2b: Type Selection (if standard Family selected)
  - Search and list of types
  - Operator can select an existing type or choose "+ New Type"
  - "+ New Type" opens camera; captured photo becomes the required single Type photo
- Step 3: Type Form (existing or new)
  - Type parameters and the required single Type photo
  - If an existing type is unchanged, proceed directly to Step 4 (Instance Form)
  - If any parameter changes in this wizard, prompt to name a new Type before proceeding
  - Branched types do not affect the original; only the new asset uses the branched type
  - New Type flow: take photo (mandatory) -> complete empty Type form -> name new Type -> Step 4
- Step 3.3: Name New Type
  - Keyboard entry for new Type name
  - Save returns to instance form
- Step 4: Instance Form
  - Instance parameters (Level/Room read-only)
  - Optional Instance photos (up to 5)
  - "Save Asset" returns to Room View
- Exit behavior:
  - Exiting mid-way shows a warning that all progress will be lost
  - Confirming returns to the Floorplan View or Room View based on where the wizard was launched

### Room Completion

- A room is considered complete when it contains at least one asset or one room note

### Locked Rooms

- A room is annotated as "locked" when the operator cannot physically access it
- If access becomes available later, the operator deletes the locked room note and adds assets normally

### Sync Behavior

- Sync attempts are triggered whenever an asset, room note, or type is created, modified, or deleted
- If a sync attempt fails, changes are backed up locally and retried every 30 seconds
- After 10 consecutive failures, retry interval switches to every 5 minutes until successful
- Operators cannot manually trigger sync

### Form Fields and Validation

- Supported field types: text, number, photos, dropdown, toggles, dates
- Field composition is defined by the project schema in the backend
- All fields in the Type Form are mandatory
- Instance Form fields can be mandatory or optional, as defined by the schema
- Validation errors appear inline during entry
- When the operator attempts to save, missing mandatory fields turn red

### Terminology and Conventions

- "Asset" always refers to a technical asset instance
- App users are referred to as "operators"
- One asset can belong to one and only one room

## Modals and Alerts

- Delete confirmation: "Do you really want to delete this asset?" with Delete/No
- Unsaved edits prompt for Instance or Type editors: Discard/Save
- Export progress: modal while export file is generated
- Read-only warning on opening a Completed project
- Wizard exit confirmation warns that progress will be lost
- Room Note flags are mutually exclusive; selecting one deselects the other, and both can be "no"
