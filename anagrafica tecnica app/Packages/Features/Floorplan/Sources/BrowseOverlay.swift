import Core
import DesignSystem
import SwiftUI

// MARK: - BrowseOverlay

/// Browse mode overlay: displayed when the user is navigating the floor plan
/// without a room selected. Contains top bar with project title and back button,
/// and bottom controls with level picker and survey report button.
struct BrowseOverlay: View {
    let safeTop: CGFloat
    let safeBottom: CGFloat
    let projectName: String
    let isReadOnly: Bool
    let levels: [DemoPlanLevel]
    @Binding var selectedLevelIndex: Int
    let onBack: () -> Void
    let onOpenSurvey: () -> Void

    var body: some View {
        ZStack {
            // Top bar under Dynamic Island
            VStack(spacing: 0) {
                BrowseTopBar(title: projectName, onBack: onBack)
                    .frame(height: AppMetrics.roomOverlayTopBarHeight)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, safeTop)
                Spacer()
            }

            // Bottom controls
            VStack {
                Spacer()
                HStack {
                    // Survey report button (hamburger menu)
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

                    // Right side: read-only badge (if applicable) + level picker
                    VStack(alignment: .trailing, spacing: AppSpacing.sm) {
                        if isReadOnly {
                            ReadOnlyBadge()
                        }
                        LevelPicker(
                            levels: levels,
                            selection: $selectedLevelIndex
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

// MARK: - BrowseTopBar

/// Top bar for browse mode: back button (left), project title (center), sync button (right).
struct BrowseTopBar: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        ZStack {
            // Center: project title
            Text(title)
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColors.textPrimary)

            HStack {
                // Left: back to projects
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

                // Right: sync indicator (placeholder)
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

// MARK: - ReadOnlyBadge

/// Badge indicating the project is in read-only mode (completed state).
struct ReadOnlyBadge: View {
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

// MARK: - LevelPicker

/// Drop-up menu for selecting the current floor/level.
struct LevelPicker: View {
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
