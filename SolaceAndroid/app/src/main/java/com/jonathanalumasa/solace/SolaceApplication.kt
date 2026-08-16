package com.jonathanalumasa.solace

import android.app.Application

/**
 * Firebase initialises itself on Android via the google-services plugin and a
 * startup ContentProvider, so there's no explicit `FirebaseApp.configure()`
 * equivalent to the iOS app's here.
 */
class SolaceApplication : Application()
