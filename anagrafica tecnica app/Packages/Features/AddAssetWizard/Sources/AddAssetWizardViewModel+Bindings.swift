import Core
import Foundation
import SwiftUI

@MainActor
extension AddAssetWizardViewModel {
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
            var updated = typeTextInputs
            updated[definition.id] = value
            typeTextInputs = updated
        case .instance:
            var updated = instanceTextInputs
            updated[definition.id] = value
            instanceTextInputs = updated
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
            var updated = typeNumberInputs
            updated[definition.id] = value
            typeNumberInputs = updated
        case .instance:
            var updated = instanceNumberInputs
            updated[definition.id] = value
            instanceNumberInputs = updated
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
            var updated = typeOptionInputs
            updated[definition.id] = value
            typeOptionInputs = updated
        case .instance:
            var updated = instanceOptionInputs
            updated[definition.id] = value
            instanceOptionInputs = updated
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
            var updated = typeBoolInputs
            updated[definition.id] = value
            typeBoolInputs = updated
        case .instance:
            var updated = instanceBoolInputs
            updated[definition.id] = value
            instanceBoolInputs = updated
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
            var updated = typeDateInputs
            updated[definition.id] = value
            typeDateInputs = updated
        case .instance:
            var updated = instanceDateInputs
            updated[definition.id] = value
            instanceDateInputs = updated
        }
    }
}
