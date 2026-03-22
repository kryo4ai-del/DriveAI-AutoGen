#!/bin/bash
echo "=== Mac Build Agent Setup ==="

# Check Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "ERROR: Xcode not installed. Install from App Store."
    exit 1
fi
echo "Xcode: $(xcodebuild -version | head -1)"

# Check xcodegen
if ! command -v xcodegen &> /dev/null; then
    echo "Installing xcodegen..."
    brew install xcodegen
fi
echo "xcodegen: $(xcodegen --version 2>/dev/null || echo 'installed')"

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 not installed."
    exit 1
fi
echo "Python: $(python3 --version)"

echo ""
echo "Setup complete. Start the agent:"
echo "  python3 mac_agent/mac_build_agent.py"
