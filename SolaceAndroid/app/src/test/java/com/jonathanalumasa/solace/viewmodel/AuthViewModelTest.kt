package com.jonathanalumasa.solace.viewmodel

import com.jonathanalumasa.solace.model.AcademicYear
import com.jonathanalumasa.solace.model.Role
import com.jonathanalumasa.solace.model.User
import com.jonathanalumasa.solace.support.FakeAuthService
import com.jonathanalumasa.solace.support.MainDispatcherRule
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import java.util.Date

@OptIn(ExperimentalCoroutinesApi::class)
class AuthViewModelTest {

    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()

    // Fixed timestamp: User.createdAt defaults to Date(), so a freshly built
    // instance would never equal an earlier one.
    private val student = User(
        id = "u1",
        email = "a@b.com",
        displayName = "Alex",
        role = Role.STUDENT,
        createdAt = Date(0)
    )

    @Test
    fun `initial state is loading`() {
        val service = FakeAuthService()
        val viewModel = AuthViewModel(service)

        assertEquals(AuthState.Loading, viewModel.state.value)
    }

    @Test
    fun `auth state observation updates state`() = runTest {
        val service = FakeAuthService()
        val viewModel = AuthViewModel(service)

        service.emitAuthState(student)

        assertEquals(AuthState.SignedIn(student), viewModel.state.value)
    }

    @Test
    fun `signed out when auth state emits null`() = runTest {
        val service = FakeAuthService()
        val viewModel = AuthViewModel(service)

        service.emitAuthState(null)

        assertEquals(AuthState.SignedOut, viewModel.state.value)
    }

    @Test
    fun `sign in failure sets error message`() = runTest {
        val service = FakeAuthService()
        val viewModel = AuthViewModel(service)
        viewModel.updateForm { it.copy(email = "a@b.com", password = "secret") }

        viewModel.signIn()

        assertNotNull(viewModel.errorMessage.value)
    }

    @Test
    fun `sign in success clears the form`() = runTest {
        val service = FakeAuthService()
        service.signInResult = Result.success(student)
        val viewModel = AuthViewModel(service)
        viewModel.updateForm { it.copy(email = "a@b.com", password = "secret") }

        viewModel.signIn()

        assertEquals("", viewModel.form.value.email)
        assertEquals("", viewModel.form.value.password)
        assertNull(viewModel.errorMessage.value)
    }

    @Test
    fun `sign up as student passes academic details`() = runTest {
        val service = FakeAuthService()
        service.signUpResult = Result.success(student)
        val viewModel = AuthViewModel(service)
        viewModel.updateForm {
            it.copy(
                email = "a@b.com",
                password = "secret",
                displayName = "Alex",
                selectedRole = Role.STUDENT,
                major = "Psychology",
                academicYear = AcademicYear.JUNIOR,
                age = "21"
            )
        }

        viewModel.signUp()

        val details = requireNotNull(service.lastSignUpDetails)
        assertEquals("Psychology", details.major)
        assertEquals(AcademicYear.JUNIOR, details.academicYear)
        assertEquals(21, details.age)
    }

    @Test
    fun `sign up as counselor omits academic details`() = runTest {
        val service = FakeAuthService()
        service.signUpResult = Result.success(student)
        val viewModel = AuthViewModel(service)
        viewModel.updateForm {
            it.copy(
                email = "c@b.com",
                password = "secret",
                displayName = "Dr. Chen",
                selectedRole = Role.COUNSELOR,
                bio = "Clinical psychologist",
                major = "Psychology",
                academicYear = AcademicYear.JUNIOR,
                age = "40"
            )
        }

        viewModel.signUp()

        val details = requireNotNull(service.lastSignUpDetails)
        assertNull(details.major)
        assertNull(details.academicYear)
        assertNull(details.age)
        assertEquals("Clinical psychologist", details.bio)
    }

    @Test
    fun `sign out delegates to the service and clears the form`() = runTest {
        val service = FakeAuthService()
        val viewModel = AuthViewModel(service)
        viewModel.updateForm { it.copy(email = "a@b.com") }

        viewModel.signOut()

        assertTrue(service.didSignOut)
        assertEquals("", viewModel.form.value.email)
    }
}
