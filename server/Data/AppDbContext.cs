using Microsoft.EntityFrameworkCore;
using iFinance.API.Models;

namespace iFinance.API.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<Transaction> Transactions => Set<Transaction>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Transaction>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Type).IsRequired().HasMaxLength(10);
            entity.Property(e => e.Category).IsRequired().HasMaxLength(50);
            entity.Property(e => e.Note).HasMaxLength(200);
            entity.HasIndex(e => e.Date);
        });
    }
}
