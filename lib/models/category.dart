import 'package:flutter/material.dart';

class CategoryDef {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const CategoryDef({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

const kExpenseCategoryIds = [
  'breakfast', 'lunch', 'dinner', 'snack', 'transport', 'groceries',
  'shopping', 'entertainment', 'medical', 'education', 'bills', 'other_expense',
];

const kIncomeCategoryIds = ['salary', 'bonus', 'other_income'];

const kCategories = <CategoryDef>[
  // 支出
  CategoryDef(id: 'breakfast', name: '早餐', icon: Icons.coffee, color: Colors.orange),
  CategoryDef(id: 'lunch', name: '午餐', icon: Icons.restaurant, color: Colors.red),
  CategoryDef(id: 'dinner', name: '晚餐', icon: Icons.dinner_dining, color: Colors.purple),
  CategoryDef(id: 'snack', name: '飲料零食', icon: Icons.local_cafe, color: Colors.pink),
  CategoryDef(id: 'transport', name: '交通', icon: Icons.directions_car, color: Colors.blue),
  CategoryDef(id: 'groceries', name: '日常用品', icon: Icons.shopping_cart, color: Colors.teal),
  CategoryDef(id: 'shopping', name: '購物', icon: Icons.shopping_bag, color: Colors.indigo),
  CategoryDef(id: 'entertainment', name: '娛樂', icon: Icons.sports_esports, color: Colors.green),
  CategoryDef(id: 'medical', name: '醫療', icon: Icons.local_hospital, color: Colors.cyan),
  CategoryDef(id: 'education', name: '教育', icon: Icons.menu_book, color: Colors.brown),
  CategoryDef(id: 'bills', name: '帳單', icon: Icons.receipt_long, color: Colors.grey),
  CategoryDef(id: 'other_expense', name: '其他支出', icon: Icons.more_horiz, color: Colors.blueGrey),
  // 收入
  CategoryDef(id: 'salary', name: '薪資', icon: Icons.attach_money, color: Colors.green),
  CategoryDef(id: 'bonus', name: '獎金', icon: Icons.star, color: Colors.amber),
  CategoryDef(id: 'other_income', name: '其他收入', icon: Icons.add_circle, color: Colors.lightGreen),
];

CategoryDef getCategoryById(String id) {
  return kCategories.firstWhere(
    (c) => c.id == id,
    orElse: () => kCategories.first!,
  );
}
