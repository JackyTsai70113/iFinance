import SwiftUI
import Charts

struct StatsView: View {
    var store: AppStore
    @State private var showBudgetSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Budget card
                    BudgetCard(store: store, showBudgetSheet: $showBudgetSheet)

                    // Pie chart
                    PieChartCard(data: store.expenseByCategory, totalExpense: store.thisMonthExpense)
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("統計")
            .sheet(isPresented: $showBudgetSheet) {
                BudgetSettingSheet(store: store)
            }
        }
    }
}

// MARK: - Budget Card

struct BudgetCard: View {
    var store: AppStore
    @Binding var showBudgetSheet: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("本月預算")
                    .font(.headline)
                Spacer()
                Button {
                    showBudgetSheet = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.secondary)
                }
            }

            if store.monthlyBudget > 0 {
                // Progress bar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("已花費 $\(Int(store.thisMonthExpense))")
                            .font(.subheadline)
                        Spacer()
                        Text("預算 $\(Int(store.monthlyBudget))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.15))
                                .frame(height: 16)

                            RoundedRectangle(cornerRadius: 8)
                                .fill(budgetColor)
                                .frame(width: max(0, geo.size.width * store.budgetProgress), height: 16)
                        }
                    }
                    .frame(height: 16)

                    HStack {
                        Image(systemName: budgetIcon)
                            .foregroundColor(budgetColor)
                        Text(budgetMessage)
                            .font(.caption)
                            .foregroundColor(budgetColor)
                    }
                }
            } else {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.secondary)
                    Text("尚未設定預算，點右上角齒輪設定")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var budgetColor: Color {
        if store.budgetProgress >= 1.0 { return .red }
        if store.budgetProgress >= 0.8 { return .orange }
        return .green
    }

    private var budgetIcon: String {
        if store.budgetProgress >= 1.0 { return "exclamationmark.triangle.fill" }
        if store.budgetProgress >= 0.8 { return "exclamationmark.circle.fill" }
        return "checkmark.circle.fill"
    }

    private var budgetMessage: String {
        if store.budgetProgress >= 1.0 { return "已超出預算！" }
        if store.budgetProgress >= 0.8 { return "快到預算上限了！" }
        return "剩餘 $\(Int(store.budgetRemaining))"
    }
}

// MARK: - Pie Chart Card

struct PieChartCard: View {
    let data: [(category: Category, amount: Double)]
    let totalExpense: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("本月支出分佈")
                .font(.headline)

            if data.isEmpty {
                HStack {
                    Image(systemName: "chart.pie")
                        .foregroundColor(.secondary)
                    Text("本月尚無支出紀錄")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                Chart(data, id: \.category.id) { item in
                    SectorMark(
                        angle: .value("金額", item.amount),
                        innerRadius: .ratio(0.55),
                        angularInset: 2
                    )
                    .foregroundStyle(item.category.color)
                    .cornerRadius(4)
                }
                .frame(height: 200)

                // Legend
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(data, id: \.category.id) { item in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(item.category.color)
                                .frame(width: 10, height: 10)
                            Text(item.category.name)
                                .font(.caption)
                                .lineLimit(1)
                            Spacer()
                            Text("$\(Int(item.amount))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Budget Setting Sheet

struct BudgetSettingSheet: View {
    var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var budgetText = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("每月預算金額")) {
                    HStack {
                        Text("$")
                        TextField("例如：30000", text: $budgetText)
                            .keyboardType(.decimalPad)
                            .onChange(of: budgetText) {
                                budgetText = budgetText.filter { $0.isNumber || $0 == "." }
                            }
                    }
                }
                Section {
                    Text("設定每月花費上限，幫助你控制支出。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("設定預算")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("儲存") {
                        if let val = Double(budgetText), val > 0 {
                            store.monthlyBudget = val
                        }
                        dismiss()
                    }
                    .bold()
                }
            }
            .onAppear {
                if store.monthlyBudget > 0 {
                    budgetText = "\(Int(store.monthlyBudget))"
                }
            }
        }
        .presentationDetents([.medium])
    }
}
