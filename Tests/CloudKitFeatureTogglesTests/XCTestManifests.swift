import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(FeatureToggleRepositoryTests.allTests),
        testCase(FeatureToggleSubscriptorTests.allTests),
    ]
}
#endif
