import Core
import CoreData
import DesignSystem
import SwiftUI

public struct AddAssetWizardView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: AddAssetWizardViewModel
    @State var showExitConfirm = false

    public init(roomNumber: String, roomName: String?, levelName: String, context: NSManagedObjectContext) {
        _viewModel = StateObject(
            wrappedValue: AddAssetWizardViewModel(
                context: context,
                roomNumber: roomNumber,
                roomName: roomName,
                levelName: levelName
            )
        )
    }

    public var body: some View {
        VStack(spacing: AppSpacing.lg) {
            header
            StepIndicator(count: viewModel.steps.count, currentIndex: viewModel.currentStepIndex)
            stepContent
            Spacer()
            footer
        }
        .padding(AppSpacing.xl)
        .background(AppGradients.page.ignoresSafeArea())
        .alert("Exit wizard?", isPresented: $showExitConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Exit", role: .destructive) { dismiss() }
        } message: {
            Text("All progress will be lost.")
        }
        .alert("Unable to save", isPresented: Binding(get: {
            viewModel.alertMessage != nil
        }, set: { _ in
            viewModel.alertMessage = nil
        })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage ?? "")
        }
        .onChange(of: viewModel.didSave) { didSave in
            if didSave {
                dismiss()
            }
        }
    }
}
