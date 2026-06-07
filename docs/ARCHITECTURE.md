# System Architecture

## 5G Standalone Network Topology

```
┌─────────────────────────────────────────────────────────────┐
│                   5G Core Network (Open5GS)                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌─────┐ │   │
│  │ │  AMF   │ │  SMF   │ │  UPF   │ │  PCF   │ │ UDR │ │   │
│  │ └────────┘ └────────┘ └────────┘ └────────┘ └─────┘ │   │
│  │                         |                            │   │
│  │                    ogstun (10.45.0.1/16)             │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────────────┬────────────────────────────────┘
                             │
                       NGAP/SCTP
                             │
                   ┌─────────────────────┐
                   │   OAI gNB (RFSim)   │
                   │   192.168.70.129    │
                   └─────────────────────┘
                             │
                       UDP (RFSim)
                             │
              ┌──────────────────────────────┐
              │                              │
         ┌─────────┐                    ┌─────────┐
         │ UE1 (uesimtun0)              │ UE2 (uesimtun1)
         │ 10.45.0.2                    │ 10.45.0.3
         │ UERANSIM                     │ UERANSIM
         │ imsi-001010000000000         │ imsi-001010000000001
         └─────────────────────────────────┘
```

## Component Description

### Open5GS (5G Core Network)

**Role**: Provides 5G System (5GS) core functionality

**Components**:
- **AMF (Access and Mobility Function)**: Handles UE registration and mobility
- **SMF (Session Management Function)**: Manages PDU sessions
- **UPF (User Plane Function)**: Routes user data between UEs and external networks
- **PCF (Policy Control Function)**: Manages policies
- **UDR (Unified Data Repository)**: Stores subscriber information

**Network Interface**:
- NGAP/SCTP (NG interface) — connects to gNB
- Tunnel interface `ogstun` — carries user plane traffic

### OpenAirInterface (OAI) gNB

**Role**: Implements the 5G New Radio (NR) base station

**Mode**: RF Simulator (RFSim)
- Simulates radio interface over UDP
- No real RF hardware required
- Suitable for testing and research

**Interfaces**:
- NG (N2 + N3) — connects to AMF/UPF
- RFSim UDP interface — connects to UEs

### UERANSIM

**Role**: Simulates 5G User Equipment (UEs)

**Per UE**:
- Full 5G-SA UE stack
- Registration and authentication
- PDU session management
- IP connectivity via TUN interface

**UE Network Interfaces**:
- `uesimtun0` (UE1): 10.45.0.2
- `uesimtun1` (UE2): 10.45.0.3

## Communication Flow

### UE Registration Flow

```
UE1 → gNB → AMF → UDR (authentication)
             ↓
          Updates UE state
             ↓
AMF sends registration acceptance
             ↓
UE1 ← gNB ← AMF
```

### PDU Session Establishment

```
UE1 → SMF (PDU Session Request)
       ↓
    Allocates IP (10.45.0.2)
    Configures UPF
       ↓
UE1 ← SMF (PDU Session Response)
       ↓
UE1 gets TUN interface uesimtun0 with IP 10.45.0.2
```

### Data Transmission (UE1 → UE2)

```
UE1 (10.45.0.2)
    ↓ (ICMP/TCP packet)
uesimtun0 interface
    ↓
gNB (simulated UDP tunnel)
    ↓
UPF (10.45.0.1)
    ↓ (routes to UE2)
gNB (simulated UDP tunnel)
    ↓
uesimtun1 interface
    ↓
UE2 (10.45.0.3)
```

## Performance Metrics

| Metric | Value | Notes |
|--------|-------|-------|
| Throughput | 72–81 Gbps | Simulator performance |
| Latency | 12–20 ms | Round-trip time |
| Packet Loss | 0% | No loss in simulation |
| Registration Time | ~2-5 sec | Per UE |
| PDU Session Setup | ~1-2 sec | Per session |

## Files and Directories

```
5g-message-passing-simulation/
├── config/
│   ├── open5gs-gnb.yaml        # Open5GS gNB config
│   ├── open5gs-ue.yaml         # Open5GS UE config (UE1)
│   └── open5gs-ue2.yaml        # Open5GS UE config (UE2)
├── src/
│   ├── gnb/                    # gNB implementation
│   ├── ue/                     # UE implementation
│   ├── lib/                    # Protocol libraries
│   └── utils/                  # Utility functions
├── docs/
│   └── architecture.md         # This file
├── scripts/
│   ├── setup.sh                # Installation script
│   └── run_simulation.sh        # Run simulation
├── README.md                   # Setup guide
├── LICENSE                     # MIT License
└── CHANGELOG.md                # Version history
```

## System Requirements

- **OS**: Ubuntu 22.04 LTS (or compatible Linux)
- **RAM**: Minimum 8 GB (16 GB recommended)
- **CPU**: Intel i5/i7 or equivalent
- **Disk**: 20 GB free space

## Deployment Modes

### Mode 1: Standalone Lab (Recommended for Testing)
- All components on single machine
- Ideal for development and validation
- ~1-2 min startup time

### Mode 2: Distributed (Future)
- Separate servers for core network and RAN
- Scales to multiple gNBs and UEs
- Requires network bridge setup

---

For detailed setup instructions, see [README.md](../README.md).
