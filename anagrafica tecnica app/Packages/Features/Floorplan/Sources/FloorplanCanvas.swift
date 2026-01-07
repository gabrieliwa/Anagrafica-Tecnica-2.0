import Core
import DesignSystem
import SwiftUI

struct FloorplanCanvas: View {
    let linework: [[Point]]
    let rooms: [FloorplanRoom]
    let bounds: Rect?
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
                Canvas { context, canvasSize in
                    let localTransform = FloorplanTransform(bounds: bounds, size: canvasSize)
                    drawLinework(lines: linework, transform: localTransform, context: &context)
                    drawRooms(rooms: rooms, transform: localTransform, context: &context)
                }
                .scaleEffect(zoomScale, anchor: .topLeading)
                .offset(panOffset)
                .gesture(dragGesture(transform: transform))
                .simultaneousGesture(magnificationGesture)
                .frame(width: size.width, height: size.height)
            } else {
                Text("No floorplan bounds")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(width: size.width, height: size.height)
            }
        }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                zoomScale = clamp(lastScale * value, min: 0.5, max: 5.0)
            }
            .onEnded { _ in
                lastScale = zoomScale
            }
    }

    private func dragGesture(transform: FloorplanTransform) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                panOffset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { value in
                let translation = value.translation
                let isTap = abs(translation.width) < 4 && abs(translation.height) < 4
                if isTap {
                    panOffset = lastOffset
                    handleTap(location: value.location, transform: transform)
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
        context: inout GraphicsContext
    ) {
        var path = Path()
        for line in lines {
            guard let first = line.first else { continue }
            path.move(to: transform.point(first))
            for point in line.dropFirst() {
                path.addLine(to: transform.point(point))
            }
        }
        context.stroke(path, with: .color(AppColors.planLinework), lineWidth: 1)
    }

    private func drawRooms(
        rooms: [FloorplanRoom],
        transform: FloorplanTransform,
        context: inout GraphicsContext
    ) {
        for room in rooms {
            guard let first = room.polygon.first else { continue }
            var roomPath = Path()
            roomPath.move(to: transform.point(first))
            for point in room.polygon.dropFirst() {
                roomPath.addLine(to: transform.point(point))
            }
            roomPath.closeSubpath()

            context.fill(roomPath, with: .color(AppColors.roomEmptyFill))
            context.stroke(roomPath, with: .color(AppColors.roomEmptyStroke), lineWidth: 1.5)

            if let label = room.labelPoint {
                let labelPoint = transform.point(label)
                let iconPath = Path(ellipseIn: CGRect(x: labelPoint.x - 12, y: labelPoint.y - 12, width: 24, height: 24))
                context.stroke(iconPath, with: .color(AppColors.roomEmptyIcon), lineWidth: 1.5)
                context.stroke(Path(CGRect(x: labelPoint.x - 6, y: labelPoint.y - 0.75, width: 12, height: 1.5)), with: .color(AppColors.roomEmptyIcon), lineWidth: 1.5)
                context.stroke(Path(CGRect(x: labelPoint.x - 0.75, y: labelPoint.y - 6, width: 1.5, height: 12)), with: .color(AppColors.roomEmptyIcon), lineWidth: 1.5)
            }
        }
    }

    private func handleTap(location: CGPoint, transform: FloorplanTransform) {
        let adjusted = CGPoint(
            x: (location.x - panOffset.width) / max(zoomScale, 0.0001),
            y: (location.y - panOffset.height) / max(zoomScale, 0.0001)
        )
        let planPoint = transform.planPoint(from: adjusted)
        if let room = rooms.first(where: { GeometryUtils.contains(point: planPoint, in: $0.polygon) }) {
            onRoomTapped(room)
        }
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
        let scale = min(size.width / width, size.height / height) * 0.92
        let offsetX = (size.width - width * scale) * 0.5
        let offsetY = (size.height - height * scale) * 0.5
        self.scale = scale
        self.offset = CGPoint(x: offsetX, y: offsetY)
    }

    func point(_ point: Point) -> CGPoint {
        let x = (point.x - bounds.minX) * scale + offset.x
        let y = (bounds.maxY - point.y) * scale + offset.y
        return CGPoint(x: x, y: y)
    }

    func planPoint(from point: CGPoint) -> Point {
        let x = (point.x - offset.x) / scale + bounds.minX
        let y = bounds.maxY - (point.y - offset.y) / scale
        return Point(x: x, y: y)
    }
}
