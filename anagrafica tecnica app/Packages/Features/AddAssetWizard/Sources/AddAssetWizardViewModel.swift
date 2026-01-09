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

    private let context: NSManagedObjectContext
    private var roomObject: NSManagedObject?
    private var projectObject: NSManagedObject?
    private var typesByFamilyId: [UUID: [TypeOption]] = [:]
    private var originalTypeParameters: [ParameterValueEntry] = []
    private var roomHasAssets = false

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

    func addTypePhoto() {
        typePhotoId = UUID()
    }

    func removeTypePhoto() {
        typePhotoId = nil
    }

    func addInstancePhoto() {
        guard instancePhotoIds.count < 5 else { return }
        instancePhotoIds.append(UUID())
    }

    func removeInstancePhoto(id: UUID) {
        instancePhotoIds.removeAll { $0 == id }
    }

    func addRoomNotePhoto() {
        if roomNoteMainPhotoId == nil {
            roomNoteMainPhotoId = UUID()
        } else if roomNoteExtraPhotoIds.count < 4 {
            roomNoteExtraPhotoIds.append(UUID())
        }
    }

    func removeRoomNotePhoto(id: UUID) {
        if roomNoteMainPhotoId == id {
            roomNoteMainPhotoId = nil
        } else {
            roomNoteExtraPhotoIds.removeAll { $0 == id }
        }
    }

    func toggleRoomNoteEmpty() {
        guard !roomHasAssets else { return }
        roomNoteEmptyRoom.toggle()
        if roomNoteEmptyRoom {
            roomNoteBlocked = false
        }
    }

    func toggleRoomNoteBlocked() {
        guard !roomHasAssets else { return }
        roomNoteBlocked.toggle()
        if roomNoteBlocked {
            roomNoteEmptyRoom = false
        }
    }

    func textBinding(for definition: ParameterDefinition, scope: ParameterScope) -> Binding<String> {
        Binding(
            get: { self.inputText(for: definition, scope: scope) },
            set: { self.setInputText($0, for: definition, scope: scope) }
        )
    }

    func numberBinding(for definition: ParameterDefinition, scope: ParameterScope) -> Binding<String> {
        Binding(
            get: { self.inputNumber(for: definition, scope: scope) },
            set: { self.setInputNumber($0, for: definition, scope: scope) }
        )
    }

    func optionBinding(for definition: ParameterDefinition, scope: ParameterScope) -> Binding<String> {
        Binding(
            get: { self.inputOption(for: definition, scope: scope) },
            set: { self.setInputOption($0, for: definition, scope: scope) }
        )
    }

    func boolBinding(for definition: ParameterDefinition, scope: ParameterScope) -> Binding<Bool> {
        Binding(
            get: { self.inputBool(for: definition, scope: scope) },
            set: { self.setInputBool($0, for: definition, scope: scope) }
        )
    }

    func dateBinding(for definition: ParameterDefinition, scope: ParameterScope) -> Binding<Date> {
        Binding(
            get: { self.inputDate(for: definition, scope: scope) },
            set: { self.setInputDate($0, for: definition, scope: scope) }
        )
    }

    private func loadCoreData() {
        do {
            roomObject = try fetchRoom()
            if let level = roomObject?.value(forKey: "level") as? NSManagedObject {
                projectObject = level.value(forKey: "project") as? NSManagedObject
            }
            roomHasAssets = (roomObject?.value(forKey: "assetCount") as? Int64 ?? 0) > 0
            families = try fetchFamilies()
            typesByFamilyId = try fetchTypesByFamily()
        } catch {
            alertMessage = "Failed to load data: \(error.localizedDescription)"
        }
    }

    private func fetchRoom() throws -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Room")
        request.predicate = NSPredicate(format: "number == %@", roomNumber)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    private func fetchFamilies() throws -> [FamilyOption] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Family")
        let sort = NSSortDescriptor(key: "sortOrder", ascending: true)
        request.sortDescriptors = [sort]
        let families = try context.fetch(request)
        let decoder = JSONCoding.makeDecoder()
        return try families.compactMap { family in
            guard let id = family.value(forKey: "id") as? UUID,
                  let name = family.value(forKey: "name") as? String else {
                return nil
            }
            let sortOrder = (family.value(forKey: "sortOrder") as? Int64).map(Int.init)
            let parametersData = family.value(forKey: "parametersData") as? Data
            let parameters = (parametersData != nil) ? (try decoder.decode([ParameterDefinition].self, from: parametersData!)) : []
            return FamilyOption(
                id: id,
                name: name,
                sortOrder: sortOrder,
                parameters: parameters,
                objectID: family.objectID
            )
        }
    }

    private func fetchTypesByFamily() throws -> [UUID: [TypeOption]] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "AssetType")
        let types = try context.fetch(request)
        let decoder = JSONCoding.makeDecoder()
        var grouped: [UUID: [TypeOption]] = [:]
        for type in types {
            guard let id = type.value(forKey: "id") as? UUID,
                  let name = type.value(forKey: "name") as? String,
                  let family = type.value(forKey: "family") as? NSManagedObject,
                  let familyId = family.value(forKey: "id") as? UUID else {
                continue
            }
            let typePhotoId = type.value(forKey: "typePhotoId") as? UUID
            let parametersData = type.value(forKey: "parametersData") as? Data
            let parameters = (parametersData != nil) ? (try decoder.decode([ParameterValueEntry].self, from: parametersData!)) : []
            let option = TypeOption(id: id, name: name, parameters: parameters, typePhotoId: typePhotoId, objectID: type.objectID)
            grouped[familyId, default: []].append(option)
        }
        return grouped
    }

    private func resetTypeInputs() {
        typeTextInputs = [:]
        typeNumberInputs = [:]
        typeOptionInputs = [:]
        typeBoolInputs = [:]
        typeDateInputs = [:]
    }

    private func applyTypeParameters(_ entries: [ParameterValueEntry]) {
        resetTypeInputs()
        for entry in entries {
            switch entry.value {
            case .text(let value):
                typeTextInputs[entry.parameterId] = value
            case .number(let value):
                typeNumberInputs[entry.parameterId] = String(value)
            case .bool(let value):
                typeBoolInputs[entry.parameterId] = value
            case .date(let value):
                typeDateInputs[entry.parameterId] = value
            case .option(let value):
                typeOptionInputs[entry.parameterId] = value
            }
        }
    }

    private func currentTypeEntries() -> [ParameterValueEntry] {
        typeDefinitions.compactMap { definition in
            guard let value = value(for: definition, scope: .type) else { return nil }
            return ParameterValueEntry(parameterId: definition.id, value: value)
        }
    }

    private func currentInstanceEntries() -> [ParameterValueEntry] {
        instanceDefinitions.compactMap { definition in
            guard let value = value(for: definition, scope: .instance) else { return nil }
            return ParameterValueEntry(parameterId: definition.id, value: value)
        }
    }

    private func hasTypeChanges() -> Bool {
        let current = currentTypeEntries().sorted(by: { $0.parameterId.uuidString < $1.parameterId.uuidString })
        let original = originalTypeParameters.sorted(by: { $0.parameterId.uuidString < $1.parameterId.uuidString })
        return current != original
    }

    private func validateTypeForm() -> Bool {
        if typePhotoId == nil {
            return false
        }
        return typeDefinitions.allSatisfy { definition in
            value(for: definition, scope: .type) != nil
        }
    }

    private func validateInstanceForm() -> Bool {
        return instanceDefinitions.allSatisfy { definition in
            if definition.isRequired {
                return value(for: definition, scope: .instance) != nil
            }
            return true
        }
    }

    private func saveRoomNote() {
        guard let roomObject else {
            alertMessage = "Missing room data."
            return
        }
        guard roomNoteMainPhotoId != nil else {
            showValidationErrors = true
            return
        }
        if roomNoteBlocked && roomNoteDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showValidationErrors = true
            return
        }
        let noteObject = insert(entityName: "RoomNote")
        noteObject.setValue(UUID(), forKey: "id")
        noteObject.setValue(roomNoteEmptyRoom, forKey: "emptyRoom")
        noteObject.setValue(roomNoteBlocked, forKey: "roomIsBlocked")
        noteObject.setValue(roomNoteDescription.isEmpty ? nil : roomNoteDescription, forKey: "noteDescription")
        noteObject.setValue(roomNoteMainPhotoId, forKey: "mainPhotoId")
        if !roomNoteExtraPhotoIds.isEmpty {
            noteObject.setValue(encode(roomNoteExtraPhotoIds), forKey: "extraPhotoIds")
        }
        noteObject.setValue(Date(), forKey: "createdAt")
        noteObject.setValue(roomObject, forKey: "room")

        incrementCount(for: roomObject, key: "roomNoteCount")
        saveContext()
    }

    private func saveAsset() {
        guard let roomObject else {
            alertMessage = "Missing room data."
            return
        }

        let typeObject: NSManagedObject
        if isCreatingNewType || needsNameStep {
            guard let family = selectedFamily else {
                alertMessage = "Missing family."
                return
            }
            typeObject = insert(entityName: "AssetType")
            typeObject.setValue(UUID(), forKey: "id")
            typeObject.setValue(newTypeName.isEmpty ? "New Type" : newTypeName, forKey: "name")
            typeObject.setValue(Date(), forKey: "createdAt")
            typeObject.setValue(typePhotoId, forKey: "typePhotoId")
            typeObject.setValue(encode(currentTypeEntries()), forKey: "parametersData")
            typeObject.setValue(context.object(with: family.objectID), forKey: "family")
        } else if let selectedType {
            typeObject = context.object(with: selectedType.objectID)
        } else {
            alertMessage = "Missing type."
            return
        }

        let instanceObject = insert(entityName: "AssetInstance")
        instanceObject.setValue(UUID(), forKey: "id")
        instanceObject.setValue(Date(), forKey: "createdAt")
        instanceObject.setValue(encode(currentInstanceEntries()), forKey: "parametersData")
        if !instancePhotoIds.isEmpty {
            instanceObject.setValue(encode(instancePhotoIds), forKey: "instancePhotoIds")
        }
        instanceObject.setValue(roomObject, forKey: "room")
        instanceObject.setValue(typeObject, forKey: "type")

        incrementCount(for: roomObject, key: "assetCount")
        if let projectObject {
            incrementCount(for: projectObject, key: "assetCount")
        }
        saveContext()
    }

    private func incrementCount(for object: NSManagedObject, key: String) {
        let current = object.value(forKey: key) as? Int64 ?? 0
        object.setValue(current + 1, forKey: key)
    }

    private func saveContext() {
        do {
            if context.hasChanges {
                try context.save()
            }
            alertMessage = nil
            didSave = true
        } catch {
            alertMessage = "Failed to save: \(error.localizedDescription)"
        }
    }

    private func insert(entityName: String) -> NSManagedObject {
        NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
    }

    private func encode<T: Encodable>(_ value: T) -> Data? {
        do {
            return try JSONCoding.makeEncoder().encode(value)
        } catch {
            return nil
        }
    }

    func value(for definition: ParameterDefinition, scope: ParameterScope) -> ParameterValue? {
        switch (definition.dataType, scope) {
        case (.text, .type):
            let text = typeTextInputs[definition.id] ?? ""
            return text.isEmpty ? nil : .text(text)
        case (.text, .instance):
            let text = instanceTextInputs[definition.id] ?? ""
            return text.isEmpty ? nil : .text(text)
        case (.number, .type):
            guard let input = typeNumberInputs[definition.id],
                  let value = Double(input) else { return nil }
            return .number(value)
        case (.number, .instance):
            guard let input = instanceNumberInputs[definition.id],
                  let value = Double(input) else { return nil }
            return .number(value)
        case (.boolean, .type):
            return .bool(typeBoolInputs[definition.id] ?? false)
        case (.boolean, .instance):
            return .bool(instanceBoolInputs[definition.id] ?? false)
        case (.date, .type):
            return .date(typeDateInputs[definition.id] ?? Date())
        case (.date, .instance):
            return .date(instanceDateInputs[definition.id] ?? Date())
        case (.enumerated, .type):
            let option = typeOptionInputs[definition.id] ?? ""
            return option.isEmpty ? nil : .option(option)
        case (.enumerated, .instance):
            let option = instanceOptionInputs[definition.id] ?? ""
            return option.isEmpty ? nil : .option(option)
        }
    }

    private func inputText(for definition: ParameterDefinition, scope: ParameterScope) -> String {
        switch scope {
        case .type:
            return typeTextInputs[definition.id] ?? ""
        case .instance:
            return instanceTextInputs[definition.id] ?? ""
        }
    }

    private func setInputText(_ value: String, for definition: ParameterDefinition, scope: ParameterScope) {
        switch scope {
        case .type:
            typeTextInputs[definition.id] = value
        case .instance:
            instanceTextInputs[definition.id] = value
        }
    }

    private func inputNumber(for definition: ParameterDefinition, scope: ParameterScope) -> String {
        switch scope {
        case .type:
            return typeNumberInputs[definition.id] ?? ""
        case .instance:
            return instanceNumberInputs[definition.id] ?? ""
        }
    }

    private func setInputNumber(_ value: String, for definition: ParameterDefinition, scope: ParameterScope) {
        switch scope {
        case .type:
            typeNumberInputs[definition.id] = value
        case .instance:
            instanceNumberInputs[definition.id] = value
        }
    }

    private func inputOption(for definition: ParameterDefinition, scope: ParameterScope) -> String {
        switch scope {
        case .type:
            return typeOptionInputs[definition.id] ?? ""
        case .instance:
            return instanceOptionInputs[definition.id] ?? ""
        }
    }

    private func setInputOption(_ value: String, for definition: ParameterDefinition, scope: ParameterScope) {
        switch scope {
        case .type:
            typeOptionInputs[definition.id] = value
        case .instance:
            instanceOptionInputs[definition.id] = value
        }
    }

    private func inputBool(for definition: ParameterDefinition, scope: ParameterScope) -> Bool {
        switch scope {
        case .type:
            return typeBoolInputs[definition.id] ?? false
        case .instance:
            return instanceBoolInputs[definition.id] ?? false
        }
    }

    private func setInputBool(_ value: Bool, for definition: ParameterDefinition, scope: ParameterScope) {
        switch scope {
        case .type:
            typeBoolInputs[definition.id] = value
        case .instance:
            instanceBoolInputs[definition.id] = value
        }
    }

    private func inputDate(for definition: ParameterDefinition, scope: ParameterScope) -> Date {
        switch scope {
        case .type:
            return typeDateInputs[definition.id] ?? Date()
        case .instance:
            return instanceDateInputs[definition.id] ?? Date()
        }
    }

    private func setInputDate(_ value: Date, for definition: ParameterDefinition, scope: ParameterScope) {
        switch scope {
        case .type:
            typeDateInputs[definition.id] = value
        case .instance:
            instanceDateInputs[definition.id] = value
        }
    }
}
