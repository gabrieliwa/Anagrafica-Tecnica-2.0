# Backend Server

Central processing engine for the Technical Asset Registry system.

## Components

### `/src/api`
REST or GraphQL endpoints for Mobile App and Admin Dashboard communication.

### `/src/sync`
Event sourcing sync engine:
- Receives events from mobile devices
- Orders and stores events to database
- Manages event compaction and snapshotting

### `/src/dwg-processing`
DWG file processing pipeline:
- Validates DWG files against contract requirements
- Extracts room polygons and level boundaries
- Generates vector tiles for mobile app
- Creates plan_version_id for geometry tracking

### `/src/schema`
Schema and parameter catalogue management:
- Stores parameter definitions and validation rules
- Creates immutable schema versions
- Binds schema versions to projects

### `/src/export`
Export generation:
- Produces CSV/Excel files with asset data
- Creates photo packages (photos retain capture-time names)
- Generates summary reports
- Assigns sequential export IDs

### `/src/storage`
Database and file storage interfaces:
- PostgreSQL client for relational data
- S3/Blob storage SDK for files (DWG, tiles, photos)

## Technology Stack

Recommended: Node.js (Express/Fastify) or Python (FastAPI)

## Key Patterns

- **Event Sourcing**: All changes stored as events for audit trail
- **UUIDv7**: Time-sortable unique IDs for all entities
- **Plan Space Coordinates**: Origin at North vector, X/Y aligned with CAD axes, meters
