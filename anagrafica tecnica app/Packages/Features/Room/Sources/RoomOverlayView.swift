import Core
import CoreData
import DesignSystem
import SwiftUI

public struct RoomOverlayView: View {
    @StateObject private var viewModel: RoomViewModel
    @State private var selectedItem: RoomItem?

    private let onClose: () -> Void
    private let onAddAsset: () -> Void
    private let onOpenSurvey: () -> Void

    public init(
        levelName: String,
        roomNumber: String,
        roomName: String?,
        context: NSManagedObjectContext,
        onClose: @escaping () -> Void,
        onAddAsset: @escaping () -> Void,
        onOpenSurvey: @escaping () -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: RoomViewModel(
                context: context,
                levelName: levelName,
                roomNumber: roomNumber,
                roomName: roomName
            )
        )
        self.onClose = onClose
        self.onAddAsset = onAddAsset
        self.onOpenSurvey = onOpenSurvey
    }

    public var body: some View {
        GeometryReader { proxy in
            let totalHeight = proxy.size.height
            let safeTop = proxy.safeAreaInsets.top
            let safeBottom = proxy.safeAreaInsets.bottom
            let sheetHeight = sheetHeight(for: viewModel.items.count, totalHeight: totalHeight)
            let topPadding = safeTop
            let bottomBarWidth = min(
                proxy.size.width * AppMetrics.roomBottomBarWidthRatio,
                proxy.size.width - AppSpacing.xl * 2
            )

            VStack(spacing: AppSpacing.xs) {
                RoomTopBar(
                    levelName: viewModel.levelName,
                    roomLabel: viewModel.roomLabel,
                    onClose: onClose
                )
                .frame(height: AppMetrics.roomOverlayTopBarHeight)
                .padding(.top, topPadding)
                .allowsHitTesting(true)

                Spacer(minLength: AppSpacing.sm)

                RoomBottomSheet(
                    items: viewModel.items,
                    height: sheetHeight,
                    onSelectItem: { selectedItem = $0 }
                )
                .allowsHitTesting(true)

                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    RoomBottomBar(
                        onAddAsset: onAddAsset,
                        onOpenSurvey: onOpenSurvey
                    )
                    .frame(width: bottomBarWidth)
                    .allowsHitTesting(true)
                    Spacer(minLength: 0)
                }
                .frame(height: AppMetrics.roomBottomBarHeight)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, max(0, safeBottom - AppSpacing.xs))
        }
        .sheet(item: $selectedItem) { item in
            switch item.kind {
            case .asset(let snapshot):
                AssetInstanceDetailView(snapshot: snapshot)
            case .roomNote(let snapshot):
                RoomNoteDetailView(snapshot: snapshot)
            }
        }
        .onAppear {
            viewModel.reload()
        }
    }

    private func sheetHeight(for itemCount: Int, totalHeight: CGFloat) -> CGFloat {
        let maxHeight = totalHeight * AppMetrics.roomSheetMaxHeightFraction
        let rowCount = max(1, itemCount)
        let contentHeight = AppMetrics.roomSheetHeaderHeight
            + CGFloat(rowCount) * AppMetrics.roomSheetRowHeight
            + AppSpacing.lg
        let minHeight = AppMetrics.roomSheetHeaderHeight
            + AppMetrics.roomSheetRowHeight
            + AppSpacing.md
        return min(maxHeight, max(minHeight, contentHeight))
    }
}

private struct RoomTopBar: View {
    let levelName: String
    let roomLabel: String
    let onClose: () -> Void

    var body: some View {
        ZStack {
            VStack(spacing: 2) {
                Text(levelName)
                    .font(AppTypography.badge)
                    .foregroundStyle(AppColors.textSecondary)
                Text(roomLabel)
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(AppColors.textPrimary)
            }
            HStack {
                Button(action: onClose) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: AppMetrics.roomRowIconSize, weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(width: AppMetrics.roomRowIconFrame, height: AppMetrics.roomRowIconFrame)
                        .background(
                            Circle().fill(AppColors.cardBackground.opacity(0.95))
                        )
                }
                Spacer()
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: AppMetrics.roomRowIconSize, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(width: AppMetrics.roomRowIconFrame, height: AppMetrics.roomRowIconFrame)
                    .background(
                        Circle().fill(AppColors.cardBackground.opacity(0.95))
                    )
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct RoomBottomSheet: View {
    let items: [RoomItem]
    let height: CGFloat
    let onSelectItem: (RoomItem) -> Void

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            HStack {
                Text("Assets & Room Notes")
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Text("\(items.count)")
                    .font(AppTypography.metricLabel)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .frame(height: AppMetrics.roomSheetHeaderHeight)

            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.sm) {
                    ForEach(items) { item in
                        Button {
                            onSelectItem(item)
                        } label: {
                            RoomItemRow(item: item)
                                .frame(minHeight: AppMetrics.roomSheetRowHeight)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, AppSpacing.xs)
            }
            .frame(maxHeight: height - AppMetrics.roomSheetHeaderHeight - AppSpacing.sm)
        }
        .padding(AppSpacing.lg)
        .frame(height: height)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card)
                .fill(AppColors.cardBackground.opacity(0.96))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.card)
                        .stroke(AppColors.cardBorder, lineWidth: AppMetrics.cardStrokeWidth)
                )
        )
        .shadow(color: AppShadow.card.color, radius: AppShadow.card.radius, x: AppShadow.card.x, y: AppShadow.card.y)
    }
}

private struct RoomBottomBar: View {
    let onAddAsset: () -> Void
    let onOpenSurvey: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Button(action: onOpenSurvey) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: AppMetrics.roomRowIconSize, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, minHeight: AppMetrics.roomBottomBarHeight - AppSpacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.field)
                            .fill(AppColors.cardBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.field)
                            .stroke(AppColors.cardBorder, lineWidth: AppMetrics.cardStrokeWidth)
                    )
            }

            Button(action: onAddAsset) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Asset")
                        .font(AppTypography.bodyEmphasis)
                }
                .frame(maxWidth: .infinity, minHeight: AppMetrics.roomBottomBarHeight - AppSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.field)
                        .fill(AppColors.accent.opacity(0.15))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.field)
                        .stroke(AppColors.accent, lineWidth: AppMetrics.cardStrokeWidth)
                )
            }
        }
        .frame(maxWidth: .infinity)
    }
}
