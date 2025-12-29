# Technical Asset Registry

## MVP Specification

**Version 1.0 — December 2025**

---

## Executive Summary

This document defines the Minimum Viable Product (MVP) specification for a field survey tool designed for technical asset registry (*anagrafica tecnica*) in buildings. The MVP enables a single operator to conduct on-site surveys using an iPhone app where the floorplan serves as the primary interface.

The MVP is designed as a proof-of-concept to demonstrate core functionality to the client. The tool is offline-first to accommodate unreliable site connectivity, with automatic synchronization when network access is available. The architecture follows BIM conventions using a Family → Type → Instance hierarchy and employs versioned parameter schemas to ensure survey consistency.

**Key MVP Simplifications:**

- Single-user operation (no multi-user collaboration or worksets)
- No authentication required (open access for demonstration)
- Simplified data model without suggestions or approval workflows
- Fixed room geometry (no plan editing capabilities)
- No AI-assisted insertion mode
- Direct sync without conflict resolution
- No undo capabilities
- No schedule generation

---

## Glossary of Terms

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

---

## System Architecture Overview

The MVP consists of three primary components:

1. **Input Preparation:** DWG processing and asset/parameter catalogue import
2. **Server Side:** Admin console and central sync hub
3. **Mobile Tool:** Field app for iOS

### Project Hierarchy

The hierarchy for the MVP is: **Site/Project → Level → Room**

There is no separate Building entity. For multi-building projects, each floor of each building is spread out on the DWG XY plane, and levels are named accordingly (e.g., "Building A - Floor 1"). An optional "Building" layer in the DWG can group levels for UI navigation purposes.

### Proposed Architecture: 4 Components

#### 1. Mobile App (iOS)

The field tool the operator uses on their iPhone.

**Key Responsibilities:**

- Display floorplans as interactive maps (vector tiles + room polygons)
- Allow asset creation following Family → Type → Instance hierarchy
- Capture and store photos locally (1–5 per asset, configurable per Family)
- Full offline operation with local database
- Sync events to server when online (background photo upload queue)
- On-device fuzzy matching to warn before creating duplicate Types
- Block save until required fields are filled (device-level validation ensures data completeness)

**Key Data Managed Locally:**

- Project package (plan tiles, room polygons, schema, type library)
- Asset instances with parameters and photos
- Event log for sync

**Suggested Technologies:** Swift/SwiftUI, Core Data or Realm, MapKit or custom tile renderer

#### 2. Admin Dashboard (Web Frontend)

A browser-based control panel for project administrators.

**Key Responsibilities:**

- Project creation and configuration
- Upload and validate DWG files (trigger backend processing)
- Upload asset/parameter catalogues (create schema versions)
- Monitor survey progress by level and room
- Track data quality: missing recommended fields, anomalies
- Approve project for export
- Generate and download exports (CSV/Excel + photo packages)

**Suggested Technologies:** React or Vue.js, TypeScript, Tailwind CSS

#### 3. Server Backend

The central processing engine running in the cloud.

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

- **Event Sourcing:** All changes stored as events for audit trail. Event compaction and snapshotting manage storage growth.
- **UUIDv7:** Time-sortable unique IDs for all entities (supports event ordering and database indexing)
- **Sequential Export IDs:** Assigned at first final export, remain stable across re-exports
- **Plan Space Coordinates:** Origin at North vector start point, X/Y aligned with CAD axes, coordinates in meters

**Suggested Technologies:** Node.js (Express/Fastify) or Python (FastAPI), PostgreSQL client, S3 SDK

#### 4. Storage

Persistent storage for all structured data and files.

| Storage Type | Technology | Contents |
|--------------|------------|----------|
| Relational Database | PostgreSQL | Projects, levels, rooms, families, types, instances, events, schemas |
| File Storage | AWS S3 / GCS / Azure Blob | DWG files, plan tiles, photos, generated exports |
| CDN (optional) | CloudFront / Cloud CDN | Fast delivery of plan tiles to mobile app |

**Key Data Characteristics:**

- Photos: JPEG, 1280px longest edge, ~1,000 per device, up to 1,000,000/year cloud
- Photo naming: globally unique at capture time ({project_uuid_short}_{operator_id}_{timestamp}_{sequence})
- **Same name everywhere:** The capture-time name is used internally and in client exports (no renaming)
- Plan tiles: Vector tiles clipped per level

---

## Input Preparation

### DWG Contract (Input Requirements)

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

### DWG Validation + Import Report

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

### Plan Ingestion Outputs

For each level, the system produces:

