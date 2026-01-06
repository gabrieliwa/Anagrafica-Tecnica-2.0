import Foundation

public struct Family: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var iconName: String?
    public var parameters: [ParameterDefinition]
    public var sortOrder: Int?

    public init(
        id: UUID,
        name: String,
        iconName: String? = nil,
        parameters: [ParameterDefinition] = [],
        sortOrder: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.parameters = parameters
        self.sortOrder = sortOrder
    }
}

public extension Family {
    var typeParameters: [ParameterDefinition] {
        parameters.filter { $0.scope == .type }
    }

    var instanceParameters: [ParameterDefinition] {
        parameters.filter { $0.scope == .instance }
    }
}
