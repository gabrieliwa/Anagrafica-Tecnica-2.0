import AddAssetWizard
import Core
import DesignSystem
import Room
import SurveyReport
import SwiftUI

public struct FloorplanView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: FloorplanViewModel
    private let projectName: String
    private let uiState: ProjectUIState?
    @State private var mode: FloorplanMode = .browse
    @State private var activeSheet: ActiveSheet?
    @State private var isSurveyReportActive = false
    @State private var viewport = FloorplanViewport()
    @State private var roomOverlayRefreshToken = UUID()

    public init(projectName: String, uiState: ProjectUIState?, bundle: Bundle = .main) {
        _viewModel = StateObject(wrappedValue: FloorplanViewModel(bundle: bundle))
        self.projectName = projectName
        self.uiState = uiState
    }

    public var body: some View {
        ZStack {
            AppGradients.page
                .ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView("Loading floorplan")
                    .foregroundStyle(AppColors.textSecondary)
            } else if let message = viewModel.errorMessage {
                VStack(spacing: AppSpacing.sm) {
                    Text("Failed to load demo plan")
                        .font(AppTypography.section)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(message)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                }
            } else {
                floorplanContent
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var floorplanContent: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let safeTop = proxy.safeAreaInsets.top
            let safeBottom = proxy.safeAreaInsets.bottom
            let margin = AppSpacing.lg
            // Calculate available space for sheet (matching RoomOverlayView)
            let availableForSheet = size.height - safeTop - safeBottom - margin - AppMetrics.roomOverlayTopBarHeight - AppMetrics.roomBottomBarHeight - AppSpacing.sm * 2
            let sheetHeight = roomSheetHeight(for: selectedRoom?.totalCount ?? 1, availableHeight: availableForSheet)
            // Insets for room focus calculation (top bar at safeTop, bottom has margin)
            let topInset = safeTop + AppMetrics.roomOverlayTopBarHeight
            let bottomInset = safeBottom + margin + sheetHeight + AppMetrics.roomBottomBarHeight + AppSpacing.sm

            ZStack {
                FloorplanCanvas(
                    linework: viewModel.linework,
                    rooms: viewModel.roomsWithCounts,
                    bounds: viewModel.bounds,
                    isReadOnly: uiState == .completed,
                    selectedRoomId: selectedRoom?.id,
                    isRoomViewActive: isRoomViewActive,
                    onRoomTapped: { room in
                        handleRoomTap(
                            room,
                            canvasSize: size,
                            topInset: topInset,
                            bottomInset: bottomInset
                        )
                    },
                    viewport: $viewport
                )
                .id(viewModel.selectedLevelIndex)
                .ignoresSafeArea()

                if isRoomViewActive, let room = selectedRoom {
                    RoomOverlayView(
                        levelName: currentLevelName,
                        roomNumber: room.number,
                        roomName: room.name,
                        context: context,
                        layout: RoomOverlayLayout(
                            safeTop: safeTop,
                            safeBottom: safeBottom,
                            screenSize: size
                        ),
                        onClose: {
                            withAnimation(.easeOut(duration: AppMetrics.roomFocusAnimationDuration)) {
                                mode = .browse
                                viewport = FloorplanViewport()
                            }
                        },
                        onAddAsset: {
                            activeSheet = .addAsset(room)
                        },
                        onOpenSurvey: {
                            isSurveyReportActive = true
                        },
                        onSelectItem: { item in
                            activeSheet = .roomItem(item)
                        }
                    )
                    .ignoresSafeArea(edges: .all)
                    .id("\(room.id)-\(roomOverlayRefreshToken)")
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else {
                    BrowseChromeOverlay(
                        safeTop: safeTop,
                        safeBottom: safeBottom,
                        projectName: projectName,
                        showReadOnly: uiState == .completed,
                        levels: viewModel.levels,
                        selection: $viewModel.selectedLevelIndex,
                        onBack: { dismiss() },
                        onOpenSurvey: { isSurveyReportActive = true }
                    )
                }
            }
            .sheet(item: $activeSheet, onDismiss: handleSheetDismiss) { sheet in
                switch sheet {
                case .addAsset(let room):
                    AddAssetWizardView(
                        roomNumber: room.number,
                        roomName: room.name,
                        levelName: currentLevelName,
                        context: context
                    )
                case .roomItem(let item):
                    switch item.kind {
                    case .asset(let snapshot):
                        AssetInstanceDetailView(snapshot: snapshot)
                    case .roomNote(let snapshot):
                        RoomNoteDetailView(snapshot: snapshot)
                    }
                }
            }
            .background(
                NavigationLink(
                    destination: SurveyReportView(),
                    isActive: $isSurveyReportActive,
                    label: { EmptyView() }
                )
                .hidden()
            )
            .onAppear {
                viewModel.reloadRoomCounts(context: context)
            }
            .onChange(of: viewModel.selectedLevelIndex) { _ in
                viewModel.reloadRoomCounts(context: context)
                resetViewport()
            }
        }
    }

    private var currentLevelName: String {
        guard viewModel.levels.indices.contains(viewModel.selectedLevelIndex) else {
            return "Level"
        }
        return viewModel.levels[viewModel.selectedLevelIndex].name
    }

    private func handleRoomTap(
        _ room: FloorplanRoom,
        canvasSize: CGSize,
        topInset: CGFloat,
        bottomInset: CGFloat
    ) {
        if room.totalCount > 0 {
            // Animate both the room selection and the viewport change together
            withAnimation(.easeOut(duration: AppMetrics.roomFocusAnimationDuration)) {
                mode = .room(room)
            }
            focusOnRoom(room, canvasSize: canvasSize, topInset: topInset, bottomInset: bottomInset)
        } else {
            if isRoomViewActive {
                withAnimation(.easeOut(duration: AppMetrics.roomFocusAnimationDuration)) {
                    mode = .room(room)
                }
                focusOnRoom(room, canvasSize: canvasSize, topInset: topInset, bottomInset: bottomInset)
            }
            activeSheet = .addAsset(room)
        }
    }

    private func focusOnRoom(
        _ room: FloorplanRoom,
        canvasSize: CGSize,
        topInset: CGFloat,
        bottomInset: CGFloat
    ) {
        guard let bounds = viewModel.bounds else { return }
        guard let roomBounds = GeometryUtils.bounds(for: room.polygon) else { return }
        let transform = FloorplanTransform(bounds: bounds, size: canvasSize)

        let availableHeight = max(1, canvasSize.height - topInset - bottomInset)
        let availableWidth = canvasSize.width

        let roomWidth = CGFloat(roomBounds.maxX - roomBounds.minX) * transform.scale
        let roomHeight = CGFloat(roomBounds.maxY - roomBounds.minY) * transform.scale
        guard roomWidth > 0, roomHeight > 0 else { return }

        let zoomBounds = zoomLimits(for: viewModel.roomsWithCounts, transform: transform, canvasSize: canvasSize)
        let targetScale = clamp(
            min(availableWidth / roomWidth, availableHeight / roomHeight) * AppMetrics.roomFocusPaddingScale,
            min: zoomBounds.min,
            max: zoomBounds.max
        )

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

    private func resetViewport() {
        viewport = FloorplanViewport()
        mode = .browse
    }

    private func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        Swift.max(min, Swift.min(max, value))
    }

    private func handleSheetDismiss() {
        viewModel.reloadRoomCounts(context: context)
        if isRoomViewActive {
            roomOverlayRefreshToken = UUID()
        }
    }

    private var selectedRoom: FloorplanRoom? {
        if case let .room(room) = mode {
            return room
        }
        return nil
    }

    private var isRoomViewActive: Bool {
        if case .room = mode {
            return true
        }
        return false
    }

    private func zoomLimits(
        for rooms: [FloorplanRoom],
        transform: FloorplanTransform,
        canvasSize: CGSize
    ) -> (min: CGFloat, max: CGFloat) {
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

    private func roomSheetHeight(for itemCount: Int, availableHeight: CGFloat) -> CGFloat {
        // Max height is 40% of available height (between top bar and bottom buttons)
        let maxHeight = availableHeight * AppMetrics.roomSheetMaxHeightFraction
        let rowCount = max(1, itemCount)
        // Account for internal padding (lg on all sides) + header + spacing
        let internalPadding = AppSpacing.lg * 2 + AppSpacing.sm
        let contentHeight = AppMetrics.roomSheetHeaderHeight
            + CGFloat(rowCount) * AppMetrics.roomSheetRowHeight
            + internalPadding
        let minHeight = AppMetrics.roomSheetHeaderHeight
            + AppMetrics.roomSheetRowHeight
            + internalPadding
        return min(maxHeight, max(minHeight, contentHeight))
    }
}

private struct BrowseChromeOverlay: View {
    let safeTop: CGFloat
    let safeBottom: CGFloat
    let projectName: String
    let showReadOnly: Bool
    let levels: [DemoPlanLevel]
    @Binding var selection: Int
    let onBack: () -> Void
    let onOpenSurvey: () -> Void

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                BrowseTopBar(title: projectName, onBack: onBack)
                    .frame(height: AppMetrics.roomOverlayTopBarHeight)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, safeTop)
                Spacer()
            }

            VStack {
                Spacer()
                HStack {
                    Button(action: onOpenSurvey) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: AppMetrics.roomRowIconSize, weight: .bold))
                            .foregroundStyle(AppColors.textPrimary)
                            .frame(width: AppMetrics.roomRowIconFrame, height: AppMetrics.roomRowIconFrame)
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.field)
                                    .fill(AppColors.cardBackground)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.field)
                                    .stroke(AppColors.cardBorder, lineWidth: AppMetrics.cardStrokeWidth)
                            )
                    }
                    .accessibilityLabel("Survey Report")
                    Spacer()
                    VStack(alignment: .trailing, spacing: AppSpacing.sm) {
                        if showReadOnly {
                            ReadOnlyBadge()
                        }
                        LevelPicker(
                            levels: levels,
                            selection: $selection
                        )
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, safeBottom + AppSpacing.lg)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct BrowseTopBar: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Text(title)
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColors.textPrimary)

            HStack {
                Button(action: onBack) {
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

private struct ReadOnlyBadge: View {
    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "lock.fill")
                .font(.system(size: AppMetrics.readOnlyBadgeIconSize, weight: .bold))
            Text("Read-only")
                .font(AppTypography.badge)
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(
            Capsule().fill(AppColors.completedBadgeBackground)
        )
        .foregroundStyle(AppColors.completedBadgeText)
    }
}

