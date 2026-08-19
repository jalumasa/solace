package com.jonathanalumasa.solace

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.getValue
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.jonathanalumasa.solace.ui.RootScaffold
import com.jonathanalumasa.solace.ui.auth.AuthGate
import com.jonathanalumasa.solace.ui.theme.SolaceTheme
import com.jonathanalumasa.solace.viewmodel.AuthState
import com.jonathanalumasa.solace.viewmodel.AuthViewModel

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            SolaceTheme {
                val authViewModel: AuthViewModel = viewModel(
                    factory = viewModelFactory { AuthViewModel(ServiceLocator.authService) }
                )
                val state by authViewModel.state.collectAsStateWithLifecycle()

                when (val current = state) {
                    is AuthState.SignedIn -> RootScaffold(
                        currentUser = current.user,
                        onSignOut = authViewModel::signOut
                    )

                    else -> AuthGate(authViewModel = authViewModel, state = state)
                }
            }
        }
    }
}
