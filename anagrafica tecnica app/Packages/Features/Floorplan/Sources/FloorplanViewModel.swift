import Core
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
    @Published var bounds: Rect?
    @Published var isLoading = true
    @Published var errorMessage: String?

    private var demoBundle: Bundle

    init(bundle: Bundle) {
        self.demoBundle = bundle
        loadPlan()
    }

    private func loadPlan() {
        do {
            let loader = try DemoPlanLoader(bundle: demoBundle)
            let template = try loader.loadPlanTemplate()
            demoBundle = loader.demoBundle
            levels = template.levels
            selectedLevelIndex = 0
            loadSelectedLevel()
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
                labelPoint: labelPoint
            )
        }

        do {
            linework = try GeoJSONLineworkLoader(bundle: demoBundle).loadLines(path: level.background.geojson)
        } catch {
            linework = []
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
}

struct FloorplanRoom: Identifiable {
    let id: String
    let name: String?
    let number: String
    let polygon: [Point]
    let labelPoint: Point?
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
