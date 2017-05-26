using OMSServiceMapExport.Model.ServiceMap;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace OMSServiceMapExport.Model
{
    public class Machine
    {
        [Key]
        public int MachineId { get; set; }
        [Required]
        public string ServiceMapReferenceKey { get; set; }
        public string State { get; set; }
        public string ComputerName { get; set; }
        public string FullyQualifiedDomainName { get; set; }
        public string OperatingSystem { get; set; }
        public int Memory { get; set; }
        public int Cpus { get; set; }

        public virtual List<MachineProcess> Processes { get; set; }
        public virtual List<MachinePort> Ports { get; set; }

        public static Machine CreateInstance(MachineDTO dto)
        {
            if (dto == null)
            {
                return null;
            }

            var machine = new Machine
            {
                ServiceMapReferenceKey = dto.Id,
                State = "Unknown"
            };

            if (dto.Properties != null)
            {
                machine.State = dto.Properties.MonitoringState;
                machine.ComputerName = dto.Properties.ComputerName;
                machine.FullyQualifiedDomainName = dto.Properties.FullyQualifiedDomainName;

                if (dto.Properties.OperatingSystem != null)
                {
                    machine.OperatingSystem = dto.Properties.OperatingSystem.FullName;
                }

                if (dto.Properties.Resources != null)
                {
                    machine.Memory = dto.Properties.Resources.PhysicalMemory;
                    machine.Cpus = dto.Properties.Resources.Cpus;
                }
            }

            return machine;
        }
    }
}
