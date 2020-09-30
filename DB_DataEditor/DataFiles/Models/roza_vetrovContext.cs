using System;
using System.Windows.Controls;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;

namespace DB_DataEditor.DataFiles.Models
{
    /// <summary>
    /// ADO.NET модель базы данных.
    /// </summary>
    public partial class roza_vetrovContext : DbContext
    {
        private static string _host, _port, _database, _username, _password;
        /// <summary>
        /// Подключение с заданными параметрами к серверу БД.
        /// </summary>
        /// <param name="host">Адрес сервера.</param>
        /// <param name="port">Порт сервера.</param>
        /// <param name="database">Имя базы данных.</param>
        /// <param name="username">Имя пользователя.</param>
        /// <param name="password">Пароль пользователя.</param>
        public roza_vetrovContext(string host, string port, string database, string username, string password)
        {
            _host = host;
            _port = port;
            _database = database;
            _username = username;
            _password = password;
        }

        public roza_vetrovContext(DbContextOptions<roza_vetrovContext> options)
            : base(options)
        {
        }

        public virtual DbSet<City> City { get; set; }
        public virtual DbSet<MinimalPriceTransportation> MinimalPriceTransportation { get; set; }
        public virtual DbSet<OptionalFunction> OptionalFunction { get; set; }
        public virtual DbSet<Package> Package { get; set; }
        public virtual DbSet<PackagePriceTransportation> PackagePriceTransportation { get; set; }
        public virtual DbSet<Price> Price { get; set; }
        public virtual DbSet<Role> Role { get; set; }
        public virtual DbSet<Size> Size { get; set; }
        public virtual DbSet<Subject> Subject { get; set; }
        public virtual DbSet<Transportation> Transportation { get; set; }
        public virtual DbSet<User> User { get; set; }
        public virtual DbSet<Weight> Weight { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
#warning Защитить данные для подключения к серверу БД: http://go.microsoft.com/fwlink/?LinkId=723263
                optionsBuilder.UseNpgsql($"Host={_host};Port={_port};Database={_database};Username={_username};Password={_password}");
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

            modelBuilder.Entity<MinimalPriceTransportation>(entity =>
            {
                entity.ToTable("minimal_price_transportation");

                entity.Property(e => e.MinimalPriceTransportationId)
                    .HasColumnName("minimal_price_transportation_id")
                    .HasDefaultValueSql("nextval('minimal_price_transportation_minimal_price_transportation_i_seq'::regclass)");

                entity.Property(e => e.Price).HasColumnName("price");

                entity.Property(e => e.TransportationId).HasColumnName("transportation_id");

                entity.HasOne(d => d.Transportation)
                    .WithMany(p => p.MinimalPriceTransportation)
                    .HasForeignKey(d => d.TransportationId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("minimal_price_transportation_fk");
            });

            modelBuilder.Entity<OptionalFunction>(entity =>
            {
                entity.HasNoKey();

                entity.ToTable("optional_function");
            });

            modelBuilder.Entity<Package>(entity =>
            {
                entity.ToTable("package");

                entity.HasComment("Первичные характеристики перевозимиго места");

                entity.Property(e => e.PackageId)
                    .HasColumnName("package_id")
                    .HasDefaultValueSql("nextval('package_packcage_id_seq'::regclass)");

                entity.Property(e => e.SizeId).HasColumnName("size_id");

                entity.Property(e => e.Value).HasColumnName("value");

                entity.Property(e => e.WeightId).HasColumnName("weight_id");

                entity.HasOne(d => d.Size)
                    .WithMany(p => p.Package)
                    .HasForeignKey(d => d.SizeId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("package_fk");

                entity.HasOne(d => d.Weight)
                    .WithMany(p => p.Package)
                    .HasForeignKey(d => d.WeightId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("package_fk_1");
            });

            modelBuilder.Entity<PackagePriceTransportation>(entity =>
            {
                entity.ToTable("package_price_transportation");

                entity.Property(e => e.PackagePriceTransportationId)
                    .HasColumnName("package_price_transportation_id")
                    .ValueGeneratedNever();

                entity.Property(e => e.PackageId).HasColumnName("package_id");

                entity.Property(e => e.Price).HasColumnName("price");

                entity.Property(e => e.TransportationId).HasColumnName("transportation_id");

                entity.HasOne(d => d.Package)
                    .WithMany(p => p.PackagePriceTransportation)
                    .HasForeignKey(d => d.PackageId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("package_price_transportation_fk_1");

                entity.HasOne(d => d.Transportation)
                    .WithMany(p => p.PackagePriceTransportation)
                    .HasForeignKey(d => d.TransportationId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("package_price_transportation_fk");
            });

            modelBuilder.Entity<Price>(entity =>
            {
                entity.ToTable("price");

                entity.Property(e => e.PriceId).HasColumnName("price_id");

                entity.Property(e => e.MinimalPriceTransportationId).HasColumnName("minimal_price_transportation_id");

                entity.Property(e => e.PackagePriceTransportationId).HasColumnName("package_price_transportation_id");

                entity.Property(e => e.Price1).HasColumnName("price");

                entity.HasOne(d => d.MinimalPriceTransportation)
                    .WithMany(p => p.PriceNavigation)
                    .HasForeignKey(d => d.MinimalPriceTransportationId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("price_fk");

                entity.HasOne(d => d.PackagePriceTransportation)
                    .WithMany(p => p.PriceNavigation)
                    .HasForeignKey(d => d.PackagePriceTransportationId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("price_fk_1");
            });

            modelBuilder.Entity<Role>(entity =>
            {
                entity.ToTable("role");

                entity.HasComment("Роль пользователя вошедшего в систему");

                entity.HasIndex(e => e.Name)
                    .HasName("role_un")
                    .IsUnique();

                entity.Property(e => e.RoleId).HasColumnName("role_id");

                entity.Property(e => e.Name)
                    .HasColumnName("name")
                    .HasMaxLength(20);
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
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("transportation_fk_1");

                entity.HasOne(d => d.Incity)
                    .WithMany(p => p.TransportationIncity)
                    .HasForeignKey(d => d.IncityId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("transportation_fk");
            });

            modelBuilder.Entity<User>(entity =>
            {
                entity.ToTable("user");

                entity.HasIndex(e => new { e.Login, e.Password })
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

                entity.Property(e => e.RoleId)
                    .HasColumnName("role_id")
                    .ValueGeneratedOnAdd();

                entity.HasOne(d => d.Role)
                    .WithMany(p => p.User)
                    .HasForeignKey(d => d.RoleId)
                    .HasConstraintName("user_fk");
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

            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}
