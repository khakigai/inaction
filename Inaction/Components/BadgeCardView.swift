import SwiftUI

struct BadgeCardView: View {
    let badge: BadgeDefinition
    let isUnlocked: Bool
    var onTap: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: badge.icon)
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(isUnlocked ? DT.textPrimary : DT.textMuted)
                .frame(height: 40)
                .padding(.bottom, 10)

            Text(badge.name)
                .font(DT.playfair(14))
                .foregroundStyle(isUnlocked ? DT.textPrimary : DT.textMuted)
                .padding(.bottom, 4)

            Text(badge.description)
                .font(DT.inter(11))
                .foregroundStyle(DT.textMuted)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(DT.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
        .opacity(isUnlocked ? 1 : 0.7)
        .onTapGesture { if isUnlocked { onTap?() } }
    }
}
