using OMSServiceMapExport.EF;
using OMSServiceMapExport.Model.ServiceMap;
using System.ComponentModel.DataAnnotations;
using System.Linq;

namespace OMSServiceMapExport.Model
{
    public class MachinePort
    {
        [Key]
        public int MachinePortId { get; set; }

        public Machine Machine { get; set; }
        public int MachineId { get; set; }

        [Required]
        public string ServiceMapReferenceKey { get; set; }
        public string State { get; set; }
        public string DisplayName { get; set; }
        public string IpAddress { get; set; }
        public int PortNumber { get; set; }

        public static MachinePort CreateInstance(ServiceMapDataContext dbContext, PortDTO dto)
        {
            if (dto == null)
            {
                return null;
            }

            var port = new MachinePort
            {
                ServiceMapReferenceKey = dto.Id
            };

            if (dto.Properties != null)
            {
                if (dto.Properties.Machine != null)
                {
                    var machine = dbContext.Machines.Where(x => x.ServiceMapReferenceKey != null && x.ServiceMapReferenceKey.Equals(dto.Properties.Machine.Id)).FirstOrDefault();
                    if (machine != null)
                    {
                        port.MachineId = machine.MachineId;
                    }
                }

                port.State = dto.Properties.MonitoringState;
                port.DisplayName = dto.Properties.DisplayName;
                port.IpAddress = dto.Properties.IpAddress;
                port.PortNumber = dto.Properties.PortNumber;
            }

            return port;
        }
    }
}
