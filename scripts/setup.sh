#!/bin/bash

# 5G Message Passing Simulation - Setup Script
# This script automates the installation and setup of the 5G simulation environment

set -e  # Exit on error

echo "=========================================="
echo "5G Simulation Environment Setup"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if running with sudo
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root (use sudo)${NC}"
   exit 1
fi

# Update system
echo -e "${BLUE}[1/5] Updating system packages...${NC}"
apt-get update
apt-get upgrade -y

# Install dependencies
echo -e "${BLUE}[2/5] Installing dependencies...${NC}"
apt-get install -y \
    git \
    cmake \
    build-essential \
    libboost-all-dev \
    curl \
    wget \
    wireshark \
    netcat \
    net-tools \
    iproute2 \
    tcpdump

# Create necessary directories
echo -e "${BLUE}[3/5] Creating simulation directories...${NC}"
mkdir -p ~/5g-simulation/{configs,logs,results}
cd ~/5g-simulation

# Clone UERANSIM if not already present
if [ ! -d "UERANSIM" ]; then
    echo -e "${BLUE}[4/5] Cloning UERANSIM repository...${NC}"
    git clone https://github.com/aligungr/UERANSIM.git
else
    echo -e "${YELLOW}UERANSIM already exists, skipping clone${NC}"
fi

# Build UERANSIM
echo -e "${BLUE}[5/5] Building UERANSIM...${NC}"
cd UERANSIM
mkdir -p build
cd build
cmake ..
make -j$(nproc)

echo -e "${GREEN}=========================================="
echo "Setup Complete!"
echo "==========================================${NC}"
echo ""
echo "Next steps:"
echo "1. Start Open5GS services:"
echo "   sudo systemctl start open5gs-amfd"
echo "   sudo systemctl start open5gs-smfd"
echo "   sudo systemctl start open5gs-upfd"
echo ""
echo "2. Start the simulation:"
echo "   bash ~/5g-message-passing-simulation/scripts/run_simulation.sh"
echo ""
echo "For detailed instructions, see README.md"
