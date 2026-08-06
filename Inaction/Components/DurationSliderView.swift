import SwiftUI

struct DurationSliderView: View {
    @Binding var selectedIndex: Int
    private let count = 5
    private let trackHeight: CGFloat = 3
    private let thumbSize: CGFloat = 24

    var body: some View {
        VStack(spacing: 10) {
            GeometryReader { geo in
                let width = geo.size.width
                let spacing = width / CGFloat(count - 1)

                // Track
                Capsule()
                    .fill(DT.borderLight)
                    .frame(height: trackHeight)
                    .frame(maxWidth: .infinity)
                    .position(x: width / 2, y: thumbSize / 2)

                // Thumb
                Circle()
                    .fill(DT.textPrimary)
                    .frame(width: thumbSize, height: thumbSize)
                    .shadow(color: .black.opacity(0.15), radius: 4, y: 1)
                    .position(x: spacing * CGFloat(selectedIndex), y: thumbSize / 2)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let idx = Int(round(value.location.x / spacing))
                                selectedIndex = max(0, min(count - 1, idx))
                            }
                    )
            }
            .frame(height: thumbSize)

            // Tick labels
            HStack {
                ForEach(0..<count, id: \.self) { i in
                    Text(durationLabels[i])
                        .font(DT.inter(11, weight: i == selectedIndex ? .semibold : .regular))
                        .foregroundStyle(i == selectedIndex ? DT.textPrimary : DT.textMuted)
                        .frame(maxWidth: .infinity)
                        .onTapGesture { selectedIndex = i }
                }
            }
        }
        .frame(maxWidth: 280)
    }
}
