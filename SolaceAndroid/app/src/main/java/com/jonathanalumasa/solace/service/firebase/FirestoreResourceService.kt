package com.jonathanalumasa.solace.service.firebase

import com.google.firebase.firestore.DocumentSnapshot
import com.google.firebase.firestore.FirebaseFirestore
import com.jonathanalumasa.solace.model.ResourceCategory
import com.jonathanalumasa.solace.model.ResourceItem
import com.jonathanalumasa.solace.service.ResourceService
import kotlinx.coroutines.tasks.await

/**
 * Firebase-backed [ResourceService]. The `resources` collection is curated
 * content, public-read and seeded server-side.
 */
class FirestoreResourceService(
    private val firestore: FirebaseFirestore = FirebaseFirestore.getInstance()
) : ResourceService {

    override suspend fun fetchResources(): List<ResourceItem> =
        firestore.collection("resources")
            .get()
            .await()
            .documents
            .mapNotNull(::resource)

    private fun resource(document: DocumentSnapshot): ResourceItem? {
        val title = document.getString("title") ?: return null
        @Suppress("UNCHECKED_CAST")
        val tags = document.get("tags") as? List<String> ?: emptyList()
        return ResourceItem(
            id = document.id,
            title = title,
            summary = document.getString("summary") ?: "",
            body = document.getString("body") ?: "",
            category = ResourceCategory.fromRaw(document.getString("category"))
                ?: ResourceCategory.GENERAL,
            tags = tags
        )
    }
}
