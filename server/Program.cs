using Microsoft.EntityFrameworkCore;
using iFinance.API.Data;
using iFinance.API.Models;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlite("Data Source=ifinance.db"));

var app = builder.Build();

// Auto create database
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    db.Database.EnsureCreated();
}

// GET /api/transactions?month=2026-03
app.MapGet("/api/transactions", async (AppDbContext db, string? month) =>
{
    var query = db.Transactions.AsQueryable();

    if (!string.IsNullOrEmpty(month) && DateTime.TryParse(month + "-01", out var monthDate))
    {
        var start = new DateTime(monthDate.Year, monthDate.Month, 1);
        var end = start.AddMonths(1);
        query = query.Where(t => t.Date >= start && t.Date < end);
    }

    var transactions = await query.OrderByDescending(t => t.Date).ToListAsync();
    return Results.Ok(transactions);
});

// GET /api/transactions/{id}
app.MapGet("/api/transactions/{id}", async (AppDbContext db, Guid id) =>
{
    var transaction = await db.Transactions.FindAsync(id);
    return transaction is not null ? Results.Ok(transaction) : Results.NotFound();
});

// POST /api/transactions
app.MapPost("/api/transactions", async (AppDbContext db, CreateTransactionRequest req) =>
{
    var transaction = new Transaction
    {
        Id = Guid.NewGuid(),
        Amount = req.Amount,
        Type = req.Type,
        Category = req.Category,
        Date = req.Date ?? DateTime.UtcNow,
        Note = req.Note,
        CreatedAt = DateTime.UtcNow
    };

    db.Transactions.Add(transaction);
    await db.SaveChangesAsync();
    return Results.Created($"/api/transactions/{transaction.Id}", transaction);
});

// PUT /api/transactions/{id}
app.MapPut("/api/transactions/{id}", async (AppDbContext db, Guid id, CreateTransactionRequest req) =>
{
    var transaction = await db.Transactions.FindAsync(id);
    if (transaction is null) return Results.NotFound();

    transaction.Amount = req.Amount;
    transaction.Type = req.Type;
    transaction.Category = req.Category;
    transaction.Date = req.Date ?? transaction.Date;
    transaction.Note = req.Note;

    await db.SaveChangesAsync();
    return Results.Ok(transaction);
});

// DELETE /api/transactions/{id}
app.MapDelete("/api/transactions/{id}", async (AppDbContext db, Guid id) =>
{
    var transaction = await db.Transactions.FindAsync(id);
    if (transaction is null) return Results.NotFound();

    db.Transactions.Remove(transaction);
    await db.SaveChangesAsync();
    return Results.NoContent();
});

// GET /api/summary?month=2026-03
app.MapGet("/api/summary", async (AppDbContext db, string? month) =>
{
    var query = db.Transactions.AsQueryable();

    if (!string.IsNullOrEmpty(month) && DateTime.TryParse(month + "-01", out var monthDate))
    {
        var start = new DateTime(monthDate.Year, monthDate.Month, 1);
        var end = start.AddMonths(1);
        query = query.Where(t => t.Date >= start && t.Date < end);
    }

    var transactions = await query.ToListAsync();
    var income = transactions.Where(t => t.Type == "收入").Sum(t => t.Amount);
    var expense = transactions.Where(t => t.Type == "支出").Sum(t => t.Amount);

    return Results.Ok(new TransactionSummary
    {
        TotalIncome = income,
        TotalExpense = expense,
        Balance = income - expense,
        Count = transactions.Count
    });
});

app.Run();
