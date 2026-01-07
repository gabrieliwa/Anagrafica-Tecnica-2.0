import Foundation

public struct DemoPlanTemplate: Decodable {
    public let levels: [DemoPlanLevel]
}

public struct DemoPlanLevel: Decodable {
    public let id: String
    public let index: Int
    public let name: String
    public let background: DemoPlanBackground
    public let north: DemoPlanNorth?
    public let rooms: [DemoPlanRoom]
}

public struct DemoPlanBackground: Decodable {
    public let geojson: String
    public let bounds: [Double]
}

public struct DemoPlanNorth: Decodable {
    public let start: [Double]
    public let end: [Double]
}

public struct DemoPlanRoom: Decodable {
    public let id: String
    public let number: String
    public let name: String?
    public let shape: DemoPlanRoomShape
}

public struct DemoPlanRoomShape: Decodable {
    public let polygon: [[Double]]
}
