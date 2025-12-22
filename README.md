# Homelab

A collection of tools for monitoring and managing my home network.

## Phone Presence Monitor

Monitors device presence on the network using the VOO router API and sends Telegram notifications.

**Features:**
- Auto-discovers all devices from router
- Logs arrivals/departures to CSV for statistics
- Sends Telegram notifications for specified devices
- **Router control** - block/unblock sites and kick devices
- Runs as a systemd service

**Telegram Bot Commands:**
- `/status`, `/stats`, `/today`, `/week` - Presence monitoring
- `/block <site>`, `/unblock <site>`, `/blocklist` - Site blocking
- `/kick <device>`, `/allow <device>`, `/banned` - Device control
- `/devices`, `/help` - Info commands

**Location:** `phone-presence-monitor/`

## MOTD Tools

Network scanning and router management tools for SSH login and command-line use.

### router
**Local CLI for router management** - works offline!
```bash
router devices          # List devices from router
router kick <name>      # Block device from network
router allow <name>     # Unblock device
router block <site>     # Block website
router banned           # Show blocked devices/sites
```

### network-scan
Scans the local network and displays connected devices with custom names.
```bash
scan                    # Quick summary
scan -v                 # Verbose details
scan --live             # Fresh scan
```

### dns-traffic
Analyze DNS queries per device to see what domains they're accessing.
```bash
dns-traffic capture     # Live capture
dns-traffic analyze     # Analyze saved capture
```

**Location:** `motd-tools/`

## Cybersecurity Training Lab

Three intentionally vulnerable applications for learning security testing:

| App | URL | Focus |
|-----|-----|-------|
| **DVWA** | http://localhost:8081 | Classic web vulnerabilities (SQLi, XSS, etc.) |
| **Juice Shop** | http://localhost:8082 | Modern web app security (100+ challenges) |
| **crAPI** | http://localhost:8083 | API security (OWASP API Top 10) |

## Dotfiles

Managed with chezmoi. Includes zsh config, git config, aliases, tool-versions, and mac settings.

## Router Compatibility

Tested with **VOO Technicolor routers** using PBKDF2 authentication.

## License

MIT
