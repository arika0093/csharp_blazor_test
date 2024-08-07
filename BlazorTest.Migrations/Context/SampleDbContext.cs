using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using BlazorTest.Core.Models;

namespace BlazorTest.Migrations.Context;

public partial class SampleDbContext : DbContext
{

    public DbSet<SampleObject> SampleEntities { get; set; }

    public SampleDbContext()
    {
    }

    public SampleDbContext(DbContextOptions<SampleDbContext> options)
        : base(options)
    {
    }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        => optionsBuilder.UseNpgsql("server=db;username=postgres;password=postgres;database=postgres");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
