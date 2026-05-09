#!/bin/bash
set -e

export PATH="/home/hermes/.local/bin:$PATH"

CONFIG_DIR="$HOME/.hermes"

if [ ! -d "$CONFIG_DIR" ] || [ -z "$(ls -A $CONFIG_DIR 2>/dev/null)" ]; then
    echo "============================================================"
    echo "  Hermes is not configured yet."
    echo ""
    echo "  To set it up, connect to this container and run:"
    echo "    hermes setup"
    echo ""
    echo "  Then restart the container to start the gateway."
    echo "============================================================"
    exec sleep infinity
else
    echo "Hermes config found -- starting gateway..."
    exec hermes gateway start
fi