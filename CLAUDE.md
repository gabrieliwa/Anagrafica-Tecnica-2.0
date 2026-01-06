# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Anagrafica Tecnica** (Technical Asset Registry) is an iOS mobile application for conducting field surveys of technical assets in buildings. The app enables operators to document equipment (lights, radiators, access points, etc.) using building floorplans as the primary interface.

This is the **MVP (Minimum Viable Product)** implementation designed as a proof-of-concept. The app is offline-first with automatic synchronization when network access is available.

## Project Structure

This is a multi-component system:

```
├── anagrafica tecnica app/     # iOS mobile application (Swift/SwiftUI)
├── admin-dashboard/            # Web-based admin control panel
├── backend/                    # Server-side processing and API
├── database/                   # PostgreSQL schema and migrations
├── storage/                    # File storage (DXF, tiles, photos, exports)
├── shared/                     # Common types and utilities
├── docs/                       # Additional documentation
└── scripts/                    # Development and deployment scripts
```

Each component has its own README with detailed information.

## Build Commands

### Mobile App (iOS)

Open the project in Xcode:
```bash
open "anagrafica tecnica app/anagrafica tecnica app.xcodeproj"
```

Build from command line (requires Xcode installation):
```bash
cd "anagrafica tecnica app"
xcodebuild -scheme "anagrafica tecnica app" -configuration Debug build
```

