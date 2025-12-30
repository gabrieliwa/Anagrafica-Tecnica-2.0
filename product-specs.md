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

Anagrafica Tecnica is an end-to-end platform for performing technical asset inventories in buildings. It combines an offline-first field application (for on-site operators), a backend/server (for synchronization, storage, validation, and integrations), and a web-based administration dashboard (for configuration, QA, review, and export). Together, these components allow teams to catalog technical equipment—such as lighting fixtures, HVAC components, network infrastructure, and electrical systems—reliably on-site, even with intermittent or no connectivity.

The platform addresses a key facility-management gap: producing accurate, structured, and verifiable asset data directly from the field, while keeping processes standardized across technicians and projects. Data is captured where it happens, validated against project rules (required fields, controlled vocabularies, anomaly flags), and synchronized when connectivity is available. The admin dashboard provides oversight and governance—templates, asset schemas, progress tracking, QA workflows, and delivery packages—ensuring consistent outputs that can be trusted and reused in downstream systems (e.g., CAFM/CMMS, BIM, reporting).

### 1.1 Key Value Propositions

| Value | Description |
|-------|-------------|
| **Offline-First Operation** | Full functionality without network connectivity, with automatic synchronization when online |
| **Spatial Context** | Interactive floorplan navigation ensures assets are accurately placed and easily located |
| **Data Quality at Source** | Validation rules and required fields prevent incomplete or incorrect data entry |
| **Standardized Taxonomy** | Family → Type → Instance hierarchy ensures consistent asset classification |
| **Configurable Schemas** | Project-specific asset schemas (fields, validation rules, controlled vocabularies, and photo requirements) enable consistent data capture across different building types and clients |
| **Photo Documentation** | Configurable photo requirements provide visual verification of each asset |
| **Export-Ready Deliverables** | Structured data exports (CSV/Excel) with organized photo archives for client delivery |

### 1.2 Scope

This specification defines the Minimum Viable Product (MVP), a proof-of-concept designed to demonstrate and validate core functionality with a single operator workflow.

---

## 2. Problem Statement

### 2.1 The Challenge

Facility managers, building owners, and service providers frequently need accurate inventories of technical assets within buildings. These inventories are essential for:

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
| **Connectivity dependency** | Building interiors often have poor or no cellular/WiFi signal, forcing operators to defer data entry |
| **Context switching** | Operators must juggle multiple tools (camera, notepad, phone) while navigating buildings |
| **Photo-data disconnection** | Photos taken separately from data entry become orphaned or mislabeled |
| **Completion uncertainty** | No systematic way to verify all rooms have been surveyed |

#### Post-Survey Problems

| Problem | Impact |
|---------|--------|
| **Manual data consolidation** | Hours spent transferring handwritten notes to digital formats |
| **Photo organization** | Matching hundreds of photos to corresponding asset records |
| **Quality assurance gaps** | Discovering missing data only after leaving the site |
| **Inconsistent deliverables** | Each project produces slightly different output formats |

### 2.3 The Cost of the Status Quo

These inefficiencies translate directly to business costs: return site visits to collect missing data, extended project timelines, and inability to leverage survey data for analytics or automation. Organizations conducting regular asset surveys need a purpose-built solution that addresses these challenges systematically.

---

## 3. Solution Overview

### 3.1 Product Vision

In technical surveys, the floorplan has always been central; Anagrafica Tecnica makes it structured and operational—turning a static backdrop into a BIM-like spatial model that drives capture, organization, and verification.

Instead of “dumb” collection (room lists, unstructured notes, photo folders), operators record assets as objects anchored to spaces, classified via Family → Type → Instance and guided by configurable schemas (fields, rules, vocabularies, photo requirements). This enforces data quality at capture (validation + required fields) and produces consistent, verifiable, export-ready data for QA, reporting, and downstream systems—fully offline with automatic sync when online.

### 3.2 Core Capabilities

#### Mobile Application (iOS)

The mobile app serves as the primary tool for field operators, designed for single-handed operation while moving through buildings.

