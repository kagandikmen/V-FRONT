#!/bin/bash

set -e

# Detect OS
OS="$(uname)"
echo "Detected OS: $OS"

if [[ "$OS" == "Linux" ]]; then
    # Update and install packages for Debian-based systems
    sudo apt-get update
    sudo apt-get install -y \
        npm autoconf automake autotools-dev curl python3 python3-pip \
        libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison \
        flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev \
        ninja-build git cmake libglib2.0-dev libslirp-dev

    sudo apt install -y iverilog

elif [[ "$OS" == "Darwin" ]]; then
    # Check for Homebrew, install if missing
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Update and install packages
    brew update
    brew install npm icarus-verilog

else
    echo "Unsupported OS: $OS"
    exit 1
fi

# Install xpm globally using npm
npm install --global xpm@latest

echo "Setup complete."
