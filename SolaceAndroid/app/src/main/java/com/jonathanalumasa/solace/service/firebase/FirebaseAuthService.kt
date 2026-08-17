package com.jonathanalumasa.solace.service.firebase

import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseAuthInvalidCredentialsException
import com.google.firebase.auth.FirebaseAuthInvalidUserException
import com.google.firebase.auth.FirebaseAuthUserCollisionException
import com.google.firebase.auth.FirebaseAuthWeakPasswordException
import com.google.firebase.firestore.DocumentSnapshot
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.jonathanalumasa.solace.model.AcademicYear
import com.jonathanalumasa.solace.model.Role
import com.jonathanalumasa.solace.model.User
import com.jonathanalumasa.solace.service.AuthError
import com.jonathanalumasa.solace.service.AuthService
import com.jonathanalumasa.solace.service.SignUpDetails
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import java.io.IOException
import java.util.Date

/**
 * Firebase-backed implementation of [AuthService]. Profile data (display name,
 * role, academic details) lives in Firestore rather than on the Firebase Auth
 * user record, matching the iOS app so both clients read the same documents.
 */
class FirebaseAuthService(
    private val auth: FirebaseAuth = FirebaseAuth.getInstance(),
    private val firestore: FirebaseFirestore = FirebaseFirestore.getInstance()
) : AuthService {

    override fun observeAuthState(): Flow<User?> = callbackFlow {
        val listener = FirebaseAuth.AuthStateListener { firebaseAuth ->
            val uid = firebaseAuth.currentUser?.uid
            if (uid == null) {
                trySend(null)
            } else {
                launch {
                    trySend(runCatching { fetchUserProfile(uid) }.getOrNull())
                }
            }
        }
        auth.addAuthStateListener(listener)
        awaitClose { auth.removeAuthStateListener(listener) }
    }

    override suspend fun signIn(email: String, password: String): User {
        val uid = try {
            auth.signInWithEmailAndPassword(email, password).await().user?.uid
        } catch (error: Exception) {
            throw mapAuthError(error)
        }
        requireNotNull(uid) { "Sign-in returned no user" }
        return fetchUserProfile(uid)
            ?: throw AuthError.Unknown("Your account exists but its profile is missing.")
    }

    override suspend fun signUp(details: SignUpDetails): User {
        val uid = try {
            auth.createUserWithEmailAndPassword(details.email, details.password).await().user?.uid
        } catch (error: Exception) {
            throw mapAuthError(error)
        }
        requireNotNull(uid) { "Sign-up returned no user" }

        val user = User(
            id = uid,
            email = details.email,
            displayName = details.displayName,
            role = details.role,
            bio = details.bio,
            major = details.major,
            academicYear = details.academicYear,
            age = details.age
        )
        saveUserProfile(user)
        return user
    }

    override fun signOut() {
        auth.signOut()
    }

    private suspend fun fetchUserProfile(uid: String): User? {
        val snapshot = firestore.collection("users").document(uid).get().await()
        if (!snapshot.exists()) return null
        return user(snapshot, uid)
    }

    private suspend fun saveUserProfile(user: User) {
        val data = mutableMapOf<String, Any>(
            "email" to user.email,
            "displayName" to user.displayName,
            "role" to user.role.rawValue,
            "createdAt" to FieldValue.serverTimestamp()
        )
        user.bio?.let { data["bio"] = it }
        user.major?.let { data["major"] = it }
        user.academicYear?.let { data["academicYear"] = it.rawValue }
        user.age?.let { data["age"] = it }

        firestore.collection("users").document(user.id).set(data).await()
    }

    private fun user(snapshot: DocumentSnapshot, uid: String): User = User(
        id = uid,
        email = snapshot.getString("email") ?: "",
        displayName = snapshot.getString("displayName") ?: "",
        role = Role.fromRaw(snapshot.getString("role")) ?: Role.STUDENT,
        bio = snapshot.getString("bio"),
        major = snapshot.getString("major"),
        academicYear = AcademicYear.fromRaw(snapshot.getString("academicYear")),
        age = snapshot.getLong("age")?.toInt(),
        createdAt = snapshot.getDate("createdAt") ?: Date()
    )

    private fun mapAuthError(error: Exception): AuthError = when (error) {
        is FirebaseAuthWeakPasswordException -> AuthError.WeakPassword
        is FirebaseAuthUserCollisionException -> AuthError.EmailAlreadyInUse
        is FirebaseAuthInvalidCredentialsException,
        is FirebaseAuthInvalidUserException -> AuthError.InvalidCredentials
        is IOException -> AuthError.Network
        else -> AuthError.Unknown(error.localizedMessage ?: "Something went wrong.")
    }
}
