#!/bin/bash
# Run this once after 'tailscale up --netfilter-mode=off' to lock SSH to Tailscale only.
# Usage: sudo lockdown-ssh
#
# Works inside Docker by binding sshd to the Tailscale IP only (no iptables needed).

set -e

TAILSCALE_IP=$(tailscale ip -4 2>/dev/null)
if [ -z "$TAILSCALE_IP" ]; then
  echo "ERROR: Tailscale is not connected. Run 'tailscale up --netfilter-mode=off' first."
  exit 1
fi

echo "Tailscale IP: $TAILSCALE_IP"

# Check if already locked down
if grep -q "ListenAddress" /etc/ssh/sshd_config; then
  echo "SSH is already restricted. Updating to current Tailscale IP..."
  sed -i "/ListenAddress/d" /etc/ssh/sshd_config
fi

echo "ListenAddress $TAILSCALE_IP" >> /etc/ssh/sshd_config

# Restart sshd to apply the change
supervisorctl restart sshd

echo "Done. SSH now only accepts connections on $TAILSCALE_IP"
echo "Connect with: ssh hermes@$TAILSCALE_IP"
