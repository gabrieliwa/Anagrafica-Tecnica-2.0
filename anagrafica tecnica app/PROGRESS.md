# Progress Checklist

Last updated: 2026-01-09

Update rule: keep this checklist current whenever milestones change.

## Project Setup

- [x] New Xcode project created (AnagraficaTecnica)
- [x] SwiftPM package created at `Packages/Package.swift`
- [x] Local package added to Xcode and linked to app target
- [x] Module folders created under `Packages/`
- [x] Legacy phase folders removed
- [x] Documentation consolidated into `README.md` + `mobile-ui-specs.md`
- [x] DemoPlan.bundle added to app resources (plan template + levels + schema)
- [ ] Add second demo project (Completed) for read-only testing once sync is implemented

## Phase 1 - Foundation (Core)

- [x] Core module scaffolding
- [x] Project state mapping (lifecycle -> UI) in Core models
- [x] CoreDataStack skeleton
- [x] Full domain models (Level, Room, Family, Type, Instance, RoomNote, Photo, SyncEvent)
- [x] Core Data model file (.xcdatamodeld)
- [x] Core Data migrations strategy
- [x] Networking layer skeleton (API client + endpoints)
- [x] Core services: ID generation + geometry helpers
- [x] Core services: validation rules
- [x] Core services: photo naming
- [x] Local file cache (photos + tiles)
- [x] Demo data loader (bundle -> Core Data seed)
- [x] App launch wires Core Data + demo seeder

## Phase 2 - Core UI (DesignSystem + Features)

- [x] DesignSystem tokens (colors, typography, spacing)
- [x] Projects list view skeleton
- [x] Floorplan renderer spike (demo GeoJSON + pan/zoom)
- [x] Level picker UI (bottom-right, drop-up)
- [x] Core navigation shell (projects -> floorplan -> wizard)

## Phase 3 - Asset Management (AddAssetWizard)

- [x] Add Asset wizard skeleton (step indicator + placeholders)
- [x] Add Asset wizard flow (family -> type -> instance)
- [x] Room Note flow
- [x] Type branching flow
- [x] Instance photo handling (optional up to 5)
- [x] Refactor AddAssetWizard ViewModel + View into smaller files
- [x] Replace magic numbers with DesignSystem metrics
- [x] Add baseline Core tests (StableID, ParameterValidator, GeometryUtils)
- [x] Add logging for silent failures in core services

## Phase 4A - Room View (overlay)

- [x] Room overlay UI on top of floorplan (top bar + bottom sheet)
- [x] Selected room highlight (strong border + opaque hatch)
- [x] Room list (assets + room notes, ordering)
- [x] Instance detail view (read-only)
- [x] Navigation: Floorplan -> Room overlay -> Instance detail

## Phase 4B - Room Editing

- [ ] Instance editor widget (editable)
- [ ] Edit Type widget (from instance context)
- [ ] Room notes editing
- [ ] Delete asset/room note with confirmation
- [ ] Core Data save/refresh on edit

## Phase 4C - Testing Sprint 1

- [x] Unit tests: Core services (ParameterValidator, StableID, GeometryUtils)
- [ ] Unit tests: Models encoding/decoding
- [ ] Integration tests: DemoDataSeeder
- [ ] ViewModel tests: AddAssetWizardViewModel state transitions

## Phase 5A - Survey Report (Rooms)

- [ ] Survey hub shell (Rooms, Types, Export)
- [ ] Room list filters
- [ ] Room list search and grouping by level
- [ ] Navigation from room list to room view

## Phase 5B - Survey Report (Types + Export)

- [ ] Type list filters
- [ ] Types list view with family grouping
- [ ] Edit Type widget from types list
- [ ] Export stub + share sheet

## Phase 6A - Photo Capture

- [ ] PHPickerViewController integration
- [ ] JPEG compression (1280px, 0.8 quality)
- [ ] LocalFileCache integration
- [ ] Photo deletion handling
- [ ] Camera permission flows

## Phase 6B - Sync Foundation

- [ ] Event log upload pipeline
- [ ] API client implementation (real endpoints)
- [ ] Offline queue management
- [ ] Basic sync status indicator

## Phase 6C - Sync Completion

- [ ] Photo upload queue
- [ ] Exponential backoff retry policy (cap 5 minutes)
- [ ] Sync status UI refinement
- [ ] Conflict detection (MVP)

## Phase 7A - Read-only Mode

- [ ] Read-only mode + warning for completed projects
- [ ] Read-only halftone styling + disabled actions

## Phase 7B - Testing Sprint 2

- [ ] UI tests: critical user flows
- [ ] Integration tests: sync pipeline
- [ ] Performance tests: large project loading
- [ ] Snapshot tests: key UI components

## Phase 7C - Hardening + QA

- [ ] Validation rules tied to schema
- [ ] Error states and alerts
- [ ] Performance profiling (floorplan and lists)
- [ ] Move demo plan loading + Core Data seeding off the main thread
- [ ] Test coverage >= 80%
