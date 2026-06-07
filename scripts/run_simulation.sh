#!/bin/bash

# 5G Message Passing Simulation - Runtime Script
# This script starts all components and manages the simulation

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
REPO_PATH="${REPO_PATH:-.}"
BUILD_PATH="$REPO_PATH/build"
CONFIG_PATH="$REPO_PATH/config"
LOG_DIR="./logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create logs directory
mkdir -p "$LOG_DIR"

echo -e "${GREEN}=========================================="
echo "5G Simulation Runtime Manager"
echo "==========================================${NC}"

# Check if running with sudo
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root (use sudo)${NC}"
   exit 1
fi

# Function: Start Open5GS services
start_open5gs() {
    echo -e "${BLUE}Starting Open5GS services...${NC}"
    
    systemctl status open5gs-amfd >/dev/null 2>&1 || {
        echo "Starting AMF..."
        systemctl start open5gs-amfd
    }
    
    systemctl status open5gs-smfd >/dev/null 2>&1 || {
        echo "Starting SMF..."
        systemctl start open5gs-smfd
    }
    
    systemctl status open5gs-upfd >/dev/null 2>&1 || {
        echo "Starting UPF..."
        systemctl start open5gs-upfd
    }
    
    echo -e "${GREEN}Open5GS services started${NC}"
    sleep 2
}

# Function: Start gNB
start_gnb() {
    echo -e "${BLUE}Starting OAI gNB...${NC}"
    
    if [ ! -f "$BUILD_PATH/nr-gnb" ]; then
        echo -e "${RED}Error: nr-gnb not found at $BUILD_PATH${NC}"
        return 1
    fi
    
    $BUILD_PATH/nr-gnb -c $CONFIG_PATH/open5gs-gnb.yaml > "$LOG_DIR/gnb_$TIMESTAMP.log" 2>&1 &
    GNB_PID=$!
    echo -e "${GREEN}gNB started (PID: $GNB_PID)${NC}"
    sleep 3
}

# Function: Start UE1
start_ue1() {
    echo -e "${BLUE}Starting UE1...${NC}"
    
    if [ ! -f "$BUILD_PATH/nr-ue" ]; then
        echo -e "${RED}Error: nr-ue not found at $BUILD_PATH${NC}"
        return 1
    fi
    
    $BUILD_PATH/nr-ue -c $CONFIG_PATH/open5gs-ue.yaml > "$LOG_DIR/ue1_$TIMESTAMP.log" 2>&1 &
    UE1_PID=$!
    echo -e "${GREEN}UE1 started (PID: $UE1_PID)${NC}"
    sleep 2
}

# Function: Start UE2
start_ue2() {
    echo -e "${BLUE}Starting UE2...${NC}"
    
    if [ ! -f "$BUILD_PATH/nr-ue" ]; then
        echo -e "${RED}Error: nr-ue not found at $BUILD_PATH${NC}"
        return 1
    fi
    
    $BUILD_PATH/nr-ue -c $CONFIG_PATH/open5gs-ue2.yaml > "$LOG_DIR/ue2_$TIMESTAMP.log" 2>&1 &
    UE2_PID=$!
    echo -e "${GREEN}UE2 started (PID: $UE2_PID)${NC}"
    sleep 2
}

# Function: Verify connectivity
verify_connectivity() {
    echo -e "${BLUE}Verifying connectivity...${NC}"
    
    # Check UE interfaces
    if ip link show uesimtun0 >/dev/null 2>&1; then
        echo -e "${GREEN}✓ UE1 interface (uesimtun0) found${NC}"
    else
        echo -e "${RED}✗ UE1 interface not found${NC}"
    fi
    
    if ip link show uesimtun1 >/dev/null 2>&1; then
        echo -e "${GREEN}✓ UE2 interface (uesimtun1) found${NC}"
    else
        echo -e "${RED}✗ UE2 interface not found${NC}"
    fi
    
    # Test ping
    echo -e "${BLUE}Testing connectivity (UE1 → UE2)...${NC}"
    if ping -I uesimtun0 -c 1 10.45.0.3 >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Ping successful${NC}"
    else
        echo -e "${YELLOW}⚠ Ping failed (this may be normal if UEs are still registering)${NC}"
    fi
}

# Function: Show status
show_status() {
    echo -e "${BLUE}System Status:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    echo -e "${YELLOW}IP Addresses:${NC}"
    ip addr show ogstun 2>/dev/null | grep "inet " | awk '{print "UPF (ogstun): " $2}' || echo "UPF: not available"
    ip addr show uesimtun0 2>/dev/null | grep "inet " | awk '{print "UE1 (uesimtun0): " $2}' || echo "UE1: not available"
    ip addr show uesimtun1 2>/dev/null | grep "inet " | awk '{print "UE2 (uesimtun1): " $2}' || echo "UE2: not available"
    
    echo -e "${YELLOW}Open5GS Services:${NC}"
    systemctl is-active open5gs-amfd >/dev/null 2>&1 && echo "✓ AMF running" || echo "✗ AMF stopped"
    systemctl is-active open5gs-smfd >/dev/null 2>&1 && echo "✓ SMF running" || echo "✗ SMF stopped"
    systemctl is-active open5gs-upfd >/dev/null 2>&1 && echo "✓ UPF running" || echo "✗ UPF stopped"
    
    echo -e "${YELLOW}Logs:${NC}"
    echo "Log files saved in: $LOG_DIR"
}

# Function: Cleanup
cleanup() {
    echo -e "${YELLOW}Cleaning up...${NC}"
    kill $GNB_PID 2>/dev/null || true
    kill $UE1_PID 2>/dev/null || true
    kill $UE2_PID 2>/dev/null || true
    echo -e "${GREEN}Cleanup complete${NC}"
}

# Trap SIGINT and SIGTERM for graceful shutdown
trap cleanup SIGINT SIGTERM

# Main execution
echo -e "${BLUE}Phase 1: Starting infrastructure${NC}"
start_open5gs

echo -e "${BLUE}Phase 2: Starting RAN and UEs${NC}"
start_gnb
start_ue1
start_ue2

sleep 5

echo -e "${BLUE}Phase 3: Verification${NC}"
verify_connectivity

show_status

echo -e "${GREEN}=========================================="
echo "Simulation is running!"
echo "==========================================${NC}"
echo ""
echo "Available commands:"
echo "  • Test connectivity: ping -I uesimtun0 10.45.0.3"
echo "  • Send message: echo 'Hi' | nc 10.45.0.3 5000"
echo "  • Monitor traffic: sudo tcpdump -i ogstun -n"
echo "  • View logs: tail -f $LOG_DIR/*.log"
echo ""
echo "Press Ctrl+C to stop the simulation"
echo ""

# Keep script running
wait
