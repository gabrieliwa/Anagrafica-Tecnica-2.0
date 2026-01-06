import Foundation

public struct AssetType: Identifiable, Codable, Equatable {
    public let id: UUID
    public let familyId: UUID
    public var name: String
    public var parameters: [ParameterValueEntry]
    public var typePhotoId: UUID?
    public var createdAt: Date
    public var updatedAt: Date?

    public init(
        id: UUID,
        familyId: UUID,
        name: String,
        parameters: [ParameterValueEntry] = [],
        typePhotoId: UUID? = nil,
        createdAt: Date,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.familyId = familyId
        self.name = name
        self.parameters = parameters
        self.typePhotoId = typePhotoId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
