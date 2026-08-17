package com.jonathanalumasa.solace.service.firebase

import com.google.firebase.functions.FirebaseFunctions
import com.google.firebase.functions.FirebaseFunctionsException
import com.jonathanalumasa.solace.model.AIChatMessage
import com.jonathanalumasa.solace.service.AIChatError
import com.jonathanalumasa.solace.service.AIChatService
import kotlinx.coroutines.tasks.await

/**
 * Calls the `chatWithAI` Cloud Function, which proxies OpenAI's API — the same
 * function the iOS app uses. The OpenAI key lives only in Firebase Functions'
 * secret storage, never on-device.
 */
class CloudFunctionAIChatService(
    private val functions: FirebaseFunctions = FirebaseFunctions.getInstance()
) : AIChatService {

    override suspend fun sendMessage(history: List<AIChatMessage>, newMessage: String): String {
        val payload = mapOf(
            "history" to history.map { mapOf("role" to it.role.rawValue, "text" to it.text) },
            "message" to newMessage
        )

        val result = try {
            functions.getHttpsCallable("chatWithAI").call(payload).await()
        } catch (error: Exception) {
            throw mapFunctionsError(error)
        }

        @Suppress("UNCHECKED_CAST")
        val data = result.getData() as? Map<String, Any?>
        return data?.get("reply") as? String
            ?: throw AIChatError.Unknown("The assistant returned an unexpected response.")
    }

    private fun mapFunctionsError(error: Exception): AIChatError {
        val functionsError = error as? FirebaseFunctionsException
            ?: return AIChatError.Unknown(error.localizedMessage ?: "Something went wrong.")

        return when (functionsError.code) {
            FirebaseFunctionsException.Code.UNAUTHENTICATED -> AIChatError.NotSignedIn
            FirebaseFunctionsException.Code.RESOURCE_EXHAUSTED -> AIChatError.RateLimited
            FirebaseFunctionsException.Code.UNAVAILABLE,
            FirebaseFunctionsException.Code.DEADLINE_EXCEEDED -> AIChatError.Network
            else -> AIChatError.Unknown(
                functionsError.localizedMessage ?: "Something went wrong."
            )
        }
    }
}
