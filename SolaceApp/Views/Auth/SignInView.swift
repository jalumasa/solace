import SwiftUI
import SolaceCore

struct SignInView: View {
    @Bindable var authViewModel: AuthViewModel
    @State private var showingSignUp = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.teal)
                    Text("Solace")
                        .font(.largeTitle.bold())
                    Text("A quiet space for student wellbeing.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)

                VStack(spacing: 12) {
                    TextField("Email", text: $authViewModel.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)

                    SecureField("Password", text: $authViewModel.password)
                        .textContentType(.password)
                        .textFieldStyle(.roundedBorder)
                }

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
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(authViewModel.isLoading || authViewModel.email.isEmpty || authViewModel.password.isEmpty)

                Button("Create an account") {
                    showingSignUp = true
                }
                .font(.footnote)

                Spacer()
            }
            .padding()
            .sheet(isPresented: $showingSignUp) {
                SignUpView(authViewModel: authViewModel)
            }
        }
    }
}
