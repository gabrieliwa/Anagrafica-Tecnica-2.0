import Core
import DesignSystem
import SwiftUI

struct FloorplanCanvas: View {
    let linework: [[Point]]
    let rooms: [FloorplanRoom]
    let bounds: Rect?
    let isReadOnly: Bool
    let onRoomTapped: (FloorplanRoom) -> Void

    @State private var zoomScale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var panOffset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            if let bounds {
                let transform = FloorplanTransform(bounds: bounds, size: size)
                let zoomBounds = zoomLimits(for: rooms, transform: transform, canvasSize: size)
                let viewCenter = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
                ZStack {
                    Canvas { context, canvasSize in
                        let localTransform = FloorplanTransform(bounds: bounds, size: canvasSize)
                        let canvasCenter = CGPoint(x: canvasSize.width * 0.5, y: canvasSize.height * 0.5)
                        context.translateBy(x: panOffset.width, y: panOffset.height)
                        context.translateBy(x: canvasCenter.x, y: canvasCenter.y)
                        context.scaleBy(x: zoomScale, y: zoomScale)
                        context.translateBy(x: -canvasCenter.x, y: -canvasCenter.y)
                        drawLinework(lines: linework, transform: localTransform, isReadOnly: isReadOnly, context: &context)
                        drawRooms(rooms: rooms, transform: localTransform, isReadOnly: isReadOnly, context: &context)
                    }
                    roomBadges(transform: transform, canvasSize: size)
                        .allowsHitTesting(false)
                }
                .contentShape(Rectangle())
                .gesture(combinedGesture(transform: transform, zoomBounds: zoomBounds, center: viewCenter))
                .frame(width: size.width, height: size.height)
            } else {
                Text("No floorplan bounds")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(width: size.width, height: size.height)
            }
        }
    }

    private func magnificationGesture(zoomBounds: ZoomBounds) -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                zoomScale = clamp(lastScale * value, min: zoomBounds.min, max: zoomBounds.max)
            }
            .onEnded { _ in
                lastScale = zoomScale
            }
    }

    private func combinedGesture(transform: FloorplanTransform, zoomBounds: ZoomBounds, center: CGPoint) -> some Gesture {
        dragGesture(transform: transform, center: center)
            .simultaneously(with: magnificationGesture(zoomBounds: zoomBounds))
    }

    private func dragGesture(transform: FloorplanTransform, center: CGPoint) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                panOffset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { value in
                let translation = value.translation
                let isTap = abs(translation.width) < AppMetrics.floorplanTapThreshold
                    && abs(translation.height) < AppMetrics.floorplanTapThreshold
                if isTap {
                    panOffset = lastOffset
                    handleTap(location: value.location, transform: transform, center: center)
                } else {
                    lastOffset = panOffset
                }
            }
    }

    private func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        Swift.max(min, Swift.min(max, value))
    }

    private func drawLinework(
        lines: [[Point]],
        transform: FloorplanTransform,
        isReadOnly: Bool,
        context: inout GraphicsContext
    ) {
        let lineworkColor = isReadOnly ? AppColors.planLinework.opacity(0.45) : AppColors.planLinework
        var path = Path()
        for line in lines {
            guard let first = line.first else { continue }
            path.move(to: transform.point(first))
            for point in line.dropFirst() {
                path.addLine(to: transform.point(point))
            }
        }
        context.stroke(path, with: .color(lineworkColor), lineWidth: AppMetrics.floorplanLineWidth)
    }

    private func drawRooms(
        rooms: [FloorplanRoom],
        transform: FloorplanTransform,
        isReadOnly: Bool,
        context: inout GraphicsContext
    ) {
        let readOnlyOpacity: Double = isReadOnly ? 0.45 : 1.0

        for room in rooms {
            guard let first = room.polygon.first else { continue }
            var roomPath = Path()
            roomPath.move(to: transform.point(first))
            for point in room.polygon.dropFirst() {
                roomPath.addLine(to: transform.point(point))
            }
            roomPath.closeSubpath()

            let isOccupied = room.totalCount > 0
            let fillColor = isOccupied ? AppColors.roomOccupiedFill : AppColors.roomEmptyFill
            context.fill(roomPath, with: .color(fillColor.opacity(readOnlyOpacity)))
            context.stroke(
                roomPath,
                with: .color(AppColors.roomEmptyStroke.opacity(readOnlyOpacity)),
                lineWidth: AppMetrics.floorplanRoomStrokeWidth
            )
        }
    }

    private func handleTap(location: CGPoint, transform: FloorplanTransform, center: CGPoint) {
        guard !isReadOnly else { return }
        let adjusted = CGPoint(
            x: (location.x - panOffset.width - center.x) / max(zoomScale, AppMetrics.floorplanZoomEpsilon) + center.x,
            y: (location.y - panOffset.height - center.y) / max(zoomScale, AppMetrics.floorplanZoomEpsilon) + center.y
        )
        let planPoint = transform.planPoint(from: adjusted)
        if let room = rooms.first(where: { GeometryUtils.contains(point: planPoint, in: $0.polygon) }) {
            onRoomTapped(room)
        }
    }

    private struct ZoomBounds {
        let min: CGFloat
        let max: CGFloat
    }

    private func zoomLimits(
        for rooms: [FloorplanRoom],
        transform: FloorplanTransform,
        canvasSize: CGSize
    ) -> ZoomBounds {
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
            return ZoomBounds(min: minZoom, max: AppMetrics.floorplanDefaultMaxZoom)
        }

        let roomWidth = CGFloat(bounds.maxX - bounds.minX) * transform.scale
        let roomHeight = CGFloat(bounds.maxY - bounds.minY) * transform.scale
        guard roomWidth > 0, roomHeight > 0 else {
            return ZoomBounds(min: minZoom, max: AppMetrics.floorplanDefaultMaxZoom)
        }

        let maxZoomX = canvasSize.width / roomWidth
        let maxZoomY = canvasSize.height / roomHeight
        let maxZoom = max(minZoom, min(maxZoomX, maxZoomY))
        return ZoomBounds(min: minZoom, max: maxZoom)
    }

    private func roomBadges(transform: FloorplanTransform, canvasSize: CGSize) -> some View {
        let center = CGPoint(x: canvasSize.width * 0.5, y: canvasSize.height * 0.5)
        return ZStack {
            ForEach(rooms) { room in
                if let label = room.labelPoint {
                    let position = screenPoint(for: label, transform: transform, center: center)
                    RoomBadge(
                        count: room.totalCount,
                        isReadOnly: isReadOnly
                    )
                    .position(position)
                }
            }
        }
    }

    private func screenPoint(for point: Point, transform: FloorplanTransform, center: CGPoint) -> CGPoint {
        let base = transform.point(point)
        let scaled = CGPoint(
            x: center.x + (base.x - center.x) * zoomScale,
            y: center.y + (base.y - center.y) * zoomScale
        )
        return CGPoint(x: scaled.x + panOffset.width, y: scaled.y + panOffset.height)
    }
}

