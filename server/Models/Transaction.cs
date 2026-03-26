namespace iFinance.API.Models;

public class Transaction
{
    public Guid Id { get; set; }
    public double Amount { get; set; }
    public string Type { get; set; } = "支出"; // 收入 or 支出
    public string Category { get; set; } = "breakfast";
    public DateTime Date { get; set; }
    public string Note { get; set; } = "";
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

public class CreateTransactionRequest
{
    public double Amount { get; set; }
    public string Type { get; set; } = "支出";
    public string Category { get; set; } = "breakfast";
    public DateTime? Date { get; set; }
    public string Note { get; set; } = "";
}

public class TransactionSummary
{
    public double TotalIncome { get; set; }
    public double TotalExpense { get; set; }
    public double Balance { get; set; }
    public int Count { get; set; }
}
