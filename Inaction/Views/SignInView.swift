import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @Environment(AuthManager.self) private var auth

    var body: some View {
        ZStack {
            DT.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 16) {
                    Image(systemName: "power")
                        .font(.system(size: 48, weight: .light))
                        .foregroundStyle(DT.textPrimary)

                    Text("Inaction")
                        .font(DT.playfair(48))
                        .foregroundStyle(DT.textPrimary)

                    Text("An app for doing nothing")
                        .font(DT.inter(14))
                        .foregroundStyle(DT.textMuted)
                }

                Spacer()

                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = []
                } onCompletion: { result in
                    if case .success(let authorization) = result {
                        auth.handleAuthorization(authorization)
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 40)
                .padding(.bottom, 80)
            }
        }
    }
}