**Key Features:**
- Interactive floorplan with map-style pan, zoom, and navigation
- Tap-to-place asset markers directly on the plan
- Structured data entry forms with field validation
- Integrated photo capture (1-5 photos per asset, configurable by asset family)
- On-device fuzzy matching to suggest existing Types and prevent duplicates
- Room-by-room progress tracking with visual indicators
- Offline first operation with automatic sync

#### Admin Dashboard (Web)

The web dashboard provides project management, configuration, and quality assurance capabilities for administrators.

**Key Features:**
- Project creation and configuration wizard
- DWG floorplan upload with automated validation
- Asset family and parameter schema management
- Real-time survey progress monitoring
- Data quality metrics and alerts
- Export generation (CSV/Excel with organized photo archives)

#### Server Backend

The backend provides data management, processing, and integration services.

**Key Features:**
- Event-sourced synchronization engine
- DWG processing pipeline (room extraction, vector tile generation)
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
| **Visual verification** | Photo requirements ensure assets are documented, not just recorded |
| **Complete coverage** | Survey cannot be marked complete until every room is addressed |

---

## 4. User Personas

### 4.1 Field Operator

**Profile:** Technical surveyor who physically visits buildings to catalog assets.

| Attribute | Description |
|-----------|-------------|
| **Environment** | On-site in buildings, often in challenging conditions (poor lighting, restricted access, no connectivity) |
| **Device** | iPhone, operated primarily one-handed while carrying equipment |
| **Goals** | Complete accurate surveys efficiently; minimize return visits |
| **Pain points** | Connectivity issues, data re-entry, forgetting rooms, in devioce storage, battery life |

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
    │  Configuartion of Project Parameters:  │
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
    │  2. UPLOAD FLOORPLAN (DWG)           │
    │  ─────────────────────────────────   │
    │  • Select DWG file                   │
    │  • System validates file structure   │
    │  • Extracts levels and rooms         │
    │  • Generates vector tiles            │
    │  • Numbers room                      │
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
│ → Fix DWG and     │  │  • Schema locked to project               │
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
- Configures project parameters, such as Name, Client, Location and other basic setting, then adds an image
- Project is created in DRAFT state

**Step 2: Upload Floorplan**
- Administrator uploads the DWG file containing building geometry
- System performs automated validation (see Section 9.3 for validation rules)
- On success: rooms, levels, and spatial data are extracted; vector tiles are generated
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
│  • Project data & tiles is Downloaded  │
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
│  • View room status + asset add botton │
└───────────────┬────────────────────────┘
 ▲              │
 │              ▼
 │  ┌────────────────────────────────────┐
 │  │  3. ADD ASSET                      │
 │  │  ──────────────────────────────    │
 │  │  • Tap the add botton              │
 │  │  • Select asset Family             │
 │  │  • Search/select existing Type     │
 │  │    OR create new Type              │
 │  │  • Fill instance parameters        │
 │  │  • Capture required photos         │
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
- Operator opens the mobile app and views available projects (state: READY)
- Selects a project and opens it. Download of the project is initianted
- App downloads complete project data: floorplan tiles, room geometry, schema, existing types
- Project state changes to ACTIVE; operator can now work fully offline

**Step 2: Navigate to Room**
- Operator views the interactive floorplan
- Uses familiar gestures: pinch to zoom, drag to pan
- Floating on top of the floorplan are:
  1. Top left a Level picker allowing switching between floors
  2. Top center the project name
  3. Top right a (↑↓) icon showing sync status with server
  4. Bottom left (⌂) lets the operator leave the project and come back to the project list
  5. Bottom right (☰) goes to the "Survey Report" page
- Rooms are color-coded by status: empty (gray), with assets (celeste)
- In the centroid of each celeste room a circle contains the number of assets present in the room
- In the centroid of each grey room a circle contains an add (+) sign
- Operator taps on the room he is phisically in -> Everything outside the room's boundary is halftoned:
  1. If the room is empty an asset creatin wizard is directly deployd
  2. If the room contains assets a "room view" is opened:
       - Zoom and pan no longer work. The background is fixed on the room outline
       - In the center top of the screen is a text showing level and room numer
       - In the bottom half of the screen, floating over the floorplan is the asset list relative to the selected room
       - An "add asset" (+) botton appears bottom center of the screen

