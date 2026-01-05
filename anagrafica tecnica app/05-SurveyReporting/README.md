# Phase 5: Survey Reporting

## Overview

Survey Reporting provides comprehensive views and analysis tools for the entire survey. This includes searchable/filterable lists of rooms and Types, progress tracking, and project export functionality. Accessed via the hamburger (☰) button.

## Components

### SurveyReportHub/
Main container for the Survey Report with tab navigation.

**Key Features:**
- Three tabs: Rooms, Types, Project Export
- Global search bar
- Bottom fixed tab bar
- Back to previous screen
- Opens from floorplan or room view

**Key Files:**
- `SurveyReportView.swift`
- `SurveyReportHeader.swift`
- `TabBar.swift`
- `SurveyReportViewModel.swift`

### RoomsList/
Searchable, filterable list of all rooms in the project.

**Key Features:**
- Grouped by level
- Show: room number, name, asset + room note count
- Tap room → open Room View
- Empty rooms show (+) → Add Asset wizard
- Search by room number or name
- Filter modal:
  - Room Type: All, Without assets, With assets
  - Asset Type: multi-select list of Types
  - Show only rooms containing selected Types
  - Reset/Save controls
- Applied filters show indicator in search bar

**Key Files:**
- `RoomsListView.swift`
- `RoomListItem.swift`
- `RoomListFilter.swift`
- `AddAssetFromListButton.swift`
- `RoomsListViewModel.swift`

### TypesList/
Searchable, filterable list of all asset Types in the project.

**Key Features:**
- Grouped by Family
- Show: Type name, parameter summary, instance count
- Tap Type → Edit Type widget
- Search by Type name or parameters
- Filter modal:
  - Family selector (required first step)
  - After Family selected, show all parameters for that Family
  - Each parameter: dropdown of existing values
  - Multi-select across parameter values
  - Match ALL selected parameters (AND)
  - Match ANY value within each parameter (OR)
  - Reset/Save controls
- Applied filters show indicator in search bar

**Key Files:**
- `TypesListView.swift`
- `TypeListItem.swift`
- `TypeListFilter.swift`
- `TypesListViewModel.swift`

### ProjectExport/
Generate and share project export package (backup mechanism).

**Key Features:**
- Show progress: "Building project export file..."
- Generate local export package
- Present iOS share sheet when ready
- Export includes: asset data, photos, metadata
- Acts as fallback if sync fails

**Key Files:**
- `ProjectExportView.swift`
- `ExportProgressView.swift`
- `ShareSheetPresenter.swift`
- `ExportGenerator.swift`
- `ExportViewModel.swift`

## Filter Logic

### Rooms List Filter

**Room Type Filter:**
- All: Show all rooms
- Without assets: Show only empty rooms (no assets, no room notes)
- With assets: Show rooms with ≥1 asset or room note

**Asset Type Filter:**
- Multi-select list of all Type names in project
- Show only rooms containing at least one instance of selected Types
- If no Types selected, filter is disabled

**Combined Logic:**
```
filtered_rooms = rooms
  .filter(room_type_condition)
  .filter(contains_any_selected_type)
```

### Types List Filter

**Family Filter (Required):**
- Must select a Family first
- Determines which parameters are available for filtering

**Parameter Filters:**
- Each parameter shows dropdown of existing values from that parameter
- Can select multiple values per parameter
- Can select across multiple parameters

**Match Logic:**
```
filtered_types = types
  .filter(family == selected_family)
  .filter(matches_all_parameter_filters)

matches_all_parameter_filters:
  for each parameter_filter:
    type[parameter] must match ANY selected value (OR)

  ALL parameter_filters must pass (AND)
```

**Example:**
- Family: Lights
- Manufacturer: [Philips, Osram] (OR)
- Wattage: [30W, 50W] (OR)

Result: Show Types where:
- Family = Lights AND
- (Manufacturer = Philips OR Osram) AND
- (Wattage = 30W OR 50W)

## Survey Completion Workflow

From Survey Report, operators can:

1. **Check Progress:**
   - Rooms tab shows which rooms are empty
   - Filter to "Without assets" to see incomplete rooms
   - Total count shows survey progress

