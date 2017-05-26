using Newtonsoft.Json;
using System.Collections.Generic;

namespace OMSServiceMapExport.Model.ServiceMap
{
    #region Machine Model
    public class MachineValuePropertyDTO
    {
        public string ComputerName { get; set; }
    }

    public class MachineValueDTO
    {
        public string Id { get; set; }
        public string Name { get; set; }

        [JsonProperty("Properties")]
        public MachineValuePropertyDTO Properties { get; set; }
    }

    public class MachineRootDTO
    {
        [JsonProperty("Value")]
        public List<MachineValueDTO> Machines { get; set; }
    }
    #endregion

    #region Service Map Model
    public class ResourcesDTO
    {
        public int PhysicalMemory { get; set; }
        public int Cpus { get; set; }
        public int CpuSpeed { get; set; }
        public string CpuSpeedAccuracy { get; set; }
    }

    public class Ipv4InterfacesDTO
    {
        public string IpAddress { get; set; }
        public string SubnetMask { get; set; }
    }

    public class Ipv6InterfacesDTO
    {
        public string IpAddress { get; set; }
    }

    public class NetworkingDTO
    {
        public List<Ipv4InterfacesDTO> Ipv4Interfaces { get; set; }
        public List<Ipv6InterfacesDTO> Ipv6Interfaces { get; set; }
        public List<string> DefaultIpv4Gateways { get; set; }
        public List<string> MacAddresses { get; set; }
        public List<string> DnsNames { get; set; }
    }

    public class OperatingSystemDTO
    {
        public string Family { get; set; }
        public string FullName { get; set; }
    }

    public class VirtualMachineDTO
    {
        public string VirtualMachineType { get; set; }
        public string NativeMachineId { get; set; }
        public string VirtualMachineName { get; set; }
        public string NativeHostMachineId { get; set; }
    }

    public class MachinePropertyDTO
    {
        public string MonitoringState { get; set; }
        public string VirtualizationState { get; set; }
        public string DisplayName { get; set; }
        public string ComputerName { get; set; }
        public string FullyQualifiedDomainName { get; set; }
        public string BootTime { get; set; }
        public ResourcesDTO Resources { get; set; }
        public NetworkingDTO Networking { get; set; }
        public OperatingSystemDTO OperatingSystem { get; set; }
        public VirtualMachineDTO VirtualMachine { get; set; }
    }

    public class MachineDTO
    {
        public string Kind { get; set; }
        public MachinePropertyDTO Properties { get; set; }
        public string Id { get; set; }
        public string Type { get; set; }
        public string Name { get; set; }
    }

    public class ProcessDetailsDTO
    {
        public string CompanyName { get; set; }
        public string InternalName { get; set; }
        public string ProductName { get; set; }
        public string ProductVersion { get; set; }
        public string FileVersion { get; set; }
        public string CommandLine { get; set; }
        public string ExecutablePath { get; set; }
        public string WorkingDirectory { get; set; }
    }

    public class UserDTO
    {
        public string UserName { get; set; }
        public string UserDomain { get; set; }
    }

    public class ProcessPropertyDTO
    {
        public string MonitoringState { get; set; }
        public MachineDTO Machine { get; set; }
        public string ExecutableName { get; set; }
        public string DisplayName { get; set; }
        public string StartTime { get; set; }
        public ProcessDetailsDTO Details { get; set; }
        public UserDTO User { get; set; }
    }

    public class ProcessDTO
    {
        public string Kind { get; set; }
        public ProcessPropertyDTO Properties { get; set; }
        public string Id { get; set; }
        public string Type { get; set; }
        public string Name { get; set; }
    }

    public class PortPropertyDTO
    {
        public string MonitoringState { get; set; }
        public MachineDTO Machine { get; set; }
        public string DisplayName { get; set; }
        public string IpAddress { get; set; }
        public int PortNumber { get; set; }
    }

    public class PortDTO
    {
        public string Kind { get; set; }
        public PortPropertyDTO Properties { get; set; }
        public string Id { get; set; }
        public string Type { get; set; }
        public string Name { get; set; }
    }

    public class NodesDTO
    {
        public List<MachineDTO> Machines { get; set; }
        public List<ProcessDTO> Processes { get; set; }
        public List<PortDTO> Ports { get; set; }
    }

    public class ConnectionSourcePropertyDTO
    {
        public MachineDTO Machine { get; set; }
    }

    public class ConnectionSourceDTO
    {
        public string Kind { get; set; }
        public ConnectionSourcePropertyDTO Properties { get; set; }
        public string Id { get; set; }
        public string Type { get; set; }
        public string Name { get; set; }
    }

    public class ConnectionDestinationPropertyDTO
    {
        public MachineDTO Machine { get; set; }
    }

    public class ConnectionDestinationDTO
    {
        public string Kind { get; set; }
        public ConnectionDestinationPropertyDTO Properties { get; set; }
        public string Id { get; set; }
        public string Type { get; set; }
        public string Name { get; set; }
    }

    public class ConnectionServerPortPropertyDTO
    {
        public MachineDTO Machine { get; set; }
        public string IpAddress { get; set; }
        public int PortNumber { get; set; }
    }

    public class ConnectionServerPortDTO
    {
        public string Kind { get; set; }
        public ConnectionServerPortPropertyDTO Properties { get; set; }
        public string Id { get; set; }
        public string Type { get; set; }
        public string Name { get; set; }
    }

    public class ConnectionPropertyDTO
    {
        public ConnectionSourceDTO Source { get; set; }
        public ConnectionDestinationDTO Destination { get; set; }
        public ConnectionServerPortDTO ServerPort { get; set; }
        public string FailureState { get; set; }
    }

    public class ConnectionDTO
    {
        public string Kind { get; set; }
        public ConnectionPropertyDTO Properties { get; set; }
        public string Id { get; set; }
        public string Type { get; set; }
        public string Name { get; set; }
    }

    public class AcceptorSourcePropertyDTO
    {
        public MachineDTO Machine { get; set; }
        public string IpAddress { get; set; }
        public int PortNumber { get; set; }
    }

    public class AcceptorSourceDTO
    {
        public string Kind { get; set; }
        public AcceptorSourcePropertyDTO Properties { get; set; }
        public string Id { get; set; }
        public string Type { get; set; }
        public string Name { get; set; }
    }

    public class AcceptorDestinationPropertyDTO
    {
        public MachineDTO Machine { get; set; }
    }

    public class AcceptorDestinationDTO
    {
        public string Kind { get; set; }
        public AcceptorDestinationPropertyDTO Properties { get; set; }
        public string Id { get; set; }
        public string Type { get; set; }
        public string Name { get; set; }
    }

    public class AcceptorPropertiesDTO
    {
        public AcceptorSourceDTO Source { get; set; }
        public AcceptorDestinationDTO Destination { get; set; }
    }

    public class AcceptorDTO
    {
        public string Kind { get; set; }
        public AcceptorPropertiesDTO Properties { get; set; }
        public string Id { get; set; }
        public string Type { get; set; }
        public string Name { get; set; }
    }

    public class EdgesDTO
    {
        public List<ConnectionDTO> Connections { get; set; }
        public List<AcceptorDTO> Acceptors { get; set; }
    }

    public class MapDTO
    {
        public NodesDTO Nodes { get; set; }
        public EdgesDTO Edges { get; set; }
    }

    public class RootDTO
    {
        public string StartTime { get; set; }
        public string EndTime { get; set; }
        public MapDTO Map { get; set; }
    }
    #endregion
}
