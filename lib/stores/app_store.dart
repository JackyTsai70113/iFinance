import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/achievement.dart';

class AppStore extends ChangeNotifier {
  List<Transaction> transactions = [];
  int streakDays = 0;
  DateTime? lastRecordDate;
  int longestStreak = 0;
  int xp = 0;
  double monthlyBudget = 0;
  Set<String> unlockedAchievements = {};

  // Reactive UI state
  bool showCelebration = false;
  Transaction? lastAddedTransaction;
  AchievementDef? newlyUnlockedAchievement;

  int get level => (xp ~/ 100) + 1;
  int get xpInCurrentLevel => xp % 100;

  double get totalBalance => transactions.fold(
      0.0, (sum, t) => sum + (t.type == TransactionType.income ? t.amount : -t.amount));

  double get totalIncome => transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  List<Transaction> get thisMonthTransactions {
    final now = DateTime.now();
    return transactions
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .toList();
  }

  double get thisMonthExpense => thisMonthTransactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get budgetRemaining => monthlyBudget - thisMonthExpense;

  double get budgetProgress {
    if (monthlyBudget <= 0) return 0;
    return (thisMonthExpense / monthlyBudget).clamp(0.0, 1.0);
  }

  List<MapEntry<CategoryDef, double>> get expenseByCategory {
    final expenses =
        thisMonthTransactions.where((t) => t.type == TransactionType.expense);
    final dict = <String, double>{};
    for (final t in expenses) {
      dict[t.category] = (dict[t.category] ?? 0) + t.amount;
    }
    final result = dict.entries
        .map((e) => MapEntry(getCategoryById(e.key), e.value))
        .toList();
    result.sort((a, b) => b.value.compareTo(a.value));
    return result;
  }

  AppStore() {
    _load().then((_) {
      _validateStreak();
      notifyListeners();
    });
  }

  void addTransaction(Transaction t) {
    transactions.add(t);
    xp += 10;
    lastAddedTransaction = t;
    _updateStreak();
    final newBadge = _checkAchievements();
    _save();

    showCelebration = true;
    if (newBadge != null) {
      newlyUnlockedAchievement = newBadge;
    }
    notifyListeners();
  }

  void setMonthlyBudget(double value) {
    monthlyBudget = value;
    _save();
    notifyListeners();
  }

  void dismissCelebration() {
    showCelebration = false;
    notifyListeners();
  }

  void dismissAchievementToast() {
    newlyUnlockedAchievement = null;
    notifyListeners();
  }

  // -- Streak --

  void _updateStreak() {
    final today = DateUtils.dateOnly(DateTime.now());
    if (lastRecordDate != null) {
      final lastDay = DateUtils.dateOnly(lastRecordDate!);
      if (lastDay == today) return;
      final diff = today.difference(lastDay).inDays;
      if (diff == 1) {
        streakDays += 1;
      } else {
        streakDays = 1;
      }
    } else {
      streakDays = 1;
    }
    lastRecordDate = today;
    if (streakDays > longestStreak) longestStreak = streakDays;
  }

  void _validateStreak() {
    if (lastRecordDate == null) return;
    final today = DateUtils.dateOnly(DateTime.now());
    final lastDay = DateUtils.dateOnly(lastRecordDate!);
    final diff = today.difference(lastDay).inDays;
    if (diff > 1) {
      streakDays = 0;
      _save();
    }
  }

  // -- Achievements --

  AchievementDef? _checkAchievements() {
    AchievementDef? newlyUnlocked;

    void tryUnlock(String id, bool condition) {
      if (condition && !unlockedAchievements.contains(id)) {
        unlockedAchievements.add(id);
        final def = kAllAchievements.where((a) => a.id == id).firstOrNull;
        if (def != null) newlyUnlocked = def;
      }
    }

    final count = transactions.length;
    final balance = totalBalance;

    tryUnlock('first_record', count >= 1);
    tryUnlock('records_10', count >= 10);
    tryUnlock('records_30', count >= 30);
    tryUnlock('records_100', count >= 100);
    tryUnlock('streak_3', streakDays >= 3);
    tryUnlock('streak_7', streakDays >= 7);
    tryUnlock('streak_30', streakDays >= 30);
    tryUnlock('save_1000', balance >= 1000);
    tryUnlock('save_10000', balance >= 10000);
    tryUnlock('level_5', level >= 5);
    tryUnlock('level_10', level >= 10);

    return newlyUnlocked;
  }

  // -- Persistence --

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final txJson = transactions.map((t) => t.toJson()).toList();
    await prefs.setString('transactions', jsonEncode(txJson));
    await prefs.setInt('streakDays', streakDays);
    if (lastRecordDate != null) {
      await prefs.setInt(
          'lastRecordDate', lastRecordDate!.millisecondsSinceEpoch);
    }
    await prefs.setInt('longestStreak', longestStreak);
    await prefs.setInt('xp', xp);
    await prefs.setDouble('monthlyBudget', monthlyBudget);
    await prefs.setStringList(
        'unlockedAchievements', unlockedAchievements.toList());
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final txString = prefs.getString('transactions');
    if (txString != null) {
      final list = jsonDecode(txString) as List;
      transactions = list.map((e) => Transaction.fromJson(e)).toList();
    }
    streakDays = prefs.getInt('streakDays') ?? 0;
    final ts = prefs.getInt('lastRecordDate');
    if (ts != null) lastRecordDate = DateTime.fromMillisecondsSinceEpoch(ts);
    longestStreak = prefs.getInt('longestStreak') ?? 0;
    xp = prefs.getInt('xp') ?? 0;
    monthlyBudget = prefs.getDouble('monthlyBudget') ?? 0;
    unlockedAchievements =
        (prefs.getStringList('unlockedAchievements') ?? []).toSet();
  }
}
