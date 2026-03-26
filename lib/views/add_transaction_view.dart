import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../stores/app_store.dart';
import '../models/transaction.dart';
import '../models/category.dart';

class AddTransactionView extends StatefulWidget {
  const AddTransactionView({super.key});

  @override
  State<AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends State<AddTransactionView> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  TransactionType _type = TransactionType.expense;
  String _selectedCategory = 'breakfast';
  DateTime _date = DateTime.now();

  List<CategoryDef> get _filteredCategories {
    final ids =
        _type == TransactionType.expense ? kExpenseCategoryIds : kIncomeCategoryIds;
    return kCategories.where((c) => ids.contains(c.id)).toList();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新增交易'),
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child:
                const Text('儲存', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Type picker
          SegmentedButton<TransactionType>(
            segments: TransactionType.values
                .map((t) => ButtonSegment(value: t, label: Text(t.label)))
                .toList(),
            selected: {_type},
            onSelectionChanged: (set) {
              setState(() {
                _type = set.first;
                _selectedCategory =
                    _type == TransactionType.expense ? 'breakfast' : 'salary';
              });
            },
          ),
          const SizedBox(height: 20),

          // Amount
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              prefixText: '\$ ',
              labelText: '金額',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          // Category grid
          Text('類別', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.8,
            children: _filteredCategories.map((cat) {
              final isSelected = _selectedCategory == cat.id;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat.id),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cat.color
                            : cat.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      transform: isSelected
                          ? (Matrix4.identity()..scale(1.1))
                          : Matrix4.identity(),
                      transformAlignment: Alignment.center,
                      child: Icon(cat.icon,
                          color: isSelected ? Colors.white : cat.color),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? cat.color : Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Date picker
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: const Text('日期'),
            subtitle: Text(
                '${_date.year}/${_date.month}/${_date.day}'),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _date = picked);
            },
          ),
          const SizedBox(height: 12),

          // Note
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: '備註',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    final t = Transaction(
      amount: amount,
      type: _type,
      category: _selectedCategory,
      date: _date,
      note: _noteController.text,
    );
    context.read<AppStore>().addTransaction(t);
    Navigator.pop(context);
  }
}
