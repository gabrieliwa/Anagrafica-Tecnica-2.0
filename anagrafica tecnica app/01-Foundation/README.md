# Phase 1: Foundation

## Overview

The Foundation phase establishes the core data structures, storage layer, network communication, and shared services that all other components depend on. This is the most critical phase as everything else builds on top of it.

## Components

### DataModels/
Core Swift data models representing the domain entities. All models use UUIDv7 for internal IDs and conform to Codable for JSON serialization.

**Key Files:**
- `Project.swift` - Project with lifecycle states
- `Level.swift`, `Room.swift` - Spatial hierarchy
- `Family.swift`, `Type.swift`, `Instance.swift` - Asset hierarchy
- `Parameter.swift` - Schema parameter definitions
- `Photo.swift` - Photo metadata and scoping
- `RoomNote.swift` - Room annotations
- `SchemaVersion.swift` - Immutable schema snapshots
- `Event.swift` - Event sourcing for sync

### LocalStorage/
Offline-first persistence layer using Core Data. Must support complete offline functionality with event logging.

**Key Files:**
- `CoreDataStack.swift` - Database setup
- `ProjectStore.swift`, `AssetStore.swift` - CRUD operations
- `EventLog.swift` - Change tracking for sync
- `PhotoQueue.swift` - Upload queue management
- `TileCache.swift` - Vector tile storage

### NetworkLayer/
REST API client with automatic retry, network monitoring, and background upload support.

**Key Files:**
- `APIClient.swift` - Base HTTP client
- `ProjectAPI.swift`, `SyncAPI.swift`, `PhotoUploadAPI.swift` - Endpoint clients
- `NetworkMonitor.swift` - Reachability detection
- `AuthenticationManager.swift` - Future auth (placeholder in MVP)

### CoreServices/
Shared business logic services used across the app.

**Key Files:**
- `ValidationService.swift` - Field validation
- `FuzzyMatchingService.swift` - Type duplicate detection
- `CoordinateService.swift` - Plan space utilities
- `IDGenerator.swift` - UUIDv7 generation
- `PhotoNamingService.swift` - Filename generation
- `StateManager.swift` - Project state transitions

## Dependencies

- **External:** SwiftUI, Core Data, Foundation, Network framework
- **Internal:** None (this is the foundation)

## Success Criteria

- [ ] All data models defined with proper relationships
- [ ] Core Data stack operational with migrations
- [ ] API client can communicate with backend
- [ ] Event log captures all changes
- [ ] Photo queue manages upload state
- [ ] Fuzzy matching detects duplicate Types
- [ ] UUIDv7 generation working correctly
- [ ] Photo naming follows specification
- [ ] 80%+ unit test coverage

## Development Timeline

**Estimated Duration:** 4 weeks (Sprints 1-2)

**Week 1:** DataModels + Core Data schema
**Week 2:** LocalStorage implementation
**Week 3:** NetworkLayer + API clients
**Week 4:** CoreServices + Testing

## Testing Requirements

- Unit tests for all models
- Core Data migration tests
- API client integration tests
- Validation rule tests
- Fuzzy matching accuracy tests
- Event log integrity tests

## Notes

- Use UUIDv7 for ALL internal IDs (time-sortable)
- Photo naming: `{project_short}_{operator_id}_{timestamp}_{sequence}.jpg`
- Event sourcing enables complete audit trail
- All network calls must support offline-first
- Schema versions are immutable once locked to project
