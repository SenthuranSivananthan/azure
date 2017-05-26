using OMSServiceMapExport.EF;
using OMSServiceMapExport.Model.ServiceMap;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;

namespace OMSServiceMapExport.Model
{
    public class MachineOutboundConnection
    {
        public int Id { get; set; }
        [Required]
        public string ServiceMapReferenceKey { get; set; }

        public string SourceKind { get; set; }

        public virtual Machine Machine { get; set; }
        [ForeignKey("Machine")]
        public int? MachineId { get; set; }

        public string DestinationKind { get; set; }

        public virtual Machine DestinationMachine { get; set; }
        [ForeignKey("DestinationMachine")]
        public int? DestinationMachineId { get; set; }

        public virtual MachinePort ServerPort { get; set; }
        [ForeignKey("ServerPort")]
        public int? ServerPortId { get; set; }

        public static MachineOutboundConnection CreateInstance(ServiceMapDataContext dbContext, ConnectionDTO dto)
        {
            if (dto == null || dto.Properties == null || dto.Properties.Source == null || dto.Properties.Destination == null)
            {
                return null;
            }

            var outbound = new MachineOutboundConnection
            {
                ServiceMapReferenceKey = dto.Id
            };

            if (dto.Properties.Source.Properties != null && dto.Properties.Source.Properties.Machine != null)
            {
                var machine = dbContext.Machines.Where(x => x.ServiceMapReferenceKey != null && x.ServiceMapReferenceKey.Equals(dto.Properties.Source.Properties.Machine.Id)).FirstOrDefault();
                if (machine != null)
                {
                    outbound.MachineId = machine.MachineId;
                }

                outbound.SourceKind = dto.Properties.Source.Kind;
            }

            if (dto.Properties.Destination.Properties != null)
            {
                if (dto.Properties.Destination.Properties.Machine != null)
                {
                    var machine = dbContext.Machines.Where(x => x.ServiceMapReferenceKey != null && x.ServiceMapReferenceKey.Equals(dto.Properties.Destination.Properties.Machine.Id)).FirstOrDefault();
                    if (machine != null)
                    {
                        outbound.DestinationMachineId = machine.MachineId;
                    }
                }

                outbound.DestinationKind = dto.Properties.Destination.Kind;
            }

            if (dto.Properties.ServerPort != null && dto.Properties.ServerPort.Properties != null)
            {
                var port = dbContext.MachinePorts.Where(x => x.ServiceMapReferenceKey != null && x.ServiceMapReferenceKey.Equals(dto.Properties.ServerPort.Id)).FirstOrDefault();
                if (port != null)
                {
                    outbound.ServerPortId = port.MachinePortId;
                }
            }

            return outbound;
        }
    }
}
