# Anagrafica Tecnica Mobile App

> iOS application for field-based technical asset surveys with offline-first architecture

## Project Status

**Status:** Planning & Setup
**Target Platform:** iOS 15+
**Language:** Swift
**UI Framework:** SwiftUI
**Development Timeline:** 28 weeks (7 months)

## Overview

Anagrafica Tecnica is a mobile application that enables field operators to conduct technical asset inventories on-site using building floorplans as the primary interface. The app works completely offline and synchronizes data automatically when connectivity is available.

### Key Features

- 📱 **Offline-first operation** - Full functionality without network
- 🗺️ **Interactive floorplan navigation** - Map-style pan/zoom interface
- 📸 **Integrated photo capture** - Type and Instance photos with compression
- 🔄 **Automatic synchronization** - Event-sourced sync with intelligent retry
- ✅ **Data quality enforcement** - Required fields and validation at source
- 📊 **Survey reporting** - Searchable/filterable rooms and Types lists
- 🔒 **Read-only mode** - Completed projects are immutable

## Development Structure

This project is organized into **7 major phases**, each containing specific task folders:

```
anagrafica tecnica app/
├── 01-Foundation/              # Core data structures and services (4 weeks)
│   ├── DataModels/            # Swift models (Family → Type → Instance)
│   ├── LocalStorage/          # Core Data persistence
│   ├── NetworkLayer/          # REST API client
│   └── CoreServices/          # Shared business logic
│
├── 02-CoreUI/                 # Fundamental UI components (4 weeks)
│   ├── ProjectsList/          # Projects home screen
│   ├── FloorplanViewer/       # Interactive map
│   ├── CommonComponents/      # Reusable UI elements
│   └── Navigation/            # App-wide navigation
│
├── 03-AssetManagement/        # Asset creation workflow (6 weeks)
│   ├── AddAssetWizard/        # Multi-step wizard
│   ├── FamilySelection/       # Family picker
│   ├── TypeSelection/         # Type picker/creator
│   ├── InstanceForm/          # Instance parameters
│   └── PhotoCapture/          # Camera integration
│
├── 04-RoomManagement/         # Room views and editing (4 weeks)
│   ├── RoomView/              # Room detail screen
│   ├── InstanceEditor/        # Edit instance widget
│   ├── TypeEditor/            # Edit Type widget
│   └── RoomNotes/             # Empty/blocked room notes
│
├── 05-SurveyReporting/        # Reporting and export (4 weeks)
│   ├── SurveyReportHub/       # Report container
│   ├── RoomsList/             # Rooms list with filters
│   ├── TypesList/             # Types list with filters
│   └── ProjectExport/         # Local export generation
│
├── 06-Synchronization/        # Backend sync (4 weeks)
│   ├── SyncEngine/            # Sync orchestrator
│   ├── EventSourcing/         # Event log pattern
│   ├── PhotoUploadQueue/      # Background photo uploads
│   └── SurveyCompletion/      # Survey completion flow
│
└── 07-Polish/                 # Production readiness (2 weeks)
    ├── ReadOnlyMode/          # Completed project protection
    ├── ErrorHandling/         # Comprehensive error handling
    ├── Testing/               # Unit, UI, integration tests
    └── Performance/           # Optimization and profiling
```

## Documentation

Each phase and component has detailed documentation:

- **[DEVELOPMENT-STRATEGY.md](./DEVELOPMENT-STRATEGY.md)** - Complete development breakdown
- **[DEVELOPMENT-QUICK-REFERENCE.md](./DEVELOPMENT-QUICK-REFERENCE.md)** - Quick reference and checklists
- **Phase READMEs** - Detailed requirements for each phase (in phase folders)
- **[../product-specs.md](../product-specs.md)** - Product requirements specification
- **[mobile-ui-specs.md](./mobile-ui-specs.md)** - Mobile UI specifications

## Getting Started

### Prerequisites

- macOS 13.0 or later
- Xcode 15.0 or later
- iOS 15.0+ target device or simulator
- Swift 5.9+

### Project Setup

1. **Review Documentation**
   ```bash
   # Read the development strategy
   open DEVELOPMENT-STRATEGY.md

   # Review product specs
   open ../product-specs.md
   ```

2. **Set Up Xcode Project**
   ```bash
   # Open the Xcode project
   open "anagrafica tecnica app.xcodeproj"
   ```

3. **Begin Phase 1: Foundation**
   - Start with DataModels
   - Set up Core Data schema
   - Implement local storage layer
   - Create API client

### Development Workflow

1. **Select a phase** based on dependencies and current progress
2. **Read the phase README** for detailed requirements
3. **Implement components** within the phase folders
4. **Write tests** for all new code (target: ≥80% coverage)
5. **Update README** in the component folder
6. **Pass the testing gate** before moving to next phase

