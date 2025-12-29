# Database

PostgreSQL database schema and migrations.

## Structure

### `/migrations`
Database schema migrations:
- Projects, levels, rooms tables
- Families, types, instances tables
- Events table for sync
- Schema versions and templates
- Users and operators (for future versions)

### `/seeds`
Seed data for development and testing:
- Sample projects
- Standard families (Lights, Radiators, etc.)
- Test schemas

## Key Tables

- **projects**: Project metadata and state
- **levels**: Building floors with spatial boundaries
- **rooms**: Spaces within levels
- **families**: Asset categories with parameter definitions
- **types**: Specific products within families
- **instances**: Individual physical assets
- **events**: Event sourcing log for sync
- **schemas**: Parameter catalogues and versions
- **photos**: Photo metadata and storage references

## Technology

PostgreSQL with UUIDv7 for primary keys
