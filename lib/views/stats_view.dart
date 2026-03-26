import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../stores/app_store.dart';

class StatsView extends StatelessWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();

    return Scaffold(
      appBar: AppBar(title: const Text('統計')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _BudgetCard(store: store),
          const SizedBox(height: 20),
          _PieChartCard(
            data: store.expenseByCategory,
            totalExpense: store.thisMonthExpense,
          ),
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final AppStore store;
  const _BudgetCard({required this.store});

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
          Row(
            children: [
              Text('本月預算',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.grey),
                onPressed: () => _showBudgetSheet(context),
              ),
            ],
          ),
          if (store.monthlyBudget > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text('已花費 \$${store.thisMonthExpense.toInt()}'),
                const Spacer(),
                Text('預算 \$${store.monthlyBudget.toInt()}',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: store.budgetProgress,
                minHeight: 16,
                backgroundColor: Colors.grey.withValues(alpha: 0.15),
                color: _budgetColor(store.budgetProgress),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(_budgetIcon(store.budgetProgress),
                    color: _budgetColor(store.budgetProgress), size: 18),
                const SizedBox(width: 4),
                Text(
                  _budgetMessage(store),
                  style: TextStyle(
                    fontSize: 13,
                    color: _budgetColor(store.budgetProgress),
                  ),
                ),
              ],
            ),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('尚未設定預算，點右上角齒輪設定',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _budgetColor(double progress) {
    if (progress >= 1.0) return Colors.red;
    if (progress >= 0.8) return Colors.orange;
    return Colors.green;
  }

  IconData _budgetIcon(double progress) {
    if (progress >= 1.0) return Icons.warning;
    if (progress >= 0.8) return Icons.error_outline;
    return Icons.check_circle;
  }

  String _budgetMessage(AppStore store) {
    if (store.budgetProgress >= 1.0) return '已超出預算！';
    if (store.budgetProgress >= 0.8) return '快到預算上限了！';
    return '剩餘 \$${store.budgetRemaining.toInt()}';
  }

  void _showBudgetSheet(BuildContext context) {
    final controller =
        TextEditingController(text: store.monthlyBudget > 0 ? '${store.monthlyBudget.toInt()}' : '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('設定預算',
                style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('設定每月花費上限，幫助你控制支出。',
                style: Theme.of(ctx).textTheme.bodySmall),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                prefixText: '\$ ',
                labelText: '每月預算金額',
                hintText: '例如：30000',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    final val = double.tryParse(controller.text);
                    if (val != null && val > 0) {
                      store.setMonthlyBudget(val);
                    }
                    Navigator.pop(ctx);
                  },
                  child: const Text('儲存'),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PieChartCard extends StatelessWidget {
  final List<MapEntry<dynamic, double>> data;
  final double totalExpense;
  const _PieChartCard({required this.data, required this.totalExpense});

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
          Text('本月支出分佈',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
          const SizedBox(height: 16),
          if (data.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.pie_chart_outline, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('本月尚無支出紀錄',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 55,
                  sections: data.map((e) {
                    return PieChartSectionData(
                      value: e.value,
                      color: e.key.color,
                      radius: 40,
                      showTitle: false,
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: data.map((e) {
                return SizedBox(
                  width: (MediaQuery.of(context).size.width - 72) / 2,
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: e.key.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(e.key.name,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text('\$${e.value.toInt()}',
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
