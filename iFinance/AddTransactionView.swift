import SwiftUI

private let expenseCategories = ["breakfast", "lunch", "dinner", "snack", "transport", "groceries", "shopping", "entertainment", "medical", "education", "bills", "other_expense"]
private let incomeCategories = ["salary", "bonus", "other_income"]

struct AddTransactionView: View {
    var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var amount = ""
    @State private var type: TransactionType = .expense
    @State private var selectedCategory = "breakfast"
    @State private var note = ""
    @State private var date = Date()

    var filteredCategories: [Category] {
        let ids = type == .expense ? expenseCategories : incomeCategories
        return CATEGORIES.filter { ids.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("類型", selection: $type) {
                        ForEach(TransactionType.allCases, id: \.self) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: type) {
                        withAnimation(.easeOut(duration: 0.25)) {
                            selectedCategory = type == .expense ? "breakfast" : "salary"
                        }
                    }

                    HStack {
                        Text("$")
                        TextField("金額", text: $amount)
                            .keyboardType(.decimalPad)
                            .onChange(of: amount) {
                                let filtered = amount.filter { $0.isNumber || $0 == "." }
                                let parts = filtered.split(separator: ".", omittingEmptySubsequences: false)
                                if parts.count > 2 {
                                    amount = String(parts[0]) + "." + String(parts[1])
                                } else if filtered != amount {
                                    amount = filtered
                                }
                            }
                    }
                }

                Section(header: Text("類別")) {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        ForEach(filteredCategories) { cat in
                            Button {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    selectedCategory = cat.id
                                }
                            } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: cat.icon)
                                        .font(.title2)
                                        .foregroundColor(selectedCategory == cat.id ? .white : cat.color)
                                        .frame(width: 48, height: 48)
                                        .background(selectedCategory == cat.id ? cat.color : cat.color.opacity(0.15))
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                        .scaleEffect(selectedCategory == cat.id ? 1.1 : 1.0)
                                    Text(cat.name)
                                        .font(.caption)
                                        .foregroundColor(selectedCategory == cat.id ? cat.color : .secondary)
                                }
                            }
                            .buttonStyle(.plain)
                            .sensoryFeedback(.selection, trigger: selectedCategory)
                        }
                    }
                    .padding(.vertical, 5)
                    .animation(.easeOut(duration: 0.25), value: type)
                }

                Section(header: Text("詳細資訊")) {
                    DatePicker("日期", selection: $date, displayedComponents: .date)
                    TextField("備註", text: $note)
                }
            }
            .navigationTitle("新增交易")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("儲存") {
                        if let val = Double(amount), val > 0 {
                            let t = Transaction(amount: val, type: type, category: selectedCategory, date: date, note: note)
                            store.addTransaction(t)
                            dismiss()
                        }
                    }
                    .bold()
                    .sensoryFeedback(.success, trigger: store.transactions.count)
                }
            }
        }
    }
}
