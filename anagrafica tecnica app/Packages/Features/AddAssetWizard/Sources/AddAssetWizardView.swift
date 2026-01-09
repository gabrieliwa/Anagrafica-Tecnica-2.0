import Core
import CoreData
import DesignSystem
import SwiftUI

public struct AddAssetWizardView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddAssetWizardViewModel
    @State private var showExitConfirm = false

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

    private var header: some View {
        HStack {
            Button {
                showExitConfirm = true
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .padding(8)
                    .background(Circle().fill(AppColors.cardBackground))
            }
            Spacer()
            VStack(spacing: 2) {
                Text(viewModel.flow == .roomNote ? "Room Note" : "Add Asset")
                    .font(AppTypography.section)
                    .foregroundStyle(AppColors.textPrimary)
                Text(viewModel.roomTitle)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            Color.clear.frame(width: 28, height: 28)
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.step {
        case .chooseFamily:
            chooseFamilyView
        case .roomNoteForm:
            roomNoteView
        case .typeSelection:
            typeSelectionView
        case .typeForm:
            typeFormView
        case .nameNewType:
            nameTypeView
        case .instanceForm:
            instanceFormView
        }
    }

    private var chooseFamilyView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Choose family")
                .font(AppTypography.section)
                .foregroundStyle(AppColors.textPrimary)
            Text("Pick a family or create a room note.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)

            SearchField(placeholder: "Search families or types", text: $viewModel.searchText)

            Button {
                viewModel.selectRoomNote()
            } label: {
                HStack {
                    Image(systemName: "note.text")
                    Text("Room Note")
                        .font(AppTypography.bodyEmphasis)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(AppSpacing.md)
                .background(RoundedRectangle(cornerRadius: AppRadius.field).fill(AppColors.cardBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.field)
                        .stroke(AppColors.cardBorder, lineWidth: 1)
                )
            }

            Divider()

            ScrollView {
                LazyVStack(spacing: AppSpacing.sm) {
                    ForEach(viewModel.filteredFamilies) { family in
                        Button {
                            viewModel.selectFamily(family)
                        } label: {
                            HStack {
                                Text(family.name)
                                    .font(AppTypography.bodyEmphasis)
                                    .foregroundStyle(AppColors.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                            .padding(AppSpacing.md)
                            .background(RoundedRectangle(cornerRadius: AppRadius.field).fill(AppColors.cardBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.field)
                                    .stroke(AppColors.cardBorder, lineWidth: 1)
                            )
                        }
                    }
                }
            }
        }
    }

    private var typeSelectionView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Choose type")
                .font(AppTypography.section)
                .foregroundStyle(AppColors.textPrimary)
            Text("Select an existing type or create a new one.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)

            SearchField(placeholder: "Search types", text: $viewModel.typeSearchText)

            Button {
                viewModel.startNewType()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("New Type")
                        .font(AppTypography.bodyEmphasis)
                    Spacer()
                }
                .padding(AppSpacing.md)
                .background(RoundedRectangle(cornerRadius: AppRadius.field).fill(AppColors.cardBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.field)
                        .stroke(AppColors.cardBorder, lineWidth: 1)
                )
            }

            ScrollView {
                LazyVStack(spacing: AppSpacing.sm) {
                    ForEach(viewModel.filteredTypes) { type in
                        Button {
                            viewModel.selectType(type)
                        } label: {
                            HStack {
                                Text(type.name)
                                    .font(AppTypography.bodyEmphasis)
                                    .foregroundStyle(AppColors.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                            .padding(AppSpacing.md)
                            .background(RoundedRectangle(cornerRadius: AppRadius.field).fill(AppColors.cardBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.field)
                                    .stroke(AppColors.cardBorder, lineWidth: 1)
                            )
                        }
                    }
                }
            }
        }
    }

    private var typeFormView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Type form")
                .font(AppTypography.section)
                .foregroundStyle(AppColors.textPrimary)
            Text("Fill in the required type fields.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)

            PhotoRow(
                title: "Type photo (required)",
                count: viewModel.typePhotoId == nil ? 0 : 1,
                maxCount: 1,
                isMissing: viewModel.showValidationErrors && viewModel.typePhotoId == nil,
                addAction: { viewModel.addTypePhoto() },
                removeAction: { _ in viewModel.removeTypePhoto() },
                photoIds: viewModel.typePhotoId.map { [$0] } ?? []
            )

            ParameterForm(
                definitions: viewModel.typeDefinitions,
                scope: .type,
                viewModel: viewModel,
                requireAll: true,
                showValidation: viewModel.showValidationErrors
            )
        }
    }

    private var nameTypeView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Name new type")
                .font(AppTypography.section)
                .foregroundStyle(AppColors.textPrimary)
            Text("Give this type a distinct name.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)

            TextField("Type name", text: $viewModel.newTypeName)
                .textFieldStyle(.plain)
                .padding(AppSpacing.md)
                .background(RoundedRectangle(cornerRadius: AppRadius.field).fill(AppColors.cardBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.field)
                        .stroke(viewModel.showValidationErrors && viewModel.newTypeName.isEmpty ? Color.red : AppColors.cardBorder, lineWidth: 1)
                )
        }
    }

    private var instanceFormView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Instance form")
                .font(AppTypography.section)
                .foregroundStyle(AppColors.textPrimary)
            Text("Capture instance details and photos.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)

            RoomInfoRow(levelName: viewModel.levelName, roomTitle: viewModel.roomTitle)

            PhotoRow(
                title: "Instance photos (optional)",
                count: viewModel.instancePhotoIds.count,
                maxCount: 5,
                isMissing: false,
                addAction: { viewModel.addInstancePhoto() },
                removeAction: { id in viewModel.removeInstancePhoto(id: id) },
                photoIds: viewModel.instancePhotoIds
            )

            ParameterForm(
                definitions: viewModel.instanceDefinitions,
                scope: .instance,
                viewModel: viewModel,
                requireAll: false,
                showValidation: viewModel.showValidationErrors
            )
        }
    }

    private var roomNoteView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Room note")
                .font(AppTypography.section)
                .foregroundStyle(AppColors.textPrimary)
            Text("Document room state and attach photos.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)

            RoomInfoRow(levelName: viewModel.levelName, roomTitle: viewModel.roomTitle)

            PhotoRow(
                title: "Room note photos (1 required + up to 4)",
                count: (viewModel.roomNoteMainPhotoId == nil ? 0 : 1) + viewModel.roomNoteExtraPhotoIds.count,
                maxCount: 5,
                isMissing: viewModel.showValidationErrors && viewModel.roomNoteMainPhotoId == nil,
                addAction: { viewModel.addRoomNotePhoto() },
                removeAction: { id in viewModel.removeRoomNotePhoto(id: id) },
                photoIds: roomNotePhotoIds
            )

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Toggle("Empty room", isOn: Binding(get: {
                    viewModel.roomNoteEmptyRoom
                }, set: { _ in
                    viewModel.toggleRoomNoteEmpty()
                }))
                .disabled(viewModel.isRoomNoteFlagsDisabled)

                Toggle("Room is blocked", isOn: Binding(get: {
                    viewModel.roomNoteBlocked
                }, set: { _ in
                    viewModel.toggleRoomNoteBlocked()
                }))
                .disabled(viewModel.isRoomNoteFlagsDisabled)
            }

            TextField("Description", text: $viewModel.roomNoteDescription, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(AppSpacing.md)
                .frame(minHeight: 80, alignment: .topLeading)
                .background(RoundedRectangle(cornerRadius: AppRadius.field).fill(AppColors.cardBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.field)
                        .stroke(viewModel.showValidationErrors && viewModel.roomNoteBlocked && viewModel.roomNoteDescription.isEmpty ? Color.red : AppColors.cardBorder, lineWidth: 1)
                )
        }
    }

    private var roomNotePhotoIds: [UUID] {
        var ids: [UUID] = []
        if let main = viewModel.roomNoteMainPhotoId {
            ids.append(main)
        }
        ids.append(contentsOf: viewModel.roomNoteExtraPhotoIds)
        return ids
    }

    private var footer: some View {
        HStack(spacing: AppSpacing.md) {
            Button {
                viewModel.back()
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
            .disabled(viewModel.currentStepIndex == 0)

            Button {
                viewModel.advance()
            } label: {
                Text(advanceLabel)
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
            .disabled(!canAdvance)
        }
    }

    private var advanceLabel: String {
        switch viewModel.step {
        case .roomNoteForm:
            return "Save Note"
        case .instanceForm:
            return "Save Asset"
        default:
            return "Next"
        }
    }

    private var canAdvance: Bool {
        switch viewModel.step {
        case .chooseFamily, .typeSelection:
            return false
        default:
            return true
        }
    }
}

private struct StepIndicator: View {
    let count: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(index <= currentIndex ? AppColors.accent : AppColors.cardBorder)
                    .frame(width: 10, height: 10)
                if index < count - 1 {
                    Capsule()
                        .fill(index < currentIndex ? AppColors.accent : AppColors.cardBorder)
                        .frame(width: 26, height: 2)
                }
            }
        }
    }
}

