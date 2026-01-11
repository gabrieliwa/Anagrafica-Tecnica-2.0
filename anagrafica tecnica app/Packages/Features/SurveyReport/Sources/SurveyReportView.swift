import DesignSystem
import SwiftUI

// MARK: - ReportsFlow

/// Survey Report view - part of the ReportsFlow.
///
/// ## Architecture
/// This view is a standard full-screen navigation view that does NOT require
/// the floor plan to be visible. It operates independently of the PlanimetricFlow.
///
/// ## Why no floor plan here
/// Reports are "server report" screens (list of all rooms, list of all asset types)
/// that benefit from full-screen layouts without the map taking up space.
/// Standard push navigation is used for detail screens.
///
/// ## Future Implementation
/// This is currently a placeholder. The full implementation will include:
/// - Room list with filters and search (grouped by level)
/// - Types list with family grouping
/// - Export functionality
public struct SurveyReportView: View {
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        ZStack {
            AppGradients.page.ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom top bar (since we're hiding the navigation bar)
                reportTopBar

                // Content
                VStack(spacing: AppSpacing.lg) {
                    Spacer()

                    // Placeholder content
                    VStack(spacing: AppSpacing.md) {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.system(size: 48, weight: .semibold))
                            .foregroundStyle(AppColors.textSecondary)

                        Text("Survey Report")
                            .font(AppTypography.section)
                            .foregroundStyle(AppColors.textPrimary)

                        Text("View all rooms and asset types")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    // Report sections preview
                    VStack(spacing: AppSpacing.md) {
                        ReportSectionCard(
                            icon: "door.left.hand.open",
                            title: "Rooms",
                            subtitle: "View all rooms by level",
                            isEnabled: false
                        )

                        ReportSectionCard(
                            icon: "cube.fill",
                            title: "Asset Types",
                            subtitle: "View all types by family",
                            isEnabled: false
                        )

                        ReportSectionCard(
                            icon: "square.and.arrow.up",
                            title: "Export",
                            subtitle: "Export survey data",
                            isEnabled: false
                        )
                    }
                    .padding(.horizontal, AppSpacing.xl)

                    Spacer()

                    Text("Coming soon")
                        .font(AppTypography.metricLabel)
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.bottom, AppSpacing.xl)
                }
            }
        }
        #if os(iOS)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        #endif
    }

    private var reportTopBar: some View {
        ZStack {
            Text("Survey Report")
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColors.textPrimary)

            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: AppMetrics.roomRowIconSize, weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(width: AppMetrics.roomRowIconFrame, height: AppMetrics.roomRowIconFrame)
                        .background(
                            Circle().fill(AppColors.cardBackground.opacity(0.95))
                        )
                }
                Spacer()
            }
        }
        .frame(height: AppMetrics.roomOverlayTopBarHeight)
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.sm)
    }
}

// MARK: - ReportSectionCard

private struct ReportSectionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let isEnabled: Bool

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.badge)
                    .fill(isEnabled ? AppGradients.cardAccent : LinearGradient(
                        colors: [AppColors.textSecondary.opacity(0.3), AppColors.textSecondary.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                Image(systemName: icon)
                    .font(.system(size: AppMetrics.roomRowIconSize, weight: .semibold))
                    .foregroundStyle(.white.opacity(isEnabled ? 0.9 : 0.6))
            }
            .frame(width: AppMetrics.roomRowIconFrame, height: AppMetrics.roomRowIconFrame)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(isEnabled ? AppColors.textPrimary : AppColors.textSecondary)
                Text(subtitle)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            if isEnabled {
                Image(systemName: "chevron.right")
                    .font(.system(size: AppMetrics.roomRowChevronSize, weight: .bold))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card)
                .fill(AppColors.cardBackground.opacity(isEnabled ? 1.0 : 0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.card)
                        .stroke(AppColors.cardBorder, lineWidth: AppMetrics.cardStrokeWidth)
                )
        )
        .shadow(color: isEnabled ? AppShadow.card.color : .clear, radius: AppShadow.card.radius, x: AppShadow.card.x, y: AppShadow.card.y)
    }
}

