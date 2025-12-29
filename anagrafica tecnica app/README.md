# Anagrafica Tecnica - Mobile App (iOS)

Field survey application for documenting technical assets in buildings using interactive floorplans.

---

## Overview

The mobile app is the primary tool for field operators conducting on-site surveys. It provides an offline-first experience where the floorplan serves as the main navigation interface, allowing operators to document assets (lights, radiators, access points, etc.) room by room.

### Key Characteristics

- **Offline-First**: Fully functional without network connectivity
- **Floorplan-Centric**: Google Maps-style navigation of building layouts
- **Photo Capture**: 1-5 photos per asset with automatic naming
- **Event Sourcing**: All changes logged for reliable sync
- **Fuzzy Matching**: Prevents duplicate asset Types during creation

---

## Requirements

### Development Environment

- **macOS**: 13.0 (Ventura) or later
- **Xcode**: 26.2 or later
- **iOS SDK**: Latest version
- **Swift**: 5.9+
- **Target iOS Version**: iOS 16.0+

### Device Requirements

- iPhone (primary target device)
- iPad support (future consideration)
- Camera access for photo capture
- Storage: ~2-3 GB free space for project data and photos

---

## Getting Started

### Opening the Project

```bash
cd "anagrafica tecnica app"
open "anagrafica tecnica app.xcodeproj"
```

### Building the App

#### Via Xcode
1. Open the project in Xcode
2. Select target device or simulator
3. Press `⌘ + B` to build
4. Press `⌘ + R` to run

#### Via Command Line

Build:
```bash
xcodebuild -scheme "anagrafica tecnica app" -configuration Debug build
```

Run tests:
```bash
xcodebuild test -scheme "anagrafica tecnica app" -destination 'platform=iOS Simulator,name=iPhone 15'
```

Clean build:
```bash
xcodebuild clean -scheme "anagrafica tecnica app"
```

---

## Project Structure

```
anagrafica tecnica app/
├── anagrafica tecnica app/
│   ├── anagrafica_tecnica_appApp.swift    # App entry point (@main)
│   ├── ContentView.swift                   # Main view
│   └── Assets.xcassets/                    # App icons and assets
└── anagrafica tecnica app.xcodeproj/      # Xcode project configuration
```

### Recommended Architecture (To Be Implemented)

```
anagrafica tecnica app/
├── App/
│   ├── anagrafica_tecnica_appApp.swift    # App lifecycle
│   └── AppDelegate.swift                   # App delegate (if needed)
├── Models/
│   ├── Project.swift                       # Project entity
│   ├── Level.swift                         # Level (floor) entity
│   ├── Room.swift                          # Room entity
│   ├── Family.swift                        # Asset family
│   ├── Type.swift                          # Asset type
│   ├── Instance.swift                      # Asset instance
│   ├── Photo.swift                         # Photo entity
│   └── Event.swift                         # Event log for sync
├── Views/
│   ├── Map/
│   │   ├── FloorplanMapView.swift         # Main map interface
│   │   ├── RoomOverlayView.swift          # Room polygons and states
│   │   └── AssetMarkerView.swift          # Asset icons on map
│   ├── Asset/
│   │   ├── AssetListView.swift            # List of assets in room
│   │   ├── AssetDetailView.swift          # Asset instance editor
│   │   ├── TypeSelectorView.swift         # Type selection/creation
│   │   └── FamilySelectorView.swift       # Family selection
│   ├── Photo/
│   │   ├── PhotoCaptureView.swift         # Camera interface
│   │   └── PhotoGalleryView.swift         # Photo viewer
│   └── Project/
│       ├── ProjectListView.swift          # Available projects
│       └── ProjectDownloadView.swift      # Project package download
├── ViewModels/
│   ├── MapViewModel.swift                  # Map state and navigation
│   ├── AssetViewModel.swift                # Asset CRUD operations
│   ├── PhotoViewModel.swift                # Photo capture and management
│   └── SyncViewModel.swift                 # Sync state and operations
├── Services/
│   ├── DataService.swift                   # Core Data / Realm operations
│   ├── SyncService.swift                   # Event sync engine
│   ├── PhotoService.swift                  # Photo storage and upload
│   ├── ValidationService.swift             # Schema validation
│   ├── FuzzyMatchService.swift             # Type duplicate detection
│   └── APIClient.swift                     # Backend API communication
├── Utilities/
│   ├── UUIDv7Generator.swift               # Time-sortable UUID generation
│   ├── CoordinateTransform.swift           # Plan space calculations
│   ├── PhotoNaming.swift                   # Photo naming convention
│   └── Extensions/                         # Swift extensions
├── Storage/
│   ├── CoreDataStack.swift                 # Core Data setup
│   └── AnagraficaTecnica.xcdatamodeld     # Data model
├── Resources/
│   ├── Assets.xcassets/                    # Images and colors
│   └── Localizable.strings                 # Localization (future)
└── Tests/
    ├── ModelTests/                         # Unit tests for models
    ├── ViewModelTests/                     # ViewModel tests
    └── ServiceTests/                       # Service layer tests
```

