import Foundation
import XCTest
@testable import Core

final class StableIDTests: XCTestCase {
    func testDeterministicFromString() {
        let first = StableID.fromString("room-1", namespace: "project")
        let second = StableID.fromString("room-1", namespace: "project")
        XCTAssertEqual(first, second)
    }

    func testDifferentNamespaceProducesDifferentIDs() {
        let first = StableID.fromString("room-1", namespace: "project-a")
        let second = StableID.fromString("room-1", namespace: "project-b")
        XCTAssertNotEqual(first, second)
    }

    func testUuidStringPassThrough() {
        let uuid = UUID()
        let result = StableID.fromString(uuid.uuidString, namespace: "project")
        XCTAssertEqual(result, uuid)
    }
}
