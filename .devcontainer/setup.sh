#!/usr/bin/env bash
set -euo pipefail

echo "[devcontainer] Installing Quarto..."
QUARTO_VERSION="1.6.40"
curl -sSL "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb" -o /tmp/quarto.deb
dpkg -i /tmp/quarto.deb
rm /tmp/quarto.deb
quarto check --no-prompt 2>&1 | head -5

echo "[devcontainer] Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

echo "[devcontainer] Setup complete."
