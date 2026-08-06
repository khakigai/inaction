import SwiftUI

struct BadgeDetailView: View {
    let badge: BadgeDefinition
    let unlockedAt: Date?
    let totalSessions: Int
    let totalMinutes: Int
    let onDismiss: () -> Void

    @State private var cardImage: UIImage?
    @State private var showSavedToast = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.95).ignoresSafeArea()

            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer()

                // Share card preview
                if let image = cardImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(1080.0 / 1920.0, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .white.opacity(0.08), radius: 20)
                        .padding(.horizontal, 40)
                }

                Spacer()

                // Action buttons
                HStack(spacing: 32) {
                    actionButton(icon: "square.and.arrow.down", label: "Save") {
                        saveToPhotos()
                    }
                    actionButton(icon: "camera", label: "Instagram") {
                        shareToInstagramStories()
                    }
                    actionButton(icon: "square.and.arrow.up", label: "More") {
                        shareSheet()
                    }
                }
                .padding(.bottom, 60)
            }

            // Saved toast
            if showSavedToast {
                VStack {
                    Spacer()
                    Text("Saved to Photos")
                        .font(DT.inter(14, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                        .padding(.bottom, 130)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            cardImage = ShareCardRenderer.render(
                badge: badge, totalSessions: totalSessions, totalMinutes: totalMinutes
            )
        }
    }

    @ViewBuilder
    private func actionButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Circle())
                Text(label)
                    .font(DT.inter(11))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }

    private func saveToPhotos() {
        guard let image = cardImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        withAnimation(.easeOut(duration: 0.3)) { showSavedToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeOut(duration: 0.3)) { showSavedToast = false }
        }
    }

    private func shareToInstagramStories() {
        guard let image = cardImage,
              let imageData = image.pngData() else { return }

        let urlScheme = URL(string: "instagram-stories://share")!
        if UIApplication.shared.canOpenURL(urlScheme) {
            let items: [[String: Any]] = [
                ["com.instagram.sharedSticker.backgroundImage": imageData]
            ]
            UIPasteboard.general.setItems(items, options: [
                .expirationDate: Date().addingTimeInterval(300)
            ])
            UIApplication.shared.open(urlScheme)
        } else {
            // Instagram not installed - fall back to general share
            shareSheet()
        }
    }

    private func shareSheet() {
        guard let image = cardImage else { return }
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(activityVC, animated: true)
        }
    }
}
