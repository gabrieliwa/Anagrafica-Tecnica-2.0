import AddAssetWizard
import Core
import DesignSystem
import SwiftUI

public struct FloorplanView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel: FloorplanViewModel
    private let projectName: String
    private let uiState: ProjectUIState?
    @State private var selectedRoom: FloorplanRoom?

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
                rooms: viewModel.rooms,
                bounds: viewModel.bounds,
                isReadOnly: uiState == .completed,
                onRoomTapped: { room in
                    guard uiState != .completed else { return }
                    selectedRoom = room
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
        .sheet(item: $selectedRoom) { room in
            AddAssetWizardView(
                roomNumber: room.number,
                roomName: room.name,
                levelName: currentLevelName,
                context: context
            )
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
                .font(.system(size: 12, weight: .bold))
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
                    .font(.system(size: 10, weight: .bold))
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(
                Capsule().fill(AppColors.cardBackground)
            )
            .overlay(
                Capsule().stroke(AppColors.cardBorder, lineWidth: 1)
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
