import SwiftUI

@Observable
class AppStore {
    var transactions: [Transaction] = []
    var streakDays: Int = 0
    var lastRecordDate: Date? = nil
    var longestStreak: Int = 0
    var xp: Int = 0
    var monthlyBudget: Double = 0 {
        didSet { save() }
    }
    var unlockedAchievements: Set<String> = []

    // Reactive state for UI
    var showCelebration = false
    var lastAddedTransaction: Transaction? = nil
    var newlyUnlockedAchievement: AchievementDef? = nil

    var level: Int { max(1, xp / 100 + 1) }
    var xpInCurrentLevel: Int { xp % 100 }

    var totalBalance: Double {
        transactions.reduce(0) { $0 + ($1.type == .income ? $1.amount : -$1.amount) }
    }

    var totalIncome: Double {
        transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }

    var totalExpense: Double {
        transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }

    var thisMonthTransactions: [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        return transactions.filter {
            calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }
    }

    var thisMonthExpense: Double {
        thisMonthTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }

    var budgetRemaining: Double {
        monthlyBudget - thisMonthExpense
    }

    var budgetProgress: Double {
        guard monthlyBudget > 0 else { return 0 }
        return min(thisMonthExpense / monthlyBudget, 1.0)
    }

    var expenseByCategory: [(category: Category, amount: Double)] {
        let expenses = thisMonthTransactions.filter { $0.type == .expense }
        var dict: [String: Double] = [:]
        for t in expenses {
            dict[t.category, default: 0] += t.amount
        }
        return dict.compactMap { key, value in
            guard let cat = CATEGORIES.first(where: { $0.id == key }) else { return nil }
            return (category: cat, amount: value)
        }.sorted { $0.amount > $1.amount }
    }

    init() {
        load()
        validateStreak()
    }

    func addTransaction(_ t: Transaction) {
        transactions.append(t)
        xp += 10
        lastAddedTransaction = t
        updateStreak()
        let newBadge = checkAchievements()
        save()

        showCelebration = true
        if let badge = newBadge {
            newlyUnlockedAchievement = badge
        }
    }

    // MARK: - Streak

    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let last = lastRecordDate {
            let lastDay = calendar.startOfDay(for: last)
            if lastDay == today { return }
            let diff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if diff == 1 {
                streakDays += 1
            } else {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }
        lastRecordDate = today
        longestStreak = max(longestStreak, streakDays)
    }

    /// Validate streak on app launch — reset if more than 1 day has passed since last record
    private func validateStreak() {
        guard let last = lastRecordDate else { return }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastDay = calendar.startOfDay(for: last)
        let diff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
        // If more than 1 day gap, streak is broken
        if diff > 1 {
            streakDays = 0
            save()
        }
    }

    // MARK: - Achievements

    @discardableResult
    private func checkAchievements() -> AchievementDef? {
        var newlyUnlocked: AchievementDef? = nil

        func tryUnlock(_ id: String, condition: Bool) {
            if condition && !unlockedAchievements.contains(id) {
                unlockedAchievements.insert(id)
                if let def = ALL_ACHIEVEMENTS.first(where: { $0.id == id }) {
                    newlyUnlocked = def
                }
            }
        }

        let count = transactions.count
        let balance = totalBalance

        tryUnlock("first_record", condition: count >= 1)
        tryUnlock("records_10", condition: count >= 10)
        tryUnlock("records_30", condition: count >= 30)
        tryUnlock("records_100", condition: count >= 100)
        tryUnlock("streak_3", condition: streakDays >= 3)
        tryUnlock("streak_7", condition: streakDays >= 7)
        tryUnlock("streak_30", condition: streakDays >= 30)
        tryUnlock("save_1000", condition: balance >= 1000)
        tryUnlock("save_10000", condition: balance >= 10000)
        tryUnlock("level_5", condition: level >= 5)
        tryUnlock("level_10", condition: level >= 10)

        return newlyUnlocked
    }

    // MARK: - Persistence

    func save() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(transactions) {
            UserDefaults.standard.set(data, forKey: "transactions")
        }
        UserDefaults.standard.set(streakDays, forKey: "streakDays")
        if let date = lastRecordDate {
            UserDefaults.standard.set(date.timeIntervalSince1970, forKey: "lastRecordDate")
        }
        UserDefaults.standard.set(longestStreak, forKey: "longestStreak")
        UserDefaults.standard.set(xp, forKey: "xp")
        UserDefaults.standard.set(monthlyBudget, forKey: "monthlyBudget")
        if let data = try? encoder.encode(Array(unlockedAchievements)) {
            UserDefaults.standard.set(data, forKey: "unlockedAchievements")
        }
    }

    private func load() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: "transactions"),
           let decoded = try? decoder.decode([Transaction].self, from: data) {
            transactions = decoded
        }
        streakDays = UserDefaults.standard.integer(forKey: "streakDays")
        let ts = UserDefaults.standard.double(forKey: "lastRecordDate")
        if ts > 0 { lastRecordDate = Date(timeIntervalSince1970: ts) }
        longestStreak = UserDefaults.standard.integer(forKey: "longestStreak")
        xp = UserDefaults.standard.integer(forKey: "xp")
        monthlyBudget = UserDefaults.standard.double(forKey: "monthlyBudget")
        if let data = UserDefaults.standard.data(forKey: "unlockedAchievements"),
           let decoded = try? decoder.decode([String].self, from: data) {
            unlockedAchievements = Set(decoded)
        }
    }
}
