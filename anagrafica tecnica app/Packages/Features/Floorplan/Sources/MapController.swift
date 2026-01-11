import Core
import DesignSystem
import SwiftUI

// MARK: - PlanMode

/// Single source of truth for UI mode within the planimetric workflow.
/// The floor plan is persistent ONLY within these two modes - it does not
/// need to remain visible outside of the planimetric workflow (e.g., Reports).
public enum PlanMode: Equatable {
    /// Default mode: user navigates the floor plan (pan/zoom), browse chrome visible
    case browse
    /// Room selected: same floor plan instance, camera animates to room, room overlay visible
    case room(roomID: String)

    var selectedRoomID: String? {
        if case .room(let id) = self {
            return id
        }
        return nil
    }
}

// MARK: - MapController

/// Abstraction responsible for map interactions:
/// - Hit-testing tap location to find roomID
/// - Highlighting selected room
/// - Computing room bounds (for centering/zoom-to-fit)
/// - Performing smooth camera/viewport animations
///
/// This controller keeps the FloorplanCanvas stateless and separates
/// viewport logic from view rendering.
@MainActor
final class MapController: ObservableObject {

    // MARK: - Published State

    @Published var viewport: FloorplanViewport = FloorplanViewport()

    // MARK: - Private State

    private var preRoomViewport: FloorplanViewport?
    private var rooms: [FloorplanRoom] = []
    private var bounds: Rect?

    // MARK: - Configuration

    /// Update rooms and bounds when level changes
    func configure(rooms: [FloorplanRoom], bounds: Rect?) {
        self.rooms = rooms
        self.bounds = bounds
    }

    // MARK: - Hit Testing

    /// Hit-test a screen point to find which room was tapped.
    /// Returns nil if tap is outside all room polygons.
    func hitTest(screenPoint: CGPoint, canvasSize: CGSize) -> FloorplanRoom? {
        guard let bounds = bounds else { return nil }
        let transform = FloorplanTransform(bounds: bounds, size: canvasSize)
        let center = CGPoint(x: canvasSize.width * 0.5, y: canvasSize.height * 0.5)

        // Reverse the viewport transformation to get the untransformed screen point
        let adjusted = CGPoint(
            x: (screenPoint.x - viewport.offset.width - center.x) / max(viewport.scale, AppMetrics.floorplanZoomEpsilon) + center.x,
            y: (screenPoint.y - viewport.offset.height - center.y) / max(viewport.scale, AppMetrics.floorplanZoomEpsilon) + center.y
        )
        let planPoint = transform.planPoint(from: adjusted)

        return rooms.first { GeometryUtils.contains(point: planPoint, in: $0.polygon) }
    }

    // MARK: - Room Bounds

    /// Compute the bounding rect for a room in plan coordinates.
    func roomBounds(for room: FloorplanRoom) -> Rect? {
        GeometryUtils.bounds(for: room.polygon)
    }

    // MARK: - Camera Animations

    /// Focus on a room: animate the viewport so the room is centered within
    /// the available screen area (accounting for overlays).
    ///
    /// - Parameters:
    ///   - room: The room to focus on
    ///   - canvasSize: Full canvas size
    ///   - topInset: Space taken by top bar
    ///   - bottomInset: Space taken by bottom sheet + bottom bar
    ///   - preserveCurrentViewport: If true, saves current viewport for later restoration
    func focusOnRoom(
        _ room: FloorplanRoom,
        canvasSize: CGSize,
        topInset: CGFloat,
        bottomInset: CGFloat,
        preserveCurrentViewport: Bool = true
    ) {
        guard let bounds = bounds else { return }
        guard let roomBounds = GeometryUtils.bounds(for: room.polygon) else { return }

        // Save current viewport for restoration when exiting room mode
        if preserveCurrentViewport {
            preRoomViewport = viewport
        }

        let transform = FloorplanTransform(bounds: bounds, size: canvasSize)

        let availableHeight = max(1, canvasSize.height - topInset - bottomInset)
        let availableWidth = canvasSize.width

        let roomWidth = CGFloat(roomBounds.maxX - roomBounds.minX) * transform.scale
        let roomHeight = CGFloat(roomBounds.maxY - roomBounds.minY) * transform.scale
        guard roomWidth > 0, roomHeight > 0 else { return }

        // Calculate zoom limits based on smallest room
        let zoomBounds = computeZoomLimits(transform: transform, canvasSize: canvasSize)

        // Target scale to fit room with padding
        let targetScale = clamp(
            min(availableWidth / roomWidth, availableHeight / roomHeight) * AppMetrics.roomFocusPaddingScale,
            min: zoomBounds.min,
            max: zoomBounds.max
        )

        // Calculate offset to center room in available area
        let roomCenter = Point(
            x: (roomBounds.minX + roomBounds.maxX) * 0.5,
            y: (roomBounds.minY + roomBounds.maxY) * 0.5
        )
        let baseCenter = transform.point(roomCenter)
        let viewCenter = CGPoint(x: canvasSize.width * 0.5, y: canvasSize.height * 0.5)
        let desiredCenter = CGPoint(x: viewCenter.x, y: topInset + availableHeight * 0.5)

        let targetOffset = CGSize(
            width: desiredCenter.x - (viewCenter.x + (baseCenter.x - viewCenter.x) * targetScale),
            height: desiredCenter.y - (viewCenter.y + (baseCenter.y - viewCenter.y) * targetScale)
        )

        withAnimation(.easeOut(duration: AppMetrics.roomFocusAnimationDuration)) {
            viewport = FloorplanViewport(scale: targetScale, offset: targetOffset)
        }
    }

