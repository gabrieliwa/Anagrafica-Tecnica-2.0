import AddAssetWizard
import Core
import DesignSystem
import Room
import SurveyReport
import SwiftUI

// MARK: - PlanimetricFlow

/// Main container for the planimetric workflow.
///
/// ## Architecture
/// The floor plan is persistent ONLY within this workflow. Two modes are supported:
/// - **Browse Mode**: Default state, user navigates the floor plan with pan/zoom.
/// - **Room Mode**: A room is selected, overlay UI shows room details, map stays mounted.
///
/// The floor plan (`FloorplanCanvas`) is always the same view instance - it is never
/// recreated during mode transitions. Only the overlay UI changes based on `PlanMode`.
///
/// ## Why persistent map matters
/// Keeping the same map instance:
/// - Preserves zoom/pan state during room selection
/// - Enables smooth camera animations (zoom-to-fit on room)
/// - Avoids "deck of cards" view hierarchy issues
/// - Improves performance by not recreating complex Canvas views
///
/// ## ReportsFlow separation
/// Outside this workflow (e.g., Survey Report), the floor plan is NOT visible.
/// Reports use standard full-screen navigation without the map background.
public struct FloorplanView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @StateObject private var viewModel: FloorplanViewModel
    @StateObject private var mapController = MapController()

    /// Single source of truth for the current UI mode
    @State private var mode: PlanMode = .browse

    /// Sheet presentation state (centralized to avoid nested sheet issues)
    @State private var activeSheet: ActiveSheet?

    /// Navigation to Survey Report (ReportsFlow)
    @State private var isSurveyReportActive = false

    /// Token to force refresh RoomOverlayView when sheet dismisses
    @State private var roomOverlayRefreshToken = UUID()

    // MARK: - Configuration

    private let projectName: String
    private let uiState: ProjectUIState?

    // MARK: - Init

    public init(projectName: String, uiState: ProjectUIState?, bundle: Bundle = .main) {
        _viewModel = StateObject(wrappedValue: FloorplanViewModel(bundle: bundle))
        self.projectName = projectName
        self.uiState = uiState
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            AppGradients.page
                .ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView("Loading floorplan")
                    .foregroundStyle(AppColors.textSecondary)
            } else if let message = viewModel.errorMessage {
                errorContent(message: message)
            } else {
                planimetricContent
            }
        }
        #if os(iOS)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        #endif
    }

    // MARK: - Error State

    private func errorContent(message: String) -> some View {
        VStack(spacing: AppSpacing.sm) {
            Text("Failed to load demo plan")
                .font(AppTypography.section)
                .foregroundStyle(AppColors.textPrimary)
            Text(message)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    // MARK: - Planimetric Content

    /// The main planimetric view structure:
    /// - ZStack with FloorplanCanvas always at the bottom
    /// - Overlay switches based on current mode
    private var planimetricContent: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let safeTop = proxy.safeAreaInsets.top
            let safeBottom = proxy.safeAreaInsets.bottom

            // Layout calculations for room focus
            let layout = RoomSheetLayout(
                safeTop: safeTop,
                safeBottom: safeBottom,
                screenSize: size
            )

            ZStack {
                // MARK: Persistent Floor Map
                // This view is NEVER recreated during mode changes.
                // It stays mounted and only the overlays change.
                FloorplanCanvas(
                    linework: viewModel.linework,
                    rooms: viewModel.roomsWithCounts,
                    bounds: viewModel.bounds,
                    isReadOnly: uiState == .completed,
                    selectedRoomId: mode.selectedRoomID,
                    isRoomViewActive: isRoomMode,
                    onRoomTapped: { room in
                        handleRoomTap(room, canvasSize: size, layout: layout)
                    },
                    viewport: $mapController.viewport
                )
                // Use level index as id to reset canvas state when level changes
                .id(viewModel.selectedLevelIndex)
                .ignoresSafeArea()

                // MARK: Mode-specific Overlays
                overlayContent(safeTop: safeTop, safeBottom: safeBottom, screenSize: size)
            }
            // Sheet presentation (centralized at top level to avoid hierarchy issues)
            .sheet(item: $activeSheet, onDismiss: handleSheetDismiss) { sheet in
                sheetContent(for: sheet)
            }
            // Hidden navigation link for Survey Report (ReportsFlow)
            .background(
                NavigationLink(
                    destination: SurveyReportView(),
                    isActive: $isSurveyReportActive,
                    label: { EmptyView() }
                )
                .hidden()
            )
            .onAppear {
                configureMapController()
                viewModel.reloadRoomCounts(context: context)
            }
            .onChange(of: viewModel.selectedLevelIndex) { _ in
                handleLevelChange()
            }
        }
    }

    // MARK: - Overlay Content

    /// Returns the appropriate overlay based on current mode.
    @ViewBuilder
    private func overlayContent(safeTop: CGFloat, safeBottom: CGFloat, screenSize: CGSize) -> some View {
        switch mode {
        case .browse:
            // Browse mode: top bar with project title, bottom bar with level picker
            BrowseOverlay(
                safeTop: safeTop,
                safeBottom: safeBottom,
                projectName: projectName,
                isReadOnly: uiState == .completed,
                levels: viewModel.levels,
                selectedLevelIndex: $viewModel.selectedLevelIndex,
                onBack: { dismiss() },
                onOpenSurvey: { isSurveyReportActive = true }
            )
            .transition(.opacity)

        case .room(let roomID):
            // Room mode: room overlay with asset list and actions
            if let room = viewModel.roomsWithCounts.first(where: { $0.id == roomID }) {
                RoomOverlayView(
                    levelName: currentLevelName,
                    roomNumber: room.number,
                    roomName: room.name,
                    context: context,
                    layout: RoomOverlayLayout(
                        safeTop: safeTop,
                        safeBottom: safeBottom,
                        screenSize: screenSize
                    ),
                    onClose: {
                        exitRoomMode()
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
            }
        }
    }

    // MARK: - Sheet Content

    @ViewBuilder
    private func sheetContent(for sheet: ActiveSheet) -> some View {
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

    // MARK: - Computed Properties

    private var currentLevelName: String {
        guard viewModel.levels.indices.contains(viewModel.selectedLevelIndex) else {
            return "Level"
        }
        return viewModel.levels[viewModel.selectedLevelIndex].name
    }

    private var isRoomMode: Bool {
        if case .room = mode { return true }
        return false
    }

    // MARK: - Actions

    /// Handle tap on a room polygon.
    private func handleRoomTap(
        _ room: FloorplanRoom,
        canvasSize: CGSize,
        layout: RoomSheetLayout
    ) {
        // If room has items or we're already in room mode, enter/switch room mode
        if room.totalCount > 0 || isRoomMode {
            enterRoomMode(room: room, canvasSize: canvasSize, layout: layout)
        } else {
            // Empty room tapped from browse mode: show add asset sheet directly
            // (also enter room mode so user sees the room highlighted)
            enterRoomMode(room: room, canvasSize: canvasSize, layout: layout)
            activeSheet = .addAsset(room)
        }
    }

    /// Enter room mode: animate camera to focus on room, show room overlay.
    private func enterRoomMode(
        room: FloorplanRoom,
        canvasSize: CGSize,
        layout: RoomSheetLayout
    ) {
        let itemCount = room.totalCount
        let topInset = layout.topInset
        let bottomInset = layout.bottomInset(for: max(1, itemCount))

        // Animate mode change and camera focus together
        withAnimation(.easeOut(duration: AppMetrics.roomFocusAnimationDuration)) {
            mode = .room(roomID: room.id)
        }

        mapController.focusOnRoom(
            room,
            canvasSize: canvasSize,
            topInset: topInset,
            bottomInset: bottomInset
        )
    }

    /// Exit room mode: return to browse mode, optionally restore previous viewport.
    private func exitRoomMode() {
        withAnimation(.easeOut(duration: AppMetrics.roomFocusAnimationDuration)) {
            mode = .browse
        }
        // Reset viewport (restores previous browse viewport or defaults)
        mapController.resetViewport(restorePreviousViewport: false)
    }

    /// Configure the MapController with current rooms and bounds.
    private func configureMapController() {
        mapController.configure(
            rooms: viewModel.roomsWithCounts,
            bounds: viewModel.bounds
        )
    }

    /// Handle level change: reset mode and viewport, reload counts.
    private func handleLevelChange() {
        mode = .browse
        mapController.resetViewportImmediate()
        viewModel.reloadRoomCounts(context: context)
        configureMapController()
    }

    /// Handle sheet dismissal: refresh data and room overlay if needed.
    private func handleSheetDismiss() {
        viewModel.reloadRoomCounts(context: context)
        configureMapController()
        if isRoomMode {
            // Force refresh the room overlay to show updated items
            roomOverlayRefreshToken = UUID()
        }
    }
}

// MARK: - ActiveSheet

/// Centralized sheet state to avoid nested sheet presentation issues.
/// All sheets are presented from the top-level container.
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