**Step 3: Add Asset**
- Operator taps on the add asset botton (+) in the bottom center of the screen
- Asset creation wizard (editor) opens
- First page is the Family selection (e.g., Lights, Radiators, Access Points)
- Secondo page is the Type selector which offers two options:
  1. Select existing Type from searchable list:
       - Third page is type parameters form
       - In this case all type parameters are pre-filled (picture included), but user can edit them (and retake the picture)
       - If any type parameter is changed a new type is created
       - Before navigating to page four the operator is promped to name the new type (suggested name is = old type name + "2", "3"...)
       - Fuzzy matching suggests similar existing Types to prevent duplicates
  2. Create new Type from scratch
       - On tap the camera launches to take a picture of the new asset type
       - Photo capture interface enforces minimum photo requirements
       - After picture is taken the third page opens, and is always the parameters form
       - In this case all type parameters fields are empty
       - After filling all necessary type parameters and trying to navigate to forth page the operator is promped to name the new type
       - Fuzzy matching suggests similar existing Types to prevent duplicates
- Forth page is the instance parameter form, displaying fields defined by the Family schema
- Some instance parameters are pre-filled and uneditable (e.g. Level, Room...)
- Required fields must be completed; validation prevents saving incomplete data
- Asset is saved locally and appears in the room's assets list

**Step 4: Asset Editing Inside Room View**
- When inside a "room view" the operator can interact with assets in the rooms' list
- By tapping on an asset a card appears displaying assets details
- By sliding the asset to the right and edit button appears
- If tapped a form dispaying type and instance parameters appears letting the operator edi them
- If type parameters are changed the operator is promped to save the new type (fuzzy matching is applied here as well)
- By sliding the asset to the left a delete botton appears, if tapped the operator is promped again before deletion.

**Step 5: Survey Report Page**
- When in the interactive plan view the operator can tap the bottom right (☰) botton entering the "Survey Report" Page
- This page contains a searchable list of room, grouped by level, and a searchable list of asset types, grouped by family
- By default the "Survey Report" Page opens in the room list
- In the botton of the screen, floating on top of the shown list are three bottons:
  1. First on the left is the link to the rooms list
  2. Center is the link to the types list
  3. On the right is the botton to trigger an emergency export of the project

**Step 6: Complete Survey**
- Operator taps (⌂) on the bottom left of the screen when finished
- The app prompts if he would like to complete the Survey or to Pause it:
  1. Operators taps on "Pause survey"
       - He goes back to the main project list 
       - he can come back any time inside the project to resume the survey
  2. Operators taps on "Complete survey"
       - System validates that every room has at least one asset or annotation
       - If rooms are empty, a report displays all unaddressed rooms
       - For legitimately empty rooms, operator must add an Annotation asset with reason
       - Once all rooms are addressed, operator confirms completion
       - Project state changes to COMPLETED; becomes read-only on device and cannot be edited any more

**Step 7: Final Sync**
- When network is available, all remaining events and photos sync to server
- Progress indicator shows upload status
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
[Asset creation wizard opens]
         │
         ▼
