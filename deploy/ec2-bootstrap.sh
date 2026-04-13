#!/usr/bin/env bash
set -euo pipefail

# One-time server setup for Ubuntu EC2
# Usage:
#   bash deploy/ec2-bootstrap.sh /home/ubuntu/careerbridge

APP_DIR="${1:-$HOME/careerbridge}"

echo "[1/7] Updating apt package index"
sudo apt-get update -y

echo "[2/7] Installing base packages"
sudo apt-get install -y ca-certificates curl gnupg git

echo "[3/7] Installing Docker"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "[4/7] Enabling Docker service"
sudo systemctl enable docker
sudo systemctl start docker

echo "[5/7] Adding current user to docker group"
sudo usermod -aG docker "$USER"

echo "[6/7] Preparing app directory"
mkdir -p "$APP_DIR"

if [ ! -d "$APP_DIR/.git" ]; then
  echo "Repository not found at $APP_DIR"
  echo "Clone your repository first, for example:"
  echo "  git clone https://github.com/Rohit9525/JobPortal.git $APP_DIR"
fi

echo "[7/7] Bootstrap complete"
echo "IMPORTANT: Re-login to the server so docker group changes apply."
echo "The GitHub Actions deploy job writes $APP_DIR/.env automatically from repository secrets."
echo "For manual deploys, create $APP_DIR/.env or pass an equivalent env file to docker compose."