private struct SearchField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColors.textSecondary)
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
        }
        .padding(AppSpacing.md)
        .background(RoundedRectangle(cornerRadius: AppRadius.field).fill(AppColors.cardBackground))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.field)
                .stroke(AppColors.cardBorder, lineWidth: 1)
        )
    }
}

private struct PhotoRow: View {
    let title: String
    let count: Int
    let maxCount: Int
    let isMissing: Bool
    let addAction: () -> Void
    let removeAction: (UUID) -> Void
    var photoIds: [UUID] = []

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text(title)
                    .font(AppTypography.bodyEmphasis)
                Spacer()
                Text("\(count)/\(maxCount)")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
            }

            if !photoIds.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.sm) {
                        ForEach(photoIds, id: \.self) { id in
                            HStack(spacing: AppSpacing.xs) {
                                Image(systemName: "photo")
                                Button {
                                    removeAction(id)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                }
                            }
                            .padding(AppSpacing.sm)
                            .background(RoundedRectangle(cornerRadius: AppRadius.field).fill(AppColors.cardBackground))
                        }
                    }
                }
            }

            Button {
                addAction()
            } label: {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("Add photo")
                        .font(AppTypography.bodyEmphasis)
                    Spacer()
                }
                .padding(AppSpacing.md)
                .background(RoundedRectangle(cornerRadius: AppRadius.field).fill(AppColors.cardBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.field)
                        .stroke(isMissing ? Color.red : AppColors.cardBorder, lineWidth: 1)
                )
            }
            .disabled(count >= maxCount)
        }
    }
}

