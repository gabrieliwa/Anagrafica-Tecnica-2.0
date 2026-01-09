import Foundation
import XCTest
@testable import Core

final class GeometryUtilsTests: XCTestCase {
    func testBoundsForPolygon() {
        let polygon = [
            Point(x: 0, y: 0),
            Point(x: 2, y: 0),
            Point(x: 2, y: 1),
            Point(x: 0, y: 1)
        ]
        let bounds = GeometryUtils.bounds(for: polygon)
        XCTAssertEqual(bounds, Rect(minX: 0, minY: 0, maxX: 2, maxY: 1))
    }

    func testContainsPointInsidePolygon() {
        let polygon = [
            Point(x: 0, y: 0),
            Point(x: 2, y: 0),
            Point(x: 2, y: 2),
            Point(x: 0, y: 2)
        ]
        XCTAssertTrue(GeometryUtils.contains(point: Point(x: 1, y: 1), in: polygon))
    }

    func testContainsPointOutsidePolygon() {
        let polygon = [
            Point(x: 0, y: 0),
            Point(x: 2, y: 0),
            Point(x: 2, y: 2),
            Point(x: 0, y: 2)
        ]
        XCTAssertFalse(GeometryUtils.contains(point: Point(x: 3, y: 3), in: polygon))
    }

    func testNorthAngleDegrees() {
        let north = GeometryUtils.northAngleDegrees(start: Point(x: 0, y: 0), end: Point(x: 0, y: 1))
        XCTAssertEqual(north, 0, accuracy: 0.0001)

        let east = GeometryUtils.northAngleDegrees(start: Point(x: 0, y: 0), end: Point(x: 1, y: 0))
        XCTAssertEqual(east, 90, accuracy: 0.0001)
    }
}
