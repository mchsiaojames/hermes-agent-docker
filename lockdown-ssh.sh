#!/bin/bash
# Run this once after 'tailscale up' to lock SSH to Tailscale only.
# Usage: sudo lockdown-ssh

set -e

TAILSCALE_IP=$(tailscale ip -4 2>/dev/null)
if [ -z "$TAILSCALE_IP" ]; then
  echo "ERROR: Tailscale is not connected. Run 'tailscale up' first."
  exit 1
fi

echo "Tailscale IP: $TAILSCALE_IP"
echo "Locking down SSH to Tailscale interface only..."

ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow in on tailscale0 to any port 22
ufw --force enable

echo "Done. SSH is now only accessible via Tailscale."
echo "Connect with: ssh hermes@$TAILSCALE_IP"
