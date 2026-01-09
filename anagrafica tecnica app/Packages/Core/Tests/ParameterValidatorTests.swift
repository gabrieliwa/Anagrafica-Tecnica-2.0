import Foundation
import XCTest
@testable import Core

final class ParameterValidatorTests: XCTestCase {
    func testMissingRequiredValue() {
        let definition = ParameterDefinition(
            id: UUID(),
            name: "Required",
            dataType: .text,
            scope: .type,
            isRequired: true
        )
        let issues = ParameterValidator.validate(value: nil, definition: definition)
        XCTAssertEqual(issues, [.missingRequired])
    }

    func testOptionalValueAllowsNil() {
        let definition = ParameterDefinition(
            id: UUID(),
            name: "Optional",
            dataType: .text,
            scope: .type,
            isRequired: false
        )
        let issues = ParameterValidator.validate(value: nil, definition: definition)
        XCTAssertEqual(issues, [])
    }

    func testTextLengthValidation() {
        let definition = ParameterDefinition(
            id: UUID(),
            name: "Code",
            dataType: .text,
            scope: .type,
            isRequired: true,
            validation: ValidationRule(minLength: 2, maxLength: 4)
        )
        let tooShort = ParameterValidator.validate(value: .text("A"), definition: definition)
        XCTAssertEqual(tooShort, [.minLength(2)])

        let tooLong = ParameterValidator.validate(value: .text("ABCDE"), definition: definition)
        XCTAssertEqual(tooLong, [.maxLength(4)])
    }

    func testTextRegexValidation() {
        let definition = ParameterDefinition(
            id: UUID(),
            name: "Plate",
            dataType: .text,
            scope: .type,
            isRequired: true,
            validation: ValidationRule(regex: "^[A-Z]{2}$")
        )
        let issues = ParameterValidator.validate(value: .text("A1"), definition: definition)
        XCTAssertEqual(issues, [.regex("^[A-Z]{2}$")])
    }

    func testNumberRangeValidation() {
        let definition = ParameterDefinition(
            id: UUID(),
            name: "Power",
            dataType: .number,
            scope: .type,
            isRequired: true,
            validation: ValidationRule(min: 1, max: 10)
        )
        let belowMin = ParameterValidator.validate(value: .number(0.5), definition: definition)
        XCTAssertEqual(belowMin, [.min(1)])

        let aboveMax = ParameterValidator.validate(value: .number(11), definition: definition)
        XCTAssertEqual(aboveMax, [.max(10)])
    }

    func testEnumValidation() {
        let definition = ParameterDefinition(
            id: UUID(),
            name: "Condition",
            dataType: .enumerated,
            scope: .instance,
            isRequired: true,
            enumValues: ["New", "Used"]
        )
        let issues = ParameterValidator.validate(value: .option("Broken"), definition: definition)
        XCTAssertEqual(issues, [.invalidOption("Broken")])
    }

    func testTypeMismatch() {
        let definition = ParameterDefinition(
            id: UUID(),
            name: "Count",
            dataType: .number,
            scope: .instance,
            isRequired: true
        )
        let issues = ParameterValidator.validate(value: .text("oops"), definition: definition)
        XCTAssertEqual(issues, [.typeMismatch(expected: .number)])
    }
}
