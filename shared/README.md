# Shared Code

Common types, schemas, and utilities shared across backend, frontend, and mobile app.

## Structure

### `/types`
TypeScript/type definitions:
- Project, Level, Room entities
- Family, Type, Instance models
- Event types for sync
- API request/response types

### `/schemas`
Parameter definitions and validation schemas:
- Family parameter structures
- Validation rules
- Data types and enums

### `/constants`
Shared constants:
- System family definitions (Levels, Rooms)
- Lifecycle states
- Photo requirements
- ID formats

### `/utils`
Common utility functions:
- UUIDv7 generation
- Coordinate transformations
- Photo naming conventions
- Validation helpers

## Usage

This package should be importable by backend, admin-dashboard, and potentially mobile app (for type definitions).
