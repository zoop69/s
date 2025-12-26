#!/usr/bin/env bash
set -e

LOG_FILE="$HOME/.tailscale-start.log"
MARKER_FILE="$HOME/.tailscale-started"

echo "========================================" | tee -a "$LOG_FILE"
echo "🚀 Tailscale startup script RUNNING" | tee -a "$LOG_FILE"
echo "🕒 Time: $(date)" | tee -a "$LOG_FILE"
echo "👤 User: $(whoami)" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"

# Create a marker file (easy visual proof)
touch "$MARKER_FILE"

# Install Tailscale if missing
if ! command -v tailscale >/dev/null 2>&1; then
  echo "📦 Installing Tailscale..." | tee -a "$LOG_FILE"
  curl -fsSL https://tailscale.com/install.sh | sh
else
  echo "✅ Tailscale already installed" | tee -a "$LOG_FILE"
fi

# Start daemon if not already running
if ! pgrep -x tailscaled >/dev/null; then
  echo "🚀 Starting tailscaled (userspace networking)..." | tee -a "$LOG_FILE"
  sudo tailscaled --tun=userspace-networking >>"$LOG_FILE" 2>&1 &
  sleep 2
else
  echo "✅ tailscaled already running" | tee -a "$LOG_FILE"
fi

# Bring Tailscale up
echo "🔐 Bringing Tailscale up..." | tee -a "$LOG_FILE"
sudo tailscale up --accept-dns --accept-routes >>"$LOG_FILE" 2>&1 || true

echo "✅ Tailscale startup COMPLETE" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