private struct ParameterForm: View {
    let definitions: [ParameterDefinition]
    let scope: ParameterScope
    let viewModel: AddAssetWizardViewModel
    let requireAll: Bool
    let showValidation: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            ForEach(definitions) { definition in
                ParameterField(
                    definition: definition,
                    scope: scope,
                    viewModel: viewModel,
                    requireAll: requireAll,
                    showValidation: showValidation
                )
            }
        }
    }
}

private struct RoomInfoRow: View {
    let levelName: String
    let roomTitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(levelName)
                .font(AppTypography.bodyEmphasis)
            Text(roomTitle)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(AppSpacing.md)
        .background(RoundedRectangle(cornerRadius: AppRadius.field).fill(AppColors.cardBackground))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.field)
                .stroke(AppColors.cardBorder, lineWidth: 1)
        )
    }
}

private struct ParameterField: View {
    let definition: ParameterDefinition
    let scope: ParameterScope
    let viewModel: AddAssetWizardViewModel
    let requireAll: Bool
    let showValidation: Bool
    @State private var localOption = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(definition.name)
                .font(AppTypography.bodyEmphasis)

            switch definition.dataType {
            case .text:
                TextField("Enter text", text: viewModel.textBinding(for: definition, scope: scope))
                    .textFieldStyle(.plain)
                    .padding(AppSpacing.sm)
                    .background(RoundedRectangle(cornerRadius: AppRadius.field).fill(AppColors.cardBackground))
            case .number:
                TextField("Enter number", text: viewModel.numberBinding(for: definition, scope: scope))
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.plain)
                    .padding(AppSpacing.sm)
                    .background(RoundedRectangle(cornerRadius: AppRadius.field).fill(AppColors.cardBackground))
            case .boolean:
                Toggle("Yes / No", isOn: viewModel.boolBinding(for: definition, scope: scope))
            case .date:
                DatePicker("", selection: viewModel.dateBinding(for: definition, scope: scope), displayedComponents: .date)
                    .labelsHidden()
            case .enumerated:
                let currentValue = viewModel.optionBinding(for: definition, scope: scope).wrappedValue
                Menu {
                    ForEach(definition.enumValues ?? [], id: \.self) { value in
                        Button(value) {
                            localOption = value
                            if currentValue != value {
                                viewModel.optionBinding(for: definition, scope: scope).wrappedValue = value
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(localOption.isEmpty ? "Select" : localOption)
                            .foregroundStyle(AppColors.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(AppSpacing.sm)
                    .background(RoundedRectangle(cornerRadius: AppRadius.field).fill(AppColors.cardBackground))
                }
                .onAppear {
                    localOption = currentValue
                }
                .onChange(of: currentValue) { newValue in
                    if localOption != newValue {
                        localOption = newValue
                    }
                }
            }

            if showValidation && requiresValue {
                Text("Required")
                    .font(.caption)
                    .foregroundStyle(Color.red)
            }
        }
        .padding(AppSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.field)
                .stroke(showValidation && requiresValue ? Color.red : AppColors.cardBorder, lineWidth: 1)
        )
    }

    private var requiresValue: Bool {
        if requireAll {
            return viewModel.value(for: definition, scope: scope) == nil
        }
        if definition.isRequired {
            return viewModel.value(for: definition, scope: scope) == nil
        }
        return false
    }
}
