import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @Environment(SessionManager.self) private var sessionManager
    @State private var isSigningIn = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            Spacer()
            
            // App logo/branding
            VStack {
                Text("Moonfish")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Your Podcast Companion")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Sign in section
            VStack(spacing: 16) {
                SignInWithAppleButton(.signIn) {
                    $0.requestedScopes = [.fullName, .email]
                } onCompletion: {
                    handle($0)
                }
                .frame(height: 48)
                .clipShape(Capsule())
                .disabled(isSigningIn)
                
                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
    
private extension SignInView {
    func handle(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential else {
                errorMessage = "Invalid credential type"
                return
            }
            
            isSigningIn = true
            errorMessage = nil
            
            // Extract user info (only provided on first sign in)
            let email = credential.email
            let fullName = credential.fullName.map { name in
                [name.givenName, name.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
            }.flatMap { $0.isEmpty ? nil : $0 }
            
            Task {
                do {
                    try await sessionManager.signIn(
                        appleId: credential.user,
                        email: email,
                        fullName: fullName
                    )
                } catch {
                    errorMessage = "Sign in failed. Please try again."
                    isSigningIn = false
                }
            }
            
        case .failure(let error):
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                errorMessage = "Sign in failed: \(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    SignInView()
        .environment(SessionManager())
}