┌──────────────────────────────────────┐
│  SELECT FAMILY                       │
│  ─────────────────────────────────   │
│  • List of asset families            │
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
└───────┬────────┘  │  Type Parameters (from Family):      │
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
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│  PHOTO CAPTURE                       │
│  ─────────────────────────────────   │
│                                      │
│  Photos (2 of 3 minimum):            │
│  ┌──────┐ ┌──────┐ ┌──────┐         │
│  │ 📷   │ │ 📷   │ │  +   │         │
│  │ IMG1 │ │ IMG2 │ │ Add  │         │
│  └──────┘ └──────┘ └──────┘         │
│                                      │
│  ⚠️ 1 more photo required            │
│                                      │
│  ┌────────────────────────────────┐  │
│  │        📷 Take Photo           │  │
│  └────────────────────────────────┘  │
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
│  • Marker appears on floorplan       │
│  • Event logged for sync             │
│  • Return to floorplan view          │
└──────────────────────────────────────┘
```

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
│                       EXPORT GENERATION FLOW                                 │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────┐
│   START      │
│  (Project    │
│  COMPLETED)  │
└──────┬───────┘
       │
       ▼
┌──────────────────────────────────────┐
│  1. REVIEW SURVEY DATA               │
│  ─────────────────────────────────   │
│  • View all assets on floorplan      │
│  • Review data quality metrics       │
│  • Check completion statistics       │
│  • Identify any issues               │
└──────────────┬───────────────────────┘
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

## 6. System Architecture

### 6.1 Architecture Overview

The system follows a four-component architecture designed for offline-first operation with eventual consistency.

```
┌────────────────────────────────────────────────────────────────────────────┐
│                              CLOUD                                          │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐ │
│  │                      SERVER BACKEND                                    │ │
│  │                                                                        │ │
│  │  ┌────────────────────────────────────────────────────────────────┐   │ │
│  │  │                        API Layer                                │   │ │
│  │  │            REST endpoints for all client operations             │   │ │
│  │  └────────────────────────────────────────────────────────────────┘   │ │
│  │                                                                        │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │ │
│  │  │    Sync     │  │    DWG      │  │    Type     │  │   Export    │   │ │
│  │  │   Engine    │  │ Processing  │  │ Normalizer  │  │  Generator  │   │ │
│  │  │             │  │             │  │             │  │             │   │ │
│  │  │ Event       │  │ Validation  │  │ Duplicate   │  │ CSV/Excel   │   │ │
│  │  │ sourcing    │  │ Room        │  │ detection   │  │ Photo       │   │ │
│  │  │ Ordering    │  │ extraction  │  │ Fuzzy       │  │ archive     │   │ │
│  │  │             │  │ Tile gen    │  │ matching    │  │ Sequential  │   │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  │ IDs         │   │ │
│  │                                                      └─────────────┘   │ │
│  │  ┌─────────────┐  ┌─────────────┐                                     │ │
│  │  │   Schema    │  │   Photo     │                                     │ │
│  │  │  Manager    │  │   Handler   │                                     │ │
│  │  │             │  │             │                                     │ │
│  │  │ Versioning  │  │ Upload      │                                     │ │
│  │  │ Validation  │  │ Processing  │                                     │ │
│  │  │ rules       │  │ Storage     │                                     │ │
│  │  └─────────────┘  └─────────────┘                                     │ │
│  └───────────────────────────┬───────────────────────────────────────────┘ │
│                              │                                              │
│  ┌───────────────────────────┴───────────────────────────────────────────┐ │
│  │                         STORAGE                                        │ │
│  │                                                                        │ │
│  │  ┌───────────────────────────┐    ┌───────────────────────────────┐   │ │
│  │  │        Database           │    │       File Storage            │   │ │
│  │  │       (PostgreSQL)        │    │        (S3/Blob)              │   │ │
│  │  │                           │    │                               │   │ │
│  │  │  • Projects               │    │  • DWG source files           │   │ │
│  │  │  • Schemas & versions     │    │  • Vector tiles               │   │ │
│  │  │  • Assets & events        │    │  • Asset photos               │   │ │
│  │  │  • Types & instances      │    │  • Export archives            │   │ │
│  │  └───────────────────────────┘    └───────────────────────────────┘   │ │
│  └───────────────────────────────────────────────────────────────────────┘ │
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
│  │  • Event log        │  │               │  │  • DWG upload & validation  │  │
│  │  • Photo queue      │  │               │  │  • Schema management        │  │
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
| **Server Backend** | Node.js/Python | API services, sync engine, DWG processing, export generation |
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
- Photo queue (pending uploads)

