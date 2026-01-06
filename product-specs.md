# Anagrafica Tecnica
## Technical Asset Registry — Product Requirements Specification

**Version 1.0 | December 2025**

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Problem Statement](#2-problem-statement)
3. [Solution Overview](#3-solution-overview)
4. [User Personas](#4-user-personas)
5. [User Flows](#5-user-flows)
6. [System Architecture](#6-system-architecture)
7. [Data Model](#7-data-model)
8. [Functional Requirements](#8-functional-requirements)
9. [Technical Specifications](#9-technical-specifications)
10. [Appendices](#10-appendices)

---

## 1. Executive Summary

Anagrafica Tecnica is an end-to-end platform for performing technical asset inventories on-site. It combines an offline-first field application (for on-site operators), a backend/server (for synchronization, storage, validation, and integrations), and a web-based administration dashboard (for configuration, QA, review, and export). Together, these components allow teams to catalog technical equipment—such as lighting fixtures, HVAC components, network infrastructure, and electrical systems—reliably on-site, even with intermittent or no connectivity.

The platform addresses a key facility-management gap: producing accurate, structured, and verifiable asset data directly from the field, while keeping processes standardized across technicians and projects. Data is captured where it happens, validated against project rules (required fields, controlled vocabularies, anomaly flags), and synchronized when connectivity is available. The admin dashboard provides oversight and governance—templates, asset schemas, progress tracking, QA workflows, and delivery packages—ensuring consistent outputs that can be trusted and reused in downstream systems (e.g., CAFM/CMMS, asset management platforms, reporting).

### 1.1 Key Value Propositions

| Value | Description |
|-------|-------------|
| **Offline-First Operation** | Full functionality without network connectivity, with automatic synchronization when online |
| **Spatial Context** | Interactive floorplan navigation links assets to rooms and makes them easy to locate |
| **Data Quality at Source** | Validation rules and required fields prevent incomplete or incorrect data entry |
| **Standardized Taxonomy** | Family → Type → Instance hierarchy ensures consistent asset classification |
| **Configurable Schemas** | Project-specific asset schemas (fields, validation rules, controlled vocabularies, and photo requirements) enable consistent data capture across different facility types and clients |
| **Photo Documentation** | Single required Type photo plus optional Instance photos provide visual verification of assets |
| **Export-Ready Deliverables** | Structured data exports (CSV/Excel) with organized photo archives for client delivery |

### 1.2 Scope

This specification defines the Minimum Viable Product (MVP), a proof-of-concept designed to demonstrate and validate core functionality with a single operator workflow. Each project is scoped to a single facility.

---

## 2. Problem Statement

### 2.1 The Challenge

Facility managers, property owners, and service providers frequently need accurate inventories of technical assets within sites. These inventories are essential for:

- Maintenance planning and scheduling
- Regulatory compliance documentation
- Insurance and risk assessment
- Renovation and retrofit projects
- Energy efficiency audits
- Operational cost optimization

Currently, technical asset surveys are conducted using a combination of paper forms, spreadsheets, generic note-taking apps, and manual photography. This fragmented approach creates significant problems.

### 2.2 Current Pain Points

#### Operational Challenges

| Problem | Impact |
|---------|--------|
| **Connectivity dependency** | Indoor environments often have poor or no cellular/WiFi signal, forcing operators to defer data entry |
| **Context switching** | Operators must juggle multiple tools (camera, notepad, phone) while navigating sites |
| **Photo-data disconnection** | Photos taken separately from data entry become orphaned or mislabeled |
| **Completion uncertainty** | No systematic way to verify all rooms have been surveyed |

#### Post-Survey Problems

| Problem | Impact |
|---------|--------|
| **Manual data consolidation** | Hours spent transferring handwritten notes to digital formats |
| **Photo organization** | Matching hundreds of photos to corresponding asset Type records |
| **Quality assurance gaps** | Discovering missing data only after leaving the site |
| **Inconsistent deliverables** | Each project produces slightly different output formats |

### 2.3 The Cost of the Status Quo

These inefficiencies translate directly to business costs: return site visits to collect missing data, extended project timelines, and inability to leverage survey data for analytics or automation. Organizations conducting regular asset surveys need a purpose-built solution that addresses these challenges systematically.

---

## 3. Solution Overview

### 3.1 Product Vision

In technical surveys, the floorplan has always been central; Anagrafica Tecnica makes it structured and operational—turning a static backdrop into a spatial model that drives capture, organization, and verification.

Instead of “dumb” collection (room lists, unstructured notes, photo folders), operators record assets linked to rooms, classified via Family → Type → Instance and guided by configurable schemas (fields, rules, vocabularies, photo requirements). This enforces data quality at capture (validation + required fields) and produces consistent, verifiable, export-ready data for QA, reporting, and downstream systems—fully offline with automatic sync when online.

### 3.2 Core Capabilities

#### Mobile Application (iOS)

The mobile app serves as the primary tool for field operators, designed for single-handed operation while moving through sites.

**Key Features:**
- Projects home with search, filters, sync status, and placeholder settings/import entry points
- Interactive floorplan with map-style pan, zoom, and navigation
- Room view with assets and room notes list plus quick add
- Add Asset wizard with progress tracker, Room Note path, and type creation flow
- Instance editor widget with in-place edits and type editing access
- Survey Report hub with rooms list, types list, filters, and project export
- Integrated Type photo capture (exactly 1 required per Type) and optional Instance photos (up to 5)
- On-device fuzzy matching to suggest existing Types and prevent duplicates
- Room-by-room progress tracking with visual indicators and sync status states
- Offline first operation with automatic sync

#### Admin Dashboard (Web)

The web dashboard provides project management, configuration, and quality assurance capabilities for administrators.

**Key Features:**
- Project creation and configuration wizard
- DXF floorplan upload with automated validation
- Asset family and parameter schema management
- Real-time survey progress monitoring
- Data quality metrics and alerts
- Export generation (CSV/Excel with organized photo archives)

#### Server Backend

The backend provides data management, processing, and integration services.

**Key Features:**
- Event-sourced synchronization engine
- DXF processing pipeline (room extraction, vector tile generation)
- Schema versioning and management
- Type normalization and duplicate detection
- Export generation with sequential client-facing IDs
- Persistent storage layer (database + object storage for photos/exports)

### 3.3 Design Principles

| Principle | Implementation |
|-----------|----------------|
| **Offline-first** | All functionality available without network; sync is additive, not required |
| **Floorplan-centric** | The map is the primary interface, not lists or menus |
| **Validation at source** | Required fields enforced on device; incomplete data cannot be saved |
| **Structured flexibility** | Standardized taxonomy with ability to create new Types in the field |
| **Visual verification** | Photo requirements ensure asset Types are documented, not just recorded |
| **Complete coverage** | Survey cannot be marked complete until every room is addressed |

---

## 4. User Personas

### 4.1 Field Operator

**Profile:** Technical surveyor who physically visits sites to catalog assets.

| Attribute | Description |
|-----------|-------------|
| **Environment** | On-site, often in challenging conditions (poor lighting, restricted access, no connectivity) |
| **Device** | iPhone, operated primarily one-handed while carrying equipment |
| **Goals** | Complete accurate surveys efficiently; minimize return visits |
| **Pain points** | Connectivity issues, data re-entry, forgetting rooms, limited device storage, battery life |

**Key Needs:**
- Works reliably offline
- Quick asset entry with minimal typing
- Minimal tapping for navigating screens
- Clear progress indication
- Confidence that nothing is missed

### 4.2 Project Administrator

**Profile:** Office-based coordinator who sets up projects, monitors progress, and delivers results to clients.

| Attribute | Description |
|-----------|-------------|
| **Environment** | Office, using desktop/laptop with reliable connectivity |
| **Device** | Web browser on desktop computer |
| **Goals** | Ensure data quality; meet project deadlines; produce professional deliverables |
| **Pain points** | Incomplete data, inconsistent formats, manual consolidation work |

**Key Needs:**
- Easy project configuration
- Visibility into field progress
- Quality assurance tools
- One-click export generation

---

## 5. User Flows

### 5.1 Project Setup Flow (Administrator)

This flow covers the complete process of preparing a project for field work.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         PROJECT SETUP FLOW                                  │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌──────────────┐
    │   START      │
    └──────┬───────┘
           │
           ▼
    ┌────────────────────────────────────────┐
    │  1. CREATE NEW PROJECT                 │
    │  ─────────────────────────────────     │
    │  Configuration of Project Parameters:  │
    │  • name                                │
    │  • location                            │
    │  • client                              │
    │  • cover image                         │
    │  • basic settings                      │
    │                                        │
    │  State: DRAFT                          │
    └──────────────┬─────────────────────────┘
                   │
                   ▼
    ┌──────────────────────────────────────┐
    │  2. UPLOAD FLOORPLAN (DXF)           │
    │  ─────────────────────────────────   │
    │  • Select DXF file                   │
    │  • System validates file structure   │
    │  • Extracts levels and rooms         │
    │  • Generates vector tiles            │
    │  • Assigns 4-digit room numbers      │
    │    (top-left → bottom-right)         │
    └──────────────┬───────────────────────┘
                   │
                   ▼
           ┌──────────────┐
           │  Validation  │
           │   Passed?    │
           └──────┬───────┘
                  │
        ┌─────────┴─────────┐
        │ NO                │ YES
        ▼                   ▼
┌───────────────────┐  ┌───────────────────────────────────────────┐
│ VALIDATION REPORT │  │  3. SELECT PARAMETER SCHEMA               │
│ ────────────────  │  │  ─────────────────────────────────        │
│ • List of errors  │  │  • Choose from existing schemas           │
│ • Required fixes  │  │  • Or Duplicate/modify existing schemas   │
│                   │  │  • Or upload new schema definition        │
│ → Fix DXF and     │  │  • Schema locked to project               │
│   re-upload       │  └──────────────┬────────────────────────────┘
└───────────────────┘                 │
                                      ▼
                       ┌──────────────────────────────────────┐
                       │  4. REVIEW & ACTIVATE                │
                       │  ─────────────────────────────────   │
                       │  • Preview floorplan rendering       │
                       │  • Verify room count per level       │
                       │  • Confirm schema parameters         │
                       │  • Activate project                  │
                       │                                      │
                       │  State: DRAFT → READY                │
                       └──────────────┬───────────────────────┘
                                      │
                                      ▼
                               ┌──────────────┐
                               │     END      │
                               │  Project     │
                               │  Available   │
                               │  for Field   │
                               └──────────────┘
```

#### Step Details

**Step 1: Create New Project**
- Administrator accesses the dashboard and initiates project creation
- Configures project parameters, such as name, client, location, and other basic settings, then adds a cover image
- Project is created in DRAFT state

**Step 2: Upload Floorplan**
- Administrator uploads the DXF file containing floorplan geometry
- System performs automated validation (see Section 9.3 for validation rules)
- On success: rooms, levels, and spatial data are extracted; vector tiles are generated
- Rooms are assigned a 4-digit number based on spatial order (top-left to bottom-right) within each level: the first digit is the floor number (from lowest = 0 to highest), and the remaining three digits are a sequential room number within the floor
- On failure: detailed validation report identifies specific issues requiring correction

**Step 3: Select Parameter Schema**
- Administrator chooses which parameter schema to use for this project
- Schema defines all asset families, their parameters, validation rules, and photo requirements
- Once selected, the schema version is locked to the project

**Step 4: Review & Activate**
- Administrator reviews the complete configuration
- Previews how the floorplan will appear on mobile devices
- Verifies room counts and level structure
- Activates the project, changing state from DRAFT to READY
- Project becomes available for download by field operators

---

### 5.2 Field Survey Flow (Operator)

This flow covers the complete on-site survey process from project download to completion.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                             FIELD SURVEY FLOW                               │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────┐
│   START      │
└──────┬───────┘
       │
       ▼
┌────────────────────────────────────────┐
│  1. OPEN PROJECT                       │
│  ─────────────────────────────────     │
│  • Browse available projects           │
│  • Select project to open              │
│  • Project data & tiles are downloaded │
│  • Full project stored locally         │
│                                        │
│  State: READY → ACTIVE                 │
└───────────────┬────────────────────────┘
                │
                ▼
┌────────────────────────────────────────┐
│  2. NAVIGATE TO ROOM                   │
│  ─────────────────────────────────     │
│  • View floorplan (pan/zoom)           │
│  • Select level from picker            │
│  • Tap target room                     │
│  • View room status + asset add button │
└───────────────┬────────────────────────┘
 ▲              │
 │              ▼
 │  ┌────────────────────────────────────┐
 │  │  3. ADD ASSET                      │
 │  │  ──────────────────────────────    │
 │  │  • Tap the add button              │
 │  │  • Select asset Family             │
 │  │  • Search/select existing Type     │
 │  │    OR create new Type              │
 │  │  • Fill instance parameters        │
 │  │  • Capture Type photo (if new)     │
 │  │  • Save asset                      │
 │  └───────────┬────────────────────────┘
 │   ▲          │
 │   │          ▼
 │   │   ┌───────────────┐
 │   │   │ More assets   │
 │   │   │ in room?      │
 │   │   └───────┬───────┘
 │   │           │
 │   └───────────┴──┐
 │    YES           │ NO
 │                  │
 │                  │
 │                  │
 │                  ▼
 │       ┌───────────────┐
 │       │ More rooms    │
 │       │ to survey?    │
 │       └───────┬───────┘
 │               │
 └───────────────┴─────┐
  YES                  │ NO
                       │
                       ▼
               ┌──────────────────────────────────────┐
               │  4. COMPLETE SURVEY                  │
               │  ─────────────────────────────────   │
               │  • Tap "Complete Survey"             │
               │  • System validates all rooms        │
               │  • Shows empty room report if any    │
               │  • Confirm completion                │
               │                                      │
               │  State: ACTIVE → COMPLETED           │
               └──────────────┬───────────────────────┘
                              │
                              ▼
               ┌──────────────────────────────────────┐
               │  5. FINAL SYNC                       │
               │  ─────────────────────────────────   │
               │  • All events uploaded               │
               │  • All photos uploaded               │
               │  • Confirmation displayed            │
               └──────────────┬───────────────────────┘
                              │
                              ▼
                       ┌──────────────┐
                       │     END      │
                       └──────────────┘
```

#### Step Details

**Step 1: Download Project**
- Operator opens the mobile app and views the Projects page (state: READY)
- If no projects are assigned, show the empty state: "No project assigned"
- Projects page includes search, filter (e.g., location/status), and per-project sync status
- Settings and Import buttons are fixed at the bottom as placeholders for future implementations
- Each project card displays: project name, project image, location, number of rooms, number of assets, and state label
- Project states (mobile UI):
  - Online (not yet downloaded): label "Online" with light gray background (#F1F1F1)
  - Open (being surveyed): label "Open" with light blue background (#DCEEFF)
  - Completed (finished survey): label "Completed" with light green background (#DFF5E1)
- Operator taps a project card to open it:
  - Online: show a loading screen while project data downloads, then open the floorplan
  - Open: open the floorplan immediately
  - Completed: show a read-only warning and open in read-only mode
- App downloads complete project data: floorplan tiles, room geometry, schema, existing Types
- Project state changes to ACTIVE (Open); operator can now work fully offline

**Step 2: Navigate to Room**
- Operator views the interactive floorplan
- Uses familiar gestures: pinch to zoom, drag to pan
- Floating on top of the floorplan are:
  1. Top left is an Exit button that opens the exit pop-up
  2. Top center is the project name
  3. Top right is the sync status indicator (tap for status message)
  4. Bottom left (☰) opens the "Survey Report" page
  5. Bottom right is a Level picker that opens upward to switch floors (drop-up)
- Room names and numbers are visible directly on the floorplan
- Rooms are color-coded by status: empty (halftone gray), with assets or room notes (light blue)
- Empty rooms show a (+) button inside the room
- Rooms with assets or room notes show a circle badge with the total item count (assets + room notes)
- The operator taps the room they are physically in. Everything outside the room boundary is half-toned:
  1. If the room is empty, the Add Asset wizard opens immediately
  2. If the room contains assets or room notes, a "room view" opens:
       - A back arrow returns to the interactive floorplan
       - At the top, a label shows the level and room number and the sync status icon
       - A scrollable list shows assets and room notes linked to the room
       - Bottom actions include a hamburger (Survey Report) and a "+ Add Asset" button

**Step 3: Add Asset**
- The operator taps the "+ Add Asset" button or taps an empty room; the Add Asset wizard opens with a progress tracker
- Step 1: Family selection
  - Search bar filters both Family names and Type names within families
  - Room Note option appears below the search bar and above the families list, separated by a horizontal line
  - Room Note is always available
- If Room Note is selected:
  - Room Note form opens with a dedicated progress tracker
  - Photos section requires 1 main photo plus up to 4 optional photos
  - Read-only info includes Level and Host Room
  - Boolean fields include "Empty room" and "Room is blocked"
  - Flags are mutually exclusive, but both can be "no"
  - If the room already contains assets, both flags are disabled (grayed out)
  - Description field is available for notes
  - "Save Note" returns to Room view and adds the note
- If a standard Family is selected:
  - Step 2: Type selection
    - Operator can select an existing Type or choose "+ New Type"
  - Existing Type path (Step 3):
       - Type form opens with pre-filled parameters and the required single Type photo
       - If no Type parameters are changed, proceed directly to Step 4 (Instance Form)
       - If any Type parameter is changed, the operator is prompted to name a new Type before proceeding
       - The original Type remains unchanged; only the new asset uses the new branched Type
  - New Type path:
       - Camera launches immediately; captured photo becomes the mandatory Type photo
       - Type form opens with empty parameters
       - Operator names the new Type, then proceeds to Step 4 (Instance Form)
  - Fuzzy matching suggests similar existing Types to prevent duplicates
  - Final step is the Instance form with Family instance parameters
  - Some instance parameters are pre-filled and read-only (e.g., Level, Room)
  - Optional Instance photos can be captured (up to 5)
  - Required fields must be completed; validation prevents saving incomplete data
  - Asset is saved locally and appears in the room's assets list with an "Asset saved" banner
- If the operator exits the wizard mid-way, a warning indicates all progress will be lost; confirming returns to the Floorplan View or Room View based on where the wizard was launched

**Step 4: Asset Editing Inside Room View**
- When inside a "room view," the operator can interact with assets and room notes in the list
- Zoom and pan are disabled; the floorplan is fixed on the current room
- Room names and numbers remain visible
- Asset list is ordered by Family, then Type, then creation time
- Room Notes appear in the same list with a distinct icon
- Tapping a row opens the Instance Editor Widget
  - Shows Type summary, instance parameters only, optional Instance photos, and Reset/Save actions
  - "Edit Type" opens the Edit Type widget (separate modal) for Type-level changes
- Type edits from the Instance Editor update the existing Type (no duplication)
- Closing the widget with unsaved edits prompts Discard/Save confirmation
- Swiping an asset row reveals Delete; a confirmation modal is required before deletion

**Step 5: Survey Report Page**
- From the floorplan or room view, the operator can tap the bottom left (☰) button to enter the "Survey Report" page
- This page contains a searchable list of rooms (grouped by level) and a searchable list of Types (grouped by Family)
- By default, the page opens in the Rooms list
- At the bottom of the screen are fixed buttons:
  1. Left: Rooms list
       - Room rows show room number, name, and asset count (assets + room notes)
       - Tapping a room opens its Room view
       - If the room has no items, a (+) button opens the Add Asset wizard
       - A filter button opens the Room List Filter:
         - Room Type filters: All, Without assets, With assets (asset counts include room notes)
         - Asset Type filters: multi-select list of asset Types; only rooms containing the selected Types are shown
         - Reset/Save controls; applied filters show an indicator in the search bar
  2. Center: Types list
       - Each row contains Type name, summary of major parameters, and instance count
       - Tapping a Type opens the Edit Type widget:
         - Type parameters and the required single Type photo; edits affect all instances of the Type
         - Edits in this context modify the existing Type (no duplication) within the current project
         - "View photo" opens the Type photo
         - Closing with unsaved edits prompts Discard/Save
       - A filter button opens the Type List Filter:
         - Family selector (required)
         - After selecting a Family, all parameters for that Family appear
         - Each parameter provides a drop-down list of existing values
         - Multi-select across parameter values; Types must match all selected parameters, and any selected value within each parameter
         - Reset/Save controls; applied filters show an indicator in the search bar
  3. Right: Project Export
       - Shows a "Building project export file..." progress pop-up
       - When ready, presents the iOS share sheet
       - Export serves as a backup mechanism if sync fails

**Step 6: Complete Survey**
- The operator taps the Exit button (top left) when finished
- The exit pop-up offers "Pause Survey" or "Complete Survey"
  1. Operator taps "Pause Survey"
       - Returns to the Projects page
       - The operator can return at any time to resume the survey
  2. Operator taps "Complete Survey"
       - The system validates that every room has at least one asset or Room Note
       - If any rooms are empty, a warning appears with "View Empty Rooms"
       - Indicated action opens Survey Report > Rooms list filtered to only empty rooms
       - For legitimately empty rooms, the operator must add a Room Note
       - A room is considered complete when it contains at least one asset or one Room Note
       - If no rooms are empty, a "Slide to complete" control is shown
       - Project state changes to COMPLETED; it becomes read-only on the device and cannot be edited

**Step 7: Final Sync**
- When network is available, update events and photos sync to server
- Sync status indicator shows "syncing", "synced", or "failed to sync" states and provides a status message on tap
- Confirmation displayed when sync is complete

---

### 5.3 Asset Creation Detail Flow

This flow details the asset creation process, the most frequent operation during surveys.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      ASSET CREATION DETAIL FLOW                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────┐
│  Tap on empty room   │
│  on floorplan        │
└────────┬─────────────┘
         │
         ▼
[Add Asset wizard opens]
         │
         ▼
┌──────────────────────────────────────┐
│  SELECT FAMILY                       │
│  ─────────────────────────────────   │
│  • List of asset families            │
│  • Includes Room Note                │
│  • Icons + labels                    │
│  • e.g., Lights, Radiators, APs      │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│  SELECT OR CREATE TYPE               │
│  ─────────────────────────────────   │
│                                      │
│  ┌────────────────────────────────┐  │
│  │  🔍 Search existing types...   │  │
│  └────────────────────────────────┘  │
│                                      │
│  All Types (47):                     │
│  ┌────────────────────────────────┐  │
│  │  [list of available types]     │  │
│  └────────────────────────────────┘  │
│                                      │
│  ┌────────────────────────────────┐  │
│  │  ➕ Create New Type            │  │
│  └────────────────────────────────┘  │
└──────────────┬───────────────────────┘
               │
    ┌──────────┴──────────┐
    │                     │
    ▼                     ▼
┌────────────────┐  ┌──────────────────────────────────────┐
│ EXISTING TYPE  │  │  NEW TYPE CREATION                   │
│ ────────────── │  │  ─────────────────────────────────   │
│ Skip to        │  │                                      │
│ Instance       │  │  Type Name: ___________________      │
│ Parameters     │  │                                      │
└───────┬────────┘  │  Type Photo (required, single):     │
        │           │  ┌──────┐                           │
        │           │  │ 📷   │                           │
        │           │  └──────┘                           │
        │           │                                      │
        │           │  Type Parameters (from Family):      │
        │           │  ┌────────────────────────────────┐  │
        │           │  │  Manufacturer: [Philips    ▼]  │  │
        │           │  │  Model: ___________________    │  │
        │           │  │  Wattage: [30W           ▼]    │  │
        │           │  │  Mount Type: [Ceiling    ▼]    │  │
        │           │  └────────────────────────────────┘  │
        │           │                                      │
        │           │  ⚠️ Similar types found:             │
        │           │  "Philips 30W LED" - Use instead?    │
        │           └──────────────┬───────────────────────┘
        │                          │
        └───────────┬──────────────┘
                    │
                    ▼
┌──────────────────────────────────────┐
│  INSTANCE PARAMETERS                 │
│  ─────────────────────────────────   │
│                                      │
│  Instance-specific data:             │
│  ┌────────────────────────────────┐  │
│  │  Serial Number: ____________   │  │
│  │  Condition: [Good        ▼]    │  │
│  │  Notes: ____________________   │  │
│  │         ____________________   │  │
│  └────────────────────────────────┘  │
│                                      │
│  * Required fields marked            │
│  * Instance photos optional (up to 5)│
└──────────────┬───────────────────────┘
               │
               ▼
       ┌───────────────┐
       │ All required  │──NO──→ Cannot save;
       │ fields filled?│       show validation
       └───────┬───────┘       errors
               │ YES
               ▼
┌──────────────────────────────────────┐
│  SAVE ASSET                          │
│  ─────────────────────────────────   │
│  • Asset saved locally               │
│  • Asset appears in room asset list  │
│  • Event logged for sync             │
│  • Return to room view               │
└──────────────────────────────────────┘
```

#### Wizard UI Notes (Latest UI)

- The Add Asset wizard includes a progress tracker (not-yet, current, completed states)
- Room Note is a first-class option in Family selection and routes to the Room Note form
- Room Note requires 1 mandatory main photo plus up to 4 optional photos
- The "+ New Type" action immediately opens the camera; the captured photo becomes the Type key image
- Naming a new Type is required when Type parameters change or a new Type is created
- Type photo is required and limited to a single image
- The Instance form can include up to 5 optional Instance photos

#### Type Selection Priority

When creating an asset, operators should follow this priority to maintain data consistency:

1. **Use an existing Type** — Maintains consistency; all Type data is pre-filled
2. **Duplicate and modify** — When a similar Type exists but differs in one parameter
3. **Create new Type** — Only when no similar Type exists

The fuzzy matching system actively suggests similar existing Types when operators enter Type names, helping prevent duplicate Type creation.

---

### 5.4 Export Generation Flow (Administrator)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       EXPORT GENERATION FLOW                                │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────┐
│   START      │
│  (Project    │
│  COMPLETED)  │
└──────┬───────┘
       │
       ▼
┌──────────────────────────────────────────┐
│  1. REVIEW SURVEY DATA                   │
│  ─────────────────────────────────       │
│  • View all assets instances in a list   │
│  • Identify any issues                   │
└──────────────┬───────────────────────────┘
               │
               ▼
       ┌───────────────┐
       │   Approve     │──NO──→ Return to operator
       │   quality?    │       for corrections
       └───────┬───────┘       (reopen if needed)
               │ YES
               ▼
┌──────────────────────────────────────┐
│  2. APPROVE PROJECT                  │
│  ─────────────────────────────────   │
│  • Confirm approval                  │
│  • Sequential IDs assigned           │
│  • State: COMPLETED → APPROVED       │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│  3. GENERATE EXPORT                  │
│  ─────────────────────────────────   │
│  • Select export format              │
│  • System generates files:           │
│    - Asset data (CSV/Excel)          │
│    - Photo archive (ZIP)             │
│  • Download package                  │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│  4. DELIVER TO CLIENT                │
│  ─────────────────────────────────   │
│  • Export package ready              │
│  • Sequential IDs are stable         │
│  • Re-exports produce same IDs       │
└──────────────┬───────────────────────┘
               │
               ▼
       ┌──────────────┐
       │     END      │
       └──────────────┘
```

---

### 5.5 Read-Only Mode (Completed Projects)

- Trigger: opening a project in the Completed state
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

---

### 5.6 Modals and Alerts

- Read-only warning when opening a Completed project
- Unsaved edits prompt with Discard/Save
- Delete confirmation modal for assets and room notes
- Wizard exit confirmation: warns that progress will be lost
- Room Note flags are mutually exclusive; selecting one deselects the other, and both can be "no"

---

## 6. System Architecture

### 6.1 Architecture Overview

The system follows a four-component architecture designed for offline-first operation with eventual consistency.

```
┌────────────────────────────────────────────────────────────────────────────┐
│                              CLOUD                                         │
│                                                                            │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                      SERVER BACKEND                                  │  │
│  │                                                                      │  │
│  │  ┌────────────────────────────────────────────────────────────────┐  │  │
│  │  │                        API Layer                               │  │  │
│  │  │            REST endpoints for all client operations            │  │  │
│  │  └────────────────────────────────────────────────────────────────┘  │  │
│  │                                                                      │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │  │
│  │  │    Sync     │  │    DXF      │  │    Type     │  │   Export    │  │  │
│  │  │   Engine    │  │ Processing  │  │ Normalizer  │  │  Generator  │  │  │
│  │  │             │  │             │  │             │  │             │  │  │
│  │  │ Event       │  │ Validation  │  │ Duplicate   │  │ CSV/Excel   │  │  │
│  │  │ sourcing    │  │ Room        │  │ detection   │  │ Photo       │  │  │
│  │  │ Ordering    │  │ extraction  │  │ Fuzzy       │  │ archive     │  │  │
│  │  │             │  │ Tile gen    │  │ matching    │  │ Sequential  │  │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  │ IDs         │  │  │
│  │                                                     └─────────────┘  │  │
│  │  ┌─────────────┐  ┌─────────────┐                                    │  │
│  │  │   Schema    │  │   Photo     │                                    │  │
│  │  │  Manager    │  │   Handler   │                                    │  │
│  │  │             │  │             │                                    │  │
│  │  │ Versioning  │  │ Upload      │                                    │  │
│  │  │ Validation  │  │ Processing  │                                    │  │
│  │  │ rules       │  │ Storage     │                                    │  │
│  │  └─────────────┘  └─────────────┘                                    │  │
│  └───────────────────────────┬──────────────────────────────────────────┘  │
│                              │                                             │
│  ┌───────────────────────────┴──────────────────────────────────────────┐  │
│  │                         STORAGE                                      │  │
│  │                                                                      │  │
│  │  ┌───────────────────────────┐    ┌───────────────────────────────┐  │  │
│  │  │        Database           │    │       File Storage            │  │  │
│  │  │       (PostgreSQL)        │    │        (S3/Blob)              │  │  │
│  │  │                           │    │                               │  │  │
│  │  │  • Projects               │    │  • DXF source files           │  │  │
│  │  │  • Schemas & versions     │    │  • Vector tiles               │  │  │
│  │  │  • Assets & events        │    │  • Type and Instance photos   │  │  │
│  │  │  • Types & instances      │    │  • Export archives            │  │  │
│  │  └───────────────────────────┘    └───────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────────────┘
                                       │
                                   INTERNET
                                       │
              ┌────────────────────────┴────────────────────────┐
              │                                                 │
┌─────────────┴─────────────┐               ┌───────────────────┴───────────────┐
│                           │               │                                   │
│      MOBILE APP           │               │         ADMIN DASHBOARD           │
│        (iOS)              │               │          (Web Browser)            │
│                           │               │                                   │
│  ┌─────────────────────┐  │               │  ┌─────────────────────────────┐  │
│  │   Local Storage     │  │               │  │      Web Application        │  │
│  │                     │  │               │  │                             │  │
│  │  • Project data     │  │               │  │  • Project management       │  │
│  │  • Event log        │  │               │  │  • DXF upload & validation  │  │
│  │  • Type and Instance photo queue │  │               │  │  • Schema management        │  │
│  │  • Tiles cache      │  │               │  │  • Progress monitoring      │  │
│  └─────────────────────┘  │               │  │  • Export generation        │  │
│                           │               │  └─────────────────────────────┘  │
│  ┌─────────────────────┐  │               │                                   │
│  │    UI Layer         │  │               └───────────────────────────────────┘
│  │                     │  │                         Administrator
│  │  • Floorplan viewer │  │
│  │  • Asset forms      │  │
│  │  • Photo capture    │  │
│  │  • Sync manager     │  │
│  └─────────────────────┘  │
│                           │
└───────────────────────────┘
        Field Operator
```

### 6.2 Component Responsibilities

| Component | Technology | Primary Responsibilities |
|-----------|------------|--------------------------|
| **Mobile App** | Swift/SwiftUI (iOS) | Field data collection, offline operation, photo capture, local storage |
| **Admin Dashboard** | Web (React/Vue) | Project configuration, monitoring, quality assurance, export generation |
| **Server Backend** | Node.js/Python | API services, sync engine, DXF processing, export generation |
| **Storage** | PostgreSQL + S3 | Persistent data storage, file storage, event log |

### 6.3 Offline-First Architecture

The mobile app maintains a complete local copy of project data, enabling full functionality without network connectivity.

**Local Storage Contents:**
- Complete project metadata
- All levels and room geometry
- Schema definition with all parameters
- All existing Types for the project
- Vector tiles for floorplan rendering
- Local event log (pending changes)
- Type and Instance photo queue (pending uploads)

**Synchronization Model:**
- Changes are recorded as events in a local log
- When online, events are pushed to server in order
- Server maintains authoritative event ordering
- Type and Instance photos upload asynchronously in background
- Sync is additive: offline work is never lost

---

### 6.4 Sync Behavior (Mobile)

- Sync attempts are triggered whenever an asset, room note, or type is created, modified, or deleted
- If a sync attempt fails, changes remain backed up locally and the device retries every 30 seconds
- After 10 consecutive failures, retry interval switches to every 5 minutes and continues indefinitely until successful
- Operators cannot manually trigger sync

---

## 7. Data Model

### 7.1 Core Concepts

#### Glossary

| Term | Definition |
|------|------------|
| **Family** | A category of assets sharing the same parameter structure (e.g., Lights, Radiators, Access Points) |
| **Type** | A specific product within a Family, defined by fixed parameter values (e.g., "Philips 30W LED Panel") |
| **Instance** | A single physical asset linked to a room, belonging to a Type |
| **Schema** | The complete set of Families, parameters, and validation rules for a project |
| **Schema Version** | An immutable snapshot of a schema, locked to a project |
| **Room Note** | A special asset type for notes, "no assets" markers, or "unreachable" flags |

#### Terminology and Conventions

- "Asset" always refers to a technical asset instance (never "product")
- App users are referred to as "operators"
- One asset can belong to one and only one room

### 7.2 Asset Hierarchy

The system follows a three-level asset hierarchy:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ASSET HIERARCHY                                     │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  FAMILY                                                                     │
│  ────────────────────────────────────────────────────────────────────────── │
│  Definition:  Category of assets with shared parameter structure            │
│  Created by:  Administrator only                                            │
│  Examples:    Lights, Radiators, Access Points, Outlets, Fire Extinguishers │
│                                                                             │
│  Defines:                                                                   │
│    • Type parameters (fields that describe the product)                     │
│    • Instance parameters (fields that describe each physical unit)          │
│    • Photo requirements (Type: exactly 1; Instance: optional up to 5)       │
│    • Validation rules for all parameters                                    │
│                                                                             │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │  TYPE                                                                  │ │
│  │  ────────────────────────────────────────────────────────────────────  │ │
│  │  Definition:  Specific product model within a Family                   │ │
│  │  Created by:  Administrator or Operator (in field)                     │ │
│  │  Examples:    "Philips 30W LED Panel", "Carrier 12000 BTU Split AC"    │ │
│  │                                                                        │ │
│  │  Contains:                                                             │ │
│  │    • Fixed values for all Type parameters                              │ │
│  │    • Manufacturer, model, specifications                               │ │
│  │    • Shared across all Instances of this Type                          │ │
│  │    • Photos of this type of asset                                      │ │
│  │                                                                        │ │
│  │  ┌──────────────────────────────────────────────────────────────────┐  │ │
│  │  │  INSTANCE                                                        │  │ │
│  │  │  ──────────────────────────────────────────────────────────────  │  │ │
│  │  │  Definition:  Single physical asset in a specific room           │  │ │
│  │  │  Created by:  Operator (in field)                                │  │ │
│  │  │  Examples:    "The specific lamp in Room 1001"                   │  │ │
│  │  │                                                                  │  │ │
│  │  │  Contains:                                                       │  │ │
│  │  │    • Reference to parent Type                                    │  │ │
│  │  │    • Room reference (room number)                                │  │ │
│  │  │    • Instance-specific parameters (serial, condition, notes)     │  │ │
│  │  │    • Inherits Type photo; may include up to 5 Instance photos     │  │ │
│  │  └──────────────────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.3 Spatial Hierarchy

```
PROJECT (Site)
    │
    ├── LEVEL (Floor)
    │       │
    │       ├── ROOM
    │       │     ├── Asset Instance
    │       │     ├── Asset Instance
    │       │     └── Asset Instance
    │       │
    │       ├── ROOM
    │       │     └── Asset Instance
    │       │
    │       └── ROOM
    │             └── Room Note (no assets)
    │
    └── LEVEL
            └── ROOM
                  └── Asset Instance
```

**Notes:**
- Room numbers are auto-assigned by spatial order (top-left to bottom-right) and use a 4-digit format: first digit is the floor number (lowest = 0), followed by a three-digit sequence within that floor (e.g., 2001)

### 7.4 Entity Relationship Model

```
┌──────────────┐       ┌──────────────┐       ┌──────────────┐
│   PROJECT    │       │    SCHEMA    │       │   SCHEMA     │
│              │       │   TEMPLATE   │       │   VERSION    │
│  project_id  │       │              │       │              │
│  name        │       │  template_id │       │  version_id  │
│  state       │◄──────│  name        │──────►│  template_id │
│  schema_     │       │  created_at  │       │  version_num │
│  version_id  │       └──────────────┘       │  created_at  │
└──────┬───────┘                              │  is_locked   │
       │                                      └──────┬───────┘
       │                                             │
       ▼                                             ▼
┌──────────────┐                              ┌──────────────┐
│    LEVEL     │                              │    FAMILY    │
│              │                              │              │
│  level_id    │                              │  family_id   │
│  project_id  │                              │  version_id  │
│  name        │                              │  name        │
│  geometry    │                              │  icon        │
│  north_angle │                              │  min_photos  │
└──────┬───────┘                              │  max_photos  │
       │                                      └──────┬───────┘
       │                                             │
       ▼                                             ▼
┌──────────────┐                              ┌──────────────┐
│     ROOM     │                              │  PARAMETER   │
│              │                              │  DEFINITION  │
│  room_id     │                              │              │
│  level_id    │                              │  param_id    │
│  name        │                              │  family_id   │
│  geometry    │                              │  name        │
│  status      │                              │  data_type   │
└──────┬───────┘                              │  is_required │
       │                                      │  scope (type/│
       │                                      │   instance)  │
       │                                      └──────────────┘
       │
       ▼
┌──────────────┐       ┌──────────────┐       ┌──────────────┐
│   INSTANCE   │       │     TYPE     │       │    PHOTO     │
│              │       │              │       │              │
│  instance_id │──────►│  type_id     │──────►│  photo_id    │
│  type_id     │       │  family_id   │       │  type_id     │
│  room_id     │       │  name        │       │  instance_id │
│  parameters  │       │  parameters  │       │  filename    │
│  (JSON)      │       │  (JSON)      │       │  captured_at │
│  created_at  │       └──────────────┘       │  uploaded    │
└──────────────┘                              └──────────────┘
```

**Note:** `PHOTO` can reference either a `type_id` (Type photo) or an `instance_id` (Instance photo). Exactly one reference is set.

### 7.5 Parameter System

Parameters are defined at the Family level and can be scoped to either Type or Instance:

| Scope | Description | Example |
|-------|-------------|---------|
| **Type Parameter** | Describes the product model; same for all instances | Manufacturer, Model, Wattage |
| **Instance Parameter** | Describes the specific physical unit | Serial Number, Condition, Installation Date |

Photos can be Type-scoped and optionally Instance-scoped. Instances inherit the Type photo and may store up to 5 optional Instance photos.

**Parameter Attributes:**

| Attribute | Description |
|-----------|-------------|
| `name` | Display name of the parameter |
| `data_type` | String, Number, Boolean, Enum, Date |
| `is_required` | Whether field must be filled to save |
| `scope` | "type" or "instance" |
| `enum_values` | For Enum type: list of valid options |
| `validation` | Additional rules (min/max, regex, etc.) |
| `unit` | Unit of measurement (W, m, °C, etc.) |

---

### 7.6 Form Fields and Validation

- Supported field types: text, number, photos, dropdown, toggles, dates
- Field composition is defined by the project schema in the backend
- All fields in the Type Form are mandatory
- Instance Form fields can be mandatory or optional, as defined by the schema
- Validation errors appear inline during entry
- When the operator attempts to save, any missing mandatory fields turn red

---

## 8. Functional Requirements

### 8.1 Mobile Application Requirements

#### FR-M01: Project Download
- App shall display a list of available projects (state: READY)
- App shall provide project search and filters (e.g., location/status)
- App shall display per-project sync status indicators
- App shall show Settings and Import buttons on the Projects page as placeholders for future functionality
- App shall show the empty state message "No project assigned" when the list is empty
- App shall display project cards with name, image, location, number of rooms, and number of assets
- App shall display project states (Online, Open, Completed) with distinct label text and background colors
- App shall show a loading screen while downloading a project after selection
- App shall open Completed projects in read-only mode with a warning popup
- App shall download complete project data including floorplan tiles, schema, and existing Types
- App shall store project data locally for offline access
- App shall update project state to ACTIVE upon successful download

#### FR-M02: Floorplan Navigation
- App shall display vector-rendered floorplan with pan and zoom gestures
- App shall support level switching via a bottom-right drop-up picker
- App shall display room boundaries with status indicators (empty vs with assets or room notes)
- App shall render empty rooms in halftone gray with a (+) button inside
- App shall render rooms with assets or room notes in light blue with a count badge (assets + room notes)
- App shall display room names and numbers directly on the floorplan
- App shall allow room selection by tapping within the room boundary
- App shall provide an Exit control that opens pause/complete options
- App shall provide Survey Report access via a hamburger control
- App shall display sync status states (syncing, synced, failed) with a tap-to-view message

#### FR-M03: Asset Creation
- App shall allow asset creation by selecting a room on the floorplan
- App shall present Family selection from schema-defined families, including Room Note
- App shall show a progress tracker for the Add Asset wizard
- App shall present Type selection with search and create-new options
- App shall allow the Add Asset search bar to match Family names and Type names
- App shall keep Room Note available at all times; if a room contains assets, Room Note flags are disabled
- App shall launch the camera when creating a new Type and use the captured photo as the Type key image
- App shall perform fuzzy matching against existing Types when creating or renaming a Type
- App shall display Type parameter form for new Type creation or modification
- App shall proceed directly to the Instance form when an existing Type is selected and unmodified
- App shall prompt for a new Type name when Type parameters change inside the Add Asset wizard
- App shall ensure branched Types do not modify the original Type and are used only for the new asset
- App shall display Instance parameter form with validation and optional Instance photos (up to 5)
- App shall enforce required field completion before save
- App shall capture exactly one required Type photo
- App shall warn that wizard progress will be lost when exiting mid-way

#### FR-M04: Photo Capture
- App shall capture Type photos and optional Instance photos using the device camera
- App shall compress Type and Instance photos to JPEG with a longest edge of 1280px and quality 0.8
- App shall assign a globally unique filename at capture time
- App shall store Type and Instance photos locally with an upload queue
- App shall enforce a single required Type photo before saving a new Type
- App shall allow optional Instance photos up to 5 per asset

#### FR-M05: Offline Operation
- App shall function fully without network connectivity
- App shall log all changes as events in local storage
- App shall queue Type and Instance photos for background upload
- App shall indicate sync status to the operator

#### FR-M06: Synchronization
- App shall detect network availability
- App shall upload pending events when online
- App shall upload queued Type and Instance photos in the background
- App shall display sync progress and status
- App shall attempt sync automatically after asset, Room Note, or Type create/update/delete events
- App shall retry failed syncs every 30 seconds, switching to every 5 minutes after 10 consecutive failures
- App shall not provide a manual sync trigger

#### FR-M07: Survey Completion
- App shall validate that all rooms have at least one asset or Room Note
- App shall display an exit pop-up with "Pause Survey" and "Complete Survey"
- App shall display a report of empty rooms if validation fails and provide a shortcut to the filtered Rooms list
- App shall require a "Slide to complete" confirmation when all rooms are addressed
- App shall consider a room complete when it contains at least one asset or one Room Note
- App shall change project state to COMPLETED upon confirmation
- App shall make project read-only after completion

#### FR-M08: Survey Report
- App shall provide a Survey Report hub with Rooms and Types lists
- Rooms list shall support search, level grouping, and filters for room and asset types
- Types list shall support search, Family filtering, Type parameter filtering, and instance counts
- App shall allow navigation to Room view and Add Asset from the Rooms list

#### FR-M09: Editing Widgets
- App shall open an Instance Editor Widget from the Room view list
- Instance edits shall support Reset/Save and prompt on unsaved changes
- App shall open an Edit Type widget for Type-level edits and apply changes to all linked instances
- Edit Type changes from the Survey Report shall update the existing Type (no duplication)

#### FR-M10: Project Export (Mobile)
- App shall generate a project export file on demand and show progress
- App shall present the iOS share sheet when the export is ready
- App shall treat export as a backup mechanism if synchronization fails

### 8.2 Admin Dashboard Requirements

#### FR-A01: Project Creation
- Dashboard shall allow creation of new projects with a name and description
- Dashboard shall display project list with status indicators
- Dashboard shall allow project state management

#### FR-A02: DXF Upload and Validation
- Dashboard shall accept DXF file uploads
- Dashboard shall validate DXF against required structure (see Section 9.3)
- Dashboard shall display validation report with specific errors if validation fails
- Dashboard shall extract levels and rooms from valid DXF
- Dashboard shall generate vector tiles for mobile rendering

#### FR-A03: Schema Management
- Dashboard shall display available schema templates
- Dashboard shall allow schema template creation/editing
- Dashboard shall create immutable schema versions
- Dashboard shall lock a schema version to a project

#### FR-A04: Progress Monitoring
- Dashboard shall display real-time survey progress
- Dashboard shall show completion percentage by level and room
- Dashboard shall display asset counts by family
- Dashboard shall show sync status for active projects

#### FR-A05: Export Generation
- Dashboard shall generate CSV/Excel exports of all asset data
- Dashboard shall generate a ZIP archive of all photos
- Dashboard shall assign sequential IDs on first export
- Dashboard shall maintain stable IDs for re-exports

### 8.3 Backend Requirements

#### FR-B01: API Services
- Backend shall provide a REST API for all client operations
- Backend shall handle authentication (future: MVP has open access)
- Backend shall validate all incoming data against the schema

#### FR-B02: Sync Engine
- Backend shall receive events from mobile clients
- Backend shall order events by timestamp
- Backend shall store events for audit trail
- Backend shall support event compaction for storage management

#### FR-B03: DXF Processing
- Backend shall validate uploaded DXF files
- Backend shall extract level and room geometry
- Backend shall identify north vectors per level
- Backend shall generate vector tiles for mobile rendering

#### FR-B04: Type Management
- Backend shall store and serve Type definitions
- Backend shall support Type search with fuzzy matching
- Backend shall detect potential duplicate Types

#### FR-B05: Export Generation
- Backend shall generate structured data exports
- Backend shall assign sequential IDs following Level → Room → Asset order
- Backend shall store assigned IDs for consistency
- Backend shall package photos with consistent naming

---

## 9. Technical Specifications

### 9.1 Coordinate System

All floorplan and room geometry use a "Plan Space" coordinate system. Asset instances are linked to rooms and do not store X/Y coordinates.

| Property | Specification |
|----------|---------------|
| **Origin** | North vector start point for each level |
| **Axes** | X/Y aligned with CAD axes |
| **Units** | Meters |
| **North Angle** | Stored per level for orientation |

### 9.2 ID Strategy

| ID Type | Format | Purpose |
|---------|--------|---------|
| **Internal ID** | UUIDv7 | All entities (projects, levels, rooms, types, instances, photos, events) |
| **Export ID** | Sequential integer | Client-facing IDs assigned at first export |
| **Photo Name** | `{project_short}_{operator_id}_{timestamp}_{sequence}.jpg` | Globally unique, assigned at capture |

**UUIDv7 Benefits:**
- Time-sortable (embeds timestamp)
- Globally unique without coordination
- Efficient generation on mobile devices
- Supports event ordering

**Export ID Assignment Rules:**
1. IDs generated only at first export (project state: APPROVED)
2. Assignment order: Level → Room → Asset creation timestamp
3. Once assigned, IDs are permanent and stored
4. Re-exports use same IDs; new assets get next sequential numbers

### 9.3 DXF Validation Rules

On upload, the system validates the DXF file against these requirements:

| Rule | Description |
|------|-------------|
| **Required Layers** | Specific layers must exist for levels, rooms, and north vectors |
| **Level Boundaries** | Each level must have a closed polyline boundary |
| **North Vector** | Each level must have a north vector starting inside the level boundary |
| **Room Regions** | All room filled regions must be inside a level boundary |
| **Room Labels** | Room name text (optional) must be inside the room region |
| **Level Labels** | Level name text must be inside the level boundary |

**Required Layer Names (exact):**
- `0` - Background linework (walls, doors, windows). Render-only; not semantically parsed.
- `1_ROOMS` - Closed room boundary polylines. Room label text is optional.
- `2_LEVEL` - Closed level boundary polylines. Must include a text label inside each level.
- `3_NORTH` - One line segment per level: start point inside the level boundary, end point indicates north direction.

**Room Labels (optional):**
- If present, label text is used as the room name only.
- If absent, the system assigns a default name (e.g., `Room 0001`).

**Room Numbering Convention:** Room numbers are auto-assigned during import based on spatial order (top-left to bottom-right) within each level. The format is four digits: first digit is the level index (lowest = 0), and the remaining three digits are the sequence within that level.

**Validation Failure:** If any rule fails, the DXF must be corrected and re-uploaded. The project cannot proceed until the floorplan passes validation.

### 9.4 Photo Specifications

| Property | Specification |
|----------|---------------|
| **Format** | JPEG |
| **Resolution** | Longest edge 1280px |
| **Quality** | 0.8 compression |
| **Min per Type** | 1 (required) |
| **Max per Type** | 1 |
| **Min per Instance** | 0 (optional) |
| **Max per Instance** | 5 |
| **Reuse** | Type photos are shared across instances; Instance photos are per-instance |
| **Naming** | Globally unique, assigned at capture, unchanged through export |

Each Type requires exactly one photo. Instance photos are optional and limited to 5 per asset.

### 9.5 Scale Constraints

| Dimension | Limit | Notes |
|-----------|-------|-------|
| **Assets per Project** | 10,000 | Soft limit |
| **Photos per Device** | ~1,000 | Storage management |
| **Photos per Year (Cloud)** | 1,000,000 | Cost controls |
| **Rooms per Level** | No fixed limit | Constrained by DXF |
| **Levels per Project** | No fixed limit | Constrained by DXF |

### 9.6 Project Lifecycle States

| State | Description | Available Actions |
|-------|-------------|-------------------|
| **DRAFT** | Being configured | Edit settings, upload DXF, select schema |
| **READY** | Configuration complete | Download to mobile, edit settings |
| **ACTIVE** | Survey in progress | Sync data, monitor progress |
| **COMPLETED** | Survey finished | Review data, approve or return for corrections |
| **APPROVED** | Admin approved | Generate exports |
| **ARCHIVED** | Long-term storage | View only |

**State Transitions:**
```
DRAFT → READY → ACTIVE → COMPLETED → APPROVED → ARCHIVED
                  ↑           │
                  └───────────┘
                (return for corrections)
```

**Mobile UI State Labels:** READY = Online, ACTIVE = Open, COMPLETED = Completed.

### 9.7 Event Sourcing Model

The sync system uses an event log pattern:

**Event Types:**
- `INSTANCE_CREATED` — New asset instance created in a room
- `INSTANCE_UPDATED` — Instance parameters modified
- `INSTANCE_DELETED` — Instance removed
- `TYPE_CREATED` — New Type defined
- `TYPE_UPDATED` — Type parameters modified
- `PHOTO_ATTACHED` — Photo linked to Type or Instance
- `ROOM_STATUS_CHANGED` — Room marked empty/with assets

**Event Structure:**
```json
{
  "event_id": "uuid-v7",
  "event_type": "INSTANCE_CREATED",
  "timestamp": "2025-12-15T14:30:00Z",
  "project_id": "uuid",
  "payload": { ... },
  "device_id": "uuid",
  "operator_id": "uuid"
}
```

**Benefits:**
- Complete audit trail
- Offline-first compatibility
- Potential for undo (future)
- Event compaction for storage management

### 9.8 Repository Structure

```
anagrafica-tecnica/
├── app/                          # iOS mobile application
│   ├── AnagraficaTecnica/
│   │   ├── Models/              # Data models
│   │   ├── Views/               # SwiftUI views
│   │   ├── ViewModels/          # View models
│   │   ├── Services/            # Business logic
│   │   │   ├── SyncService/     # Synchronization
│   │   │   ├── StorageService/  # Local storage
│   │   │   └── PhotoService/    # Photo capture/management
│   │   └── Resources/           # Assets, localization
│   └── Tests/
│
├── admin-dashboard/              # Web admin application
│   ├── src/
│   │   ├── components/          # UI components
│   │   ├── pages/               # Page components
│   │   ├── services/            # API clients
│   │   └── store/               # State management
│   └── tests/
│
├── backend/                      # Server application
│   ├── src/
│   │   ├── api/                 # REST endpoints
│   │   ├── sync/                # Event sourcing engine
│   │   ├── dxf-processing/      # DXF validation and tile generation
│   │   ├── schema/              # Parameter catalogue management
│   │   ├── export/              # Export generation
│   │   └── storage/             # Database and file storage
│   └── tests/
│
├── database/                     # Database management
│   ├── migrations/              # Schema migrations
│   └── seeds/                   # Test data
│
├── shared/                       # Shared code
│   ├── types/                   # TypeScript type definitions
│   ├── schemas/                 # Validation schemas
│   └── constants/               # Shared constants
│
├── docs/                         # Documentation
└── scripts/                      # Development and deployment
```

---

## 10. Appendices

### Appendix A: Handling Rooms Without Assets

When an operator encounters a room that legitimately has no assets to record, they must add a Room Note with an appropriate reason:

| Situation | Action Required |
|-----------|-----------------|
| **No assets to register** | Add Room Note + set "Empty room" = yes + optional description |
| **Room unreachable / blocked** | Add Room Note + set "Room is blocked" = yes + required description |

This ensures every room is explicitly addressed, preventing accidental omissions.

Room Note form includes read-only Level/Room, 1 mandatory main photo plus up to 4 optional photos, and the two mutually exclusive boolean fields; both booleans can be "no" when used as a general note.

### Appendix B: Type Creation Guidelines

When creating assets, operators should follow this priority:

1. **Use existing Type** — Maintains consistency; fastest option
2. **Duplicate and modify** — When a similar Type exists but one parameter differs
3. **Create new Type** — Only when no similar Type exists

The fuzzy matching system suggests existing Types when operators type a new name, helping prevent duplicates.

### Appendix C: Photo Naming Convention

Photos receive a globally unique name at capture time that remains unchanged through export:

**Format:** `{project_short}_{operator_id}_{timestamp}_{sequence}.jpg`

**Example:** `PRJ001_OP42_20251215143022_001.jpg`

This ensures:
- No duplicate names across projects
- Traceability to source project and operator
- Consistent naming from capture through client delivery

### Appendix D: Locked Rooms

- A room is annotated as "locked" when the operator cannot physically access it (Room Note with "Room is blocked" = yes)
- If access becomes available later, the operator deletes the locked Room Note and adds assets normally

---

*End of Specification*