1. Background visualization (vector tiles) clipped to level boundary
2. Room polygons in "plan space" coordinate system
3. Level origin point and North angle
4. **plan_version_id** for tracking geometry changes (every import creates a new version—no silent overwrites)

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

#### Optional Pre-Work

- Pre-create standard Types to speed up field work
- Type normalization (fuzzy matching) configured to reduce duplicate Type creation

---

## Data Model

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

### Asset Family → Type → Instance Hierarchy

| Level | Example | Who Can Modify |
|-------|---------|----------------|
| **Family** | Lights, Radiators, Access Points | Admin only—defines parameter structure and photo rules |
| **Type** | "Philips 30W wall light" | Operator can create; parameters fixed by Family |
| **Instance** | Specific lamp in Room 101 | Operator fills instance parameters (serial, condition, notes) |

#### Type Creation & Management

When inserting an asset, operators should follow this priority:

1. Use an existing Type (keeps all previously inserted info)
2. Duplicate an existing Type, rename it, and modify some parameters
3. Create a new Type from scratch (last resort)

**Type Creation Rules:**

- Type parameters are defined by the parent Family and cannot be changed by operators
- Only admins can create, modify, or delete parameter definitions in Families
- **On-device fuzzy matching:** Warns operator before creating potential duplicates against downloaded Type library
- **Server-side normalization:** Final authority for duplicate detection and merge
- **Naming consistency:** New Types should follow the naming scheme of existing Types in the project

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

### Annotation Assets

A special asset family for internal notes and status markers:

- Used to mark rooms as "Without any assets" or "Unreachable"
- Requires a reason (dropdown selection) + optional note/photo
- Visible to operator and admin for internal communication
- **Excluded from client exports**

---

## Server Side Components

### Core Responsibilities

- Prepare projects (DWG + schema → app-ready package)
- Central sync and data storage
- Monitor progress (room states, missing fields)
- Generate exports (CSV/Excel + photo package + report)

### Admin Console Workflows

#### Before Survey

1. Create Project
2. Import DWG → run validation → generate plan_version_id
3. Import catalogue → create schema_version_id
4. Optional: pre-build Types, configure normalization
5. Create project package for mobile download

#### During Survey

1. Monitor progress by level/room
2. Track data quality: missing recommended fields, anomalies

**Note:** Required fields block save at the device level, so they cannot be missing. Admin monitoring focuses on recommended fields and data quality issues.

#### After Survey

1. Export client deliverables: clean CSV/Excel per required mapping
2. Generate photo package (photos retain their capture-time names)
3. Produce summary report (time, coverage, assets registered, etc.)

### Sync Model

- Device stores a complete local copy of the project
- Changes are logged as events locally
- When online: events sync to server, photos upload asynchronously
- Server stores and orders events

> **Note:** In the MVP, since there is only a single user, sync conflict resolution is not required.

### ID Strategy

| ID Type | Specification |
|---------|---------------|
| **Internal IDs** | UUIDv7 for all entities (projects, levels, rooms, types, instances, photos, events) |
| **Export IDs** | Sequential per project, assigned at first final export |
| **Photo Naming** | Globally unique name assigned at capture time; same name used internally and on export |

#### Sequential Export ID Assignment Rules

1. IDs generated only at first final export (when project is Approved)
2. Assignment order: Level → Room → Asset creation timestamp
3. Once assigned, IDs become permanent and are stored in the database
4. If project is reopened and assets added, new assets receive the next sequential numbers
5. Re-exports use the same IDs for existing assets, ensuring stable client references

---

## Mobile Application

### Initial Setup

1. Operator opens the app (no login required for MVP)
2. Views list of available projects
3. Opens a project: the app downloads the project package (plan tiles, room polygons, schema, family/type library)

### Map Interface (UI/UX)

The floorplan serves as the primary navigation interface, similar to Google Maps.

#### Navigation

- On project entry, the first level's floorplan is displayed
- Two-finger gestures for pan and zoom (Google Maps-style)
- Level selector to switch between floors
- Building selector (if Building layer defined) to filter levels

#### Room Interaction

| Action | Result |
|--------|--------|
| **Tap inside a room** | Enter room editing mode; room is selected |
| **Tap asset icon** | Reveal individual assets radially around centroid |
| **Tap neighboring room** | Switch to that room for editing |
| **Tap outside floorplan** | Deselect room; enter navigation mode |

#### Room Display

- **Empty room:** displays (+) icon at centroid
- **Room with assets:** displays icon with asset count at centroid
- Tapping the icon reveals individual assets arranged radially

#### Navigation Mode (No Room Selected)

When tapped outside the floorplan, the operator enters navigation mode where they can:

