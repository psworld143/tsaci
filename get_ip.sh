#!/bin/bash
#
# Get Local IP Address for TSACI Mobile Configuration
# This script helps you find your machine's IP address to configure mobile devices
#

echo "========================================="
echo "TSACI - Get IP Address for Mobile Setup"
echo "========================================="
echo ""

echo "🔍 Detecting your local IP addresses..."
echo ""

# macOS and Linux
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Platform: macOS"
    echo ""
    
    # Get IP from active network interface
    IP=$(ipconfig getifaddr en0)
    if [ -z "$IP" ]; then
        IP=$(ipconfig getifaddr en1)
    fi
    
    if [ -n "$IP" ]; then
        echo "✅ Your IP Address: $IP"
        echo ""
        echo "📱 Configuration Steps:"
        echo "1. Edit: lib/core/constants/api_constants.dart"
        echo "2. Find the line with 'return 'http://localhost/tsaci/backend';'"
        echo "3. Replace with: return 'http://$IP/tsaci/backend';"
        echo ""
        echo "🌐 Test in mobile browser: http://$IP/tsaci/backend"
    else
        echo "⚠️  Could not detect IP automatically"
        echo ""
        echo "Run: ifconfig | grep 'inet '"
        echo "Look for IP like 192.168.x.x or 10.0.x.x"
    fi
    
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Platform: Linux"
    echo ""
    
    # Try different methods to get IP
    IP=$(hostname -I | awk '{print $1}')
    
    if [ -z "$IP" ]; then
        IP=$(ip addr show | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -n1)
    fi
    
    if [ -n "$IP" ]; then
        echo "✅ Your IP Address: $IP"
        echo ""
        echo "📱 Configuration Steps:"
        echo "1. Edit: lib/core/constants/api_constants.dart"
        echo "2. Find the line with 'return 'http://localhost/tsaci/backend';'"
        echo "3. Replace with: return 'http://$IP/tsaci/backend';"
        echo ""
        echo "🌐 Test in mobile browser: http://$IP/tsaci/backend"
    else
        echo "⚠️  Could not detect IP automatically"
        echo ""
        echo "Run: ip addr show"
        echo "Look for IP like 192.168.x.x or 10.0.x.x"
    fi
else
    echo "Platform: Unknown"
    echo ""
    echo "Please run one of these commands:"
    echo "  - macOS: ipconfig getifaddr en0"
    echo "  - Linux: hostname -I"
    echo "  - Or check your network settings"
fi

echo ""
echo "========================================="
echo "📖 For more details, see: API_CONFIGURATION.md"
echo "========================================="
echo ""

