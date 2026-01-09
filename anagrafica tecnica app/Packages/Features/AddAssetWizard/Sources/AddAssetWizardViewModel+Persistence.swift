import Core
import CoreData
import Foundation

@MainActor
extension AddAssetWizardViewModel {
    func loadCoreData() {
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

    func fetchRoom() throws -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Room")
        request.predicate = NSPredicate(format: "number == %@", roomNumber)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    func fetchFamilies() throws -> [FamilyOption] {
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

    func fetchTypesByFamily() throws -> [UUID: [TypeOption]] {
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

    func resetTypeInputs() {
        typeTextInputs = [:]
        typeNumberInputs = [:]
        typeOptionInputs = [:]
        typeBoolInputs = [:]
        typeDateInputs = [:]
    }

    func applyTypeParameters(_ entries: [ParameterValueEntry]) {
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

    func saveRoomNote() {
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

    func saveAsset() {
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

    func incrementCount(for object: NSManagedObject, key: String) {
        let current = object.value(forKey: key) as? Int64 ?? 0
        object.setValue(current + 1, forKey: key)
    }

    func saveContext() {
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

    func insert(entityName: String) -> NSManagedObject {
        NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
    }

    func encode<T: Encodable>(_ value: T) -> Data? {
        do {
            return try JSONCoding.makeEncoder().encode(value)
        } catch {
            print("AddAssetWizard: Failed to encode \(T.self): \(error)")
            return nil
        }
    }
}
