import XCTest
@testable import CloudKitFeatureToggles

final class CloudKitFeatureTogglesTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CloudKitFeatureToggles().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