## Architecture

### Data Hierarchy

```
Family (e.g., "Lights")
    │
    ├── Type (e.g., "Philips 30W LED Panel")
    │       │
    │       └── Instance (specific light in Room 1001)
    │
    └── Type (e.g., "Osram 50W LED Downlight")
            │
            └── Instance (specific light in Room 1002)
```

### Spatial Hierarchy

```
Project → Level (Floor) → Room → Asset Instance
```

### Technology Stack

- **UI:** SwiftUI
- **Storage:** Core Data
- **Networking:** URLSession with background support
- **Photos:** AVFoundation (camera), Photos framework
- **Background Tasks:** BackgroundTasks framework
- **IDs:** UUIDv7 (time-sortable)
- **Photos:** JPEG (1280px, 0.8 quality)

## Key Concepts

### Offline-First Architecture

All functionality works without network connectivity:
- Complete project data stored locally
- Changes logged as events
- Automatic sync when online
- Background photo uploads

### Event Sourcing

All changes tracked as events for:
- Complete audit trail
- Sync with server
- Future undo capability
- Data recovery

### Schema Versioning

- **Schema Template:** Editable master
- **Schema Version:** Immutable snapshot
- Each project locked to one schema version

### Validation at Source

- Required fields block save
- Inline validation
- No incomplete assets
- Data quality enforced on device

## Development Timeline

| Phase | Duration | Deliverables |
|-------|----------|--------------|
| **1. Foundation** | 4 weeks | Data models, storage, API client, services |
| **2. Core UI** | 4 weeks | Projects list, floorplan viewer, common components |
| **3. Asset Management** | 6 weeks | Add Asset wizard, photo capture |
| **4. Room Management** | 4 weeks | Room view, editors, Room Notes |
| **5. Survey Reporting** | 4 weeks | Report hub, lists, filters, export |
| **6. Synchronization** | 4 weeks | Sync engine, event sourcing, completion |
| **7. Polish** | 2 weeks | Read-only mode, error handling, testing |
| **TOTAL** | **28 weeks** | **Production-ready MVP** |

## Testing Requirements

- **Unit Tests:** ≥80% code coverage
- **UI Tests:** Critical user flows
- **Integration Tests:** Sync, API, storage
- **Performance Tests:** Large datasets (1000+ assets)
- **Snapshot Tests:** Visual regression prevention

## Contributing

### Code Standards

- Follow Swift API Design Guidelines
- Use SwiftLint for consistency
- Write self-documenting code
- Include inline documentation for complex logic
- Keep functions small and focused

### Pull Request Process

1. Create feature branch from `main`
2. Implement functionality with tests
3. Update relevant README files
4. Ensure all tests pass
5. Request code review
6. Merge after approval

### Commit Message Format

```
[Phase] Component: Description

Example:
[Phase1] DataModels: Add Instance model with validation
[Phase3] PhotoCapture: Implement JPEG compression
[Phase7] Testing: Add UI tests for Add Asset flow
```

## Milestones

- [ ] **M1:** Data Layer Complete (Week 4)
- [ ] **M2:** Navigation Working (Week 8)
- [ ] **M3:** Can Add Assets (Week 14)
- [ ] **M4:** Can Edit Assets (Week 18)
- [ ] **M5:** Survey Report Working (Week 22)
- [ ] **M6:** Sync Working (Week 26)
- [ ] **M7:** Production Ready (Week 28)

## Performance Targets

- App launch: <2 seconds
- Floorplan render: <1 second
- List scroll: 60 fps
- Photo capture: <1 second
- Photo compression: <1 second
- Search results: <100ms
- Asset save: <200ms

## Scale Constraints (MVP)

- Assets per project: 10,000 (soft limit)
- Photos per device: ~1,000
- Photos per year (cloud): 1,000,000
- Rooms per level: No fixed limit
- Levels per project: No fixed limit

## Resources

### Internal Documentation
- [Product Specs](../product-specs.md)
- [Mobile UI Specs](./mobile-ui-specs.md)
- [Development Strategy](./DEVELOPMENT-STRATEGY.md)
- [Quick Reference](./DEVELOPMENT-QUICK-REFERENCE.md)
- [Claude Code Guide](../CLAUDE.md)

### External Resources
- [Swift Documentation](https://docs.swift.org)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Core Data Guide](https://developer.apple.com/documentation/coredata)
- [Background Tasks](https://developer.apple.com/documentation/backgroundtasks)

## Support

For questions or issues:
1. Check the relevant phase README
2. Review the development strategy
3. Consult the product specs
4. Ask the team lead

## License

Proprietary - All rights reserved

---

**Project Start Date:** 2026-01-05
**Target Completion:** 2026-08-01
**Current Phase:** Phase 1 - Foundation
**Last Updated:** 2026-01-05
