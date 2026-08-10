import Foundation
import Observation

@MainActor
@Observable
public final class ConversationListViewModel {
    public private(set) var conversations: [Conversation] = []
    public private(set) var counselors: [User] = []
    public private(set) var isLoading = false
    public private(set) var errorMessage: String?

    private let currentUser: User
    private let messagingService: MessagingServicing
    @ObservationIgnored
    private nonisolated(unsafe) var observationTask: Task<Void, Never>?

    public init(currentUser: User, messagingService: MessagingServicing) {
        self.currentUser = currentUser
        self.messagingService = messagingService
        observationTask = Task { [weak self] in
            guard let self else { return }
            for await conversations in messagingService.observeConversations(for: currentUser.id) {
                self.conversations = conversations
            }
        }
    }

    deinit {
        observationTask?.cancel()
    }

    public func clearError() {
        errorMessage = nil
    }

    public func loadCounselors() async {
        guard currentUser.role == .student else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            counselors = try await messagingService.fetchCounselors()
        } catch {
            errorMessage = "Couldn't load counselors. Please try again."
        }
    }

    public func startConversation(with counselor: User) async -> Conversation? {
        do {
            return try await messagingService.startConversation(
                studentID: currentUser.id,
                studentName: currentUser.displayName,
                counselorID: counselor.id,
                counselorName: counselor.displayName
            )
        } catch {
            errorMessage = "Couldn't start conversation. Please try again."
            return nil
        }
    }
}
