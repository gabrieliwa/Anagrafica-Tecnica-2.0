# UI Structure Proposal — Persistent Floor Map + Overlay Chrome (iOS / SwiftUI)

## Goal
Build a UI where:
- A **GeoJSON floor map** is the **persistent background** (pan/zoom always available).
- Standard **top/bottom navigation bars** appear in the default “browse” mode.
- When the user taps a room:
  - The background map **does not change screens**.
  - The map **animates to center** on the selected room.
  - Browse bars **disappear** and a **room-focused overlay UI** appears:
    - Top bar: back + room title + sync
    - Middle: overlay panel listing assets in room
    - Bottom: two primary actions

---

## Core principle
**One screen owns the map.**  
Everything else is an **overlay layer** that swaps based on a single UI state.

This avoids:
- Rebuilding the map (losing pan/zoom state)
- Stacking multiple “screens” in the view hierarchy (the “deck of cards” effect)
- Nested `NavigationStack` / repeated `sheet` presentations

---

## Recommended architecture
### Layer model (ZStack)
1) **Map layer (always present)**
- GeoJSON floor map renderer
- Handles pan/zoom gestures
- Exposes camera control:
  - `center(on roomID, animated: true)`
  - `highlight(roomID)`
  - `clearHighlight()`

2) **Browse chrome overlay (default mode)**
- Top navigation bar (global actions)
- Bottom bar (primary app sections / actions)

3) **Room overlay (selected room mode)**
- Top bar: back + title + sync
- **Bottom sheet / overlay panel** listing room assets
- Bottom actions (either pinned or inside the sheet)

---

## State model (simple + robust)
Use a single source of truth for the UI mode:

```swift
enum AppMode: Equatable {
  case browse
  case room(roomID: RoomID)
}
```

Store in a `@StateObject` / `ObservableObject`:
- `@Published var mode: AppMode`
- `@Published var selectedRoomID: RoomID?` (optional if redundant)
- `@Published var roomAssets: [Asset]` (or fetched on demand)

---

## Interaction flow
### Tap a room
1. Determine `roomID`
2. Update state:
   - `mode = .room(roomID: roomID)`
3. Map camera:
   - `mapController.center(on: roomID, animated: true)`
   - `mapController.highlight(roomID)`
4. Show room overlay (bars/panels), hide browse chrome

### Back from room overlay
1. `mode = .browse`
2. `mapController.clearHighlight()` (optional)
3. Restore browse chrome

---

## SwiftUI composition (concept)
Top-level screen:

```swift
struct FloorMapScreen: View {
  @StateObject var vm: FloorMapViewModel
  @StateObject var mapController = MapController()

  var body: some View {
    ZStack {
      FloorMapView(controller: mapController,
                   geojson: vm.geojson,
                   selectedRoomID: vm.selectedRoomID)

      switch vm.mode {
      case .browse:
        BrowseChromeOverlay(
          topBar: { BrowseTopBar(...) },
          bottomBar: { BrowseBottomBar(...) }
        )

      case .room(let roomID):
        RoomOverlay(
          roomID: roomID,
          onBack: {
            vm.mode = .browse
            mapController.clearHighlight()
          },
          onSync: { vm.syncRoom(roomID) },
          assets: vm.assets(for: roomID),
          primaryAction: { vm.doPrimary(roomID) },
          secondaryAction: { vm.doSecondary(roomID) }
        )
      }
    }
  }
}
```

**Key idea:** the `FloorMapView` stays mounted regardless of mode. Only overlays switch.

---

## Room assets panel: best choice
### Preferred: bottom sheet style (keeps context)
- Keeps map visible and maintains spatial context
- Can support detents (collapsed/medium/large)
- Can be interactive while still showing the room highlight

Implementation options:
1) SwiftUI `.sheet` with detents (fastest)
2) Custom in-ZStack draggable panel (more control)

**Recommendation:** start with `.sheet` + detents if it fits your UX; switch to custom if you need deeper gesture coordination with map.

---

## Gesture coordination (important)
When the room overlay is open:
- The map should usually still allow **pan/zoom**, unless the user is interacting with the sheet.
- If you implement a custom draggable panel, consider:
  - `hitTest` layering (panel captures touches)
  - simultaneous gestures vs exclusive gestures

---

## Keep map state stable (avoid rebuilds)
- Use a dedicated controller object (`MapController`) that survives overlay swaps.
- Don’t recreate the map renderer on every state change.
- Keep expensive GeoJSON parsing/caching outside the SwiftUI body (e.g., view model / renderer cache).

---

## Common pitfalls to avoid
- **Nested `NavigationStack`** (often causes “extra screens” in Debug View Hierarchy)
- Driving room selection via a navigation push to a different screen (forces map recreation)
- Multiple simultaneous `.sheet` / `.fullScreenCover` layers from different subviews
  - Prefer a single sheet driven by the floor map screen (Add Asset + item detail)
- Leaving the system navigation bar enabled on the floorplan screen (use a custom top bar for consistent overlay layout)
- Rebuilding map view when `mode` changes (loses zoom/offset)

---

## Recommended component breakdown
- `FloorMapScreen` (root for this feature)
- `FloorMapView` (rendering + gestures)
- `MapController` (camera control + highlighting API)
- `BrowseTopBar`, `BrowseBottomBar`
- `RoomTopBar` (back/title/sync)
- `RoomAssetsPanel` (sheet/panel content)
- `RoomBottomActions` (two buttons)

---

## Notes for the GeoJSON renderer
- Precompute room bounds (min/max or polygon bounding box) for `center(on:)`.
- Provide a “room hit test” function to map tap location → roomID.
- Highlight selected room with a distinct stroke/fill layer.

---

## Summary
Use **one persistent map view** + **overlay UI layers** controlled by a single `mode` state.
This yields:
- stable pan/zoom
- clean transitions (overlay swap + camera move)
- minimal navigation complexity
- fewer weird view-hierarchy artifacts