Run tests:
```bash
xcodebuild test -scheme "anagrafica tecnica app" -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Backend

See `backend/README.md` for backend setup and build instructions.

### Admin Dashboard

See `admin-dashboard/README.md` for frontend setup and build instructions.

## Architecture & Data Model

### Core Hierarchy: Family → Type → Instance

The app follows BIM (Building Information Modeling) conventions:

1. **Family**: Asset category (e.g., Lights, Radiators, Access Points)
   - Defines parameter structure and photo requirements
   - Created by admins only

2. **Type**: Specific product within a family (e.g., "Philips 30W wall light")
   - Fixed parameters defined by parent Family
   - Operators can create new Types but cannot modify parameter definitions

3. **Instance**: Individual physical asset at a specific location
   - Belongs to a Type
   - Contains instance-specific data (serial number, condition, notes, photos)

### System Families

Built-in element categories with predefined parameters:

**Levels**: Building floors with name, number, building reference, elevation
**Rooms**: Spaces within levels with name, number, lifecycle state, calculated area

### Spatial Hierarchy

```
Project → Level (Floor) → Room → Asset Instance
```

- No separate Building entity in MVP
- Multi-building projects: levels spread on XY plane with names like "Building A - Floor 1"
- Optional Building layer in DXF groups levels for UI navigation

### Coordinate System ("Plan Space")

- Origin: Start point of North vector (per level)
- Axes: Aligned with CAD X/Y axes
- Units: Meters
- North angle stored for orientation and export

### Asset Positioning

- Assets treated as "hosted families" placed within rooms
- Each asset positioned at room centroid
- All assets in a room share the same plan_point
- Visual representation: Room shows icon with asset count at centroid
- Tap icon to reveal individual assets arranged radially

## Key Implementation Concepts

### Offline-First Architecture

The app must function completely offline:
- Full project data stored locally (plan tiles, room polygons, schema, type library)
- Changes logged as events locally
- Automatic sync when online (event log + background photo upload)
- Event sourcing pattern for audit trail

### Schema Versioning

- **Schema Template**: Editable master parameter definitions
- **Schema Version**: Immutable snapshot (v1.0, v1.1) pinned to projects
- Each project references exactly one schema_version_id
- Schema cannot change mid-survey to ensure consistency

### Validation Rules

**Required fields block save at device level**:
- Operators cannot save an instance until all required parameters are filled
- Ensures data completeness at source
- No partial/incomplete instances

**Photo Requirements** (configurable per Family):
- Minimum: 1 photo per instance
- Maximum: 5 photos per instance
- Photos can be reused across multiple instances

### ID Strategy

- **Internal IDs**: UUIDv7 (time-sortable, globally unique)
- **Export IDs**: Sequential per project, assigned at first final export
- **Photo Naming**: Globally unique at capture time, format: `{project_uuid_short}_{operator_id}_{timestamp}_{sequence}`
- Photo names remain unchanged from capture through export

### Room Lifecycle States

1. **Empty**: No assets present
2. **Complete**: At least one asset, meets validation + photo rules
3. **Approved**: Admin-approved, ready for export

State flow: Empty → Complete → Approved

### Type Creation Priority

When inserting assets, operators should:
1. Use existing Type (preferred - preserves consistency)
2. Duplicate existing Type and modify parameters
3. Create new Type from scratch (last resort)

**On-device fuzzy matching** warns before creating potential duplicates.

### Annotation Assets

Special asset family for internal notes:
- Mark rooms as "Without any assets" or "Unreachable"
- Requires reason (dropdown) + optional note/photo
- Excluded from client exports
- Used for internal communication only

## DXF Input Requirements

### Required Layers

- **Architecture**: Walls, doors, windows (visualization only)
- **Rooms**: Filled regions + optional name text
- **Level**: Closed polyline boundary + name text
- **North**: One segment per level (start = origin, end = north direction)

### Optional Layer

- **Building**: Closed polylines grouping levels + name text

### Validation Requirements

DXF must pass validation before project proceeds:
- Required layers exist
- Level boundaries are closed polylines
- North vector exists per level and starts inside boundary
- All room regions are inside a level boundary
- Name texts are geometrically inside their parent elements

## Technology Stack Recommendations

Based on MVP specification (not yet implemented):

### Mobile App (iOS)
- Swift/SwiftUI for UI
- Core Data or Realm for local storage
- MapKit or custom tile renderer for floorplan display
- Background task processing for photo uploads

### Local Data Storage
- Project package (plan tiles, room polygons, schema, type library)
- Asset instances with parameters and photos
- Event log for synchronization

### Server Communication
- REST or GraphQL API
- Event sourcing sync model
- Background photo upload queue

## MVP Simplifications

The following are explicitly excluded from MVP:

- Authentication/logins (open access for demonstration)
- Multi-user collaboration or worksets
- Suggestions/approval workflows for asset placement
- Plan editing (room splitting, merging, deletion)
- AI-assisted insertion or photo classification
- Undo capabilities
- Sync conflict resolution (single-user operation)
- Schedule generation (Revit-style views)

## Development Guidelines

### Documentation Maintenance

**IMPORTANT**: When making changes to any component, always update the corresponding README.md file in that component's folder to reflect the changes. Each component folder has its own README.md that serves as the primary documentation for that component.

Component folders with README files:
- `anagrafica tecnica app/README.md` - iOS mobile application
- `admin-dashboard/README.md` - Web-based admin control panel
- `backend/README.md` - Server-side processing and API
- Other component folders as they are created

After editing code in any component, verify the README is updated with:
- New features or functionality
- Changed build commands or setup instructions
- Updated dependencies or requirements
- Modified architecture or design decisions

### Photo Management

- Format: JPEG, 1280px longest edge, quality 0.8
- Device storage target: ~1,000 photos
- Cloud storage target: Up to 1,000,000 photos/year
- Background upload queue required for offline operation

### Event Sourcing Pattern

- All changes stored as events for audit trail
- Device sends events to server
- Server orders and stores events
- Event compaction and snapshotting manage storage growth
- Enables future undo functionality

### Map Interface (UI/UX)

Primary navigation via floorplan (Google Maps-style):
- Two-finger pan and zoom
- Level selector to switch floors
- Building selector (if applicable)
- Tap inside room to enter editing mode
- Tap outside to enter navigation mode
- Empty rooms show (+) icon
- Rooms with assets show count icon

### Job Completion Requirements

When operator marks job complete:
- Every room must have at least one Instance
- Empty rooms require Annotation asset with reason
- App displays report of incomplete rooms

## Scale Constraints (MVP)

- Assets per Project: 10,000 (soft limit)
- Photos per Device: ~1,000
- Photos per Year (Cloud): Up to 1,000,000

## Related Documentation

See `Technical_Asset_Registry_MVP_Specification.md` for complete system architecture including server backend, admin dashboard, DXF processing, and export generation.
