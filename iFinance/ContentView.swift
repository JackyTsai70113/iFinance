import SwiftUI

struct ContentView: View {
    var store: AppStore

    var body: some View {
        TabView {
            HomeView(store: store)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("首頁")
                }

            StatsView(store: store)
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("統計")
                }

            AchievementsView(store: store)
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("成就")
                }
        }
        .overlay(alignment: .top) {
            if let ach = store.newlyUnlockedAchievement {
                AchievementToast(achievement: ach) {
                    store.newlyUnlockedAchievement = nil
                }
                .allowsHitTesting(false)
            }
        }
    }
}

// MARK: - Home View

struct HomeView: View {
    @Bindable var store: AppStore
    @State private var isShowingAddView = false
    @State private var cardAppeared = false
    @State private var ponyReaction: PonyReaction = .idle

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if store.streakDays > 0 {
                        StreakBanner(days: store.streakDays)
                    }

                    SummaryCard(balance: store.totalBalance, income: store.totalIncome, expense: store.totalExpense)
                        .offset(y: cardAppeared ? 0 : -30)
                        .opacity(cardAppeared ? 1 : 0)

                    VStack(alignment: .leading) {
                        Text("最近交易")
                            .font(.headline)
                            .padding(.horizontal)

                        if store.transactions.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "tray")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary.opacity(0.5))
                                Text("尚無交易紀錄")
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                            .opacity(cardAppeared ? 1 : 0)
                        } else {
                            ForEach(store.transactions.reversed()) { transaction in
                                TransactionRow(transaction: transaction)
                            }
                        }
                    }
                }
                .padding()
                .padding(.bottom, 80)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .overlay(alignment: .bottomTrailing) {
                PonyBuddyView(
                    transactionCount: store.transactions.count,
                    balance: store.totalBalance,
                    reaction: ponyReaction
                )
                .padding(.trailing, 8)
                .padding(.bottom, 16)
                .allowsHitTesting(false)
            }
            .overlay {
                if store.showCelebration {
                    CelebrationView(isActive: $store.showCelebration)
                        .allowsHitTesting(false)
                }
            }
            .navigationTitle("我的帳本")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingAddView = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .symbolEffect(.pulse, options: .repeating.speed(0.5))
                    }
                }
            }
            .sheet(isPresented: $isShowingAddView) {
                AddTransactionView(store: store)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    cardAppeared = true
                }
            }
            .animation(.easeOut(duration: 0.35), value: store.transactions.count)
            .onChange(of: store.showCelebration) {
                if store.showCelebration, let t = store.lastAddedTransaction {
                    if t.type == .income {
                        ponyReaction = .happy
                    } else if t.amount >= 1000 {
                        ponyReaction = .surprised
                    } else {
                        ponyReaction = .cheerful
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        ponyReaction = .idle
                    }
                }
            }
        }
    }
}

// MARK: - Streak Banner

struct StreakBanner: View {
    let days: Int

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .foregroundColor(.orange)
            Text("連續記帳 \(days) 天！")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.orange)
            Spacer()
            Text("繼續保持")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Summary Card

struct SummaryCard: View {
    let balance: Double
    let income: Double
    let expense: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("本月結餘")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("$\(Int(balance))")
                .font(.system(size: 40, weight: .bold, design: .rounded))

            HStack {
                SummaryStat(title: "收入", amount: income, color: .green)
                Spacer()
                SummaryStat(title: "支出", amount: expense, color: .red)
            }
            .padding(.top)
        }
        .padding(25)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct SummaryStat: View {
    let title: String
    let amount: Double
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: title == "收入" ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .foregroundColor(color)
            VStack(alignment: .leading) {
                Text(title).font(.caption).foregroundColor(.secondary)
                Text("$\(Int(amount))")
                    .font(.headline)
                    .foregroundColor(color)
            }
        }
    }
}

// MARK: - Transaction Row

struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 15) {
            let category = CATEGORIES.first(where: { $0.id == transaction.category }) ?? CATEGORIES[0]

            Image(systemName: category.icon)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(category.color)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading) {
                Text(transaction.note.isEmpty ? category.name : transaction.note)
                    .font(.system(size: 17, weight: .semibold))
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("\(transaction.type == .income ? "+" : "-")$\(Int(transaction.amount))")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(transaction.type == .income ? .green : .primary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: - Achievement Toast

struct AchievementToast: View {
    let achievement: AchievementDef
    let onDismiss: () -> Void
    @State private var show = false

    var body: some View {
        if show {
            HStack(spacing: 12) {
                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(achievement.color)

                VStack(alignment: .leading, spacing: 2) {
                    Text("成就解鎖！")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(achievement.name)
                        .font(.headline)
                }

                Spacer()
            }
            .padding(16)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .transition(.move(edge: .top).combined(with: .opacity))
        }

        Spacer()
            .onAppear {
                withAnimation(.easeOut(duration: 0.4)) {
                    show = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeIn(duration: 0.3)) {
                        show = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        onDismiss()
                    }
                }
            }
    }
}

#Preview {
    ContentView(store: AppStore())
}
