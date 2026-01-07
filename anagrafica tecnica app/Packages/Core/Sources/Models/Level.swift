import Foundation

public struct Level: Identifiable, Codable, Equatable {
    public let id: UUID
    public let projectId: UUID
    public var name: String
    public var number: Int?
    public var orderIndex: Int
    public var backgroundGeoJSONPath: String?
    public var backgroundBounds: Rect?
    public var northAngleDegrees: Double?

    public init(
        id: UUID,
        projectId: UUID,
        name: String,
        number: Int? = nil,
        orderIndex: Int,
        backgroundGeoJSONPath: String? = nil,
        backgroundBounds: Rect? = nil,
        northAngleDegrees: Double? = nil
    ) {
        self.id = id
        self.projectId = projectId
        self.name = name
        self.number = number
        self.orderIndex = orderIndex
        self.backgroundGeoJSONPath = backgroundGeoJSONPath
        self.backgroundBounds = backgroundBounds
        self.northAngleDegrees = northAngleDegrees
    }
}
