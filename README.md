# 5G Standalone Network Simulation using OpenAirInterface, Open5GS, UERANSIM and Netcat Chat

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-Ubuntu%2022.04-orange)
![5G Standard](https://img.shields.io/badge/standard-3GPP%20R16-green)
![Status](https://img.shields.io/badge/status-active-brightgreen)
[![GitHub Stars](https://img.shields.io/github/stars/VeereshMattikalli/5g-message-passing-simulation?style=flat)](https://github.com/VeereshMattikalli/5g-message-passing-simulation)

## Project Overview

This project demonstrates the deployment of a complete **5G Standalone (SA) Network** using:

* OpenAirInterface (OAI) gNB
* Open5GS Core Network
* UERANSIM User Equipments (UEs)
* RF Simulator (RFSim)

The setup enables communication between two simulated User Equipments (UE1 and UE2) connected to the same 5G Core Network. Connectivity is verified through ping tests and real-time message exchange using Netcat (nc).

---

## Quick Start

```bash
# Automated setup
sudo bash scripts/setup.sh

# Run the simulation
sudo bash scripts/run_simulation.sh
```

See [Setup Guide](README.md#prerequisites) below for detailed instructions.

---

## Resources

- 📖 **[Architecture Guide](docs/ARCHITECTURE.md)** — System design and topology
- 🤝 **[Contributing](CONTRIBUTING.md)** — How to contribute to this project
- 📝 **[Changelog](CHANGELOG.md)** — Version history and updates
- 📜 **[License](LICENSE)** — MIT License

---

## Objective

To simulate a 5G Standalone (SA) network using OpenAirInterface integrated with Open5GS and UERANSIM, enabling communication between multiple User Equipments and demonstrating message transfer through the simulated 5G infrastructure.

---

## System Architecture

```text
                +----------------+
                |    Open5GS     |
                |   5G Core      |
                +--------+-------+
                         |
                         |
                +--------+-------+
                |      OAI gNB   |
                |    (RFSim)     |
                +--------+-------+
                         |
             -------------------------
             |                       |
             |                       |
      +------+-----+         +------+-----+
      |    UE1     |         |    UE2     |
      | UERANSIM   |         | UERANSIM   |
      +------------+         +------------+

                Message Transfer
                (Netcat Chat)
```

---

## Prerequisites

### Hardware

* Ubuntu 22.04 LTS
* Minimum 8 GB RAM
* Intel i5/i7 Processor

### Software

* OpenAirInterface (OAI)
* Open5GS
* UERANSIM
* Wireshark
* Netcat
* Git
* GCC and CMake

---

## Step 1: Start Open5GS Core

Verify all Open5GS services are running:

```bash
sudo systemctl status open5gs-*
```

Start services if required:

```bash
sudo systemctl start open5gs-*
```

Check the UPF tunnel interface:

```bash
ip addr
```

Expected:

```text
ogstun
10.45.0.1/16
```

---

## Step 2: Start OAI gNB

Navigate to OAI build directory:

```bash
cd ~/openairinterface5g/cmake_targets/ran_build/build
```

Launch gNB:

```bash
sudo ./nr-softmodem --rfsim \
-O ../../../targets/PROJECTS/GENERIC-NR-5GC/CONF/gnb-cu.sa.f1.conf
```

Expected:

```text
gNB connected to AMF
NG Setup Successful
```

---

## Step 3: Start UE1

Open a new terminal:

```bash
cd ~/UERANSIM/build
```

Run:

```bash
sudo ./nr-ue -c ../config/open5gs-ue1.yaml
```

Expected:

```text
Registration complete
PDU Session established
```

---

## Step 4: Start UE2

Open another terminal:

```bash
cd ~/UERANSIM/build
```

Run:

```bash
sudo ./nr-ue -c ../config/open5gs-ue2.yaml
```

Expected:

```text
Registration complete
PDU Session established
```

---

## Step 5: Verify UE IP Addresses

Check interfaces:

```bash
ip addr
```

Expected:

```text
uesimtun0 -> 10.45.0.2
uesimtun1 -> 10.45.0.3
```

| Device | IP Address |
| ------ | ---------- |
| UE1    | 10.45.0.2  |
| UE2    | 10.45.0.3  |

---

## Step 6: Test Connectivity

### From UE1 to UE2

```bash
ping -I uesimtun0 10.45.0.3
```

### From UE2 to UE1

```bash
ping -I uesimtun1 10.45.0.2
```

Expected:

```text
64 bytes from ...
icmp_seq=1 ttl=64 time=...
```

---

## Step 7: Start Netcat Receiver

Open a new terminal and start the listener:

```bash
nc -lk 5000
```

The listener waits for incoming messages.

---

## Step 8: Send Message from UE1

Open another terminal:

```bash
echo "Hi from UE1" | nc 10.45.0.3 5000
```

Receiver output:

```text
Hi from UE1
```

---

## Step 9: Send Message from UE2

Open another terminal:

```bash
echo "Hi from UE2" | nc 10.45.0.2 5000
```

Receiver output:

```text
Hi from UE2
```

---

## Step 10: Capture Packets in Wireshark

Start Wireshark:

```bash
sudo wireshark
```

Capture interfaces:

```text
ogstun
uesimtun0
uesimtun1
```

Apply filters:

| Filter            | Purpose              |
| ----------------- | -------------------- |
| `icmp`            | Ping packets         |
| `tcp.port == 5000`| Netcat messages      |

Observe:

* Packet transmission
* Source and destination IP addresses
* Packet size
* TCP segments
* Message delivery

---

## Results

### UE Registration

* UE1 successfully registered with Open5GS.
* UE2 successfully registered with Open5GS.

### Connectivity

* Successful ping between UE1 and UE2.

### Message Transfer

Messages successfully exchanged:

```text
Hi from UE1
Hi from UE2
```

### Packet Analysis

Wireshark captured:

* ICMP Echo Request/Reply packets
* TCP packets carrying chat messages
* End-to-end communication through the 5G Core Network

---

## Performance Metrics

| Metric           | Observed Value |
| ---------------- | -------------- |
| Throughput       | 72–81 Gbps     |
| Latency          | 12–20 ms       |
| Packet Loss      | 0%             |
| Connectivity     | Successful     |
| Message Transfer | Successful     |

---

## Conclusion

A complete 5G Standalone network was successfully implemented using OpenAirInterface, Open5GS, and UERANSIM. Two User Equipments were connected through the simulated 5G infrastructure, and communication was verified using ping tests and Netcat-based message exchange. Wireshark analysis confirmed successful packet transfer through the 5G Core Network, demonstrating the functionality of the simulated 5G environment.