**Synchronization Model:**
- Changes are recorded as events in a local log
- When online, events are pushed to server in order
- Server maintains authoritative event ordering
- Photos upload asynchronously in background
- Sync is additive: offline work is never lost

---

## 7. Data Model

### 7.1 Core Concepts

#### Glossary

| Term | Definition |
|------|------------|
| **Family** | A category of assets sharing the same parameter structure (e.g., Lights, Radiators, Access Points) |
| **Type** | A specific product within a Family, defined by fixed parameter values (e.g., "Philips 30W LED Panel") |
| **Instance** | A single physical asset placed in a specific location, belonging to a Type |
| **Schema** | The complete set of Families, parameters, and validation rules for a project |
| **Schema Version** | An immutable snapshot of a schema, locked to a project |
| **Annotation** | A special asset type for notes, "no assets" markers, or "unreachable" flags |

### 7.2 Asset Hierarchy

The system follows BIM (Building Information Modeling) conventions with a three-level hierarchy:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ASSET HIERARCHY                                      │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  FAMILY                                                                      │
│  ────────────────────────────────────────────────────────────────────────── │
│  Definition:  Category of assets with shared parameter structure             │
│  Created by:  Administrator only                                             │
│  Examples:    Lights, Radiators, Access Points, Outlets, Fire Extinguishers │
│                                                                              │
│  Defines:                                                                    │
│    • Type parameters (fields that describe the product)                     │
│    • Instance parameters (fields that describe each physical unit)          │
│    • Photo requirements (min/max photos per instance)                       │
│    • Validation rules for all parameters                                    │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │  TYPE                                                                   │ │
│  │  ──────────────────────────────────────────────────────────────────── │ │
│  │  Definition:  Specific product model within a Family                   │ │
│  │  Created by:  Administrator or Operator (in field)                     │ │
│  │  Examples:    "Philips 30W LED Panel", "Carrier 12000 BTU Split AC"   │ │
│  │                                                                         │ │
│  │  Contains:                                                              │ │
│  │    • Fixed values for all Type parameters                              │ │
│  │    • Manufacturer, model, specifications                               │ │
│  │    • Shared across all Instances of this Type                          │ │
│  │                                                                         │ │
│  │  ┌──────────────────────────────────────────────────────────────────┐  │ │
│  │  │  INSTANCE                                                         │  │ │
│  │  │  ────────────────────────────────────────────────────────────── │  │ │
│  │  │  Definition:  Single physical asset at a specific location        │  │ │
│  │  │  Created by:  Operator (in field)                                 │  │ │
│  │  │  Examples:    "The specific lamp in Room 101 at position X,Y"    │  │ │
│  │  │                                                                   │  │ │
│  │  │  Contains:                                                        │  │ │
│  │  │    • Reference to parent Type                                    │  │ │
│  │  │    • Location (room + X,Y coordinates)                           │  │ │
│  │  │    • Instance-specific parameters (serial, condition, notes)     │  │ │
│  │  │    • Photos of this specific asset                               │  │ │
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
    │             └── Annotation (no assets)
    │
    └── LEVEL
            └── ROOM
                  └── Asset Instance
```

**Notes:**
- There is no separate Building entity in the MVP
- For multi-building projects, floors are named to include building (e.g., "Building A - Floor 1")
- An optional "Building" layer in the DWG can group levels for UI navigation

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
│  instance_id │──────►│  type_id     │       │  photo_id    │
│  type_id     │       │  family_id   │       │  instance_id │
│  room_id     │       │  name        │       │  filename    │
│  position_x  │       │  parameters  │       │  captured_at │
│  position_y  │       │  (JSON)      │       │  uploaded    │
│  parameters  │       └──────────────┘       └──────────────┘
│  (JSON)      │
│  created_at  │◄──────────────────────────────────────┘
└──────────────┘
```

### 7.5 Parameter System

Parameters are defined at the Family level and can be scoped to either Type or Instance:

