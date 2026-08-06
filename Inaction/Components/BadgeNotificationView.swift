import SwiftUI

struct BadgeNotificationView: View {
    let badge: BadgeDefinition
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Image(systemName: badge.icon)
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(DT.textPrimary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("BADGE EARNED")
                        .font(DT.inter(11, weight: .medium))
                        .foregroundStyle(DT.textMuted)
                        .kerning(1)

                    Text(badge.name)
                        .font(DT.playfair(18))
                        .foregroundStyle(DT.textPrimary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DT.textMuted)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: 360)
        .background(DT.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
    }
}
