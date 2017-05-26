using OMSServiceMapExport.EF;
using OMSServiceMapExport.Model.ServiceMap;
using System.ComponentModel.DataAnnotations;
using System.Linq;

namespace OMSServiceMapExport.Model
{
    public class MachineProcess
    {
        [Key]
        public int MachineProcessId { get; set; }

        public Machine Machine { get; set; }
        public int MachineId { get; set; }

        [Required]
        public string ServiceMapReferenceKey { get; set; }
        public string State { get; set; }

        public string CompanyName { get; set; }
        public string DisplayName { get; set; }
        public string InternalName { get; set; }
        public string ProductName { get; set; }
        public string ProductVersion { get; set; }
        public string FileVersion { get; set; }
        public string CommandLine { get; set; }
        public string ExecutablePath { get; set; }
        public string WorkingDirectory { get; set; }

        public static MachineProcess CreateInstance(ServiceMapDataContext dbContext, ProcessDTO dto)
        {
            if (dto == null)
            {
                return null;
            }

            var process = new MachineProcess()
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
                        process.MachineId = machine.MachineId;
                    }
                }

                process.State = dto.Properties.MonitoringState;
                process.DisplayName = dto.Properties.DisplayName;

                if (dto.Properties.Details != null)
                {
                    process.CommandLine = dto.Properties.Details.CommandLine;
                    process.CompanyName = dto.Properties.Details.CommandLine;
                    process.ExecutablePath = dto.Properties.Details.ExecutablePath;
                    process.FileVersion = dto.Properties.Details.FileVersion;
                    process.InternalName = dto.Properties.Details.InternalName;
                    process.ProductName = dto.Properties.Details.ProductName;
                    process.ProductVersion = dto.Properties.Details.ProductVersion;
                    process.WorkingDirectory = dto.Properties.Details.WorkingDirectory;
                }
            }

            return process;
        }
    }
}