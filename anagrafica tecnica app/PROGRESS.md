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

## Phase 4 - Room Management (Room)

- [ ] Room view list (assets + room notes, ordering)
- [ ] Instance editor widget
- [ ] Edit Type widget
- [ ] Room notes editing

## Phase 5 - Survey Hub + Export (SurveyReport + Export)

- [ ] Survey hub shell (Rooms, Types, Export)
- [ ] Room list filters
- [ ] Type list filters
- [ ] Export stub + share sheet

## Phase 6 - Synchronization (Core/Sync)

- [ ] Event log upload pipeline
- [ ] Photo upload queue
- [ ] Exponential backoff retry policy (cap 5 minutes)
- [ ] Sync status indicator
- [ ] Read-only mode + warning for completed projects
- [ ] Read-only halftone styling + disabled actions

## Phase 7 - Hardening + QA

- [ ] Validation rules tied to schema
- [ ] Error states and alerts
- [ ] Performance profiling (floorplan and lists)
- [ ] Move demo plan loading + Core Data seeding off the main thread
- [ ] Test coverage >= 80%
