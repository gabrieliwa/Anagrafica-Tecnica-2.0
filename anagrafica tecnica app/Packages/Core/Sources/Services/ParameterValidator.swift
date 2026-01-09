import Foundation

public enum ParameterValidationIssue: Equatable {
    case missingRequired
    case typeMismatch(expected: ParameterDataType)
    case min(Double)
    case max(Double)
    case minLength(Int)
    case maxLength(Int)
    case regex(String)
    case invalidOption(String)
}

public enum ParameterValidator {
    public static func validate(
        value: ParameterValue?,
        definition: ParameterDefinition
    ) -> [ParameterValidationIssue] {
        guard let value else {
            return definition.isRequired ? [.missingRequired] : []
        }

        switch (definition.dataType, value) {
        case (.text, .text(let text)):
            return validateText(text, definition: definition)
        case (.number, .number(let number)):
            return validateNumber(number, definition: definition)
        case (.boolean, .bool):
            return []
        case (.date, .date):
            return []
        case (.enumerated, .option(let option)):
            return validateOption(option, definition: definition)
        default:
            return [.typeMismatch(expected: definition.dataType)]
        }
    }

    private static func validateText(
        _ text: String,
        definition: ParameterDefinition
    ) -> [ParameterValidationIssue] {
        var issues: [ParameterValidationIssue] = []
        if let minLength = definition.validation?.minLength, text.count < minLength {
            issues.append(.minLength(minLength))
        }
        if let maxLength = definition.validation?.maxLength, text.count > maxLength {
            issues.append(.maxLength(maxLength))
        }
        if let regex = definition.validation?.regex {
            if !matchesRegex(text, pattern: regex) {
                issues.append(.regex(regex))
            }
        }
        return issues
    }

    private static func validateNumber(
        _ number: Double,
        definition: ParameterDefinition
    ) -> [ParameterValidationIssue] {
        var issues: [ParameterValidationIssue] = []
        if let min = definition.validation?.min, number < min {
            issues.append(.min(min))
        }
        if let max = definition.validation?.max, number > max {
            issues.append(.max(max))
        }
        return issues
    }

    private static func validateOption(
        _ option: String,
        definition: ParameterDefinition
    ) -> [ParameterValidationIssue] {
        guard let values = definition.enumValues, !values.isEmpty else {
            return []
        }
        return values.contains(option) ? [] : [.invalidOption(option)]
    }

    private static func matchesRegex(_ text: String, pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            logInvalidRegex(pattern)
            return true
        }
        let range = NSRange(text.startIndex..., in: text)
        return regex.firstMatch(in: text, options: [], range: range) != nil
    }

    private static func logInvalidRegex(_ pattern: String) {
        #if DEBUG
        print("ParameterValidator: Invalid regex pattern: \(pattern)")
        #endif
    }
}
