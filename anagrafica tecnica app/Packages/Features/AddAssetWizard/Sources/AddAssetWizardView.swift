import DesignSystem
import SwiftUI

public struct AddAssetWizardView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var stepIndex = 0

    private let steps: [AddAssetStep] = [.family, .typeSelection, .typeForm, .instanceForm]

    public init() {}

    public var body: some View {
        VStack(spacing: AppSpacing.lg) {
            header
            StepIndicator(steps: steps, currentIndex: stepIndex)
            stepContent
            Spacer()
            footer
        }
        .padding(AppSpacing.xl)
        .background(AppGradients.page.ignoresSafeArea())
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .padding(8)
                    .background(Circle().fill(AppColors.cardBackground))
            }
            Spacer()
            Text("Add Asset Wizard")
                .font(AppTypography.section)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Color.clear.frame(width: 28, height: 28)
        }
    }

    private var stepContent: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(steps[stepIndex].title)
                .font(AppTypography.section)
                .foregroundStyle(AppColors.textPrimary)
            Text(steps[stepIndex].subtitle)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
            RoundedRectangle(cornerRadius: AppRadius.card)
                .fill(AppColors.cardBackground)
                .frame(height: 220)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.card)
                        .stroke(AppColors.cardBorder, lineWidth: 1)
                )
                .overlay(
                    Text("UI content goes here")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                )
        }
    }

    private var footer: some View {
        HStack(spacing: AppSpacing.md) {
            Button {
                stepIndex = max(0, stepIndex - 1)
            } label: {
                Text("Back")
                    .font(AppTypography.bodyEmphasis)
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, AppSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.field)
                    .fill(AppColors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.field)
                    .stroke(AppColors.cardBorder, lineWidth: 1)
            )
            .disabled(stepIndex == 0)

            Button {
                stepIndex = min(steps.count - 1, stepIndex + 1)
            } label: {
                Text(stepIndex == steps.count - 1 ? "Save" : "Next")
                    .font(AppTypography.bodyEmphasis)
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, AppSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.field)
                    .fill(AppColors.accent.opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.field)
                    .stroke(AppColors.accent, lineWidth: 1)
            )
        }
    }
}

private enum AddAssetStep: Int, CaseIterable {
    case family
    case typeSelection
    case typeForm
    case instanceForm

    var title: String {
        switch self {
        case .family:
            return "Choose family"
        case .typeSelection:
            return "Choose type"
        case .typeForm:
            return "Type form"
        case .instanceForm:
            return "Instance form"
        }
    }

    var subtitle: String {
        switch self {
        case .family:
            return "Pick a family or create a room note."
        case .typeSelection:
            return "Select an existing type or create a new one."
        case .typeForm:
            return "Fill in the required type fields."
        case .instanceForm:
            return "Capture instance details and photos."
        }
    }
}

private struct StepIndicator: View {
    let steps: [AddAssetStep]
    let currentIndex: Int

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(steps.indices, id: \.self) { index in
                Circle()
                    .fill(index <= currentIndex ? AppColors.accent : AppColors.cardBorder)
                    .frame(width: 10, height: 10)
                if index < steps.count - 1 {
                    Capsule()
                        .fill(index < currentIndex ? AppColors.accent : AppColors.cardBorder)
                        .frame(width: 26, height: 2)
                }
            }
        }
    }
}
