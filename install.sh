#!/bin/bash
#
# Homelab Dotfiles Installer
#
# Usage:
#   ./install.sh           # Interactive installation
#   ./install.sh --all     # Install everything
#   ./install.sh --minimal # Install only essential scripts
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}           ${BOLD}🏠 Homelab Dotfiles Installer${NC}                     ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

#=============================================================================
# Helper Functions
#=============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

ask_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    
    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n] "
    else
        prompt="$prompt [y/N] "
    fi
    
    read -p "$prompt" -n 1 -r
    echo ""
    
    if [[ -z "$REPLY" ]]; then
        REPLY="$default"
    fi
    
    [[ $REPLY =~ ^[Yy]$ ]]
}

backup_file() {
    local file="$1"
    if [[ -f "$file" && ! -L "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$file" "$backup"
        log_info "Backed up $file to $backup"
    fi
}

#=============================================================================
# Check Dependencies
#=============================================================================

check_dependencies() {
    log_info "Checking dependencies..."
    
    local missing=()
    
    # Required
    command -v bash >/dev/null || missing+=("bash")
    command -v nmap >/dev/null || missing+=("nmap")
    command -v python3 >/dev/null || missing+=("python3")
    command -v curl >/dev/null || missing+=("curl")
    command -v docker >/dev/null || missing+=("docker")
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_warning "Missing required dependencies: ${missing[*]}"
        echo ""
        echo "Install with:"
        echo "  sudo apt update && sudo apt install -y ${missing[*]}"
        echo ""
        
        if ! ask_yes_no "Continue anyway?"; then
            exit 1
        fi
    else
        log_success "All required dependencies found"
    fi
    
    # Optional
    local optional_missing=()
    command -v avahi-resolve >/dev/null || optional_missing+=("avahi-utils")
    command -v nmblookup >/dev/null || optional_missing+=("samba-common-bin")
    
    if [[ ${#optional_missing[@]} -gt 0 ]]; then
        log_info "Optional packages for better hostname resolution: ${optional_missing[*]}"
    fi
}

#=============================================================================
# Install Functions
#=============================================================================

install_bash_config() {
    log_info "Installing bash configuration..."
    
    # Backup existing files
    backup_file "$HOME/.bashrc"
    backup_file "$HOME/.bash_aliases"
    backup_file "$HOME/.profile"
    
    # Option 1: Replace entirely
    # cp "$SCRIPT_DIR/bash/bashrc" "$HOME/.bashrc"
    
    # Option 2: Append to existing (safer)
    if ! grep -q "# Homelab dotfiles" "$HOME/.bashrc" 2>/dev/null; then
        echo "" >> "$HOME/.bashrc"
        echo "# Homelab dotfiles" >> "$HOME/.bashrc"
        echo "source \"$SCRIPT_DIR/bash/bashrc\"" >> "$HOME/.bashrc"
        log_success "Added bashrc source to ~/.bashrc"
    else
        log_warning "Homelab bashrc already sourced in ~/.bashrc"
    fi
    
    # Copy aliases
    cp "$SCRIPT_DIR/bash/bash_aliases" "$HOME/.bash_aliases"
    log_success "Installed ~/.bash_aliases"
}

install_bin_scripts() {
    log_info "Installing bin scripts..."
    
    # Create directories
    mkdir -p "$HOME/bin/config"
    mkdir -p "$HOME/.local/share/network-scan"
    
    # Copy scripts
    cp "$SCRIPT_DIR/bin/network-scan" "$HOME/bin/"
    cp "$SCRIPT_DIR/bin/network-scan-daemon" "$HOME/bin/"
    cp "$SCRIPT_DIR/bin/voo-router-api" "$HOME/bin/"
    cp "$SCRIPT_DIR/bin/voo-router-sync" "$HOME/bin/"
    
    # Make executable
    chmod +x "$HOME/bin/network-scan"
    chmod +x "$HOME/bin/network-scan-daemon"
    chmod +x "$HOME/bin/voo-router-api"
    chmod +x "$HOME/bin/voo-router-sync"
    
    # Create symlinks
    ln -sf "$HOME/bin/network-scan" "$HOME/bin/scan"
    ln -sf "$HOME/bin/voo-router-sync" "$HOME/bin/voorouter"
    
    log_success "Installed scripts to ~/bin/"
    
    # Copy config template if no config exists
    if [[ ! -f "$HOME/bin/config/router.conf" ]]; then
        cp "$SCRIPT_DIR/bin/config/router.conf.example" "$HOME/bin/config/router.conf"
        log_warning "Created ~/bin/config/router.conf - please edit with your credentials!"
    else
        log_info "Router config already exists, skipping"
    fi
}

install_g3_config() {
    log_info "Installing G3 AI assistant configuration..."
    
    mkdir -p "$HOME/.config/g3"
    
    if [[ ! -f "$HOME/.config/g3/config.toml" ]]; then
        cp "$SCRIPT_DIR/config/g3/config.toml.example" "$HOME/.config/g3/config.toml"
        log_warning "Created ~/.config/g3/config.toml - please edit with your API keys!"
    else
        log_info "G3 config already exists, skipping"
    fi
}

install_cron_jobs() {
    log_info "Setting up cron jobs..."
    
    if ask_yes_no "Install cron jobs for automatic scanning?"; then
        bash "$SCRIPT_DIR/scripts/setup-cron.sh"
    else
        log_info "Skipping cron setup. Run scripts/setup-cron.sh later if needed."
    fi
}

install_systemd_timers() {
    log_info "Setting up systemd timers (alternative to cron)..."
    
    mkdir -p "$HOME/.config/systemd/user"
    
    cp "$SCRIPT_DIR/systemd/network-scan.service" "$HOME/.config/systemd/user/"
    cp "$SCRIPT_DIR/systemd/network-scan.timer" "$HOME/.config/systemd/user/"
    
    log_success "Copied systemd units to ~/.config/systemd/user/"
    log_info "To enable: systemctl --user enable --now network-scan.timer"
}

install_seclab() {
    log_info "Setting up cybersecurity training lab..."
    
    # Create symlink to seclab script
    ln -sf "$SCRIPT_DIR/docker/cybersecurity/seclab.sh" "$HOME/bin/seclab"
    
    log_success "Installed seclab command to ~/bin/seclab"
    
    echo ""
    echo -e "${YELLOW}Cybersecurity Lab includes:${NC}"
    echo "  • DVWA - Damn Vulnerable Web Application"
    echo "  • OWASP Juice Shop - Modern web app security"
    echo "  • crAPI - API security testing"
    echo ""
    echo "Start with: seclab start"
    echo "Or start individual apps: seclab start dvwa"
    echo ""
    log_warning "These apps are INTENTIONALLY VULNERABLE - never expose to internet!"
    
    # Offer to pull images now
    if command -v docker >/dev/null 2>&1; then
        echo ""
        if ask_yes_no "Pull Docker images now? (saves time on first start, ~2GB download)" "n"; then
            log_info "Pulling Docker images (this may take a while)..."
            cd "$SCRIPT_DIR/docker/cybersecurity"
            docker compose pull
            log_success "Docker images pulled successfully"
        fi
    fi
}

#=============================================================================
# Main Installation
#=============================================================================

main() {
    local mode="${1:-interactive}"
    
    case "$mode" in
        --all)
            check_dependencies
            install_bash_config
            install_bin_scripts
            install_g3_config
            install_systemd_timers
            install_seclab
            install_cron_jobs
            ;;
        --minimal)
            check_dependencies
            install_bin_scripts
            ;;
        *)
            # Interactive mode
            check_dependencies
            echo ""
            
            if ask_yes_no "Install bash configuration?" "y"; then
                install_bash_config
            fi
            echo ""
            
            if ask_yes_no "Install network scanning scripts?" "y"; then
                install_bin_scripts
            fi
            echo ""
            
            if ask_yes_no "Install G3 AI assistant config?" "n"; then
                install_g3_config
            fi
            echo ""
            
            if ask_yes_no "Install systemd timer units?" "n"; then
                install_systemd_timers
            fi
            echo ""
            
            if ask_yes_no "Install cybersecurity training lab?" "y"; then
                install_seclab
            fi
            echo ""
            
            if ask_yes_no "Setup cron jobs?" "y"; then
                install_cron_jobs
            fi
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}              ${BOLD}✓ Installation Complete!${NC}                       ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Edit ~/bin/config/router.conf with your router credentials"
    echo "  2. Run 'source ~/.bashrc' to reload shell configuration"
    echo "  3. Run 'scan --live' to test the network scanner"
    echo "  4. Run 'seclab start' to launch the cybersecurity lab"
    echo ""
    echo "For help: scan --help"
    echo ""
}

main "$@"