---

## Key Features

### 1. Offline-First Architecture

**Local Data Storage:**
- Complete project package stored on device
- Floorplan tiles (vector or raster)
- Room polygons with spatial data
- Schema version and validation rules
- Family and Type library
- Asset instances with parameters
- Photos (JPEG, 1280px max dimension)
- Event log for sync

**Sync Behavior:**
- Automatic sync when network available
- Background photo upload queue
- Event sourcing pattern
- No data loss during offline periods

**Recommended Technologies:**
- Core Data for structured data
- Realm as alternative (simpler API, better performance)
- FileManager for photo storage
- Background URLSession for uploads

### 2. Floorplan Map Interface

**Navigation (Google Maps Style):**
- Two-finger pan and zoom gestures
- Level selector (floor switcher)
- Building selector (if multi-building project)
- Smooth animations and transitions

**Room Interaction:**

| User Action | App Response |
|-------------|-------------|
| Tap inside room polygon | Enter room editing mode; room selected |
| Tap asset count icon | Reveal assets arranged radially around centroid |
| Tap individual asset | Open asset detail view |
| Tap neighboring room | Switch to that room |
| Tap outside floorplan | Deselect room; enter navigation mode |

**Visual States:**
- **Empty room**: (+) icon at centroid
- **Room with assets**: Icon with count badge
- **Selected room**: Highlighted boundary
- **Complete room**: Green tint or checkmark
- **Approved room**: Different visual indicator

**Implementation Options:**
- MapKit with custom overlays (if map-like behavior needed)
- Custom SwiftUI Canvas (full control, lighter weight)
- SpriteKit (for complex tile rendering)

### 3. Asset Creation Workflow

**Step 1: Select Family**
- Display list of available families (Lights, Radiators, etc.)
- Show family icon and description
- Filter by category if needed

**Step 2: Select or Create Type**

Priority order (guide user to prefer existing Types):
1. **Use Existing Type** - Search and select from library
2. **Duplicate Type** - Copy existing, modify parameters
3. **Create New Type** - Start from scratch (show fuzzy match warnings)

**Fuzzy Matching:**
- Real-time comparison against existing Types
- Warn if similar Type name or parameters exist
- Allow operator to proceed or select suggested match

**Step 3: Create Instance**
- Pre-fill Type parameters (read-only)
- Fill instance-specific parameters
- Required fields block save (show validation errors)
- Optional fields allow save

**Step 4: Capture Photos**
- Minimum: 1 photo (configurable per Family)
- Maximum: 5 photos (configurable per Family)
- Photo naming: `{project_uuid_short}_{operator_id}_{timestamp}_{sequence}`
- Photos can be reused for multiple instances
- Compress to JPEG, 1280px max dimension, quality 0.8

**Step 5: Save Instance**
- Validate all required fields
- Create event log entry
- Store locally
- Position at room centroid
- Queue for sync when online

### 4. Photo Management

**Capture:**
- Native camera integration (AVFoundation)
- Compress immediately after capture
- Generate unique filename at capture time
- Store in app's Documents directory
- Create thumbnail for UI

**Storage:**
- Local: Documents directory, organized by project
- Remote: S3/Blob storage after upload
- Naming preserved throughout lifecycle

**Upload Queue:**
- Background URLSession for reliability
- Retry logic with exponential backoff
- Upload only when on WiFi (configurable)
- Progress tracking per photo
- Handle app termination/restart gracefully

**Implementation:**
```swift
// Photo naming convention
func generatePhotoName(projectId: UUID, operatorId: String) -> String {
    let projectShort = projectId.uuidString.prefix(8)
    let timestamp = Date().timeIntervalSince1970
    let sequence = getNextSequence()
    return "\(projectShort)_\(operatorId)_\(timestamp)_\(sequence).jpg"
}
```

### 5. Event Sourcing for Sync

