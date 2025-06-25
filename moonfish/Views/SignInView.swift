import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @Binding var userIdentifier: String
    
    var body: some View {
        SignInWithAppleButton(
            onRequest: { request in
                request.requestedScopes = [.fullName, .email]
            },
            onCompletion: { result in
                switch result {
                case .success(let auth):
                    if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                        userIdentifier = credential.user
                        
                        // Optional: Get email/name (only provided first time)
                        if let name = credential.fullName {
                            print("Name: \(name)")
                        }
                        
                        if let email = credential.email {
                            print("Email: \(email)")
                        }
                    }
                case .failure(let error):
                    print("Authorization failed: \(error)")
                }
            }
        )
        .frame(height: 48)
        .clipShape(Capsule())
        .padding()
    }
}

#Preview {
    @Previewable @State var userIdentifier: String = ""
    SignInView(userIdentifier: $userIdentifier)
}
