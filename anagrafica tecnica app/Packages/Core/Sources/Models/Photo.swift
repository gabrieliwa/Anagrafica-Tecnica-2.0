import Foundation

public enum PhotoScope: String, Codable, CaseIterable {
    case type = "TYPE"
    case instance = "INSTANCE"
    case roomNote = "ROOM_NOTE"
}

public enum PhotoRole: String, Codable, CaseIterable {
    case main = "MAIN"
    case extra = "EXTRA"
}

public enum PhotoUploadState: String, Codable, CaseIterable {
    case pending = "PENDING"
    case uploading = "UPLOADING"
    case uploaded = "UPLOADED"
    case failed = "FAILED"
}

public struct Photo: Identifiable, Codable, Equatable {
    public let id: UUID
    public var scope: PhotoScope
    public var role: PhotoRole
    public var ownerId: UUID
    public var filename: String
    public var localURL: URL?
    public var remoteURL: URL?
    public var width: Int?
    public var height: Int?
    public var sizeBytes: Int?
    public var createdAt: Date
    public var uploadState: PhotoUploadState

    public init(
        id: UUID,
        scope: PhotoScope,
        role: PhotoRole,
        ownerId: UUID,
        filename: String,
        localURL: URL? = nil,
        remoteURL: URL? = nil,
        width: Int? = nil,
        height: Int? = nil,
        sizeBytes: Int? = nil,
        createdAt: Date,
        uploadState: PhotoUploadState = .pending
    ) {
        self.id = id
        self.scope = scope
        self.role = role
        self.ownerId = ownerId
        self.filename = filename
        self.localURL = localURL
        self.remoteURL = remoteURL
        self.width = width
        self.height = height
        self.sizeBytes = sizeBytes
        self.createdAt = createdAt
        self.uploadState = uploadState
    }
}
