# Anagrafica Tecnica (Technical Asset Registry)

**Version 1.0 — December 2025**

Field survey tool for technical asset registry (*anagrafica tecnica*) in buildings. The MVP enables a single operator to conduct on-site surveys using an iPhone app where the floorplan serves as the primary interface.

This is a **proof-of-concept MVP** designed to demonstrate core functionality. The tool is offline-first to accommodate unreliable site connectivity, with automatic synchronization when network access is available.

---

## Table of Contents

- [Executive Summary](#executive-summary)
- [System Architecture](#system-architecture)
- [Project Structure](#project-structure)
- [Data Model](#data-model)
- [Getting Started](#getting-started)
- [Component Details](#component-details)
- [Input Requirements](#input-requirements)
- [Development Workflow](#development-workflow)
- [Key Technical Concepts](#key-technical-concepts)
- [MVP Simplifications](#mvp-simplifications)
- [Scale Constraints](#scale-constraints)

---

## Executive Summary

### Key MVP Simplifications

- Single-user operation (no multi-user collaboration or worksets)
- No authentication required (open access for demonstration)
- Simplified data model without suggestions or approval workflows
- Fixed room geometry (no plan editing capabilities)
- No AI-assisted insertion mode
- Direct sync without conflict resolution
- No undo capabilities
- No schedule generation

### Core Features

**Mobile App (iOS)**
- Offline-first operation with full local data
- Interactive floorplan navigation (Google Maps-style)
- Asset creation following Family → Type → Instance hierarchy
- Photo capture (1-5 per asset, configurable)
- Automatic sync when online
- On-device fuzzy matching to prevent duplicate Types

**Admin Dashboard (Web)**
- Project creation and DWG upload/validation
- Asset/parameter catalogue management
- Survey progress monitoring
- Data quality tracking
- Export generation (CSV/Excel + photos)

**Server Backend**
- Event sourcing sync engine
- DWG processing (room extraction, vector tiles)
- Schema versioning
- Type normalization
- Export generation with sequential IDs

---

## System Architecture

### 4-Component Architecture

```
┌────────────────────────────────────────────────────┐
│                         CLOUD                          │
│                                                        │
│  ┌─────────────────────────────────────────────────┐  │
│  │              3. SERVER BACKEND                  │  │
│  │                                                 │  │
│  │  ┌─────────────────────────────────────────┐   │  │
│  │  │              API Layer                  │   │  │
│  │  └─────────────────────────────────────────┘   │  │
│  │                                                 │  │
│  │  ┌───────────┐ ┌─────────────┐ ┌────────────┐  │  │
│  │  │   Sync    │ │    DWG      │ │   Type     │  │  │
│  │  │  Engine   │ │ Processing  │ │ Normalize  │  │  │
│  │  └───────────┘ └─────────────┘ └────────────┘  │  │
│  │                                                 │  │
│  │  ┌───────────┐ ┌─────────────┐                 │  │
│  │  │  Schema   │ │   Export    │                 │  │
│  │  │Management │ │ Generation  │                 │  │
│  │  └───────────┘ └─────────────┘                 │  │
│  └─────────────────────┬───────────────────────────┘  │
│                        │                              │
│  ┌─────────────────────┴───────────────────────────┐  │
│  │               4. STORAGE                        │  │
│  │                                                 │  │
│  │  ┌──────────────────┐  ┌─────────────────────┐ │  │
│  │  │    Database      │  │   File Storage      │ │  │
│  │  │  (PostgreSQL)    │  │   (S3 / Blob)       │ │  │
│  │  └──────────────────┘  └─────────────────────┘ │  │
│  └─────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────┘
                         │
                      INTERNET
                         │
        ┌────────────────┴────────────────┐
        │                                 │
┌───────┴───────┐             ┌───────────┴───────────┐
│ 1. MOBILE APP │             │  2. ADMIN DASHBOARD   │
│     (iOS)     │             │    (Web Browser)      │
└───────────────┘             └───────────────────────┘
  Field Operator                   Administrator
```

### Project Hierarchy

**Spatial hierarchy:** Site/Project → Level → Room → Asset Instance

There is no separate Building entity. For multi-building projects, each floor of each building is spread out on the DWG XY plane, and levels are named accordingly (e.g., "Building A - Floor 1"). An optional "Building" layer in the DWG can group levels for UI navigation purposes.

---

## Project Structure

This is a multi-component monorepo:

```
├── anagrafica tecnica app/     # iOS mobile application (Swift/SwiftUI)
├── admin-dashboard/            # Web-based admin control panel
├── backend/                    # Server-side processing and API
│   ├── src/
│   │   ├── api/               # REST/GraphQL endpoints
│   │   ├── sync/              # Event sourcing sync engine
│   │   ├── dwg-processing/    # DWG validation and tile generation
│   │   ├── schema/            # Parameter catalogue management
│   │   ├── export/            # CSV/Excel and photo export
│   │   └── storage/           # Database and file storage interfaces
│   └── tests/
├── database/                   # PostgreSQL schema and migrations
│   ├── migrations/
│   └── seeds/
├── storage/                    # File storage directories
│   ├── dwg-files/
│   ├── plan-tiles/
│   ├── photos/
│   └── exports/
├── shared/                     # Common types and utilities
│   ├── types/                 # TypeScript type definitions
│   ├── schemas/               # Validation schemas
│   ├── constants/             # Shared constants
│   └── utils/                 # Utility functions
├── docs/                       # Additional documentation
└── scripts/                    # Development and deployment scripts
```

Each component has its own README with detailed information.

---

## Data Model

### Glossary of Terms

| Term | Definition |
|------|------------|
| **Family** | A category of assets sharing the same parameter structure (e.g., Lights, Radiators, Access Points). |
| **System Family** | Built-in element categories (Levels, Rooms) with predefined system parameters. |
| **Type** | A specific product within a Family, defined by fixed parameter values (e.g., "Philips 30W wall light"). |
| **Instance** | A single physical asset placed in a specific location, belonging to a Type. |
| **Schema** | The set of parameter definitions, validation rules, and data types defining what must be surveyed. |
| **Schema Version** | An immutable snapshot of a schema, pinned to a project to prevent mid-survey rule changes. |
| **Plan Version** | A unique identifier for each imported floorplan, enabling tracking of geometry changes. |
| **Annotation** | A special asset type for notes, "no assets" markers, or "unreachable" flags—excluded from client exports. |

### Core Hierarchy: Family → Type → Instance

The system follows BIM (Building Information Modeling) conventions:

| Level | Example | Who Can Modify |
|-------|---------|----------------|
| **Family** | Lights, Radiators, Access Points | Admin only—defines parameter structure and photo rules |
| **Type** | "Philips 30W wall light" | Operator can create; parameters fixed by Family |
| **Instance** | Specific lamp in Room 101 | Operator fills instance parameters (serial, condition, notes) |

#### Type Creation Priority

When inserting assets, operators should follow this priority:

1. **Use an existing Type** (keeps all previously inserted info)
2. **Duplicate an existing Type**, rename it, and modify some parameters
3. **Create a new Type from scratch** (last resort)

**Type Creation Rules:**
- Type parameters are defined by the parent Family and cannot be changed by operators
- Only admins can create, modify, or delete parameter definitions in Families
- **On-device fuzzy matching:** Warns operator before creating potential duplicates
- **Server-side normalization:** Final authority for duplicate detection and merge
- **Naming consistency:** New Types should follow the naming scheme of existing Types

### System Families

Levels and Rooms are treated as System Families with their own parameters:

#### Level Parameters

| Parameter | Description |
|-----------|-------------|
| **Name** | Display name of the level (e.g., "Floor 1", "Building A - Floor 2") |
| **Number** | Sequential identifier within project |
| **Building** | Parent building (if Building layer defined) |
| **Elevation** | Vertical position (optional, for future use) |

#### Room Parameters

| Parameter | Description |
|-----------|-------------|
| **Name** | Display name of the room |
| **Number** | Sequential identifier within level |
| **Level** | Parent level reference |
| **Lifecycle State** | Empty, Complete, Approved |
| **Area** | Calculated from room polygon (m²) |

### Asset Location & Positioning

Assets are treated as "hosted families" that can only be placed within a room.

**Positioning Rules:**
- Each asset's position corresponds to the centroid of its host room
- All assets in a room share the same plan_point (room centroid)
- *Future enhancement:* Specific positioning within rooms may be added in a later version

**Visual Representation:**
- Room displays a single icon at the centroid showing asset count
- Tapping the icon reveals individual assets arranged radially around the centroid
- Empty rooms display a (+) icon instead of a count

**Stored Data per Instance:**
- **room_id:** The room containing the asset
- **plan_point (x, y):** Room centroid coordinates relative to level origin
- **plan_version_id:** Reference to floorplan version

### Room Lifecycle States

| State | Description & Transitions |
|-------|--------------------------|
| **Empty** | No assets. Adding any asset (including Annotation) moves to Complete. |
| **Complete** | At least one asset present. Meets schema validation + photo rules. |
| **Approved** | Final state after admin approval. Ready for export. |

**State Flow:** Empty → Complete → Approved

### Annotation Assets

A special asset family for internal notes and status markers:
- Used to mark rooms as "Without any assets" or "Unreachable"
- Requires a reason (dropdown selection) + optional note/photo
- Visible to operator and admin for internal communication
- **Excluded from client exports**

---

## Getting Started

### Mobile App (iOS)

Requirements:
- macOS with Xcode 26.2+
- iOS SDK

Open the project:
```bash
open "anagrafica tecnica app/anagrafica tecnica app.xcodeproj"
```

Build from command line:
```bash
cd "anagrafica tecnica app"
xcodebuild -scheme "anagrafica tecnica app" -configuration Debug build
```

Run tests:
```bash
xcodebuild test -scheme "anagrafica tecnica app" -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Backend

Recommended stack: Node.js (Express/Fastify) or Python (FastAPI)

See `backend/README.md` for detailed setup instructions.

### Admin Dashboard

Recommended stack: React or Vue.js with TypeScript and Tailwind CSS

See `admin-dashboard/README.md` for detailed setup instructions.

### Database

Technology: PostgreSQL with UUIDv7 for primary keys

See `database/README.md` for schema and migration instructions.

---

## Component Details

### 1. Mobile App (iOS)

**Key Responsibilities:**
- Display floorplans as interactive maps (vector tiles + room polygons)
- Allow asset creation following Family → Type → Instance hierarchy
- Capture and store photos locally (1–5 per asset, configurable per Family)
- Full offline operation with local database
- Sync events to server when online (background photo upload queue)
- On-device fuzzy matching to warn before creating duplicate Types
- Block save until required fields are filled

**Key Data Managed Locally:**
- Project package (plan tiles, room polygons, schema, type library)
- Asset instances with parameters and photos
- Event log for sync

**Suggested Technologies:** Swift/SwiftUI, Core Data or Realm, MapKit or custom tile renderer

#### Map Interface (UI/UX)

The floorplan serves as the primary navigation interface, similar to Google Maps.

**Navigation:**
- Two-finger gestures for pan and zoom
- Level selector to switch between floors
- Building selector (if applicable) to filter levels

**Room Interaction:**

| Action | Result |
|--------|--------|
| **Tap inside a room** | Enter room editing mode; room is selected |
| **Tap asset icon** | Reveal individual assets radially around centroid |
| **Tap neighboring room** | Switch to that room for editing |
| **Tap outside floorplan** | Deselect room; enter navigation mode |

#### Main Survey Flow

1. Choose Family
2. Choose existing Type, duplicate and modify existing Type, or create new Type (with fuzzy match warning)
3. Create Instance
4. Take photos (minimum 1, maximum 5 per family rules)
5. Fill instance parameters (notes, condition, serial, etc.)

**Constraints:**
- Operators can create new Types but cannot introduce new parameter keys
- All parameters must exist in the pinned schema version

#### Offline Behavior

| Feature | Requires Connectivity |
|---------|----------------------|
| Survey rooms | No |
| Create/edit/delete assets | No |
| Photo capture | No |
| Photo upload | Yes (background queue) |
| Sync events to server | Yes |

### 2. Admin Dashboard (Web Frontend)

**Key Responsibilities:**
- Project creation and configuration
- Upload and validate DWG files (trigger backend processing)
- Upload asset/parameter catalogues (create schema versions)
- Monitor survey progress by level and room
- Track data quality: missing recommended fields, anomalies
- Approve project for export
- Generate and download exports (CSV/Excel + photo packages)

**Suggested Technologies:** React or Vue.js, TypeScript, Tailwind CSS

#### Workflows

**Before Survey:**
1. Create Project
2. Import DWG → run validation → generate plan_version_id
3. Import catalogue → create schema_version_id
4. Optional: pre-build Types, configure normalization
5. Create project package for mobile download

**During Survey:**
1. Monitor progress by level/room
2. Track data quality: missing recommended fields, anomalies

**After Survey:**
1. Export client deliverables: clean CSV/Excel per required mapping
2. Generate photo package (photos retain their capture-time names)
3. Produce summary report (time, coverage, assets registered, etc.)

### 3. Server Backend

**Key Sub-Modules:**

| Sub-Module | Purpose |
|------------|---------|
| **API Layer** | REST or GraphQL endpoints for Mobile App and Admin Dashboard |
| **Sync Engine** | Event sourcing: receive events from device, order them, store to database |
| **DWG Processing** | Validate DWG files, extract room polygons, generate vector tiles, create plan_version_id |
| **Schema Management** | Store parameter catalogues, create immutable schema versions, bind to projects |
| **Type Normalization** | Server-side duplicate detection for Types |
| **Export Generation** | Produce CSV/Excel files, photo packages (photos retain capture-time names), summary reports |

**Key Technical Patterns:**
- **Event Sourcing:** All changes stored as events for audit trail
- **UUIDv7:** Time-sortable unique IDs for all entities
- **Sequential Export IDs:** Assigned at first final export, remain stable across re-exports
- **Plan Space Coordinates:** Origin at North vector start point, X/Y aligned with CAD axes, coordinates in meters

**Suggested Technologies:** Node.js (Express/Fastify) or Python (FastAPI), PostgreSQL client, S3 SDK

### 4. Storage

| Storage Type | Technology | Contents |
|--------------|------------|----------|
| Relational Database | PostgreSQL | Projects, levels, rooms, families, types, instances, events, schemas |
| File Storage | AWS S3 / GCS / Azure Blob | DWG files, plan tiles, photos, generated exports |
| CDN (optional) | CloudFront / Cloud CDN | Fast delivery of plan tiles to mobile app |

**Key Data Characteristics:**
- Photos: JPEG, 1280px longest edge, ~1,000 per device, up to 1,000,000/year cloud
- Photo naming: globally unique at capture time (`{project_uuid_short}_{operator_id}_{timestamp}_{sequence}`)
- **Same name everywhere:** The capture-time name is used internally and in client exports (no renaming)
- Plan tiles: Vector tiles clipped per level

---

## Input Requirements

### DWG Contract

**Units:** Always meters.

#### Mandatory Layers

| Layer | Contents & Rules |
|-------|------------------|
| **Architecture** | Walls, doors, windows, etc. Background visualization only—not semantically interpreted. |
| **Rooms** | Filled regions representing room polygons. Must fall within a level boundary. Optional: text element inside with room name. |
| **Level** | Closed polyline boundary per floor + text element inside with level name. Need not be rectangular. |
| **North** | One segment per level: start point = level origin (inside boundary), end point indicates north direction. |

#### Optional Layer

| Layer | Contents & Purpose |
|-------|-------------------|
| **Building** | Closed polylines enclosing groups of levels + text element inside with building name. Assigns levels to buildings for UI navigation in multi-building projects. |

#### Naming Conventions

- **Single-building projects:** "Floor 1", "Floor 2", etc.
- **Multi-building projects:** "Building A - Floor 1", "Building B - Floor 2", etc.

#### Coordinate System

- Origin = start point of North vector
- Axes = CAD X/Y
- North angle stored for orientation and export
- Level origins should ideally be vertically aligned across floors (helpful but not required)
- Coordinates are in meters

#### Supported Elements

Only simple geometries are processed. Blocks, XREFs and proxy entities are ignored. The DWG must provide a clean, readable architectural background using supported entities only.

### DWG Validation

On upload, the system generates an Import Validation Report checking:

1. Required layers exist
2. Level boundaries are closed polylines
3. North vector exists per level and starts inside boundary
4. All rooms' filled regions are inside a level boundary
5. All rooms' name texts (if any) are geometrically inside a filled region
6. Level name text is present inside each level boundary
7. Building layer polylines (if present) properly enclose levels
8. All buildings' name texts are geometrically inside a building's closed polyline

**Failure Handling:** If validation fails, the DWG must be corrected and re-uploaded. The project cannot proceed until the floorplan passes validation.

### Asset/Parameter Catalogue → Versioned Schema

Input format: CSV, Excel, or JSON describing:

- Families (Lights, Radiators, Access Points, Outlets, etc.)
- Parameter definitions per family with rules: required/optional, data type, unit, enum values, validation constraints
- **Photo rules per family:** minimum 1, maximum 5 photos per instance

**Validation Rule:** Required fields block save at the device level. Operators cannot save an instance until all required parameters are filled. This ensures data completeness at the source.

#### Schema Storage

| Concept | Description |
|---------|-------------|
| **Schema Template** | Editable master definition of parameters and rules. |
| **Schema Version** | Immutable snapshot (v1.0, v1.1, etc.) pinned to projects. |
| **Project Binding** | Each project references exactly one schema_version_id that cannot change mid-survey. |

---

## Development Workflow

1. **Input Preparation**: Admin uploads DWG and parameter catalogue
2. **Project Setup**: System validates DWG, generates tiles, creates schema version
3. **Field Survey**: Operator downloads project to mobile app, works offline
4. **Sync**: Events and photos upload to server when online
5. **Export**: Admin approves project and generates client deliverables

### Sync Model

- Device stores a complete local copy of the project
- Changes are logged as events locally
- When online: events sync to server, photos upload asynchronously
- Server stores and orders events

> **Note:** In the MVP, since there is only a single user, sync conflict resolution is not required.

### Project Lifecycle

| State | Description |
|-------|-------------|
| **Draft** | Project being configured; not available to operator. |
| **Ready** | Project fully configured but not yet started in the field. Available for operator download. |
| **Active** | Survey in progress; operator is working in the field. |
| **Completed** | Survey finished; read-only for operator. Awaiting admin review. |
| **Approved** | Admin reviewed and approved. Ready for client submission. |
| **Archived** | Long-term storage; data retained but project inactive. |

**State Flow:** Draft → Ready → Active → Completed → Approved → Archived

---

## Key Technical Concepts

### Event Sourcing Architecture

The sync model uses an event log pattern. The device sends changes as events; the server orders and stores them. This enables audit trails and potential future undo functionality. Event compaction and snapshotting manage long-term storage growth.

### Coordinate System ("Plan Space")

All coordinates use the "plan space" system:
- Origin at North vector start point
- X/Y axes aligned with CAD axes
- North angle stored for orientation and export transformations
- Coordinates are in meters

### ID Strategy

| ID Type | Specification |
|---------|---------------|
| **Internal IDs** | UUIDv7 for all entities (projects, levels, rooms, types, instances, photos, events) |
| **Export IDs** | Sequential per project, assigned at first final export |
| **Photo Naming** | Globally unique name assigned at capture time; same name used internally and on export |

#### UUIDv7

UUIDv7 is chosen for internal IDs because it is time-sortable (embeds timestamp), globally unique, and generates efficiently. This supports event ordering and database indexing.

#### Sequential Export ID Assignment Rules

1. IDs generated only at first final export (when project is Approved)
2. Assignment order: Level → Room → Asset creation timestamp
3. Once assigned, IDs become permanent and are stored in the database
4. If project is reopened and assets added, new assets receive the next sequential numbers
5. Re-exports use the same IDs for existing assets, ensuring stable client references

### Photo Management

**Photo Specifications:**

| Aspect | Specification |
|--------|---------------|
| **Minimum per Instance** | 1 photo (configurable per Family in schema) |
| **Maximum per Instance** | 5 photos (configurable per Family in schema) |
| **Photo Reuse** | A single photo can be linked to multiple instances |
| **Format** | JPEG, longest edge 1280px, quality 0.8 |
| **Device Storage Target** | ~1,000 photos per device |
| **Cloud Storage Target** | Up to 1,000,000 photos/year with cost controls |

**Photo Naming:**

Photo names are assigned at capture time and remain unchanged through export:
- Each photo receives a globally unique identifier at the moment of capture
- Photo name is stored as an instance parameter
- **Same name everywhere:** The capture-time name is used internally and in client exports (no renaming)
- **Uniqueness constraint:** No duplicate photo names across projects or operators
- **Format:** `{project_uuid_short}_{operator_id}_{timestamp}_{sequence}`

**Photo Synchronization:**

Photos sync from device to server only:
- All photos upload to the central server
- Photos are uploaded in a background queue
- All photos are available for export from the admin console

### Job Completion Requirements

When the operator marks a job as complete:
- Every room must have at least one Instance
- If any room is empty, the app displays a report of all empty rooms
- Operator must either add assets or insert an Annotation asset with a reason

#### Handling Rooms Without Assets

| Situation | Required Action |
|-----------|-----------------|
| **No assets to register** | Add Annotation asset + select reason from dropdown + optional note/photo |
| **Room unreachable** | Add Annotation asset + select reason + mandatory photo (or note if photo impossible) |

---

## MVP Simplifications

The following features from the full specification are explicitly excluded from the MVP to accelerate development:

- **Authentication & Logins:** No login required for admin dashboard or mobile app
- **Multi-User Model:** Single operator, no worksets or ownership management
- **Suggestions Mechanism:** Assets are directly placed, edited, or deleted without approval workflow
- **Plan Editing:** No room splitting, merging, or deletion
- **Schedule Generation:** No Revit-style schedule views in admin console
- **AI Support:** No AI-assisted insertion or photo classification
- **Undo Capability:** No undo for actions
- **Sync Conflict Resolution:** Not applicable for single-user operation
- **Emergency Export Bundles:** Simplified sync without emergency fallback
- **QA-Flagged State:** Simplified room lifecycle without QA step
- **Two-factor Authentication:** Planned for future versions

---

## Scale Constraints

The MVP targets the following limits:

| Dimension | Limit |
|-----------|-------|
| Assets per Project | 10,000 (soft limit) |
| Photos per Device | ~1,000 |
| Photos per Year (Cloud) | Up to 1,000,000 |

---

## Documentation

- `CLAUDE.md` - Guidance for Claude Code when working in this repository
- Component READMEs in each folder (`backend/`, `admin-dashboard/`, etc.)
- `docs/` - Additional technical documentation

---

## Contributing

This is an MVP proof-of-concept. For development guidelines specific to each component, see the respective README files in each directory.

---

*— End of Documentation —*
