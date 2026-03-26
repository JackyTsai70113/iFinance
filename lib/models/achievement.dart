import 'package:flutter/material.dart';

class AchievementDef {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const AchievementDef({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}

const kAllAchievements = <AchievementDef>[
  AchievementDef(id: 'first_record', name: '初心者', description: '記下第一筆交易', icon: Icons.edit, color: Colors.green),
  AchievementDef(id: 'records_10', name: '記帳新手', description: '累計記帳 10 筆', icon: Icons.format_list_bulleted, color: Colors.blue),
  AchievementDef(id: 'records_30', name: '記帳好手', description: '累計記帳 30 筆', icon: Icons.playlist_add_check, color: Colors.purple),
  AchievementDef(id: 'records_100', name: '記帳大師', description: '累計記帳 100 筆', icon: Icons.workspace_premium, color: Colors.amber),
  AchievementDef(id: 'streak_3', name: '三日不懈', description: '連續記帳 3 天', icon: Icons.local_fire_department, color: Colors.orange),
  AchievementDef(id: 'streak_7', name: '一週達人', description: '連續記帳 7 天', icon: Icons.whatshot, color: Colors.red),
  AchievementDef(id: 'streak_30', name: '月度之星', description: '連續記帳 30 天', icon: Icons.star, color: Colors.pink),
  AchievementDef(id: 'save_1000', name: '小富翁', description: '結餘達到 \$1,000', icon: Icons.savings, color: Colors.teal),
  AchievementDef(id: 'save_10000', name: '大富翁', description: '結餘達到 \$10,000', icon: Icons.account_balance, color: Colors.indigo),
  AchievementDef(id: 'level_5', name: '升級達人', description: '達到等級 5', icon: Icons.arrow_upward, color: Colors.teal),
  AchievementDef(id: 'level_10', name: '記帳之神', description: '達到等級 10', icon: Icons.bolt, color: Colors.cyan),
];
