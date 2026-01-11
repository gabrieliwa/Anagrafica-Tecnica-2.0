import DesignSystem
import SwiftUI

public struct SurveyReportView: View {
    public init() {}

    public var body: some View {
        ZStack {
            AppGradients.page.ignoresSafeArea()
            VStack(spacing: AppSpacing.md) {
                Image(systemName: "list.bullet.rectangle")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)
                Text("Survey Report")
                    .font(AppTypography.section)
                    .foregroundStyle(AppColors.textPrimary)
                Text("Coming soon")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .navigationTitle("Survey Report")
        .navigationBarTitleDisplayMode(.inline)
    }
}
