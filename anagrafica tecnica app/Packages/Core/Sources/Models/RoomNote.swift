import Foundation

public struct RoomNoteFlags: Codable, Equatable {
    public var emptyRoom: Bool
    public var roomIsBlocked: Bool

    public init(emptyRoom: Bool = false, roomIsBlocked: Bool = false) {
        self.emptyRoom = emptyRoom
        self.roomIsBlocked = roomIsBlocked
    }
}

public struct RoomNote: Identifiable, Codable, Equatable {
    public let id: UUID
    public let roomId: UUID
    public var flags: RoomNoteFlags
    public var description: String?
    public var mainPhotoId: UUID?
    public var extraPhotoIds: [UUID]
    public var createdAt: Date
    public var updatedAt: Date?

    public init(
        id: UUID,
        roomId: UUID,
        flags: RoomNoteFlags = RoomNoteFlags(),
        description: String? = nil,
        mainPhotoId: UUID? = nil,
        extraPhotoIds: [UUID] = [],
        createdAt: Date,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.roomId = roomId
        self.flags = flags
        self.description = description
        self.mainPhotoId = mainPhotoId
        self.extraPhotoIds = extraPhotoIds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public extension RoomNote {
    var isLocked: Bool {
        flags.roomIsBlocked
    }
}
