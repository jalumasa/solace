import Foundation

struct TestError: Error, Equatable {}

/// AsyncStream delivery to an in-flight `for await` loop happens on another
/// scheduling turn, so tests that emit into a mock stream give the consuming
/// Task a brief moment to run before asserting on the result.
func allowStreamDelivery() async {
    try? await Task.sleep(nanoseconds: 50_000_000)
}