2. **Complete Empty Rooms:**
   - Tap (+) on empty room → Add Asset wizard
   - Or add Room Note if legitimately empty

3. **Review Types:**
   - Types tab shows all Types with instance counts
   - Identify potential duplicates
   - Edit Types to consolidate

4. **Export for Backup:**
   - If sync fails, use Export tab
   - Generate local package
   - Share via iOS share sheet

## Dependencies

- **Phase 1:** DataModels, LocalStorage, CoreServices
- **Phase 2:** CommonComponents, Navigation
- **Phase 4:** RoomView, TypeEditor
- **External:** SwiftUI, Combine, UniformTypeIdentifiers (for export)

## Success Criteria

- [ ] Survey Report opens from floorplan and room view
- [ ] Tab navigation works smoothly
- [ ] Rooms list grouped by level correctly
- [ ] Types list grouped by Family correctly
- [ ] Search filters results in real-time
- [ ] Room filters work correctly (type + asset type)
- [ ] Type filters work correctly (family + parameters)
- [ ] Filter indicators show when active
- [ ] Tap room opens Room View
- [ ] Tap Type opens Edit Type widget
- [ ] Empty rooms show (+) button
- [ ] (+) button opens Add Asset wizard
- [ ] Export generates valid package
- [ ] Share sheet presents correctly
- [ ] All lists perform well with 1000+ items
- [ ] 80%+ unit test coverage

## Development Timeline

**Estimated Duration:** 4 weeks (Sprints 10-11)

**Week 19:** SurveyReportHub framework
**Week 20:** RoomsList with filters
**Week 21:** TypesList with filters
**Week 22:** ProjectExport + Testing

## Testing Requirements

- Unit tests for all view models
- Filter logic tests (rooms and types)
- Search functionality tests
- Performance tests with large datasets
- Export generation tests
- Share sheet integration tests
- Navigation flow tests

## UI/UX Guidelines

### Layout
- Fixed header with search and back button
- Scrollable content area
- Fixed bottom tab bar
- Pull-to-refresh for updated data

### Search
- Instant search (no submit button)
- Clear button in search field
- Search placeholder contextual to tab
- Results update as user types

### Filters
- Modal presentation for filter UI
- Clear visual indicator when filters active
- Reset button clears all filters
- Save/Cancel buttons in filter modal
- Show filter count badge on filter button

### Lists
- Section headers for grouping (level/family)
- Row tap area large and obvious
- Disclosure indicators for navigation
- Empty state when no results
- Loading state while fetching

### Performance
- Lazy loading for large lists
- Smooth scrolling at 60fps
- Instant search/filter response
- Background export generation

## Common Pitfalls

- Don't load all data at once (use pagination)
- Don't block UI during export generation
- Don't lose filter state on tab switch
- Don't allow invalid filter combinations
- Don't forget to show empty states
- Don't make filter UI too complex
- Don't allow Type editing in read-only mode

## Export Package Format

### Structure
```
project_export_[project_id]_[timestamp]/
├── manifest.json
├── assets.csv
├── rooms.csv
├── types.csv
├── photos/
│   ├── types/
│   │   ├── [photo_filename].jpg
│   │   └── ...
│   └── instances/
│       ├── [photo_filename].jpg
│       └── ...
└── metadata.json
```

### manifest.json
```json
{
  "project_id": "uuid",
  "project_name": "string",
  "export_date": "ISO8601",
  "export_version": "1.0",
  "asset_count": 1234,
  "photo_count": 567,
  "type_count": 89,
  "room_count": 45
}
```

### CSV Format
- UTF-8 encoding
- Comma-separated
- Headers in first row
- Quoted strings for text fields
- Photo filenames referenced in photo columns

## Notes

- Survey Report is the "dashboard" for field operators
- Filters help find specific rooms or Types quickly
- Export is a backup mechanism if sync fails
- Large projects may have 1000+ assets and 100+ Types
- Performance testing with realistic data volumes is critical
- Filter logic should be unit tested thoroughly
- Export should work completely offline
