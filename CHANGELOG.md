# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-06-07

### Added
- Initial project release with 5G Standalone network simulation
- Support for OpenAirInterface (OAI) gNB integration
- Open5GS 5G Core Network connectivity
- UERANSIM User Equipment (UE) simulation
- RF Simulator (RFSim) for virtual radio interface
- Dual UE registration and connectivity testing
- Netcat-based message passing between UEs
- Comprehensive documentation and setup guides
- Configuration examples for Open5GS and UERANSIM
- Network packet capture analysis with Wireshark

### Features
- 5G-SA network topology with OAI, Open5GS, and UERANSIM
- UE registration to 5G Core Network
- PDU session establishment
- IP address assignment (10.45.0.x range)
- ICMP connectivity testing (ping)
- TCP message transfer using Netcat
- Performance metrics (throughput, latency, packet loss)

### Documentation
- Detailed README with step-by-step setup instructions
- System architecture diagrams
- Configuration guides
- Troubleshooting tips
- Performance analysis results

## [Unreleased]

### Planned
- Multi-UE simultaneous communication
- Application traffic simulation
- Quality of Service (QoS) testing
- Mobility scenarios
- Handover procedures
- 4G/5G interworking
- CI/CD pipeline with GitHub Actions
- Automated testing framework

---

For upgrade instructions, see [README.md](README.md).
