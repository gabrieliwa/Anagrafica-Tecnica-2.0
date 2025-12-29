# Anagrafica Tecnica (Technical Asset Registry)

Field survey tool for technical asset registry in buildings. The MVP enables operators to conduct on-site surveys using an iPhone app where the floorplan serves as the primary interface.

## System Architecture

This is a multi-component system with offline-first mobile operation and cloud-based administration.

### Components

```
├── anagrafica tecnica app/     # iOS mobile application (Swift/SwiftUI)
├── admin-dashboard/            # Web-based admin control panel
├── backend/                    # Server-side processing and API
├── database/                   # PostgreSQL schema and migrations
├── storage/                    # File storage (DWG, tiles, photos, exports)
├── shared/                     # Common types and utilities
├── docs/                       # Additional documentation
└── scripts/                    # Development and deployment scripts
```

### Component Interactions

```
┌─────────────────────────────────────────────────┐
│                    CLOUD                        │
│                                                 │
│  ┌──────────────┐         ┌─────────────────┐  │
│  │   Backend    │◄───────►│    Database     │  │
│  │   (API)      │         │  (PostgreSQL)   │  │
│  └──────┬───────┘         └─────────────────┘  │
│         │                                       │
│         ├──────────────────┐                    │
│         │                  │                    │
│  ┌──────▼───────┐   ┌──────▼──────┐            │
│  │   Storage    │   │    Admin    │            │
│  │  (S3/Blob)   │   │  Dashboard  │            │
│  └──────────────┘   └─────────────┘            │
└─────────────────────────────────────────────────┘
           │
        INTERNET
           │
    ┌──────▼──────┐
    │  Mobile App │
    │    (iOS)    │
    └─────────────┘
```

## Data Model: Family → Type → Instance

The system follows BIM conventions:

- **Family**: Asset category (Lights, Radiators, Access Points)
- **Type**: Specific product within a family (e.g., "Philips 30W wall light")
- **Instance**: Individual physical asset at a specific location

## Key Features

### Mobile App (iOS)
- Offline-first operation with full local data
- Interactive floorplan navigation (Google Maps-style)
- Asset creation following Family → Type → Instance hierarchy
- Photo capture (1-5 per asset, configurable)
- Automatic sync when online
- On-device fuzzy matching to prevent duplicate Types

### Admin Dashboard (Web)
- Project creation and DWG upload/validation
- Asset/parameter catalogue management
- Survey progress monitoring
- Data quality tracking
- Export generation (CSV/Excel + photos)

### Server Backend
- Event sourcing sync engine
- DWG processing (room extraction, vector tiles)
- Schema versioning
- Type normalization
- Export generation with sequential IDs

## MVP Simplifications

This is a proof-of-concept with the following limitations:

- No authentication (open access)
- Single-user operation only
- No multi-user collaboration
- No plan editing capabilities
- No AI-assisted features
- No undo functionality
- Direct sync without conflict resolution

See `Technical_Asset_Registry_MVP_Specification.md` for complete system requirements.

## Getting Started

### Mobile App
```bash
open "anagrafica tecnica app/anagrafica tecnica app.xcodeproj"
```

### Backend
See `backend/README.md` for setup instructions.

### Admin Dashboard
See `admin-dashboard/README.md` for setup instructions.

## Documentation

- `CLAUDE.md` - Guidance for Claude Code when working in this repository
- `Technical_Asset_Registry_MVP_Specification.md` - Complete MVP specification
- Component READMEs in each folder

## Development Workflow

1. **Input Preparation**: Admin uploads DWG and parameter catalogue
2. **Project Setup**: System validates DWG, generates tiles, creates schema version
3. **Field Survey**: Operator downloads project to mobile app, works offline
4. **Sync**: Events and photos upload to server when online
5. **Export**: Admin approves project and generates client deliverables

## Scale Targets (MVP)

- Assets per Project: 10,000 (soft limit)
- Photos per Device: ~1,000
- Photos per Year (Cloud): Up to 1,000,000
