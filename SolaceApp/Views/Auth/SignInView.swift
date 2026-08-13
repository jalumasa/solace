import SwiftUI
import SolaceCore

struct SignInView: View {
    @Bindable var authViewModel: AuthViewModel
    @State private var showingSignUp = false

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground(colors: Theme.Ambient.today)

                ScrollView {
                    VStack(spacing: Theme.Spacing.large) {
                        VStack(spacing: Theme.Spacing.small) {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(Theme.primary)
                                .frame(width: 96, height: 96)
                                .glassEffect(.regular, in: Circle())

                            Text("Solace")
                                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            Text("A quiet space for student wellbeing.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 60)

                        VStack(spacing: Theme.Spacing.medium) {
                            TextField("Email", text: $authViewModel.email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .textFieldStyle(.roundedBorder)

                            SecureField("Password", text: $authViewModel.password)
                                .textContentType(.password)
                                .textFieldStyle(.roundedBorder)

                            if let errorMessage = authViewModel.errorMessage {
                                Text(errorMessage)
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                            }

                            Button {
                                Task { await authViewModel.signIn() }
                            } label: {
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Text("Sign In")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .buttonStyle(.glassProminent)
                            .controlSize(.large)
                            .disabled(authViewModel.isLoading || authViewModel.email.isEmpty || authViewModel.password.isEmpty)

                            Button("Create an account") {
                                showingSignUp = true
                            }
                            .font(.subheadline.weight(.medium))
                        }
                        .padding(Theme.Spacing.large)
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: Theme.Radius.card))
                        .padding(.horizontal, Theme.Spacing.medium)

                        Spacer(minLength: 40)
                    }
                    .padding(.bottom, Theme.Spacing.large)
                }
            }
            .sheet(isPresented: $showingSignUp) {
                SignUpView(authViewModel: authViewModel)
            }
        }
    }
}
