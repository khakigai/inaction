import AuthenticationServices
import Observation

@Observable
final class AuthManager {
    var isSignedIn: Bool = false
    var userID: String?

    private let keychainKey = "inaction.appleUserID"

    init() {
        userID = KeychainHelper.read(key: keychainKey)
        isSignedIn = userID != nil
    }

    func checkCredentialState() {
        guard let userID else {
            isSignedIn = false
            return
        }
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID) { state, _ in
            DispatchQueue.main.async {
                switch state {
                case .authorized:
                    self.isSignedIn = true
                default:
                    self.signOut()
                }
            }
        }
    }

    func handleAuthorization(_ authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let id = credential.user
            KeychainHelper.save(key: keychainKey, value: id)
            userID = id
            isSignedIn = true
        }
    }

    func signOut() {
        KeychainHelper.delete(key: keychainKey)
        userID = nil
        isSignedIn = false
    }
}
