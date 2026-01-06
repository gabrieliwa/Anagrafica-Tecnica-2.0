import Foundation

public struct Project: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var state: ProjectLifecycleState
    public var location: String?
    public var roomCount: Int?
    public var assetCount: Int?
    public var imageURL: URL?

    public init(
        id: UUID,
        name: String,
        state: ProjectLifecycleState,
        location: String? = nil,
        roomCount: Int? = nil,
        assetCount: Int? = nil,
        imageURL: URL? = nil
    ) {
        self.id = id
        self.name = name
        self.state = state
        self.location = location
        self.roomCount = roomCount
        self.assetCount = assetCount
        self.imageURL = imageURL
    }
}

public extension Project {
    var uiState: ProjectUIState? {
        state.uiState
    }
}
