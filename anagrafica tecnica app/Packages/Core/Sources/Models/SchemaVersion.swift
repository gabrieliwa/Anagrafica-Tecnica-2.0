import Foundation

public struct SchemaVersion: Identifiable, Codable, Equatable {
    public let id: UUID
    public let projectId: UUID
    public var version: String
    public var createdAt: Date
    public var isLocked: Bool
    public var families: [Family]

    public init(
        id: UUID,
        projectId: UUID,
        version: String,
        createdAt: Date,
        isLocked: Bool,
        families: [Family] = []
    ) {
        self.id = id
        self.projectId = projectId
        self.version = version
        self.createdAt = createdAt
        self.isLocked = isLocked
        self.families = families
    }
}
