#!/bin/bash

# Test Checkov configuration for CloudMart project
echo "🛡️ Testing Checkov configuration..."

# Install checkov if not present
if ! command -v checkov &> /dev/null; then
    echo "Installing Checkov..."
    pip install checkov
fi

# Run Checkov with new configuration
echo "Running Checkov scan with updated configuration..."
checkov -d terraform/ \
    --framework terraform \
    --config-file .checkov.yml \
    --compact \
    --soft-fail \
    --output cli

echo "✅ Checkov scan completed!"
echo "Check the output above for remaining violations."
echo "The configuration should significantly reduce the number of failed checks."
