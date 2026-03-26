import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti_widget/confetti_widget.dart';
import '../stores/app_store.dart';
import '../models/category.dart';
import '../widgets/pony_buddy.dart';
import 'add_transaction_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late ConfettiController _confettiController;
  String _ponyReaction = 'idle';

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onCelebration(AppStore store) {
    _confettiController.play();
    final t = store.lastAddedTransaction;
    if (t != null) {
      if (t.type.name == 'income') {
        _ponyReaction = 'happy';
      } else if (t.amount >= 1000) {
        _ponyReaction = 'surprised';
      } else {
        _ponyReaction = 'cheerful';
      }
      setState(() {});
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _ponyReaction = 'idle');
      });
    }
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) store.dismissCelebration();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();

    // Trigger celebration when flag is set
    if (store.showCelebration) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onCelebration(store);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的帳本'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, size: 30),
            onPressed: () => _showAddTransaction(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Streak banner
              if (store.streakDays > 0) _StreakBanner(days: store.streakDays),
              if (store.streakDays > 0) const SizedBox(height: 16),

              // Summary card
              _SummaryCard(
                balance: store.totalBalance,
                income: store.totalIncome,
                expense: store.totalExpense,
              ),
              const SizedBox(height: 20),

              // Recent transactions
              Text('最近交易',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              const SizedBox(height: 12),

              if (store.transactions.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(
                      children: [
                        Icon(Icons.inbox,
                            size: 48,
                            color: Colors.grey.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        const Text('尚無交易紀錄',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else
                ...store.transactions.reversed.map(
                    (t) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _TransactionRow(transaction: t),
                        )),

              // Extra space for pony
              const SizedBox(height: 100),
            ],
          ),

          // Pony buddy
          Positioned(
            right: 8,
            bottom: 16,
            child: PonyBuddy(
              transactionCount: store.transactions.length,
              balance: store.totalBalance,
              reaction: _ponyReaction,
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 30,
              gravity: 0.3,
              colors: const [
                Colors.red, Colors.orange, Colors.yellow,
                Colors.green, Colors.blue, Colors.purple, Colors.pink,
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const AddTransactionView(),
    );
  }
}

class _StreakBanner extends StatelessWidget {
  final int days;
  const _StreakBanner({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: Colors.orange),
          const SizedBox(width: 8),
          Text('連續記帳 $days 天！',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.orange)),
          const Spacer(),
          Text('繼續保持',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;
  const _SummaryCard(
      {required this.balance, required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('本月結餘',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text('\$${balance.toInt()}',
              style: const TextStyle(
                  fontSize: 40, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              _SummaryStat(
                  title: '收入', amount: income, color: Colors.green,
                  icon: Icons.arrow_upward),
              const Spacer(),
              _SummaryStat(
                  title: '支出', amount: expense, color: Colors.red,
                  icon: Icons.arrow_downward),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;
  const _SummaryStat(
      {required this.title,
      required this.amount,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            Text('\$${amount.toInt()}',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ],
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final dynamic transaction;
  const _TransactionRow({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final cat = getCategoryById(transaction.category);
    final isIncome = transaction.type.name == 'income';
    final dateStr =
        '${transaction.date.year}/${transaction.date.month}/${transaction.date.day}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cat.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(cat.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.note.isEmpty ? cat.name : transaction.note,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600),
                ),
                Text(dateStr,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            '${isIncome ? "+" : "-"}\$${transaction.amount.toInt()}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }
}
