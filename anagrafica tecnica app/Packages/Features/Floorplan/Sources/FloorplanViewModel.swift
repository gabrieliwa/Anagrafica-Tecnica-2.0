import Core
import CoreData
import Foundation

@MainActor
final class FloorplanViewModel: ObservableObject {
    @Published var levels: [DemoPlanLevel] = []
    @Published var selectedLevelIndex: Int = 0 {
        didSet {
            if oldValue != selectedLevelIndex {
                loadSelectedLevel()
            }
        }
    }
    @Published var linework: [[Point]] = []
    @Published var rooms: [FloorplanRoom] = []
    @Published var roomCounts: [String: RoomCounts] = [:]
    @Published var bounds: Rect?
    @Published var isLoading = true
    @Published var errorMessage: String?

    private var demoBundle: Bundle

    init(bundle: Bundle) {
        self.demoBundle = bundle
        loadPlan()
    }

    var roomsWithCounts: [FloorplanRoom] {
        rooms.map { room in
            let counts = roomCounts[room.number] ?? .zero
            return room.withCounts(assetCount: counts.assetCount, roomNoteCount: counts.roomNoteCount)
        }
    }

    private func loadPlan() {
        do {
            let loader = try DemoPlanLoader(bundle: demoBundle)
            let template = try loader.loadPlanTemplate()
            demoBundle = loader.demoBundle
            levels = template.levels.sorted { lhs, rhs in
                let lhsKey = levelSortKey(for: lhs)
                let rhsKey = levelSortKey(for: rhs)
                if lhsKey == rhsKey {
                    return lhs.index < rhs.index
                }
                return lhsKey < rhsKey
            }
            if selectedLevelIndex != 0 {
                selectedLevelIndex = 0
            } else {
                loadSelectedLevel()
            }
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }


    private func loadSelectedLevel() {
        guard levels.indices.contains(selectedLevelIndex) else {
            return
        }
        let level = levels[selectedLevelIndex]
        bounds = rect(from: level.background.bounds)
        roomCounts = [:]
        rooms = level.rooms.compactMap { room in
            let polygon = room.shape.polygon.compactMap(point(from:))
            guard polygon.count >= 3 else {
                return nil
            }
            let labelPoint = GeometryUtils.bounds(for: polygon).map { bounds in
                Point(x: (bounds.minX + bounds.maxX) * 0.5, y: (bounds.minY + bounds.maxY) * 0.5)
            }
            return FloorplanRoom(
                id: room.id,
                name: room.name,
                number: room.number,
                polygon: polygon,
                labelPoint: labelPoint,
                assetCount: 0,
                roomNoteCount: 0
            )
        }

        do {
            linework = try GeoJSONLineworkLoader(bundle: demoBundle).loadLines(path: level.background.geojson)
        } catch {
            linework = []
        }
    }

    func reloadRoomCounts(context: NSManagedObjectContext) {
        guard levels.indices.contains(selectedLevelIndex) else {
            roomCounts = [:]
            return
        }
        let levelName = levels[selectedLevelIndex].name
        let request = NSFetchRequest<NSManagedObject>(entityName: "Room")
        request.predicate = NSPredicate(format: "level.name == %@", levelName)
        do {
            let results = try context.fetch(request)
            var counts: [String: RoomCounts] = [:]
            for room in results {
                guard let number = room.value(forKey: "number") as? String, !number.isEmpty else { continue }
                let assetCount = Int(room.value(forKey: "assetCount") as? Int64 ?? 0)
                let roomNoteCount = Int(room.value(forKey: "roomNoteCount") as? Int64 ?? 0)
                counts[number] = RoomCounts(assetCount: assetCount, roomNoteCount: roomNoteCount)
            }
            roomCounts = counts
        } catch {
            roomCounts = [:]
        }
    }

    private func rect(from bounds: [Double]) -> Rect? {
        guard bounds.count >= 4 else {
            return nil
        }
        return Rect(minX: bounds[0], minY: bounds[1], maxX: bounds[2], maxY: bounds[3])
    }

    private func point(from coords: [Double]) -> Point? {
        guard coords.count >= 2 else {
            return nil
        }
        return Point(x: coords[0], y: coords[1])
    }

    private func levelSortKey(for level: DemoPlanLevel) -> Int {
        let name = level.name.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if name == "PT" || name == "G" || name == "GROUND" {
            return 0
        }
        if let basement = parseLevelNumber(prefix: "S", name: name) {
            return -basement
        }
        if let basement = parseLevelNumber(prefix: "B", name: name) {
            return -basement
        }
        if let above = parseLevelNumber(prefix: "P", name: name) {
            return above
        }
        if let numeric = Int(name) {
            return numeric
        }
        return level.index
    }

    private func parseLevelNumber(prefix: String, name: String) -> Int? {
        guard name.hasPrefix(prefix) else { return nil }
        let raw = String(name.dropFirst(prefix.count))
        return Int(raw)
    }
}

struct FloorplanRoom: Identifiable {
    let id: String
    let name: String?
    let number: String
    let polygon: [Point]
    let labelPoint: Point?
    let assetCount: Int
    let roomNoteCount: Int

