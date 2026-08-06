import SwiftUI

let durationSteps = [300, 600, 900, 1200, 1800]
let durationLabels = ["5m", "10m", "15m", "20m", "30m"]

func durationLevel(_ seconds: Int) -> Int {
    switch seconds {
    case 1800...: return 5
    case 1200...: return 4
    case 900...: return 3
    case 600...: return 2
    default: return 1
    }
}

func durationLevelColor(_ level: Int) -> Color {
    switch level {
    case 1: return DT.heatmapLevel1
    case 2: return DT.heatmapLevel2
    case 3: return DT.heatmapLevel3
    case 4: return DT.heatmapLevel4
    case 5: return DT.heatmapLevel5
    default: return DT.heatmapEmpty
    }
}
