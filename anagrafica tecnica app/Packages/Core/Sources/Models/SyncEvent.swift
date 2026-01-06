import Foundation

public enum SyncEventType: String, Codable, CaseIterable {
    case instanceCreated = "INSTANCE_CREATED"
    case instanceUpdated = "INSTANCE_UPDATED"
    case instanceDeleted = "INSTANCE_DELETED"
    case typeCreated = "TYPE_CREATED"
    case typeUpdated = "TYPE_UPDATED"
    case photoAttached = "PHOTO_ATTACHED"
    case roomNoteCreated = "ROOM_NOTE_CREATED"
    case roomNoteUpdated = "ROOM_NOTE_UPDATED"
    case roomNoteDeleted = "ROOM_NOTE_DELETED"
}

public enum SyncEventStatus: String, Codable, CaseIterable {
    case pending = "PENDING"
    case uploading = "UPLOADING"
    case uploaded = "UPLOADED"
    case failed = "FAILED"
}

public struct SyncEvent: Identifiable, Codable, Equatable {
    public let id: UUID
    public let projectId: UUID
    public var type: SyncEventType
    public var timestamp: Date
    public var payload: Data
    public var deviceId: String
    public var operatorId: String
    public var status: SyncEventStatus
    public var retryCount: Int
    public var lastAttemptAt: Date?

    public init(
        id: UUID,
        projectId: UUID,
        type: SyncEventType,
        timestamp: Date,
        payload: Data,
        deviceId: String,
        operatorId: String,
        status: SyncEventStatus = .pending,
        retryCount: Int = 0,
        lastAttemptAt: Date? = nil
    ) {
        self.id = id
        self.projectId = projectId
        self.type = type
        self.timestamp = timestamp
        self.payload = payload
        self.deviceId = deviceId
        self.operatorId = operatorId
        self.status = status
        self.retryCount = retryCount
        self.lastAttemptAt = lastAttemptAt
    }
}