    /// Reset viewport to default (or restore pre-room viewport if available).
    ///
    /// - Parameter restorePreviousViewport: If true, restores the viewport from before
    ///   room focus; if false, resets to default (scale 1.0, zero offset).
    func resetViewport(restorePreviousViewport: Bool = false) {
        if restorePreviousViewport, let previous = preRoomViewport {
            withAnimation(.easeOut(duration: AppMetrics.roomFocusAnimationDuration)) {
                viewport = previous
            }
        } else {
            withAnimation(.easeOut(duration: AppMetrics.roomFocusAnimationDuration)) {
                viewport = FloorplanViewport()
            }
        }
        preRoomViewport = nil
    }

    /// Reset viewport immediately (no animation) - used when changing levels.
    func resetViewportImmediate() {
        viewport = FloorplanViewport()
        preRoomViewport = nil
    }

    // MARK: - Zoom Limits

    /// Compute dynamic zoom limits based on the smallest room.
    func computeZoomLimits(transform: FloorplanTransform, canvasSize: CGSize) -> (min: CGFloat, max: CGFloat) {
        let minZoom = AppMetrics.floorplanMinZoom
        var smallestBounds: Rect?
        var smallestArea: Double = .infinity

        for room in rooms {
            guard let bounds = GeometryUtils.bounds(for: room.polygon) else { continue }
            let width = bounds.maxX - bounds.minX
            let height = bounds.maxY - bounds.minY
            guard width > 0, height > 0 else { continue }
            let area = width * height
            if area < smallestArea {
                smallestArea = area
                smallestBounds = bounds
            }
        }

        guard let bounds = smallestBounds else {
            return (minZoom, AppMetrics.floorplanDefaultMaxZoom)
        }

        let roomWidth = CGFloat(bounds.maxX - bounds.minX) * transform.scale
        let roomHeight = CGFloat(bounds.maxY - bounds.minY) * transform.scale
        guard roomWidth > 0, roomHeight > 0 else {
            return (minZoom, AppMetrics.floorplanDefaultMaxZoom)
        }

        let maxZoomX = canvasSize.width / roomWidth
        let maxZoomY = canvasSize.height / roomHeight
        let maxZoom = max(minZoom, min(maxZoomX, maxZoomY))
        return (minZoom, maxZoom)
    }

    // MARK: - Helpers

    private func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        Swift.max(min, Swift.min(max, value))
    }
}

// MARK: - Room Sheet Height Calculator

/// Helper to calculate the room sheet height based on item count and available space.
struct RoomSheetLayout {
    let safeTop: CGFloat
    let safeBottom: CGFloat
    let screenSize: CGSize

    /// Calculate sheet height for given item count
    func sheetHeight(for itemCount: Int) -> CGFloat {
        let margin = AppSpacing.lg
        let availableForSheet = screenSize.height - safeTop - safeBottom - margin
            - AppMetrics.roomOverlayTopBarHeight
            - AppMetrics.roomBottomBarHeight
            - AppSpacing.sm * 2

        let maxHeight = availableForSheet * AppMetrics.roomSheetMaxHeightFraction
        let rowCount = max(1, itemCount)
        let internalPadding = AppSpacing.lg * 2 + AppSpacing.sm
        let contentHeight = AppMetrics.roomSheetHeaderHeight
            + CGFloat(rowCount) * AppMetrics.roomSheetRowHeight
            + internalPadding
        let minHeight = AppMetrics.roomSheetHeaderHeight
            + AppMetrics.roomSheetRowHeight
            + internalPadding

        return min(maxHeight, max(minHeight, contentHeight))
    }

    /// Calculate top inset for room focus (top bar area)
    var topInset: CGFloat {
        safeTop + AppMetrics.roomOverlayTopBarHeight
    }

    /// Calculate bottom inset for room focus (sheet + bottom bar area)
    func bottomInset(for itemCount: Int) -> CGFloat {
        let margin = AppSpacing.lg
        return safeBottom + margin + sheetHeight(for: itemCount) + AppMetrics.roomBottomBarHeight + AppSpacing.sm
    }
}
