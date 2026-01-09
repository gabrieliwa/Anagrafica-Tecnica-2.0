import Core
import Foundation

@MainActor
extension AddAssetWizardViewModel {
    func currentTypeEntries() -> [ParameterValueEntry] {
        typeDefinitions.compactMap { definition in
            guard let value = value(for: definition, scope: .type) else { return nil }
            return ParameterValueEntry(parameterId: definition.id, value: value)
        }
    }

    func currentInstanceEntries() -> [ParameterValueEntry] {
        instanceDefinitions.compactMap { definition in
            guard let value = value(for: definition, scope: .instance) else { return nil }
            return ParameterValueEntry(parameterId: definition.id, value: value)
        }
    }

    func hasTypeChanges() -> Bool {
        let current = currentTypeEntries().sorted(by: { $0.parameterId.uuidString < $1.parameterId.uuidString })
        let original = originalTypeParameters.sorted(by: { $0.parameterId.uuidString < $1.parameterId.uuidString })
        return current != original
    }

    func validateTypeForm() -> Bool {
        if typePhotoId == nil {
            return false
        }
        return typeDefinitions.allSatisfy { definition in
            value(for: definition, scope: .type) != nil
        }
    }

    func validateInstanceForm() -> Bool {
        return instanceDefinitions.allSatisfy { definition in
            if definition.isRequired {
                return value(for: definition, scope: .instance) != nil
            }
            return true
        }
    }
}
