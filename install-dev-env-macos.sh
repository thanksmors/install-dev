#!/bin/bash
#
# macOS Development Environment Installer
# Installs: Python, Node.js, Git, Gemini CLI, and cc-mirror
#
# Usage: ./install-dev-env-macos.sh
#
# Requirements: macOS, internet connection
# Assumes: Nothing installed (full environment setup)
#

set -e

LOG_FILE="$HOME/dev-env-install.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1"; echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $1" >> "$LOG_FILE"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARN: $1" >> "$LOG_FILE"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >> "$LOG_FILE"; exit 1; }

echo "=== macOS Dev Environment Install - $(date) ===" > "$LOG_FILE"

# ============ Pre-flight Checks ============
check_macos() {
    log "Checking OS..."
    if [[ "$(uname)" != "Darwin" ]]; then
        error "This script is for macOS only. Detected: $(uname)"
    fi
    success "macOS confirmed ($(sw_vers -productVersion))"
}

# ============ Homebrew ============
install_homebrew() {
    log "Checking Homebrew..."
    if command -v brew &> /dev/null; then
        success "Homebrew already installed: $(brew --version | head -n1)"
        log "Updating Homebrew..."
        brew update >> "$LOG_FILE" 2>&1 || true
    else
        log "Installing Homebrew (this may take a while)..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Add to PATH for Apple Silicon
        if [[ -f "/opt/homebrew/bin/brew" ]] && [[ ":$PATH:" != *":/opt/homebrew/bin:"* ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        success "Homebrew installed"
    fi
}

# ============ Core Tools ============
install_core_tools() {
    log "Installing Python, Node.js, Git..."
    brew install python node git >> "$LOG_FILE" 2>&1
    success "Core tools installed"
}

verify_core_tools() {
    log "Verifying installations..."
    for cmd in python3 node git; do
        if command -v "$cmd" &> /dev/null; then
            local version=$($cmd --version 2>&1 | head -n1)
            success "$cmd: $version"
        else
            warn "$cmd not found (try restarting terminal)"
        fi
    done
    if command -v pip3 &> /dev/null; then
        success "pip3: $(pip3 --version)"
    fi
    if command -v npm &> /dev/null; then
        success "npm: $(npm --version)"
    fi
}

# ============ Gemini CLI ============
install_gemini_cli() {
    log "Installing Gemini CLI..."
    if command -v gemini &> /dev/null; then
        warn "Gemini CLI already installed"
    else
        npm install -g @google/gemini-cli >> "$LOG_FILE" 2>&1
        if command -v gemini &> /dev/null; then
            success "Gemini CLI installed"
        else
            error "Gemini CLI installation failed"
        fi
    fi
}

# ============ cc-mirror (Minimax) ============
install_cc_mirror() {
    log "Installing cc-mirror (Minimax variant)..."
    echo ""
    echo -e "${YELLOW}=== cc-mirror (Minimax) ===${NC}"
    echo "Reference: https://github.com/numman-ali/cc-mirror"
    echo ""

    if [ -n "$MINIMAX_API_KEY" ]; then
        log "MINIMAX_API_KEY found in environment"
        npx cc-mirror quick --provider minimax --api-key "$MINIMAX_API_KEY" >> "$LOG_FILE" 2>&1 || warn "cc-mirror setup had issues"
    else
        echo "To configure cc-mirror with Minimax:"
        echo "  1. Get your Minimax API key"
        echo "  2. Run: export MINIMAX_API_KEY='your-key-here'"
        echo "  3. Run: npx cc-mirror quick --provider minimax --api-key \"\$MINIMAX_API_KEY\""
        echo ""
        echo "Or run interactively: npx cc-mirror"
    fi
}

# ============ Summary ============
show_summary() {
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  macOS Installation Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Installed:"
    echo "  • Python (via Homebrew)"
    echo "  • Node.js (via Homebrew)"
    echo "  • Git (via Homebrew)"
    echo "  • Gemini CLI (via npm)"
    echo "  • cc-mirror (via npx)"
    echo ""
    echo "Log: $LOG_FILE"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  1. Restart terminal"
    echo "  2. Configure cc-mirror with Minimax API key"
    echo ""
    echo "cc-mirror Quick Start:"
    echo "  export MINIMAX_API_KEY='your-minimax-key'"
    echo "  npx cc-mirror quick --provider minimax --api-key \"\$MINIMAX_API_KEY\""
    echo ""
}

# ============ Main ============
main() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  macOS Development Environment Setup${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo "Will install:"
    echo "  • Python"
    echo "  • Node.js"
    echo "  • Git"
    echo "  • Gemini CLI"
    echo "  • cc-mirror"
    echo ""

    check_macos
    install_homebrew
    install_core_tools
    verify_core_tools
    install_gemini_cli
    install_cc_mirror
    show_summary
}

main "$@"
