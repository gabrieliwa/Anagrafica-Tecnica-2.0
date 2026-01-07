import Foundation

public enum GeometryUtils {
    public static func bounds(for polygon: [Point]) -> Rect? {
        guard let first = polygon.first else {
            return nil
        }
        var minX = first.x
        var minY = first.y
        var maxX = first.x
        var maxY = first.y

        for point in polygon.dropFirst() {
            minX = min(minX, point.x)
            minY = min(minY, point.y)
            maxX = max(maxX, point.x)
            maxY = max(maxY, point.y)
        }

        return Rect(minX: minX, minY: minY, maxX: maxX, maxY: maxY)
    }

    public static func northAngleDegrees(start: Point, end: Point) -> Double {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let radians = atan2(dx, dy)
        return radians * 180 / .pi
    }

    public static func contains(point: Point, in polygon: [Point]) -> Bool {
        guard polygon.count >= 3 else {
            return false
        }
        var isInside = false
        var j = polygon.count - 1
        for i in 0..<polygon.count {
            let pi = polygon[i]
            let pj = polygon[j]
            let intersects = ((pi.y > point.y) != (pj.y > point.y)) &&
                (point.x < (pj.x - pi.x) * (point.y - pi.y) / (pj.y - pi.y + 0.000001) + pi.x)
            if intersects {
                isInside.toggle()
            }
            j = i
        }
        return isInside
    }
}
