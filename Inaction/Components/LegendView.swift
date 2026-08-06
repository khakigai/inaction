import SwiftUI

struct LegendView: View {
    let activeLevel: Int

    private let labels = ["5m", "10m", "15m", "20m", "30m"]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(1...5, id: \.self) { level in
                let isActive = level == activeLevel
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: isActive ? 3 : 2)
                        .fill(durationLevelColor(level))
                        .frame(width: isActive ? 14 : 9, height: isActive ? 14 : 9)

                    Text(labels[level - 1])
                        .font(DT.inter(10, weight: isActive ? .semibold : .regular))
                        .foregroundStyle(isActive ? Color(hex: "4A4A4A") : DT.textMuted)
                }
                .opacity(isActive ? 1 : 0.25)
            }
        }
    }
}
