#!/bin/bash
# Run this once after 'tailscale up' to lock SSH to Tailscale only.
# Usage: sudo lockdown-ssh
#
# Note: Uses userspace networking mode - restricts by Tailscale IP, not interface.

set -e

TAILSCALE_IP=$(tailscale ip -4 2>/dev/null)
if [ -z "$TAILSCALE_IP" ]; then
  echo "ERROR: Tailscale is not connected. Run 'tailscale up --netfilter-mode=off' first."
  exit 1
fi

echo "Tailscale IP: $TAILSCALE_IP"
echo "Locking down SSH to Tailscale IP range only..."

ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow from 100.64.0.0/10 to any port 22
ufw --force enable

echo "Done. SSH is now only accessible via Tailscale (100.x.x.x addresses)."
echo "Connect with: ssh hermes@$TAILSCALE_IP"
