using System;
using System.Collections.Generic;
using BlazorTest.Core.Models;
using Microsoft.EntityFrameworkCore;
using Npgsql;
using DotNetEnv;
using NLog;

namespace BlazorTest.Core.Context;

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

    private static Logger Logger => LogManager.GetCurrentClassLogger();

    private static NpgsqlConnectionStringBuilder ConnectionStringBuilder
    {
        get
        {
            // load .env file
            Env.TraversePath().Load();
            var builder = new NpgsqlConnectionStringBuilder
            {
                Host = Env.GetString("DB_HOST"),
                Username = Env.GetString("DB_USERNAME"),
                Password = Env.GetString("DB_PASSWORD"),
                Database = Env.GetString("DB_DATABASE"),
            };
            return builder;
        }
    }

    private static NpgsqlConnectionStringBuilder PasswordHiddenConnStrBuilder
    {
        get
        {
            var builder = ConnectionStringBuilder;
            builder.Password = "********";
            return builder;
        }
    }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        Logger.Info("DB Connect to: {0}", PasswordHiddenConnStrBuilder.ConnectionString);
        optionsBuilder.UseNpgsql(
            ConnectionStringBuilder.ConnectionString
            ,x => x.MigrationsAssembly("BlazorTest.Migrations")
        );
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