- Switch between levels
- Switch between buildings (if applicable)
- Cannot add assets until a room is selected

### Room Lifecycle States (Simplified for MVP)

| State | Description & Transitions |
|-------|--------------------------|
| **Empty** | No assets. Adding any asset (including Annotation) moves to Complete. |
| **Complete** | At least one asset present. Meets schema validation + photo rules. |
| **Approved** | Final state after admin approval. Ready for export. |

**State Flow:** Empty → Complete → Approved. Admin can batch-approve all Complete rooms before export.

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

### Main Survey Flow

Operators interact via the floorplan. Tap inside a room polygon to select it.

#### Manual Asset Insertion

1. Choose Family
2. Choose existing Type, duplicate and modify existing Type, or create new Type (with fuzzy match warning)
3. Create Instance
4. Take photos (minimum 1, maximum 5 per family rules)
5. Fill instance parameters (notes, condition, serial, etc.)

**Constraints:**

- Operators can create new Types but cannot introduce new parameter keys
- All parameters must exist in the pinned schema version

### Offline Behavior

| Feature | Requires Connectivity |
|---------|----------------------|
| Survey rooms | No |
| Create/edit/delete assets | No |
| Photo capture | No |
| Photo upload | Yes (background queue) |
| Sync events to server | Yes |

---

## Photo Management

### Photo Specifications

| Aspect | Specification |
|--------|---------------|
| **Minimum per Instance** | 1 photo (configurable per Family in schema) |
| **Maximum per Instance** | 5 photos (configurable per Family in schema) |
| **Photo Reuse** | A single photo can be linked to multiple instances |
| **Format** | JPEG, longest edge 1280px, quality 0.8 |
| **Device Storage Target** | ~1,000 photos per device |
| **Cloud Storage Target** | Up to 1,000,000 photos/year with cost controls |

### Photo Naming

Photo names are assigned at capture time and remain unchanged through export:

- Each photo receives a globally unique identifier at the moment of capture
- Photo name is stored as an instance parameter
- **Same name everywhere:** The capture-time name is used internally and in client exports (no renaming)
- **Uniqueness constraint:** No duplicate photo names across projects or operators
- **Format:** Combination of project ID, operator ID, timestamp, and sequence number

### Photo Synchronization

Photos sync from device to server only:

- All photos upload to the central server
- Photos are uploaded in a background queue
- All photos are available for export from the admin console

---

## Project Lifecycle

| State | Description |
|-------|-------------|
| **Draft** | Project being configured; not available to operator. |
| **Ready** | Project fully configured but not yet started in the field. Available for operator download. |
| **Active** | Survey in progress; operator is working in the field. |
| **Completed** | Survey finished; read-only for operator. Awaiting admin review. |
| **Approved** | Admin reviewed and approved. Ready for client submission. |
| **Archived** | Long-term storage; data retained but project inactive. |

**State Flow:** Draft → Ready → Active → Completed → Approved → Archived. Only admin can transition between states. Admin can reopen a Completed project back to Active if needed.

---

## Scale Constraints (MVP)

The MVP targets the following limits:

| Dimension | Limit |
|-----------|-------|
| Assets per Project | 10,000 (soft limit) |
| Photos per Device | ~1,000 |
| Photos per Year (Cloud) | Up to 1,000,000 |

---

## Features Reserved for Future Versions

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

## Technical Implementation Notes

### Event Sourcing Architecture

The sync model uses an event log pattern. The device sends changes as events; the server orders and stores them. This enables audit trails and potential future undo functionality. Event compaction and snapshotting manage long-term storage growth.

### Coordinate System

All coordinates use the "plan space" system: origin at North vector start point, X/Y axes aligned with CAD axes, North angle stored for orientation and export transformations. Coordinates are in meters.

### UUIDv7

UUIDv7 is chosen for internal IDs because it is time-sortable (embeds timestamp), globally unique, and generates efficiently. This supports event ordering and database indexing.

### Photo Naming Implementation

Photo names are generated at capture using the format: `{project_uuid_short}_{operator_id}_{timestamp}_{sequence}`. This ensures global uniqueness without requiring server coordination at capture time. The photo name becomes an immutable instance parameter and is used unchanged in client exports.

---

## Visual Architecture Summary

```
┌────────────────────────────────────────────────────────┐
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
│  │  ┌───────────┐ ┌─────────────┐ ┌────────────┐  │  │
│  │  │  Schema   │ │   Export    │ │            │  │  │
│  │  │Management │ │ Generation  │ │            │  │  │
│  │  └───────────┘ └─────────────┘ └────────────┘  │  │
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

---

*— End of MVP Specification —*
