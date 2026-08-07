import Foundation

func toDateKey(_ date: Date) -> String {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd"
    f.locale = Locale(identifier: "en_US_POSIX")
    return f.string(from: date)
}

func dateFromKey(_ key: String) -> Date? {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd"
    f.locale = Locale(identifier: "en_US_POSIX")
    return f.date(from: key)
}

/// Monday = 0, Tuesday = 1, ..., Sunday = 6
func mondayDOW(_ date: Date) -> Int {
    (Calendar.current.component(.weekday, from: date) + 5) % 7
}

func computeMaxStreak(from dateKeys: [String]) -> Int {
    let sorted = dateKeys.sorted()
    guard sorted.count > 0 else { return 0 }
    var maxStreak = 1
    var current = 1
    for i in 1..<sorted.count {
        guard let prev = dateFromKey(sorted[i - 1]),
              let curr = dateFromKey(sorted[i]) else { continue }
        let diff = Calendar.current.dateComponents([.day], from: prev, to: curr).day ?? 0
        if diff == 1 {
            current += 1
            maxStreak = max(maxStreak, current)
        } else if diff > 1 {
            current = 1
        }
    }
    return maxStreak
}

func computeCurrentStreak(from dateKeys: [String]) -> Int {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let uniqueKeys = Set(dateKeys)
    let todayKey = toDateKey(today)

    var checkDate: Date
    if uniqueKeys.contains(todayKey) {
        checkDate = today
    } else {
        checkDate = calendar.date(byAdding: .day, value: -1, to: today)!
    }

    var streak = 0
    while true {
        if uniqueKeys.contains(toDateKey(checkDate)) {
            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        } else {
            break
        }
    }
    return streak
}
