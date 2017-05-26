using OMSServiceMapExport.Model;
using System.Data.Entity;

namespace OMSServiceMapExport.EF
{
    public class ServiceMapDataContext : DbContext
    {
        public ServiceMapDataContext()
            : base("ServiceMapDatabase")
        {
        }

        public DbSet<Machine> Machines { get; set; }
        public DbSet<MachineProcess> MachineProcesses { get; set; }
        public DbSet<MachinePort> MachinePorts { get; set; }
        public DbSet<MachineInboundConnection> MachineInboundConnections { get; set; }
        public DbSet<MachineOutboundConnection> MachineOutboundConnections { get; set; }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            modelBuilder.Entity<MachineInboundConnection>()
               .HasRequired(f => f.SourceMachine)
               .WithMany()
               .WillCascadeOnDelete(false);

            modelBuilder.Entity<MachineOutboundConnection>()
               .HasRequired(f => f.DestinationMachine)
               .WithMany()
               .WillCascadeOnDelete(false);

            modelBuilder.Entity<MachineOutboundConnection>()
               .HasRequired(f => f.ServerPort)
               .WithMany()
               .WillCascadeOnDelete(false);
        }
    }
}
