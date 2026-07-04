#!/bin/bash
# run_translation.sh
# Script to install and run LibreTranslate locally

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VENV_DIR="$DIR/libretranslate_venv"

if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment for LibreTranslate..."
    python3 -m venv "$VENV_DIR"
fi

source "$VENV_DIR/bin/activate"

echo "Checking dependencies..."
pip install --upgrade pip
pip install libretranslate

echo "Starting LibreTranslate server on port 5000..."
echo "It may take some time to download language models on the first run."
libretranslate --host 0.0.0.0 --port 5000
