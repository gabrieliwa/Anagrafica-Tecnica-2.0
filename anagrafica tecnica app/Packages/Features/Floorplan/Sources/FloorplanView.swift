import AddAssetWizard
import Core
import DesignSystem
import Room
import SurveyReport
import SwiftUI

public struct FloorplanView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel: FloorplanViewModel
    private let projectName: String
    private let uiState: ProjectUIState?
    @State private var selectedRoomForWizard: FloorplanRoom?
    @State private var selectedRoom: FloorplanRoom?
    @State private var isRoomViewActive = false
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
        .navigationTitle(isRoomViewActive ? "" : projectName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(isRoomViewActive ? .hidden : .visible, for: .navigationBar)
    }

    private var floorplanContent: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let safeTop = proxy.safeAreaInsets.top
            let safeBottom = proxy.safeAreaInsets.bottom
            // Calculate available space for sheet (matching RoomOverlayView)
            let availableForSheet = size.height - safeTop - AppMetrics.roomOverlayTopBarHeight - safeBottom - AppMetrics.roomBottomBarHeight - AppSpacing.lg
            let sheetHeight = roomSheetHeight(for: selectedRoom?.totalCount ?? 1, availableHeight: availableForSheet)
            // Insets for room focus calculation (top bar at safe area, bottom elements)
            let topInset = safeTop + AppMetrics.roomOverlayTopBarHeight
            let bottomInset = safeBottom + AppSpacing.lg + sheetHeight + AppMetrics.roomBottomBarHeight

            ZStack(alignment: .bottomTrailing) {
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
                        onClose: {
                            withAnimation(.easeOut(duration: AppMetrics.roomFocusAnimationDuration)) {
                                isRoomViewActive = false
                                selectedRoom = nil
                                viewport = FloorplanViewport()
                            }
                        },
                        onAddAsset: {
                            selectedRoomForWizard = room
                        },
                        onOpenSurvey: {
                            isSurveyReportActive = true
                        }
                    )
                    .id("\(room.id)-\(roomOverlayRefreshToken)")
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else {
                    VStack(alignment: .trailing, spacing: AppSpacing.sm) {
                        if uiState == .completed {
                            ReadOnlyBadge()
                        }
                        LevelPicker(
                            levels: viewModel.levels,
                            selection: $viewModel.selectedLevelIndex
                        )
                    }
                    .padding(AppSpacing.lg)
                }
            }
            .sheet(item: $selectedRoomForWizard, onDismiss: {
                viewModel.reloadRoomCounts(context: context)
                if isRoomViewActive {
                    roomOverlayRefreshToken = UUID()
                }
            }) { room in
                AddAssetWizardView(
                    roomNumber: room.number,
                    roomName: room.name,
                    levelName: currentLevelName,
                    context: context
                )
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
                selectedRoom = room
                isRoomViewActive = true
            }
            focusOnRoom(room, canvasSize: canvasSize, topInset: topInset, bottomInset: bottomInset)
        } else {
            if isRoomViewActive {
                withAnimation(.easeOut(duration: AppMetrics.roomFocusAnimationDuration)) {
                    selectedRoom = room
                }
                focusOnRoom(room, canvasSize: canvasSize, topInset: topInset, bottomInset: bottomInset)
            }
            selectedRoomForWizard = room
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
        selectedRoom = nil
        isRoomViewActive = false
    }

    private func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        Swift.max(min, Swift.min(max, value))
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
