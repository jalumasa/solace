import Foundation
import Observation

@MainActor
@Observable
public final class CircleListViewModel {
    public private(set) var circles: [SupportCircle] = []
    public private(set) var errorMessage: String?

    private let currentUserID: String
    private let circleService: CircleServicing
    @ObservationIgnored
    private nonisolated(unsafe) var observationTask: Task<Void, Never>?

    public init(currentUserID: String, circleService: CircleServicing) {
        self.currentUserID = currentUserID
        self.circleService = circleService
        observationTask = Task { [weak self] in
            guard let self else { return }
            for await circles in circleService.observeCircles() {
                self.circles = circles
            }
        }
    }

    deinit {
        observationTask?.cancel()
    }

    public func clearError() {
        errorMessage = nil
    }

    public var myCircles: [SupportCircle] {
        circles.filter { $0.isMember(currentUserID) }
    }

    public var availableCircles: [SupportCircle] {
        circles.filter { !$0.isMember(currentUserID) }
    }

    public func join(_ circle: SupportCircle) async {
        do {
            try await circleService.join(circleID: circle.id, userID: currentUserID)
        } catch {
            errorMessage = "Couldn't join that circle. Please try again."
        }
    }

    public func leave(_ circle: SupportCircle) async {
        do {
            try await circleService.leave(circleID: circle.id, userID: currentUserID)
        } catch {
            errorMessage = "Couldn't leave that circle. Please try again."
        }
    }
}
