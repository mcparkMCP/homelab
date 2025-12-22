#!/bin/bash
#
# seclab.sh - Cybersecurity Lab Management Script
#
# Usage:
#   seclab start [all|dvwa|juice|crapi]  - Start services
#   seclab stop                          - Stop all services
#   seclab status                        - Show status
#   seclab logs [service]                - View logs
#   seclab reset                         - Reset all data
#   seclab urls                          - Show access URLs
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
cd "$SCRIPT_DIR"

show_banner() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}          ${BOLD}🔐 Cybersecurity Training Lab${NC}                     ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
}

show_urls() {
    echo ""
    echo -e "${BOLD}📍 Access URLs:${NC}"
    echo -e "  ${GREEN}DVWA${NC}:        http://localhost:8081  (admin/password)"
    echo -e "  ${GREEN}Juice Shop${NC}:  http://localhost:8082"
    echo -e "  ${GREEN}crAPI${NC}:       http://localhost:8083"
    echo -e "  ${GREEN}MailHog${NC}:     http://localhost:8025  (crAPI emails)"
    echo ""
}

show_warning() {
    echo ""
    echo -e "${RED}${BOLD}⚠️  WARNING: These apps are INTENTIONALLY VULNERABLE!${NC}"
    echo -e "${RED}   Never expose to the internet. Use for learning only.${NC}"
    echo ""
}

start_services() {
    local target="${1:-all}"
    
    show_banner
    show_warning
    
    case "$target" in
        all)
            echo -e "${BLUE}[*]${NC} Starting all services..."
            docker compose up -d
            ;;
        dvwa)
            echo -e "${BLUE}[*]${NC} Starting DVWA..."
            docker compose up -d dvwa dvwa-db
            ;;
        juice|juiceshop|juice-shop)
            echo -e "${BLUE}[*]${NC} Starting Juice Shop..."
            docker compose up -d juice-shop
            ;;
        crapi)
            echo -e "${BLUE}[*]${NC} Starting crAPI..."
            docker compose up -d crapi-web crapi-identity crapi-community crapi-workshop crapi-postgres crapi-mongodb crapi-mailhog
            ;;
        *)
            echo -e "${RED}Unknown target: $target${NC}"
            echo "Options: all, dvwa, juice, crapi"
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}[✓]${NC} Services starting..."
    
    # Wait a moment for services to initialize
    sleep 3
    
    show_urls
    
    echo -e "${YELLOW}Tip:${NC} Run 'seclab status' to check if all services are healthy"
}

stop_services() {
    show_banner
    echo ""
    echo -e "${BLUE}[*]${NC} Stopping all services..."
    docker compose down
    echo -e "${GREEN}[✓]${NC} All services stopped"
}

show_status() {
    show_banner
    echo ""
    echo -e "${BOLD}📊 Service Status:${NC}"
    echo ""
    docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
    show_urls
}

show_logs() {
    local service="${1:-}"
    
    if [[ -n "$service" ]]; then
        docker compose logs -f "$service"
    else
        docker compose logs -f
    fi
}

reset_lab() {
    show_banner
    echo ""
    echo -e "${YELLOW}This will delete all data and reset the lab to initial state.${NC}"
    read -p "Are you sure? [y/N] " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}[*]${NC} Stopping services and removing data..."
        docker compose down -v
        echo -e "${GREEN}[✓]${NC} Lab reset complete"
        echo ""
        echo "Run 'seclab start' to start fresh"
    else
        echo "Cancelled"
    fi
}

show_help() {
    show_banner
    echo ""
    echo -e "${BOLD}Usage:${NC} seclab <command> [options]"
    echo ""
    echo -e "${BOLD}Commands:${NC}"
    echo "  start [target]   Start services (all, dvwa, juice, crapi)"
    echo "  stop             Stop all services"
    echo "  status           Show service status"
    echo "  logs [service]   View logs (all or specific service)"
    echo "  reset            Reset lab (delete all data)"
    echo "  urls             Show access URLs"
    echo "  help             Show this help"
    echo ""
    echo -e "${BOLD}Examples:${NC}"
    echo "  seclab start           # Start all services"
    echo "  seclab start dvwa      # Start only DVWA"
    echo "  seclab logs juice-shop # View Juice Shop logs"
    echo "  seclab reset           # Reset everything"
    echo ""
}

# Main
case "${1:-help}" in
    start)
        start_services "${2:-all}"
        ;;
    stop)
        stop_services
        ;;
    status|ps)
        show_status
        ;;
    logs|log)
        show_logs "${2:-}"
        ;;
    reset|clean)
        reset_lab
        ;;
    urls|url)
        show_banner
        show_urls
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        show_help
        exit 1
        ;;
esac
