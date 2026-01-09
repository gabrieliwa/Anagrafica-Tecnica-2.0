# Code Review & Next Steps Analysis

Last updated: 2026-01-09

This document provides a critical review of the current codebase implementation (Phases 1-3) and recommendations for moving forward.

---

## Part 1: Issues to Address in Current Implementation

### 1.1 Architecture & Code Organization

#### Large File Problem
| File | Lines | Issue |
|------|-------|-------|
| `AddAssetWizardViewModel.swift` | ~680 | Too many responsibilities in one file |
| `AddAssetWizardView.swift` | ~500+ | Large view file with many nested subviews |

**Recommendation**: Extract these into smaller, focused components:
- Create `AddAssetWizardStepViews/` folder with one file per step
- Extract parameter form logic into `ParameterFormBuilder`
- Move save/persistence logic to `AssetPersistenceService`

#### Missing Dependency Injection
The viewmodels directly access Core Data context via `@Environment(\.managedObjectContext)`:

```swift
// Current pattern in AddAssetWizardViewModel
func save(context: NSManagedObjectContext) { ... }
```

**Recommendation**: Introduce a protocol-based repository pattern:
```swift
protocol AssetRepository {
    func saveInstance(_ instance: AssetInstance) throws
    func saveType(_ type: AssetType) throws
}
```
This enables testing and decouples the ViewModel from Core Data.

---

### 1.2 Core Module Issues

#### StableID Inconsistency
`StableID.swift` generates deterministic IDs for seeding but the approach has issues:

```swift
// Current: SHA256 of string, truncated to UUID
static func fromString(_ string: String) -> UUID
```

**Issues**:
- No namespace isolation (collisions possible across different entity types)
- SHA256 truncation loses entropy

**Recommendation**: Use namespaced v5 UUIDs:
```swift
static func fromString(_ string: String, namespace: UUID) -> UUID
```

#### Photo Model Missing Validation
`Photo.swift` stores both `localURL` and `remoteURL` but lacks validation:

```swift
public var localURL: URL?
public var remoteURL: URL?
```

**Issue**: No enforcement that at least one URL exists. A Photo with both nil is invalid but allowed.

**Recommendation**: Add computed property or factory method:
```swift
public var isValid: Bool { localURL != nil || remoteURL != nil }
```

#### GeometryUtils Point-in-Polygon Edge Cases
`GeometryUtils.pointInPolygon` uses ray casting but doesn't handle:
- Points exactly on edges
- Degenerate polygons (< 3 points)

**Recommendation**: Add edge case guards and document behavior.

---

### 1.3 Persistence Layer Issues

#### Binary JSON Encoding Risk
Parameters are stored as binary-encoded JSON in Core Data:

```swift
// In AssetInstance entity
parametersData: Binary  // JSON-encoded [ParameterValue]
```

