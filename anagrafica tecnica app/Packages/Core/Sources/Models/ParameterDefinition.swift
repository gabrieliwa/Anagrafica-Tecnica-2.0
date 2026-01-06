import Foundation

public enum ParameterScope: String, Codable, CaseIterable {
    case type = "TYPE"
    case instance = "INSTANCE"
}

public enum ParameterDataType: String, Codable, CaseIterable {
    case text = "TEXT"
    case number = "NUMBER"
    case boolean = "BOOLEAN"
    case date = "DATE"
    case enumerated = "ENUM"
}

public struct ValidationRule: Codable, Equatable {
    public var min: Double?
    public var max: Double?
    public var minLength: Int?
    public var maxLength: Int?
    public var regex: String?

    public init(
        min: Double? = nil,
        max: Double? = nil,
        minLength: Int? = nil,
        maxLength: Int? = nil,
        regex: String? = nil
    ) {
        self.min = min
        self.max = max
        self.minLength = minLength
        self.maxLength = maxLength
        self.regex = regex
    }
}

public struct ParameterDefinition: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var dataType: ParameterDataType
    public var scope: ParameterScope
    public var isRequired: Bool
    public var unit: String?
    public var enumValues: [String]?
    public var validation: ValidationRule?

    public init(
        id: UUID,
        name: String,
        dataType: ParameterDataType,
        scope: ParameterScope,
        isRequired: Bool,
        unit: String? = nil,
        enumValues: [String]? = nil,
        validation: ValidationRule? = nil
    ) {
        self.id = id
        self.name = name
        self.dataType = dataType
        self.scope = scope
        self.isRequired = isRequired
        self.unit = unit
        self.enumValues = enumValues
        self.validation = validation
    }
}