private struct LevelPicker: View {
    let levels: [DemoPlanLevel]
    @Binding var selection: Int

    var body: some View {
        Menu {
            ForEach(levels.indices, id: \.self) { index in
                Button(levels[index].name) {
                    selection = index
                }
            }
        } label: {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "square.stack.3d.up")
                Text(levelLabel)
                    .font(AppTypography.badge)
                Image(systemName: "chevron.up")
                    .font(.system(size: AppMetrics.levelPickerChevronSize, weight: .bold))
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(
                Capsule().fill(AppColors.cardBackground)
            )
            .overlay(
                Capsule().stroke(AppColors.cardBorder, lineWidth: AppMetrics.cardStrokeWidth)
            )
            .foregroundStyle(AppColors.textPrimary)
            .shadow(color: AppShadow.card.color, radius: AppShadow.card.radius, x: AppShadow.card.x, y: AppShadow.card.y)
        }
    }

    private var levelLabel: String {
        guard levels.indices.contains(selection) else {
            return "Level"
        }
        return levels[selection].name
    }
}

private enum FloorplanMode: Equatable {
    case browse
    case room(FloorplanRoom)
}

private enum ActiveSheet: Identifiable {
    case addAsset(FloorplanRoom)
    case roomItem(RoomItem)

    var id: String {
        switch self {
        case .addAsset(let room):
            return "add-asset-\(room.id)"
        case .roomItem(let item):
            return "room-item-\(item.id.uuidString)"
        }
    }
}
