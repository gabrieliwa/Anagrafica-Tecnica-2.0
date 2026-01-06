import Foundation

public struct AssetInstance: Identifiable, Codable, Equatable {
    public let id: UUID
    public let roomId: UUID
    public let typeId: UUID
    public var parameters: [ParameterValueEntry]
    public var instancePhotoIds: [UUID]
    public var createdAt: Date
    public var updatedAt: Date?

    public init(
        id: UUID,
        roomId: UUID,
        typeId: UUID,
        parameters: [ParameterValueEntry] = [],
        instancePhotoIds: [UUID] = [],
        createdAt: Date,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.roomId = roomId
        self.typeId = typeId
        self.parameters = parameters
        self.instancePhotoIds = instancePhotoIds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
