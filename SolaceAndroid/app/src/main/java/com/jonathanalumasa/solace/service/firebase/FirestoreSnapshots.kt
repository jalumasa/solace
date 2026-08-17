package com.jonathanalumasa.solace.service.firebase

import com.google.firebase.firestore.DocumentSnapshot
import com.google.firebase.firestore.Query
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow

/**
 * Bridges a Firestore snapshot listener to a cold [Flow], the Kotlin
 * counterpart of the `AsyncStream` + `addSnapshotListener` pairing the iOS
 * services use. Documents that fail to map are dropped rather than throwing,
 * and — matching iOS — snapshot errors are swallowed: the flow simply doesn't
 * emit rather than tearing down the screen.
 */
internal fun <T> Query.snapshotListFlow(mapper: (DocumentSnapshot) -> T?): Flow<List<T>> =
    callbackFlow {
        val registration = addSnapshotListener { snapshot, _ ->
            if (snapshot == null) return@addSnapshotListener
            trySend(snapshot.documents.mapNotNull(mapper))
        }
        awaitClose { registration.remove() }
    }