    var totalCount: Int {
        assetCount + roomNoteCount
    }

    func withCounts(assetCount: Int, roomNoteCount: Int) -> FloorplanRoom {
        FloorplanRoom(
            id: id,
            name: name,
            number: number,
            polygon: polygon,
            labelPoint: labelPoint,
            assetCount: assetCount,
            roomNoteCount: roomNoteCount
        )
    }
}

struct RoomCounts: Equatable {
    let assetCount: Int
    let roomNoteCount: Int

    static let zero = RoomCounts(assetCount: 0, roomNoteCount: 0)
}

struct GeoJSONLineworkLoader {
    let bundle: Bundle

    func loadLines(path: String) throws -> [[Point]] {
        guard let url = resourceURL(for: path) else {
            throw DemoPlanLoaderError.resourceMissing(path)
        }
        let data = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let features = json?["features"] as? [[String: Any]] ?? []

        var lines: [[Point]] = []
        for feature in features {
            guard let geometry = feature["geometry"] as? [String: Any],
                  let type = geometry["type"] as? String else {
                continue
            }
            let coordinates = geometry["coordinates"]
            switch type {
            case "LineString":
                if let line = parseLineString(coordinates) {
                    lines.append(line)
                }
            case "MultiLineString":
                lines.append(contentsOf: parseMultiLineString(coordinates))
            case "Polygon":
                lines.append(contentsOf: parsePolygon(coordinates))
            case "MultiPolygon":
                lines.append(contentsOf: parseMultiPolygon(coordinates))
            default:
                continue
            }
        }

        return lines
    }

    private func resourceURL(for path: String) -> URL? {
        let nsPath = path as NSString
        let directory = nsPath.deletingLastPathComponent
        let filename = nsPath.lastPathComponent as NSString
        let name = filename.deletingPathExtension
        let ext = filename.pathExtension
        return bundle.url(forResource: name, withExtension: ext, subdirectory: directory)
    }

    private func parseLineString(_ coordinates: Any?) -> [Point]? {
        guard let coords = coordinates as? [[Any]] else {
            return nil
        }
        return coords.compactMap(point(from:))
    }

    private func parseMultiLineString(_ coordinates: Any?) -> [[Point]] {
        guard let coords = coordinates as? [[[Any]]] else {
            return []
        }
        return coords.compactMap { line in
            let points = line.compactMap(point(from:))
            return points.isEmpty ? nil : points
        }
    }

    private func parsePolygon(_ coordinates: Any?) -> [[Point]] {
        guard let coords = coordinates as? [[[Any]]] else {
            return []
        }
        return coords.compactMap { ring in
            let points = ring.compactMap(point(from:))
            return points.isEmpty ? nil : points
        }
    }

    private func parseMultiPolygon(_ coordinates: Any?) -> [[Point]] {
        guard let coords = coordinates as? [[[[Any]]]] else {
            return []
        }
        return coords.flatMap { polygon in
            polygon.compactMap { ring in
                let points = ring.compactMap(point(from:))
                return points.isEmpty ? nil : points
            }
        }
    }

    private func point(from coords: [Any]) -> Point? {
        guard coords.count >= 2,
              let x = coords[0] as? Double,
              let y = coords[1] as? Double else {
            return nil
        }
        return Point(x: x, y: y)
    }
}
