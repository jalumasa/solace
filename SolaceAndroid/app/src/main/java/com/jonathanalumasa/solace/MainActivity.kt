package com.jonathanalumasa.solace

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.jonathanalumasa.solace.prefs.AppPreferences
import com.jonathanalumasa.solace.ui.RootScaffold
import com.jonathanalumasa.solace.ui.auth.AuthGate
import com.jonathanalumasa.solace.ui.onboarding.OnboardingScreen
import com.jonathanalumasa.solace.ui.theme.SolaceTheme
import com.jonathanalumasa.solace.viewmodel.AuthState
import com.jonathanalumasa.solace.viewmodel.AuthViewModel

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        val preferences = AppPreferences(this)

        setContent {
            SolaceTheme {
                // Shown once before sign-in, mirroring the iOS gate on
                // `hasCompletedOnboarding`.
                var onboarded by remember { mutableStateOf(preferences.hasCompletedOnboarding) }

                val authViewModel: AuthViewModel = viewModel(
                    factory = viewModelFactory { AuthViewModel(ServiceLocator.authService) }
                )
                val state by authViewModel.state.collectAsStateWithLifecycle()

                when {
                    !onboarded && state !is AuthState.SignedIn -> OnboardingScreen(
                        onFinish = {
                            preferences.hasCompletedOnboarding = true
                            onboarded = true
                        }
                    )

                    state is AuthState.SignedIn -> RootScaffold(
                        currentUser = (state as AuthState.SignedIn).user,
                        onSignOut = authViewModel::signOut
                    )

                    else -> AuthGate(authViewModel = authViewModel, state = state)
                }
            }
        }
    }
}
