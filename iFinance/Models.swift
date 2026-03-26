import Foundation
import SwiftUI

enum TransactionType: String, Codable, CaseIterable {
    case income = "收入"
    case expense = "支出"
}

struct Transaction: Identifiable, Codable {
    var id = UUID()
    var amount: Double
    var type: TransactionType
    var category: String
    var date: Date
    var note: String
}

struct Category: Identifiable {
    var id: String
    var name: String
    var icon: String
    var color: Color
}

let CATEGORIES = [
    // 支出類別
    Category(id: "breakfast", name: "早餐", icon: "cup.and.saucer.fill", color: .orange),
    Category(id: "lunch", name: "午餐", icon: "fork.knife", color: .red),
    Category(id: "dinner", name: "晚餐", icon: "fork.knife.circle.fill", color: .purple),
    Category(id: "snack", name: "飲料零食", icon: "takeoutbag.and.cup.and.straw.fill", color: .pink),
    Category(id: "transport", name: "交通", icon: "car.fill", color: .blue),
    Category(id: "groceries", name: "日常用品", icon: "cart.fill", color: .teal),
    Category(id: "shopping", name: "購物", icon: "bag.fill", color: .indigo),
    Category(id: "entertainment", name: "娛樂", icon: "gamecontroller.fill", color: .mint),
    Category(id: "medical", name: "醫療", icon: "cross.case.fill", color: .cyan),
    Category(id: "education", name: "教育", icon: "book.fill", color: .brown),
    Category(id: "bills", name: "帳單", icon: "doc.text.fill", color: .gray),
    Category(id: "other_expense", name: "其他支出", icon: "ellipsis.circle.fill", color: .secondary),
    // 收入類別
    Category(id: "salary", name: "薪資", icon: "dollarsign.circle.fill", color: .green),
    Category(id: "bonus", name: "獎金", icon: "star.circle.fill", color: .yellow),
    Category(id: "other_income", name: "其他收入", icon: "plus.circle.fill", color: .green),
]

// MARK: - Achievement Definitions

struct AchievementDef: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let color: Color
}

let ALL_ACHIEVEMENTS: [AchievementDef] = [
    AchievementDef(id: "first_record", name: "初心者", description: "記下第一筆交易", icon: "pencil.circle.fill", color: .green),
    AchievementDef(id: "records_10", name: "記帳新手", description: "累計記帳 10 筆", icon: "list.bullet.circle.fill", color: .blue),
    AchievementDef(id: "records_30", name: "記帳好手", description: "累計記帳 30 筆", icon: "list.star", color: .purple),
    AchievementDef(id: "records_100", name: "記帳大師", description: "累計記帳 100 筆", icon: "crown.fill", color: .yellow),
    AchievementDef(id: "streak_3", name: "三日不懈", description: "連續記帳 3 天", icon: "flame.fill", color: .orange),
    AchievementDef(id: "streak_7", name: "一週達人", description: "連續記帳 7 天", icon: "flame.circle.fill", color: .red),
    AchievementDef(id: "streak_30", name: "月度之星", description: "連續記帳 30 天", icon: "star.circle.fill", color: .pink),
    AchievementDef(id: "save_1000", name: "小富翁", description: "結餘達到 $1,000", icon: "banknote.fill", color: .mint),
    AchievementDef(id: "save_10000", name: "大富翁", description: "結餘達到 $10,000", icon: "building.columns.fill", color: .indigo),
    AchievementDef(id: "level_5", name: "升級達人", description: "達到等級 5", icon: "arrow.up.circle.fill", color: .teal),
    AchievementDef(id: "level_10", name: "記帳之神", description: "達到等級 10", icon: "bolt.circle.fill", color: .cyan),
]
