import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../stores/app_store.dart';
import '../models/achievement.dart';

class AchievementsView extends StatelessWidget {
  const AchievementsView({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();

    return Scaffold(
      appBar: AppBar(title: const Text('成就')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _LevelCard(
            level: store.level,
            xp: store.xpInCurrentLevel,
            streak: store.streakDays,
          ),
          const SizedBox(height: 20),
          _AchievementsGrid(
            unlockedIds: store.unlockedAchievements,
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final int xp;
  final int streak;
  const _LevelCard(
      {required this.level, required this.xp, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Level badge
          Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.amber],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text('Lv.$level',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(height: 4),
              Text('等級', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(width: 20),

          // XP bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('經驗值', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: xp / 100.0,
                    minHeight: 12,
                    backgroundColor: Colors.orange.withOpacity(0.15),
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                Text('$xp / 100 XP',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 20),

          // Streak
          Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: streak > 0
                        ? [Colors.red, Colors.orange]
                        : [Colors.grey.shade300, Colors.grey.shade200],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_fire_department,
                        size: 16,
                        color: streak > 0 ? Colors.white : Colors.grey),
                    Text('$streak',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color:
                                streak > 0 ? Colors.white : Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text('連續天數', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _AchievementsGrid extends StatelessWidget {
  final Set<String> unlockedIds;
  const _AchievementsGrid({required this.unlockedIds});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('成就徽章',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
          const SizedBox(height: 4),
          Text('${unlockedIds.length} / ${kAllAchievements.length} 已解鎖',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.7,
            children: kAllAchievements.map((ach) {
              final unlocked = unlockedIds.contains(ach.id);
              return _AchievementBadge(achievement: ach, isUnlocked: unlocked);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final AchievementDef achievement;
  final bool isUnlocked;
  const _AchievementBadge(
      {required this.achievement, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked
                  ? achievement.color.withOpacity(0.15)
                  : Colors.grey.withOpacity(0.1),
            ),
            child: Icon(
              achievement.icon,
              color: isUnlocked
                  ? achievement.color
                  : Colors.grey.withOpacity(0.4),
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(achievement.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isUnlocked ? null : Colors.grey,
              ),
              overflow: TextOverflow.ellipsis),
          Text(achievement.description,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
