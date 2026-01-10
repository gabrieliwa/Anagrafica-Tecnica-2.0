import Core
import CoreData
import DesignSystem
import SwiftUI

public struct RoomView: View {
    @StateObject private var viewModel: RoomViewModel

    public init(levelName: String, roomNumber: String, roomName: String?, context: NSManagedObjectContext) {
        _viewModel = StateObject(
            wrappedValue: RoomViewModel(
                context: context,
                levelName: levelName,
                roomNumber: roomNumber,
                roomName: roomName
            )
        )
    }

    public var body: some View {
        ZStack {
            AppGradients.page
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    if let geometry = viewModel.roomGeometry {
                        RoomPlanCard(geometry: geometry, roomLabel: viewModel.roomLabel)
                    } else if let message = viewModel.errorMessage {
                        ErrorState(message: message)
                    } else {
                        ErrorState(message: "Room plan unavailable.")
                    }

                    RoomItemsList(items: viewModel.items)
                }
                .padding(AppSpacing.xl)
                .padding(.bottom, AppSpacing.xl)
            }
        }
        .navigationTitle(viewModel.titleText)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.reload()
        }
    }
}

private struct RoomPlanCard: View {
    let geometry: RoomGeometry
    let roomLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(roomLabel)
                .font(AppTypography.section)
                .foregroundStyle(AppColors.textPrimary)

            RoomPlanView(geometry: geometry)
                .frame(height: AppMetrics.roomPlanHeight)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.card)
                        .fill(AppColors.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.card)
                                .stroke(AppColors.cardBorder, lineWidth: AppMetrics.cardStrokeWidth)
                        )
                )
        }
    }
}

private struct RoomPlanView: View {
    let geometry: RoomGeometry

    var body: some View {
        GeometryReader { proxy in
            Canvas { context, size in
                let polygon = geometry.polygon
                guard polygon.count >= 3 else { return }
                let bounds = geometry.bounds ?? GeometryUtils.bounds(for: polygon)
                guard let bounds else { return }
                let transform = RoomPlanTransform(bounds: bounds, size: size)

                var path = Path()
                if let first = polygon.first {
                    path.move(to: transform.point(first))
                }
                for point in polygon.dropFirst() {
                    path.addLine(to: transform.point(point))
                }
                path.closeSubpath()

                context.fill(path, with: .color(AppColors.roomEmptyFill))
                context.stroke(path, with: .color(AppColors.roomEmptyStroke), lineWidth: AppMetrics.floorplanRoomStrokeWidth)
            }
        }
    }
}

private struct RoomPlanTransform {
    let bounds: Rect
    let size: CGSize

    private var scale: CGFloat {
        let width = CGFloat(bounds.maxX - bounds.minX)
        let height = CGFloat(bounds.maxY - bounds.minY)
        guard width > 0, height > 0 else { return 1 }
        let base = min(size.width / width, size.height / height)
        return base * AppMetrics.floorplanFitScale
    }

    private var offset: CGPoint {
        let width = CGFloat(bounds.maxX - bounds.minX)
        let height = CGFloat(bounds.maxY - bounds.minY)
        let scaledWidth = width * scale
        let scaledHeight = height * scale
        return CGPoint(
            x: (size.width - scaledWidth) * 0.5,
            y: (size.height - scaledHeight) * 0.5
        )
    }

    func point(_ point: Point) -> CGPoint {
        CGPoint(
            x: (CGFloat(point.x - bounds.minX) * scale) + offset.x,
            y: (CGFloat(bounds.maxY - point.y) * scale) + offset.y
        )
    }
}

private struct ErrorState: View {
    let message: String

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("Room View")
                .font(AppTypography.section)
                .foregroundStyle(AppColors.textPrimary)
            Text(message)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
