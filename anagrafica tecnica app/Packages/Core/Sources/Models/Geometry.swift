import Foundation

public struct Point: Codable, Equatable {
    public var x: Double
    public var y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public struct Rect: Codable, Equatable {
    public var minX: Double
    public var minY: Double
    public var maxX: Double
    public var maxY: Double

    public init(minX: Double, minY: Double, maxX: Double, maxY: Double) {
        self.minX = minX
        self.minY = minY
        self.maxX = maxX
        self.maxY = maxY
    }
}

public struct RoomGeometry: Codable, Equatable {
    public var polygon: [Point]
    public var labelPoint: Point?
    public var bounds: Rect?

    public init(polygon: [Point], labelPoint: Point? = nil, bounds: Rect? = nil) {
        self.polygon = polygon
        self.labelPoint = labelPoint
        self.bounds = bounds
    }
}
