package com.jonathanalumasa.solace.support

import com.jonathanalumasa.solace.model.User
import com.jonathanalumasa.solace.service.AuthService
import com.jonathanalumasa.solace.service.SignUpDetails
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.test.TestDispatcher
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.setMain
import org.junit.rules.TestWatcher
import org.junit.runner.Description

class TestError : Exception("test")

/** Redirects Dispatchers.Main to a test dispatcher for `viewModelScope` work. */
@OptIn(ExperimentalCoroutinesApi::class)
class MainDispatcherRule(
    private val dispatcher: TestDispatcher = UnconfinedTestDispatcher()
) : TestWatcher() {
    override fun starting(description: Description) {
        Dispatchers.setMain(dispatcher)
    }

    override fun finished(description: Description) {
        Dispatchers.resetMain()
    }
}

/**
 * Mirrors the Swift `MockAuthService`. The auth-state flow uses `replay = 1`
 * so a test can emit before the ViewModel starts collecting — the Kotlin
 * counterpart of the eagerly-created `AsyncStream` pairs in SolaceCoreTests.
 */
class FakeAuthService : AuthService {
    private val authState = MutableSharedFlow<User?>(replay = 1)

    var signInResult: Result<User> = Result.failure(TestError())
    var signUpResult: Result<User> = Result.failure(TestError())
    var lastSignUpDetails: SignUpDetails? = null
    var didSignOut: Boolean = false
        private set

    override fun observeAuthState(): Flow<User?> = authState

    override suspend fun signIn(email: String, password: String): User = signInResult.getOrThrow()

    override suspend fun signUp(details: SignUpDetails): User {
        lastSignUpDetails = details
        return signUpResult.getOrThrow()
    }

    override fun signOut() {
        didSignOut = true
    }

    suspend fun emitAuthState(user: User?) {
        authState.emit(user)
    }
}
