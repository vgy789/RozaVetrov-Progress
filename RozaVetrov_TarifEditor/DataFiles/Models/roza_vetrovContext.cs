using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;

namespace RozaVetrov_TarifEditor.DataFiles.Models
{
    public partial class roza_vetrovContext : DbContext
    {
        public roza_vetrovContext()
        {
        }

        public roza_vetrovContext(DbContextOptions<roza_vetrovContext> options)
            : base(options)
        {
        }

        public virtual DbSet<City> City { get; set; }
        public virtual DbSet<History> History { get; set; }
        public virtual DbSet<MinimalWeightPrice> MinimalWeightPrice { get; set; }
        public virtual DbSet<Size> Size { get; set; }
        public virtual DbSet<SizeCoefficient> SizeCoefficient { get; set; }
        public virtual DbSet<Subject> Subject { get; set; }
        public virtual DbSet<Transportation> Transportation { get; set; }
        public virtual DbSet<User> User { get; set; }
        public virtual DbSet<Weight> Weight { get; set; }
        public virtual DbSet<WeightCoefficient> WeightCoefficient { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. See http://go.microsoft.com/fwlink/?LinkId=723263 for guidance on storing connection strings.
                optionsBuilder.UseNpgsql("Host=localhost;Port=5434;Database=roza_vetrov;Username=postgres;Password=postgres");
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<City>(entity =>
            {
                entity.ToTable("city");

                entity.HasComment("Города и их субъекты");

                entity.HasIndex(e => e.Name)
                    .HasName("city_un")
                    .IsUnique();

                entity.Property(e => e.CityId).HasColumnName("city_id");

                entity.Property(e => e.Name)
                    .IsRequired()
                    .HasColumnName("name")
                    .HasMaxLength(30);

                entity.Property(e => e.SubjectId).HasColumnName("subject_id");

                entity.HasOne(d => d.Subject)
                    .WithMany(p => p.City)
                    .HasForeignKey(d => d.SubjectId)
                    .HasConstraintName("city_fk");
            });

            modelBuilder.Entity<History>(entity =>
            {
                entity.ToTable("history");

                entity.HasComment("Хранит даты изменения данных таблиц.");

                entity.Property(e => e.HistoryId).HasColumnName("history_id");

                entity.Property(e => e.DateEvent)
                    .HasColumnName("date_event")
                    .HasColumnType("timestamp(0) without time zone");

                entity.Property(e => e.Status)
                    .IsRequired()
                    .HasColumnName("status");

                entity.Property(e => e.TableName)
                    .IsRequired()
                    .HasColumnName("table_name")
                    .HasMaxLength(30);
            });

            modelBuilder.Entity<MinimalWeightPrice>(entity =>
            {
                entity.HasKey(e => e.MinWeightPriceId)
                    .HasName("minimal_weight_price_pk");

                entity.ToTable("minimal_weight_price");

                entity.HasComment("Цена по минимальному тарифу за перевозки по весу.");

                entity.Property(e => e.MinWeightPriceId).HasColumnName("min_weight_price_id");

                entity.Property(e => e.Price).HasColumnName("price");

                entity.Property(e => e.TransportationId).HasColumnName("transportation_id");

                entity.HasOne(d => d.Transportation)
                    .WithMany(p => p.MinimalWeightPrice)
                    .HasForeignKey(d => d.TransportationId)
                    .HasConstraintName("minimal_weight_price_fk");
            });

            modelBuilder.Entity<Size>(entity =>
            {
                entity.ToTable("size");

                entity.HasIndex(e => e.Name)
                    .HasName("size_un")
                    .IsUnique();

                entity.Property(e => e.SizeId).HasColumnName("size_id");

                entity.Property(e => e.Name)
                    .IsRequired()
                    .HasColumnName("name")
                    .HasMaxLength(10);
            });

            modelBuilder.Entity<SizeCoefficient>(entity =>
            {
                entity.ToTable("size_coefficient");

                entity.HasComment("Коэффицент перевозки по объёму");

                entity.Property(e => e.SizeCoefficientId)
                    .HasColumnName("size_coefficient_id")
                    .HasDefaultValueSql("nextval('size_price_size_price_id_seq'::regclass)");

                entity.Property(e => e.Price).HasColumnName("price");

                entity.Property(e => e.SizeId).HasColumnName("size_id");

                entity.Property(e => e.TransportationId).HasColumnName("transportation_id");

                entity.HasOne(d => d.Size)
                    .WithMany(p => p.SizeCoefficient)
                    .HasForeignKey(d => d.SizeId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("size_price_fk");

                entity.HasOne(d => d.Transportation)
                    .WithMany(p => p.SizeCoefficient)
                    .HasForeignKey(d => d.TransportationId)
                    .HasConstraintName("size_price_fk1");
            });

            modelBuilder.Entity<Subject>(entity =>
            {
                entity.ToTable("subject");

                entity.HasComment("Название субъектов РФ");

                entity.HasIndex(e => e.Name)
                    .HasName("subject_un")
                    .IsUnique();

                entity.Property(e => e.SubjectId).HasColumnName("subject_id");

                entity.Property(e => e.Name)
                    .IsRequired()
                    .HasColumnName("name")
                    .HasMaxLength(30);
            });

            modelBuilder.Entity<Transportation>(entity =>
            {
                entity.ToTable("transportation");

                entity.HasComment("Список возможных перевозок между городами");

                entity.Property(e => e.TransportationId).HasColumnName("transportation_id");

                entity.Property(e => e.FromcityId).HasColumnName("fromcity_id");

                entity.Property(e => e.IncityId).HasColumnName("incity_id");

                entity.HasOne(d => d.Fromcity)
                    .WithMany(p => p.TransportationFromcity)
                    .HasForeignKey(d => d.FromcityId)
                    .HasConstraintName("transportation_fk_1");

                entity.HasOne(d => d.Incity)
                    .WithMany(p => p.TransportationIncity)
                    .HasForeignKey(d => d.IncityId)
                    .HasConstraintName("transportation_fk");
            });

            modelBuilder.Entity<User>(entity =>
            {
                entity.ToTable("user");

                entity.HasIndex(e => e.Login)
                    .HasName("user_un")
                    .IsUnique();

                entity.Property(e => e.UserId).HasColumnName("user_id");

                entity.Property(e => e.Login)
                    .IsRequired()
                    .HasColumnName("login")
                    .HasMaxLength(20);

                entity.Property(e => e.Name)
                    .IsRequired()
                    .HasColumnName("name")
                    .HasMaxLength(40);

                entity.Property(e => e.Password)
                    .IsRequired()
                    .HasColumnName("password")
                    .HasMaxLength(20);
            });

            modelBuilder.Entity<Weight>(entity =>
            {
                entity.ToTable("weight");

                entity.HasIndex(e => e.Name)
                    .HasName("weight_un")
                    .IsUnique();

                entity.Property(e => e.WeightId).HasColumnName("weight_id");

                entity.Property(e => e.Name)
                    .IsRequired()
                    .HasColumnName("name")
                    .HasMaxLength(10);
            });

            modelBuilder.Entity<WeightCoefficient>(entity =>
            {
                entity.ToTable("weight_coefficient");

                entity.HasComment("Коэффициент перевозки по весу.");

                entity.Property(e => e.WeightCoefficientId)
                    .HasColumnName("weight_coefficient_id")
                    .HasDefaultValueSql("nextval('weight_price_weight_price_id_seq'::regclass)");

                entity.Property(e => e.Price)
                    .HasColumnName("price")
                    .HasColumnType("numeric(4,2)");

                entity.Property(e => e.TransportationId).HasColumnName("transportation_id");

                entity.Property(e => e.WeightId).HasColumnName("weight_id");

                entity.HasOne(d => d.Transportation)
                    .WithMany(p => p.WeightCoefficient)
                    .HasForeignKey(d => d.TransportationId)
                    .HasConstraintName("weight_price_fk1");

                entity.HasOne(d => d.Weight)
                    .WithMany(p => p.WeightCoefficient)
                    .HasForeignKey(d => d.WeightId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("weight_price_fk");
            });

            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}
