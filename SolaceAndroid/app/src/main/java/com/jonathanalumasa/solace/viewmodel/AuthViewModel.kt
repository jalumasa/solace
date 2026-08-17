package com.jonathanalumasa.solace.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.jonathanalumasa.solace.model.AcademicYear
import com.jonathanalumasa.solace.model.Role
import com.jonathanalumasa.solace.model.User
import com.jonathanalumasa.solace.service.AuthError
import com.jonathanalumasa.solace.service.AuthService
import com.jonathanalumasa.solace.service.SignUpDetails
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

/** Mirrors `SolaceCore.AuthViewModel.State`, plus an initial Loading case. */
sealed interface AuthState {
    data object Loading : AuthState
    data object SignedOut : AuthState
    data class SignedIn(val user: User) : AuthState
}

/** The sign-in / sign-up form's editable fields. */
data class AuthFormState(
    val email: String = "",
    val password: String = "",
    val displayName: String = "",
    val selectedRole: Role = Role.STUDENT,
    val bio: String = "",
    val major: String = "",
    val academicYear: AcademicYear? = null,
    val age: String = ""
)

class AuthViewModel(
    private val authService: AuthService
) : ViewModel() {

    private val _state = MutableStateFlow<AuthState>(AuthState.Loading)
    val state: StateFlow<AuthState> = _state.asStateFlow()

    private val _form = MutableStateFlow(AuthFormState())
    val form: StateFlow<AuthFormState> = _form.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    init {
        viewModelScope.launch {
            authService.observeAuthState().collect { user ->
                _state.value = if (user == null) AuthState.SignedOut else AuthState.SignedIn(user)
            }
        }
    }

    fun updateForm(transform: (AuthFormState) -> AuthFormState) {
        _form.update(transform)
    }

    fun clearError() {
        _errorMessage.value = null
    }

    fun signIn() {
        val current = _form.value
        viewModelScope.launch {
            _errorMessage.value = null
            _isLoading.value = true
            try {
                authService.signIn(current.email.trim(), current.password)
                clearForm()
            } catch (error: Exception) {
                _errorMessage.value = message(error)
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun signUp() {
        val current = _form.value
        val isStudent = current.selectedRole == Role.STUDENT
        val details = SignUpDetails(
            email = current.email.trim(),
            password = current.password,
            displayName = current.displayName.trim(),
            role = current.selectedRole,
            bio = current.bio.trim().takeIf { it.isNotEmpty() },
            // Academic details are student-only — always null for counselors,
            // matching the iOS AuthViewModel.
            major = if (isStudent) current.major.trim().takeIf { it.isNotEmpty() } else null,
            academicYear = if (isStudent) current.academicYear else null,
            age = if (isStudent) current.age.trim().toIntOrNull() else null
        )

        viewModelScope.launch {
            _errorMessage.value = null
            _isLoading.value = true
            try {
                authService.signUp(details)
                clearForm()
            } catch (error: Exception) {
                _errorMessage.value = message(error)
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun signOut() {
        authService.signOut()
        clearForm()
    }

    private fun clearForm() {
        _form.value = AuthFormState()
    }

    private fun message(error: Exception): String = when (error) {
        is AuthError.InvalidCredentials -> "That email or password doesn't look right."
        is AuthError.EmailAlreadyInUse -> "An account with that email already exists."
        is AuthError.WeakPassword -> "Please choose a longer password."
        is AuthError.Network -> "Check your connection and try again."
        else -> "Something went wrong. Please try again."
    }
}