private struct RoomBadge: View {
    let count: Int
    let isReadOnly: Bool

    var body: some View {
        let isEmpty = count == 0
        let opacity = isReadOnly ? 0.45 : 1.0
        ZStack {
            Circle()
                .stroke(AppColors.roomEmptyIcon.opacity(opacity), lineWidth: AppMetrics.floorplanBadgeStrokeWidth)
            if isEmpty {
                Text("+")
                    .font(.system(size: AppMetrics.floorplanBadgePlusSize, weight: .bold))
                    .foregroundStyle(AppColors.roomEmptyIcon.opacity(opacity))
            } else {
                Text("\(count)")
                    .font(.system(size: AppMetrics.floorplanBadgeTextSize, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary.opacity(opacity))
            }
        }
        .frame(width: AppMetrics.floorplanBadgeSize, height: AppMetrics.floorplanBadgeSize)
    }
}

struct FloorplanTransform {
    let bounds: Rect
    let scale: CGFloat
    let offset: CGPoint

    init(bounds: Rect, size: CGSize) {
        self.bounds = bounds
        let width = bounds.maxX - bounds.minX
        let height = bounds.maxY - bounds.minY
        let scale = min(size.width / width, size.height / height) * AppMetrics.floorplanFitScale
        let offsetX = (size.width - width * scale) * 0.5
        let offsetY = (size.height - height * scale) * 0.5
        self.scale = scale
        self.offset = CGPoint(x: offsetX, y: offsetY)
    }

    func point(_ point: Point) -> CGPoint {
        // Convert plan coordinates into screen coordinates (origin flipped on Y).
        let x = (point.x - bounds.minX) * scale + offset.x
        let y = (bounds.maxY - point.y) * scale + offset.y
        return CGPoint(x: x, y: y)
    }

    func planPoint(from point: CGPoint) -> Point {
        // Convert screen coordinates back into plan coordinates.
        let x = (point.x - offset.x) / scale + bounds.minX
        let y = bounds.maxY - (point.y - offset.y) / scale
        return Point(x: x, y: y)
    }
}