| Scope | Description | Example |
|-------|-------------|---------|
| **Type Parameter** | Describes the product model; same for all instances | Manufacturer, Model, Wattage |
| **Instance Parameter** | Describes the specific physical unit | Serial Number, Condition, Installation Date |

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

## 8. Functional Requirements

### 8.1 Mobile Application Requirements

#### FR-M01: Project Download
- App shall display list of available projects (state: READY)
- App shall download complete project data including floorplan tiles, schema, and existing Types
- App shall store project data locally for offline access
- App shall update project state to ACTIVE upon successful download

#### FR-M02: Floorplan Navigation
- App shall display vector-rendered floorplan with pan and zoom gestures
- App shall support level switching via picker control
- App shall display room boundaries with status indicators (not started, in progress, completed)
- App shall allow room selection by tapping within room boundary

#### FR-M03: Asset Creation
- App shall allow asset placement by tapping location on floorplan
- App shall present Family selection from schema-defined families
- App shall present Type selection with search, recently used, and create new options
- App shall perform fuzzy matching against existing Types when creating new Type
- App shall display Type parameter form for new Type creation
- App shall display Instance parameter form with validation
- App shall enforce required field completion before save
- App shall capture photos with configurable min/max per family

#### FR-M04: Photo Capture
- App shall capture photos using device camera
- App shall compress photos to JPEG, longest edge 1280px, quality 0.8
- App shall assign globally unique filename at capture time
- App shall store photos locally with upload queue
- App shall enforce minimum photo requirement before asset save

#### FR-M05: Offline Operation
- App shall function fully without network connectivity
- App shall log all changes as events in local storage
- App shall queue photos for background upload
- App shall indicate sync status to operator

#### FR-M06: Synchronization
- App shall detect network availability
- App shall upload pending events when online
- App shall upload queued photos in background
- App shall display sync progress and status

#### FR-M07: Survey Completion
- App shall validate all rooms have at least one asset or annotation
- App shall display report of empty rooms if validation fails
- App shall allow completion confirmation when all rooms addressed
- App shall change project state to COMPLETED upon confirmation
- App shall make project read-only after completion

### 8.2 Admin Dashboard Requirements

#### FR-A01: Project Creation
- Dashboard shall allow creation of new projects with name and description
- Dashboard shall display project list with status indicators
- Dashboard shall allow project state management

#### FR-A02: DWG Upload and Validation
- Dashboard shall accept DWG file upload
- Dashboard shall validate DWG against required structure (see Section 9.3)
- Dashboard shall display validation report with specific errors if failed
- Dashboard shall extract levels and rooms from valid DWG
- Dashboard shall generate vector tiles for mobile rendering

#### FR-A03: Schema Management
- Dashboard shall display available schema templates
- Dashboard shall allow schema template creation/editing
- Dashboard shall create immutable schema versions
- Dashboard shall lock schema version to project

#### FR-A04: Progress Monitoring
- Dashboard shall display real-time survey progress
- Dashboard shall show completion percentage by level and room
- Dashboard shall display asset counts by family
- Dashboard shall show sync status for active projects

#### FR-A05: Export Generation
- Dashboard shall generate CSV/Excel export of all asset data
- Dashboard shall generate ZIP archive of all photos
- Dashboard shall assign sequential IDs at first export
- Dashboard shall maintain stable IDs for re-exports

### 8.3 Backend Requirements

#### FR-B01: API Services
- Backend shall provide REST API for all client operations
- Backend shall handle authentication (future: MVP has open access)
- Backend shall validate all incoming data against schema

#### FR-B02: Sync Engine
- Backend shall receive events from mobile clients
- Backend shall order events by timestamp
- Backend shall store events for audit trail
- Backend shall support event compaction for storage management

#### FR-B03: DWG Processing
- Backend shall validate uploaded DWG files
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

All spatial data uses a "Plan Space" coordinate system:

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
| **Photo Name** | `{project_short}_{operator}_{timestamp}_{seq}` | Globally unique, assigned at capture |

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

### 9.3 DWG Validation Rules

On upload, the system validates the DWG file against these requirements:

