import SwiftUI

struct AchievementsView: View {
    var store: AppStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Level & XP card
                    LevelCard(level: store.level, xp: store.xpInCurrentLevel, streak: store.streakDays)

                    // Achievements grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text("成就徽章")
                            .font(.headline)
                            .padding(.horizontal, 4)

                        Text("\(store.unlockedAchievements.count) / \(ALL_ACHIEVEMENTS.count) 已解鎖")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(ALL_ACHIEVEMENTS) { ach in
                                AchievementBadge(
                                    achievement: ach,
                                    isUnlocked: store.unlockedAchievements.contains(ach.id)
                                )
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("成就")
        }
    }
}

// MARK: - Level Card

struct LevelCard: View {
    let level: Int
    let xp: Int
    let streak: Int

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                // Level badge
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .yellow],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)

                        Text("Lv.\(level)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    Text("等級")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // XP bar
                VStack(alignment: .leading, spacing: 6) {
                    Text("經驗值")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.orange.opacity(0.15))
                                .frame(height: 12)

                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [.orange, .yellow],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(0, geo.size.width * (Double(xp) / 100.0)), height: 12)
                        }
                    }
                    .frame(height: 12)

                    Text("\(xp) / 100 XP")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                // Streak
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: streak > 0 ? [.red, .orange] : [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)

                        VStack(spacing: 0) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 16))
                                .foregroundColor(streak > 0 ? .white : .gray)
                            Text("\(streak)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(streak > 0 ? .white : .gray)
                        }
                    }
                    Text("連續天數")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Achievement Badge

struct AchievementBadge: View {
    let achievement: AchievementDef
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? achievement.color.opacity(0.15) : Color.gray.opacity(0.1))
                    .frame(width: 56, height: 56)

                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(isUnlocked ? achievement.color : .gray.opacity(0.4))
            }

            Text(achievement.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isUnlocked ? .primary : .secondary)
                .lineLimit(1)

            Text(achievement.description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .opacity(isUnlocked ? 1.0 : 0.5)
    }
}
