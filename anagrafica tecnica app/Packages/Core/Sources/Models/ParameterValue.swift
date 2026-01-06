import Foundation

public enum ParameterValue: Codable, Equatable {
    case text(String)
    case number(Double)
    case bool(Bool)
    case date(Date)
    case option(String)

    private enum CodingKeys: String, CodingKey {
        case type
        case stringValue
        case numberValue
        case boolValue
        case dateValue
    }

    private enum ValueType: String, Codable {
        case text
        case number
        case bool
        case date
        case option
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ValueType.self, forKey: .type)
        switch type {
        case .text:
            let value = try container.decode(String.self, forKey: .stringValue)
            self = .text(value)
        case .number:
            let value = try container.decode(Double.self, forKey: .numberValue)
            self = .number(value)
        case .bool:
            let value = try container.decode(Bool.self, forKey: .boolValue)
            self = .bool(value)
        case .date:
            let value = try container.decode(Date.self, forKey: .dateValue)
            self = .date(value)
        case .option:
            let value = try container.decode(String.self, forKey: .stringValue)
            self = .option(value)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let value):
            try container.encode(ValueType.text, forKey: .type)
            try container.encode(value, forKey: .stringValue)
        case .number(let value):
            try container.encode(ValueType.number, forKey: .type)
            try container.encode(value, forKey: .numberValue)
        case .bool(let value):
            try container.encode(ValueType.bool, forKey: .type)
            try container.encode(value, forKey: .boolValue)
        case .date(let value):
            try container.encode(ValueType.date, forKey: .type)
            try container.encode(value, forKey: .dateValue)
        case .option(let value):
            try container.encode(ValueType.option, forKey: .type)
            try container.encode(value, forKey: .stringValue)
        }
    }
}

public struct ParameterValueEntry: Codable, Equatable {
    public var parameterId: UUID
    public var value: ParameterValue

    public init(parameterId: UUID, value: ParameterValue) {
        self.parameterId = parameterId
        self.value = value
    }
}
