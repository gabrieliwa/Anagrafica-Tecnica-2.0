# iOS App Roadmap (Anagrafica Tecnica)

This roadmap reflects the latest product and UI specs in this repo.

## Recommended Technical Decisions

- iOS minimum version: 16.0
  - Reason: broad device coverage while still supporting modern SwiftUI and async/await.
- Persistence: SQLite via GRDB
  - Reason: reliable offline-first storage, explicit migrations, strong control for event logs and sync retries.
- Floorplan tiles: vector tiles from DWG output (offline cached)
- Language: English only

## Phase 0 - Project Bootstrap

- Create a clean Xcode project (SwiftUI, iOS 16).
- Add SwiftPM modules:
  - Core (networking, persistence, sync, models)
  - DesignSystem (colors, typography, icons)
  - Features (Projects, Floorplan, Room, Wizard, SurveyHub, Export)
- Set up build configs and app bundle identifiers.
- Define app-wide navigation shell and routing.

Deliverable: running app shell with empty screens and navigation.

## Phase 1 - Data Contracts and Persistence

- Define canonical models: Project, Level, Room, Family, Type, Instance, RoomNote, Photo, SyncEvent.
- Define JSON contracts that match backend.
- Implement SQLite schema and migrations:
  - Projects, Levels, Rooms, Families, Types, Instances, RoomNotes
  - Photos (Type and Instance)
  - SyncEvent queue
- Implement local file cache for photos and tiles.

Deliverable: local CRUD + JSON mapping + event log.

## Phase 2 - Sync Engine (Offline First)

- Implement SyncManager:
  - Event queue, background upload, retry logic (30s, then 5m after 10 failures).
  - No manual sync trigger.
  - Status indicator states (syncing, synced, failed).
- Wire to network reachability and background tasks.

Deliverable: simulated sync loop with mock endpoints.

## Phase 3 - Floorplan Viewer (High Risk)

- Build vector tile renderer with pan/zoom and room hit-testing.
- Overlay room states:
  - Empty rooms: halftone gray + (+) button.
  - Rooms with assets/room notes: light blue + count badge.
- Level picker (bottom-right, drop-up).
- Room names/numbers visible on floorplan.

Deliverable: interactive floorplan with room selection.

## Phase 4 - Core Survey Flow

- Projects page with states, empty state, loading screen.
- Room View:
  - Fixed floorplan, list of assets + room notes.
  - Ordering: family -> type -> creation time.
  - Distinct icon for room notes.
- Add Asset Wizard:
  - Room Note flow.
  - Existing Type flow (branch on parameter change).
  - New Type flow (photo -> form -> name).
  - Instance Form (optional photos up to 5).
- Read-only mode behavior and UI.

Deliverable: end-to-end survey flow with local data only.

## Phase 5 - Survey Hub and Export

- Survey Report hub:
  - Rooms list, Types list, filters, counts include room notes.
  - Edit Type widget (current project only).
- Project Export:
  - Local export stub and iOS share sheet.

Deliverable: survey hub feature complete (export mocked).

## Phase 6 - Hardening and QA

- Validation rules from schema (Type fields required, Instance fields per schema).
- Error states, empty states, and alerts.
- Performance profiling on floorplan rendering.
- Manual QA checklist against UI specs.

Deliverable: feature-complete beta ready for backend integration.

## Dependencies and Inputs

- Vector tiles pipeline from backend (tile format + metadata).
- Schema definition format (families, parameters, validation).
- Auth strategy (if any) and API base URL.

## Immediate Next Actions

1. Confirm iOS 16 + GRDB (or request changes).
2. Scaffold a new Xcode project and modules.
3. Define the JSON contracts for the mobile app.
4. Start a floorplan rendering spike with sample tiles.
