package com.jonathanalumasa.solace.ui.auth

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import com.jonathanalumasa.solace.model.AcademicYear
import com.jonathanalumasa.solace.model.Role
import com.jonathanalumasa.solace.ui.theme.Spacing
import com.jonathanalumasa.solace.viewmodel.AuthState
import com.jonathanalumasa.solace.viewmodel.AuthViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle

/**
 * Shows a spinner while the initial auth-state check runs, then the signed-out
 * experience. The iOS app gates this behind a one-time onboarding carousel;
 * that's a follow-up here.
 */
@Composable
fun AuthGate(authViewModel: AuthViewModel, state: AuthState) {
    if (state is AuthState.Loading) {
        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            CircularProgressIndicator()
        }
        return
    }

    var showSignUp by remember { mutableStateOf(false) }

    if (showSignUp) {
        SignUpScreen(
            authViewModel = authViewModel,
            onShowSignIn = { showSignUp = false }
        )
    } else {
        SignInScreen(
            authViewModel = authViewModel,
            onShowSignUp = { showSignUp = true }
        )
    }
}

@Composable
fun SignInScreen(authViewModel: AuthViewModel, onShowSignUp: () -> Unit) {
    val form by authViewModel.form.collectAsStateWithLifecycle()
    val isLoading by authViewModel.isLoading.collectAsStateWithLifecycle()
    val errorMessage by authViewModel.errorMessage.collectAsStateWithLifecycle()

    Scaffold { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(Spacing.large)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(Spacing.medium)
        ) {
            Text("Solace", style = MaterialTheme.typography.displaySmall)
            Text(
                "Support for students, whenever you need it.",
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )

            OutlinedTextField(
                value = form.email,
                onValueChange = { value -> authViewModel.updateForm { it.copy(email = value) } },
                label = { Text("Email") },
                singleLine = true,
                keyboardOptions = KeyboardOptions(
                    keyboardType = KeyboardType.Email,
                    imeAction = ImeAction.Next
                ),
                modifier = Modifier.fillMaxWidth()
            )

            OutlinedTextField(
                value = form.password,
                onValueChange = { value -> authViewModel.updateForm { it.copy(password = value) } },
                label = { Text("Password") },
                singleLine = true,
                visualTransformation = PasswordVisualTransformation(),
                keyboardOptions = KeyboardOptions(
                    keyboardType = KeyboardType.Password,
                    imeAction = ImeAction.Done
                ),
                modifier = Modifier.fillMaxWidth()
            )

            errorMessage?.let {
                Text(it, color = MaterialTheme.colorScheme.error)
            }

            Button(
                onClick = authViewModel::signIn,
                enabled = !isLoading && form.email.isNotBlank() && form.password.isNotBlank(),
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(if (isLoading) "Signing in…" else "Sign In")
            }

            TextButton(onClick = onShowSignUp, modifier = Modifier.fillMaxWidth()) {
                Text("New here? Create an account")
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class, ExperimentalLayoutApi::class)
@Composable
fun SignUpScreen(authViewModel: AuthViewModel, onShowSignIn: () -> Unit) {
    val form by authViewModel.form.collectAsStateWithLifecycle()
    val isLoading by authViewModel.isLoading.collectAsStateWithLifecycle()
    val errorMessage by authViewModel.errorMessage.collectAsStateWithLifecycle()

    Scaffold { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(Spacing.large)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(Spacing.medium)
        ) {
            Text("Create your account", style = MaterialTheme.typography.headlineMedium)

            OutlinedTextField(
                value = form.displayName,
                onValueChange = { v -> authViewModel.updateForm { it.copy(displayName = v) } },
                label = { Text("Full name") },
                singleLine = true,
                modifier = Modifier.fillMaxWidth()
            )

            OutlinedTextField(
                value = form.email,
                onValueChange = { v -> authViewModel.updateForm { it.copy(email = v) } },
                label = { Text("Email") },
                singleLine = true,
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
                modifier = Modifier.fillMaxWidth()
            )

            OutlinedTextField(
                value = form.password,
                onValueChange = { v -> authViewModel.updateForm { it.copy(password = v) } },
                label = { Text("Password") },
                singleLine = true,
                visualTransformation = PasswordVisualTransformation(),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                modifier = Modifier.fillMaxWidth()
            )

            Text("I'm a…", style = MaterialTheme.typography.labelLarge)
            Row(
                horizontalArrangement = Arrangement.spacedBy(Spacing.small),
                modifier = Modifier.fillMaxWidth()
            ) {
                Role.entries.forEach { role ->
                    FilterChip(
                        selected = form.selectedRole == role,
                        onClick = { authViewModel.updateForm { it.copy(selectedRole = role) } },
                        label = {
                            Text(if (role == Role.STUDENT) "Student" else "Counselor")
                        }
                    )
                }
            }

            if (form.selectedRole == Role.STUDENT) {
                Text("Academic details", style = MaterialTheme.typography.labelLarge)

                OutlinedTextField(
                    value = form.major,
                    onValueChange = { v -> authViewModel.updateForm { it.copy(major = v) } },
                    label = { Text("Major") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )

                FlowRow(
                    horizontalArrangement = Arrangement.spacedBy(Spacing.small),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    AcademicYear.entries.forEach { year ->
                        FilterChip(
                            selected = form.academicYear == year,
                            onClick = {
                                authViewModel.updateForm { it.copy(academicYear = year) }
                            },
                            label = { Text(year.label) }
                        )
                    }
                }

                OutlinedTextField(
                    value = form.age,
                    onValueChange = { v -> authViewModel.updateForm { it.copy(age = v) } },
                    label = { Text("Age") },
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    modifier = Modifier.fillMaxWidth()
                )
            } else {
                OutlinedTextField(
                    value = form.bio,
                    onValueChange = { v -> authViewModel.updateForm { it.copy(bio = v) } },
                    label = { Text("Short bio (shown to students)") },
                    minLines = 3,
                    modifier = Modifier.fillMaxWidth()
                )
            }

            errorMessage?.let {
                Text(it, color = MaterialTheme.colorScheme.error)
            }

            Button(
                onClick = authViewModel::signUp,
                enabled = !isLoading &&
                    form.email.isNotBlank() &&
                    form.password.isNotBlank() &&
                    form.displayName.isNotBlank(),
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(if (isLoading) "Creating account…" else "Create Account")
            }

            TextButton(onClick = onShowSignIn, modifier = Modifier.fillMaxWidth()) {
                Text("Already have an account? Sign in")
            }
        }
    }
}