**Issues**:
- No migration path if ParameterValue structure changes
- Debugging difficult (can't query parameter values directly)
- No schema evolution strategy

**Recommendation**: Either:
1. Add explicit versioning inside the JSON blob
2. Use a separate normalized `ParameterValueEntity` table (more queryable)

#### Missing Cascade Delete Audit
Some relationships use `nullify` which can leave orphaned data:

| Relationship | Rule | Potential Issue |
|--------------|------|-----------------|
| AssetInstance -> Room | Nullify | Instances persist if room deleted |
| AssetInstance -> Type | Nullify | Instances reference nil type |
| RoomNote -> Room | Nullify | Orphaned room notes |

**Recommendation**: Audit whether nullify is intentional or if cascade delete is safer. Add cleanup logic if nullify is required for soft-delete scenarios.

---

### 1.4 Feature Implementation Issues

#### FloorplanCanvas Performance
`FloorplanCanvas` recalculates geometry on every render:

```swift
var body: some View {
    Canvas { context, size in
        // Recalculates transform every frame
        let transform = FloorplanTransform(...)
    }
}
```

**Recommendation**: Cache the transform when bounds/size don't change. Consider using `drawingGroup()` for complex paths.

#### Projects List Missing Pagination
`ProjectsListView` uses a single `@FetchRequest`:

```swift
@FetchRequest(sortDescriptors: [...])
private var projects: FetchedResults<ProjectEntity>
```

**Issue**: Loads all projects into memory. Fine for MVP scale but won't scale.

**Recommendation**: Add `fetchBatchSize` for basic optimization:
```swift
@FetchRequest(sortDescriptors: [...], animation: .default)
var request: NSFetchRequest<ProjectEntity> = {
    let r = NSFetchRequest<ProjectEntity>(entityName: "ProjectEntity")
    r.fetchBatchSize = 20
    return r
}()
```

#### AddAssetWizard Missing Exit Animation
The wizard uses `@Environment(\.dismiss)` but the transition is abrupt:

**Recommendation**: Add `.interactiveDismissDisabled()` and custom transition for better UX.

---

### 1.5 Missing Functionality (Claimed Complete)

#### Phase 1: Local File Cache Underutilized
`LocalFileCache` is implemented but:
- Not integrated with Photo saving flow
- Demo tiles loaded directly from bundle, not cached

**Recommendation**: Wire the cache into `DemoDataSeeder` and photo capture flow.

#### Phase 2: Level Picker Not Persisting Selection
`FloorplanViewModel.selectedLevelIndex` resets on view recreation:

**Recommendation**: Persist in UserDefaults or pass via navigation state.

#### Phase 3: No Actual Photo Capture
`AddAssetWizardViewModel.captureTypePhoto()` just generates a UUID:

```swift
func captureTypePhoto() {
    typePhoto = Photo(id: UUID(), ...)
}
```

**Issue**: Photo capture is marked complete in PROGRESS.md but isn't implemented.

**Recommendation**: Mark as incomplete or implement `PHPickerViewController` integration.

---

### 1.6 Code Quality Issues

#### Missing Documentation
Complex algorithms lack comments:
- `GeometryUtils.pointInPolygon` (ray casting)
- `FloorplanTransform` coordinate conversion
- `ParameterValidator` rule evaluation

#### Inconsistent Error Handling
Some places use `try?` silently:

```swift
// In DemoDataSeeder
let data = try? JSONEncoder().encode(params)
```

**Recommendation**: At minimum, log failures even if swallowing errors.

#### Magic Numbers
Scattered throughout views:

```swift
.frame(width: 80, height: 80)  // Why 80?
.padding(.horizontal, 16)       // Should use AppSpacing
```

**Recommendation**: Move all to DesignSystem constants.

---

### 1.7 Testing Gap (Critical)

**Zero test coverage** despite PROGRESS.md claiming Phase 1-3 complete.

**High-priority tests needed**:

| Area | Priority | Rationale |
|------|----------|-----------|
| `ParameterValidator` | P0 | Core business logic |
| `StableID` generation | P0 | Data integrity |
| `GeometryUtils` | P0 | Spatial calculations |
| `DemoDataSeeder` | P1 | Setup reliability |
| `AddAssetWizardViewModel` | P1 | Complex state machine |

---

## Part 2: Next Steps Restructuring

### Current PROGRESS.md Phase 4-7 Structure

```
Phase 4 - Room Management
Phase 5 - Survey Hub + Export
Phase 6 - Synchronization
Phase 7 - Hardening + QA
```

### Recommended Restructuring

I recommend splitting Phase 4-5 differently and adding a dedicated testing phase earlier:

---

#### **Phase 4A: Room View & Instance Editing** (Foundation)
- [ ] Room view list (assets + room notes display)
- [ ] Instance editor widget (read-only first)
- [ ] Type info display in instance view
- [ ] Navigation: Floorplan -> Room -> Instance detail

*Rationale*: Get read-only viewing working before edit capabilities.

---

#### **Phase 4B: Room Editing & Deletion**
- [ ] Instance editor widget (editable)
- [ ] Edit Type widget (from instance context)
- [ ] Room notes editing
- [ ] Delete asset/room note with confirmation
- [ ] Core Data save/refresh on edit

*Rationale*: Editing is more complex and benefits from having read-only working first.

---

#### **Phase 4C: Testing Sprint 1** (NEW)
- [ ] Unit tests: Core services (ParameterValidator, StableID, GeometryUtils)
- [ ] Unit tests: Models encoding/decoding
- [ ] Integration tests: DemoDataSeeder
- [ ] ViewModel tests: AddAssetWizardViewModel state transitions

*Rationale*: Testing early catches bugs before they compound. Phases 1-3 have testable code that should be covered before adding more features.

---

#### **Phase 5A: Survey Report - Rooms**
- [ ] Survey hub shell with tab navigation
- [ ] Rooms list view with level grouping
- [ ] Room list search and filtering
- [ ] Navigation from room list to room view
- [ ] Empty room indicator and quick-add

---

#### **Phase 5B: Survey Report - Types & Export**
- [ ] Types list view with family grouping
- [ ] Type filtering by family and parameters
- [ ] Edit Type widget from types list
- [ ] Export data generation (JSON/CSV)
- [ ] iOS share sheet integration

*Rationale*: Splitting Survey Hub lets you ship incrementally. Rooms list is more critical for operators than Types list.

---

#### **Phase 6A: Photo Capture Implementation** (NEW - moved from implicit)
- [ ] PHPickerViewController integration
- [ ] JPEG compression (1280px, 0.8 quality)
- [ ] LocalFileCache integration
- [ ] Photo deletion handling
- [ ] Camera permission flows

*Rationale*: Photo capture is currently missing despite Phase 3 being "complete". This deserves its own phase.

---

#### **Phase 6B: Sync Foundation**
- [ ] Event log upload pipeline
- [ ] API client implementation (real endpoints)
- [ ] Offline queue management
- [ ] Basic sync status indicator

---

#### **Phase 6C: Sync Completion**
- [ ] Photo upload queue with background tasks
- [ ] Exponential backoff retry (cap at 5 min)
- [ ] Sync status UI refinement
- [ ] Conflict detection (not resolution for MVP)

*Rationale*: Sync is complex. Breaking it into foundation + completion prevents a monolithic phase.

---

#### **Phase 7A: Read-Only Mode**
- [ ] Completed project detection
- [ ] Warning popup on open
- [ ] Halftone styling for read-only
- [ ] Disabled interactions (add, edit, delete)

*Rationale*: Read-only mode is a distinct feature that affects many views. Better as its own phase than buried in hardening.

---

#### **Phase 7B: Testing Sprint 2**
- [ ] UI tests: Critical user flows
- [ ] Integration tests: Sync pipeline
- [ ] Performance tests: Large project loading
- [ ] Snapshot tests: Key UI components

---

#### **Phase 7C: Hardening & Polish**
- [ ] Validation rules tied to schema
- [ ] Error states and user-friendly alerts
- [ ] Performance profiling and fixes
- [ ] Memory leak audit
- [ ] Final QA pass

---

### Visual Comparison

| Current Structure | Recommended Structure |
|-------------------|----------------------|
| Phase 4: Room Management | Phase 4A: Room View (read-only) |
| | Phase 4B: Room Editing |
| | Phase 4C: Testing Sprint 1 |
| Phase 5: Survey Hub + Export | Phase 5A: Survey Report - Rooms |
| | Phase 5B: Survey Report - Types & Export |
| Phase 6: Synchronization | Phase 6A: Photo Capture |
| | Phase 6B: Sync Foundation |
| | Phase 6C: Sync Completion |
| Phase 7: Hardening + QA | Phase 7A: Read-Only Mode |
| | Phase 7B: Testing Sprint 2 |
| | Phase 7C: Hardening & Polish |

---

### Phase Priority Matrix

If you need to ship faster, here's what's essential vs. deferrable:

| Phase | Essential for MVP | Can Defer |
|-------|-------------------|-----------|
| 4A Room View | Yes | - |
| 4B Room Editing | Yes | - |
| 4C Testing Sprint 1 | Highly recommended | Technically yes |
| 5A Survey Rooms | Yes | - |
| 5B Survey Types/Export | Types list deferrable | Export essential |
| 6A Photo Capture | **Critical - currently missing** | - |
| 6B Sync Foundation | Yes | - |
| 6C Sync Completion | Photo upload essential | Backoff can simplify |
| 7A Read-Only Mode | Yes (per spec) | - |
| 7B Testing Sprint 2 | Highly recommended | Technically yes |
| 7C Hardening | Essential | Some items deferrable |

---

## Part 3: Immediate Action Items

### Before Starting Phase 4

1. **Fix Photo Capture Gap**
   Phase 3 claims photo handling complete but it's placeholder code. Either:
   - Update PROGRESS.md to mark incomplete
   - Implement actual capture before proceeding

2. **Add Minimum Tests**
   At least cover `ParameterValidator` and `StableID` - these are critical for data integrity.

3. **Refactor Large Files**
   Split `AddAssetWizardViewModel` before it grows larger. Suggested split:
   - `AddAssetWizardViewModel+Navigation.swift`
   - `AddAssetWizardViewModel+Persistence.swift`
   - `AddAssetWizardViewModel+Validation.swift`

4. **Document Magic Numbers**
   Create constants in DesignSystem for dimensions used across views.

5. **Audit Core Data Relationships**
   Decide on cascade vs. nullify for each relationship and document why.

---

## Summary

The codebase has solid foundations with good architecture decisions. The main concerns are:

1. **Testing is absent** - biggest risk
2. **Photo capture isn't implemented** - Phase 3 incomplete
3. **Large files need refactoring** - technical debt accumulating
4. **Error handling is inconsistent** - silent failures

The recommended phase restructuring introduces testing earlier, breaks large phases into deliverable chunks, and makes the missing photo capture explicit. This reduces risk and enables incremental shipping.
