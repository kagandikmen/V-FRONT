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

    # Install Sail
    mkdir -p $HOME/.bin/
    curl --location https://github.com/riscv/sail-riscv/releases/download/0.13.1/sail-riscv-Linux-$(arch).tar.gz | tar xvz --directory=$HOME/.local --strip-components=1

elif [[ "$OS" == "Darwin" ]]; then
    # Check for Homebrew, install if missing
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Update and install packages
    brew update
    brew install npm icarus-verilog gawk z3 aisk/homebrew-tap/timeout

    Z3_LIB_DIR="$(brew --prefix z3)/lib"
    Z3_DYLIB="$(find "$Z3_LIB_DIR" -maxdepth 1 -name 'libz3*.dylib' -print -quit)"

    if [[ -z "$Z3_DYLIB" ]]; then
        echo "Homebrew Z3 dynamic library not found in $Z3_LIB_DIR"
        exit 1
    fi

    ln -sf "$Z3_DYLIB" "$Z3_LIB_DIR/libz3"

    echo "Using Z3 library: $Z3_DYLIB"
    echo "DYLD_LIBRARY_PATH=$Z3_LIB_DIR" >> $GITHUB_ENV

    # Install Sail
    mkdir -p $HOME/.bin/
    curl --location https://github.com/riscv/sail-riscv/releases/download/0.13.1/sail-riscv-Mac-$(arch).tar.gz | tar xvz --directory=$HOME/.local --strip-components=1

else
    echo "Unsupported OS: $OS"
    exit 1
fi

# Install xpm globally using npm
npm install --global xpm@latest

# Install mise
curl https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"
echo "$HOME/.local/bin/" >> $GITHUB_PATH

cd "$GITHUB_WORKSPACE/ut/riscv-arch-test"
mise trust .mise.toml
mise install
mise reshim
echo "$HOME/.local/share/mise/shims" >> "$GITHUB_PATH"

echo "Setup complete."
