import Core
import CoreData
import Foundation
import SwiftUI

@MainActor
final class AddAssetWizardViewModel: ObservableObject {
    enum Step: Hashable {
        case chooseFamily
        case roomNoteForm
        case typeSelection
        case typeForm
        case nameNewType
        case instanceForm
    }

    enum Flow {
        case asset
        case roomNote
    }

    struct FamilyOption: Identifiable {
        let id: UUID
        let name: String
        let sortOrder: Int?
        let parameters: [ParameterDefinition]
        let objectID: NSManagedObjectID
    }

    struct TypeOption: Identifiable {
        let id: UUID
        let name: String
        let parameters: [ParameterValueEntry]
        let typePhotoId: UUID?
        let objectID: NSManagedObjectID
    }

    @Published var step: Step = .chooseFamily
    @Published var flow: Flow = .asset
    @Published var searchText = ""
    @Published var typeSearchText = ""
    @Published var families: [FamilyOption] = []
    @Published var selectedFamily: FamilyOption?
    @Published var selectedType: TypeOption?
    @Published var isCreatingNewType = false
    @Published var newTypeName = ""

    @Published var typePhotoId: UUID?
    @Published var instancePhotoIds: [UUID] = []

    @Published var roomNoteMainPhotoId: UUID?
    @Published var roomNoteExtraPhotoIds: [UUID] = []
    @Published var roomNoteEmptyRoom = false
    @Published var roomNoteBlocked = false
    @Published var roomNoteDescription = ""

    @Published var typeTextInputs: [UUID: String] = [:]
    @Published var typeNumberInputs: [UUID: String] = [:]
    @Published var typeOptionInputs: [UUID: String] = [:]
    @Published var typeBoolInputs: [UUID: Bool] = [:]
    @Published var typeDateInputs: [UUID: Date] = [:]

    @Published var instanceTextInputs: [UUID: String] = [:]
    @Published var instanceNumberInputs: [UUID: String] = [:]
    @Published var instanceOptionInputs: [UUID: String] = [:]
    @Published var instanceBoolInputs: [UUID: Bool] = [:]
    @Published var instanceDateInputs: [UUID: Date] = [:]

    @Published var showValidationErrors = false
    @Published var alertMessage: String?
    @Published var didSave = false

    let roomNumber: String
    let roomName: String?
    let levelName: String

    let context: NSManagedObjectContext
    var roomObject: NSManagedObject?
    var projectObject: NSManagedObject?
    var typesByFamilyId: [UUID: [TypeOption]] = [:]
    var originalTypeParameters: [ParameterValueEntry] = []
    var roomHasAssets = false

    init(context: NSManagedObjectContext, roomNumber: String, roomName: String?, levelName: String) {
        self.context = context
        self.roomNumber = roomNumber
        self.roomName = roomName
        self.levelName = levelName
        loadCoreData()
    }

    var filteredFamilies: [FamilyOption] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return families }
        let query = trimmed.lowercased()
        return families.filter { family in
            if family.name.lowercased().contains(query) {
                return true
            }
            let types = typesByFamilyId[family.id] ?? []
            return types.contains(where: { $0.name.lowercased().contains(query) })
        }
    }

    var filteredTypes: [TypeOption] {
        guard let family = selectedFamily else { return [] }
        let types = typesByFamilyId[family.id] ?? []
        let trimmed = typeSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return types }
        let query = trimmed.lowercased()
        return types.filter { $0.name.lowercased().contains(query) }
    }

    var roomTitle: String {
        if let roomName, !roomName.isEmpty {
            return "Room \(roomNumber) - \(roomName)"
        }
        return "Room \(roomNumber)"
    }

    var typeDefinitions: [ParameterDefinition] {
        selectedFamily?.parameters.filter { $0.scope == .type } ?? []
    }

    var instanceDefinitions: [ParameterDefinition] {
        selectedFamily?.parameters.filter { $0.scope == .instance } ?? []
    }

    var steps: [Step] {
        switch flow {
        case .roomNote:
            return [.chooseFamily, .roomNoteForm]
        case .asset:
            var steps: [Step] = [.chooseFamily, .typeSelection, .typeForm]
            if needsNameStep {
                steps.append(.nameNewType)
            }
            steps.append(.instanceForm)
            return steps
        }
    }

    var currentStepIndex: Int {
        steps.firstIndex(of: step) ?? 0
    }

    var isRoomNoteFlagsDisabled: Bool {
        roomHasAssets
    }

    var needsNameStep: Bool {
        if isCreatingNewType {
            return true
        }
        guard selectedType != nil else { return false }
        return hasTypeChanges()
    }

    func selectRoomNote() {
        flow = .roomNote
        step = .roomNoteForm
        showValidationErrors = false
    }

    func selectFamily(_ family: FamilyOption) {
        flow = .asset
        selectedFamily = family
        selectedType = nil
        isCreatingNewType = false
        newTypeName = ""
        typePhotoId = nil
        resetTypeInputs()
        step = .typeSelection
        showValidationErrors = false
    }

    func selectType(_ type: TypeOption) {
        selectedType = type
        isCreatingNewType = false
        newTypeName = ""
        typePhotoId = type.typePhotoId
        applyTypeParameters(type.parameters)
        originalTypeParameters = type.parameters
        step = .typeForm
        showValidationErrors = false
    }

    func startNewType() {
        selectedType = nil
        isCreatingNewType = true
        newTypeName = ""
        typePhotoId = nil
        resetTypeInputs()
        originalTypeParameters = []
        step = .typeForm
        showValidationErrors = false
    }

    func back() {
        let index = currentStepIndex
        guard index > 0 else { return }
        step = steps[index - 1]
        showValidationErrors = false
    }

    func advance() {
        showValidationErrors = false
        switch step {
        case .chooseFamily:
            break
        case .roomNoteForm:
            saveRoomNote()
        case .typeSelection:
            break
        case .typeForm:
            guard validateTypeForm() else {
                showValidationErrors = true
                return
            }
            if needsNameStep {
                step = .nameNewType
            } else {
                step = .instanceForm
            }
        case .nameNewType:
            guard !newTypeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                showValidationErrors = true
                return
            }
            step = .instanceForm
        case .instanceForm:
            guard validateInstanceForm() else {
                showValidationErrors = true
                return
            }
            saveAsset()
        }
    }
}
