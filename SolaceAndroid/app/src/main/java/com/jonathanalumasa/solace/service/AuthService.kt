package com.jonathanalumasa.solace.service

import com.jonathanalumasa.solace.model.AcademicYear
import com.jonathanalumasa.solace.model.Role
import com.jonathanalumasa.solace.model.User
import kotlinx.coroutines.flow.Flow

/** Mirrors `SolaceCore.SignUpDetails`. */
data class SignUpDetails(
    val email: String,
    val password: String,
    val displayName: String,
    val role: Role,
    val bio: String? = null,
    val major: String? = null,
    val academicYear: AcademicYear? = null,
    val age: Int? = null
)

/** Mirrors `SolaceCore.AuthError`. */
sealed class AuthError(message: String? = null) : Exception(message) {
    data object InvalidCredentials : AuthError()
    data object EmailAlreadyInUse : AuthError()
    data object WeakPassword : AuthError()
    data object Network : AuthError()
    data class Unknown(val detail: String) : AuthError(detail)
}

/**
 * Abstracts authentication so ViewModels can be tested without touching
 * Firebase. Mirrors `SolaceCore.AuthServicing`.
 */
interface AuthService {
    fun observeAuthState(): Flow<User?>
    suspend fun signIn(email: String, password: String): User
    suspend fun signUp(details: SignUpDetails): User
    fun signOut()
}
