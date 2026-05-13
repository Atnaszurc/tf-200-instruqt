#!/bin/bash
# Network Discovery Script
# Helps discover existing libvirt networks for import

echo "=== Libvirt Network Discovery ==="
echo ""
echo "Discovering all libvirt networks..."
echo ""

# List all networks
virsh net-list --all | tail -n +3 | while read -r line; do
  if [ -n "$line" ]; then
    name=$(echo "$line" | awk '{print $1}')
    if [ -n "$name" ] && [ "$name" != "Name" ]; then
      uuid=$(virsh net-uuid "$name" 2>/dev/null || echo "N/A")
      state=$(echo "$line" | awk '{print $2}')
      autostart=$(echo "$line" | awk '{print $3}')
      
      echo "Network: $name"
      echo "  UUID: $uuid"
      echo "  State: $state"
      echo "  Autostart: $autostart"
      
      # Get network details
      if [ "$uuid" != "N/A" ]; then
        bridge=$(virsh net-info "$name" 2>/dev/null | grep "Bridge:" | awk '{print $2}')
        echo "  Bridge: $bridge"
        
        # Get IP configuration
        ip_info=$(virsh net-dumpxml "$name" 2>/dev/null | grep -A 1 "<ip " | grep "address=" | sed 's/.*address="\([^"]*\)".*/\1/')
        if [ -n "$ip_info" ]; then
          echo "  IP Address: $ip_info"
        fi
      fi
      
      echo ""
    fi
  fi
done

echo "=== Import Command Examples ==="
echo ""
echo "To import a network into Terraform:"
echo "  1. Get the UUID: UUID=\$(virsh net-uuid <network-name>)"
echo "  2. Import: terraform import libvirt_network.<resource-name> \"\$UUID\""
echo ""
echo "Example:"
echo "  UUID=\$(virsh net-uuid legacy-network)"
echo "  terraform import libvirt_network.legacy \"\$UUID\""
echo ""

# Made with Bob
