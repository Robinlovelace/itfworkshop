#!/usr/bin/env bash
set -euo pipefail

echo "[devcontainer] Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

echo "[devcontainer] Setup complete."
