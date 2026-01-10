import AddAssetWizard
import Core
import DesignSystem
import Room
import SwiftUI

public struct FloorplanView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel: FloorplanViewModel
    private let projectName: String
    private let uiState: ProjectUIState?
    @State private var selectedRoomForWizard: FloorplanRoom?
    @State private var selectedRoomForDetails: FloorplanRoom?
    @State private var isRoomDetailsActive = false

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
        .navigationTitle(projectName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var floorplanContent: some View {
        ZStack(alignment: .bottomTrailing) {
            FloorplanCanvas(
                linework: viewModel.linework,
                rooms: viewModel.roomsWithCounts,
                bounds: viewModel.bounds,
                isReadOnly: uiState == .completed,
                onRoomTapped: { room in
                    if uiState == .completed || room.totalCount > 0 {
                        selectedRoomForDetails = room
                        isRoomDetailsActive = true
                    } else {
                        selectedRoomForWizard = room
                    }
                }
            )
            .id(viewModel.selectedLevelIndex)
            .ignoresSafeArea()

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
        .sheet(item: $selectedRoomForWizard, onDismiss: {
            viewModel.reloadRoomCounts(context: context)
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
                destination: roomDetailDestination,
                isActive: $isRoomDetailsActive,
                label: { EmptyView() }
            )
            .hidden()
        )
        .onAppear {
            viewModel.reloadRoomCounts(context: context)
        }
        .onChange(of: viewModel.selectedLevelIndex) { _ in
            viewModel.reloadRoomCounts(context: context)
        }
        .onChange(of: isRoomDetailsActive) { isActive in
            if !isActive {
                selectedRoomForDetails = nil
            }
        }
    }

    private var roomDetailDestination: some View {
        Group {
            if let room = selectedRoomForDetails {
                RoomView(
                    levelName: currentLevelName,
                    roomNumber: room.number,
                    roomName: room.name,
                    context: context
                )
            } else {
                EmptyView()
            }
        }
    }

    private var currentLevelName: String {
        guard viewModel.levels.indices.contains(viewModel.selectedLevelIndex) else {
            return "Level"
        }
        return viewModel.levels[viewModel.selectedLevelIndex].name
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