**Event Types:**
- `TypeCreated`, `TypeUpdated`
- `InstanceCreated`, `InstanceUpdated`, `InstanceDeleted`
- `PhotoCaptured`, `PhotoLinked`
- `RoomStateChanged`

**Event Structure:**
```swift
struct Event {
    let id: UUID               // UUIDv7 (time-sortable)
    let type: EventType
    let timestamp: Date
    let projectId: UUID
    let operatorId: String
    let entityId: UUID
    let payload: JSON
    let synced: Bool
}
```

**Sync Flow:**
1. Operator performs action (create, update, delete)
2. Event logged locally with UUIDv7
3. Changes applied to local database
4. UI updates immediately
5. When online: events sent to server in batch
6. Server ACKs received events
7. Local events marked as synced

**Conflict Resolution:**
- Not needed in MVP (single user)
- Last-write-wins for future multi-user

---

## Data Model

### Core Entities

**Project**
- id (UUIDv7)
- name
- state (Draft, Ready, Active, Completed, Approved)
- schemaVersionId
- planVersionId
- downloadedAt
- lastSyncAt

**Level (System Family)**
- id (UUIDv7)
- projectId
- name (e.g., "Floor 1", "Building A - Floor 2")
- number
- buildingName (optional)
- originPoint (x, y)
- northAngle
- boundary (polygon)

**Room (System Family)**
- id (UUIDv7)
- levelId
- name
- number
- area (calculated from polygon)
- polygon (coordinates array)
- centroid (x, y)
- lifecycleState (Empty, Complete, Approved)

**Family**
- id (UUIDv7)
- name (e.g., "Lights", "Radiators")
- iconName
- parameterSchema (JSON)
- photoMin (default 1)
- photoMax (default 5)

**Type**
- id (UUIDv7)
- familyId
- name (e.g., "Philips 30W wall light")
- parameters (JSON - fixed values)
- createdByOperator
- createdAt

**Instance**
- id (UUIDv7)
- typeId
- roomId
- planPoint (x, y) - room centroid
- planVersionId
- parameters (JSON - instance values)
- photoIds (array of UUIDs)
- createdAt

**Photo**
- id (UUIDv7)
- filename (globally unique, assigned at capture)
- filepath (local path)
- uploadStatus (Pending, Uploading, Completed, Failed)
- uploadedAt
- size (bytes)

**Event**
- id (UUIDv7)
- type
- timestamp
- projectId
- operatorId
- entityId
- payload (JSON)
- synced

### Database Technology Choice

**Option 1: Core Data**
- Pros: Native, integrated with SwiftUI, iCloud sync ready
- Cons: Steeper learning curve, verbose API

**Option 2: Realm**
- Pros: Simpler API, better performance, reactive queries
- Cons: Additional dependency, larger app size

**Recommendation**: Start with Core Data for MVP, consider Realm if performance issues arise.

---

## Key Implementation Patterns

### 1. Schema Validation

```swift
class ValidationService {
    func validate(instance: Instance, schema: ParameterSchema) -> [ValidationError] {
        var errors: [ValidationError] = []

        for param in schema.parameters where param.required {
            if instance.parameters[param.key] == nil {
                errors.append(.missingRequiredField(param.key))
            }
        }

        // Type validation, range checks, enum validation, etc.

        return errors
    }

    func canSave(instance: Instance, schema: ParameterSchema) -> Bool {
        return validate(instance: instance, schema: schema).isEmpty
    }
}
```

### 2. Fuzzy Type Matching

```swift
class FuzzyMatchService {
    func findSimilarTypes(name: String, parameters: [String: Any], threshold: Double = 0.8) -> [Type] {
        // Levenshtein distance for name matching
        // Parameter similarity scoring
        // Return Types above similarity threshold
    }

    func warnIfDuplicate(name: String, parameters: [String: Any]) -> Type? {
        let similar = findSimilarTypes(name: name, parameters: parameters)
        return similar.first // Return most similar
    }
}
```

### 3. Coordinate System

```swift
struct PlanPoint {
    let x: Double  // meters from level origin
    let y: Double  // meters from level origin
}

class CoordinateTransform {
    // Level origin is at North vector start point
    // X/Y aligned with CAD axes

    func calculateCentroid(polygon: [PlanPoint]) -> PlanPoint {
        // Calculate geometric center
    }

    func isPointInPolygon(point: PlanPoint, polygon: [PlanPoint]) -> Bool {
        // Ray casting algorithm
    }

    func transformToScreen(planPoint: PlanPoint, zoom: Double, offset: CGPoint) -> CGPoint {
        // Convert plan space to screen space
    }
}
```

