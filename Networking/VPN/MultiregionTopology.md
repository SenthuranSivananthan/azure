# Multi-region Topology

## Overview
Describe the topology that enables customers to connect multiple virtual networks together across disparate regions using S2S VPN, Peering and VNET to VNET integration.

## Diagram

![Topology](images/multi-region-topology.png "Topology")

## Use Cases

| VNET Network Link | Connection Type | Description |
| ----------------- | :-------------: | :-------------: |
| VNET 1 -> VNET 2 | VNET Peering | Regional Peering |
| VNET 1 -> VNET 3 | S2S VPN + BGP | S2S IPSec |
| VNET 1 -> VNET 4 | VNET to VNET + BGP | VNET to VNET IPSec |
| VNET 2 -> VNET 1 | VNET Peering | Regional Peering |
| VNET 2 -> VNET 3 | via `VNET 1` | Route discovered through BGP |
| VNET 2 -> VNET 4 | via `VNET 1` | Route discovered through BGP |
| VNET 3 -> VNET 1 | S2S VPN + BGP | S2S IPSec connection |
| VNET 3 -> VNET 2 | via `VNET 1` | Route discovered through BGP |
| VNET 3 -> VNET 4 | via `VNET 1` | Route discovered through BGP |
| VNET 4 -> VNET 1 | VNET to VNET + BGP | VNET to VNET IPSec |
| VNET 4 -> VNET 2 | via `VNET 1` | Route discovered through BGP |
| VNET 4 -> VNET 3 | via `VNET 1` | Route discovered through BGP |

## Automation Template

Coming Soon