| Rule | Description |
|------|-------------|
| **Required Layers** | Specific layers must exist for levels, rooms, and north vectors |
| **Level Boundaries** | Each level must have a closed polyline boundary |
| **North Vector** | Each level must have a north vector starting inside the level boundary |
| **Room Regions** | All room filled regions must be inside a level boundary |
| **Room Labels** | Room name text (if present) must be inside the room region |
| **Level Labels** | Level name text must be inside the level boundary |
| **Building Groups** | Building layer polylines (optional) must properly enclose levels |
| **Building Labels** | Building name text must be inside building boundary |

**Validation Failure:** If any rule fails, the DWG must be corrected and re-uploaded. The project cannot proceed until the floorplan passes validation.

### 9.4 Photo Specifications

| Property | Specification |
|----------|---------------|
| **Format** | JPEG |
| **Resolution** | Longest edge 1280px |
| **Quality** | 0.8 compression |
| **Min per Instance** | 1 (configurable per Family) |
| **Max per Instance** | 5 (configurable per Family) |
| **Reuse** | A photo can be linked to multiple instances |
| **Naming** | Globally unique, assigned at capture, unchanged through export |

### 9.5 Scale Constraints

| Dimension | Limit | Notes |
|-----------|-------|-------|
| **Assets per Project** | 10,000 | Soft limit |
| **Photos per Device** | ~1,000 | Storage management |
| **Photos per Year (Cloud)** | 1,000,000 | Cost controls |
| **Rooms per Level** | No fixed limit | Constrained by DWG |
| **Levels per Project** | No fixed limit | Constrained by DWG |

### 9.6 Project Lifecycle States

| State | Description | Available Actions |
|-------|-------------|-------------------|
| **Draft** | Being configured | Edit settings, upload DWG, select schema |
| **Ready** | Configuration complete | Download to mobile, edit settings |
| **Active** | Survey in progress | Sync data, monitor progress |
| **Completed** | Survey finished | Review data, approve or return for corrections |
| **Approved** | Admin approved | Generate exports |
| **Archived** | Long-term storage | View only |

**State Transitions:**
```
Draft → Ready → Active → Completed → Approved → Archived
                  ↑           │
                  └───────────┘
                (return for corrections)
```

### 9.7 Event Sourcing Model

The sync system uses an event log pattern:

**Event Types:**
- `INSTANCE_CREATED` — New asset instance placed
- `INSTANCE_UPDATED` — Instance parameters modified
- `INSTANCE_DELETED` — Instance removed
- `TYPE_CREATED` — New Type defined
- `TYPE_UPDATED` — Type parameters modified
- `PHOTO_ATTACHED` — Photo linked to instance
- `ROOM_STATUS_CHANGED` — Room marked complete/incomplete

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
│   │   ├── dwg-processing/      # DWG validation and tile generation
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

When an operator encounters a room that legitimately has no assets to record, they must add an Annotation asset with an appropriate reason:

| Situation | Action Required |
|-----------|-----------------|
| **No assets to register** | Add Annotation + select reason from dropdown + optional note/photo |
| **Room unreachable** | Add Annotation + select reason + mandatory photo (or note if photo impossible) |

This ensures every room is explicitly addressed, preventing accidental omissions.

### Appendix B: Type Creation Guidelines

When creating assets, operators should follow this priority:

1. **Use existing Type** — Maintains consistency; fastest option
2. **Duplicate and modify** — When a similar Type exists but one parameter differs
3. **Create new Type** — Only when no similar Type exists

The fuzzy matching system suggests existing Types when operators type a new name, helping prevent duplicates.

### Appendix C: Photo Naming Convention

Photos receive a globally unique name at capture time that remains unchanged through export:

**Format:** `{project_short}_{operator_id}_{timestamp}_{sequence}`

**Example:** `PRJ001_OP42_20251215143022_001.jpg`

This ensures:
- No duplicate names across projects
- Traceability to source project and operator
- Consistent naming from capture through client delivery

---

*End of Specification*