### 4. UUIDv7 Generation

```swift
class UUIDv7Generator {
    static func generate() -> UUID {
        // UUIDv7 format:
        // - First 48 bits: Unix timestamp in milliseconds
        // - Next 12 bits: Random
        // - Version (7) and variant bits
        // - Remaining bits: Random

        let timestamp = UInt64(Date().timeIntervalSince1970 * 1000)
        // ... implementation
    }
}
```

---

## UI/UX Guidelines

### Design Principles

1. **Touch-First**: Large tap targets (minimum 44x44 pt)
2. **Gesture-Driven**: Pan, zoom, tap for navigation
3. **Visual Feedback**: Immediate response to all actions
4. **Error Prevention**: Validation before save, confirmation dialogs
5. **Offline Awareness**: Clear indicators of sync status

### Color Coding

- **Empty rooms**: Gray or neutral
- **In-progress rooms**: Blue
- **Complete rooms**: Green
- **Approved rooms**: Dark green or checkmark
- **Selected room**: Highlighted border
- **Sync pending**: Orange dot
- **Sync error**: Red dot

### Typography

- **SF Pro**: System font (readable, native)
- **Titles**: 28pt Bold
- **Body**: 17pt Regular
- **Captions**: 13pt Regular

### Icons

- Use SF Symbols for consistency
- Asset families: Custom icons (provided by design team)
- Room states: Standard symbols (checkmark, exclamation, etc.)

---

## Testing Strategy

### Unit Tests

- Model validation logic
- Coordinate transformations
- Photo naming generation
- Event creation and ordering
- Fuzzy matching algorithms

### Integration Tests

- Core Data stack operations
- API client communication
- Event sync flow
- Photo upload queue

### UI Tests

- Map navigation gestures
- Asset creation workflow
- Photo capture flow
- Form validation

### Manual Testing Checklist

- [ ] Project download and setup
- [ ] Floorplan rendering and navigation
- [ ] Room selection and highlighting
- [ ] Asset creation (all families)
- [ ] Photo capture and compression
- [ ] Offline operation (airplane mode)
- [ ] Sync when reconnected
- [ ] Validation errors display correctly
- [ ] Fuzzy match warnings appear
- [ ] Job completion with empty rooms

---

## Performance Considerations

### Memory Management

- Lazy load floorplan tiles
- Unload non-visible level data
- Compress images immediately
- Use thumbnail caches
- Limit concurrent photo uploads (max 3)

### Battery Optimization

- Background sync only on WiFi
- Batch API requests
- Use CoreLocation efficiently (not always on)
- Dim screen timeout during extended use

### Storage Optimization

- Photo compression (1280px, quality 0.8)
- Clean up synced events (keep last 30 days)
- Remove cached tiles after project completion
- Target: 1000 photos = ~300-500 MB

---

## Known Limitations (MVP)

- Single user only (no collaboration)
- No undo/redo functionality
- Cannot edit room polygons or boundaries
- No AI-assisted asset placement
- No conflict resolution (last-write-wins)
- English only (no localization)
- iPhone only (no iPad optimization)

---

## Future Enhancements

### Post-MVP Features

1. **Specific Asset Positioning**: Drag assets within rooms
2. **Annotation Tools**: Freehand drawing, text notes on plan
3. **Voice Notes**: Audio recordings per asset
4. **Barcode Scanning**: QR/barcode for serial numbers
5. **Offline Maps**: Support for completely offline projects
6. **Multi-User**: Real-time collaboration with worksets
7. **AR Mode**: Overlay assets on camera view
8. **iPad Support**: Optimized layouts for larger screens

---

## Development Commands

### Build & Run
```bash
# Build only
xcodebuild -scheme "anagrafica tecnica app" build

# Run tests
xcodebuild test -scheme "anagrafica tecnica app" -destination 'platform=iOS Simulator,name=iPhone 15'

# Clean
xcodebuild clean -scheme "anagrafica tecnica app"

# Archive for distribution
xcodebuild archive -scheme "anagrafica tecnica app" -archivePath ./build/App.xcarchive
```

### Code Quality
```bash
# Format code (if using SwiftFormat)
swiftformat .

# Lint (if using SwiftLint)
swiftlint

# Run analyzer
xcodebuild analyze -scheme "anagrafica tecnica app"
```

---

## Contributing

See main project README.md for contribution guidelines.

---

## License

[To be determined]

---

## Support

For issues or questions, contact the development team or refer to the main project documentation.
