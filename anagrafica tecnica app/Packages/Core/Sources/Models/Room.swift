import Foundation

public struct Room: Identifiable, Codable, Equatable {
    public let id: UUID
    public let levelId: UUID
    public var name: String?
    public var number: String?
    public var geometry: RoomGeometry?
    public var assetCount: Int?
    public var roomNoteCount: Int?
    public var updatedAt: Date?

    public init(
        id: UUID,
        levelId: UUID,
        name: String? = nil,
        number: String? = nil,
        geometry: RoomGeometry? = nil,
        assetCount: Int? = nil,
        roomNoteCount: Int? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.levelId = levelId
        self.name = name
        self.number = number
        self.geometry = geometry
        self.assetCount = assetCount
        self.roomNoteCount = roomNoteCount
        self.updatedAt = updatedAt
    }
}

public extension Room {
    var itemCount: Int {
        (assetCount ?? 0) + (roomNoteCount ?? 0)
    }

    var isEmpty: Bool {
        itemCount == 0
    }
}
