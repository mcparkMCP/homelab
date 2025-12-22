# 🔐 Cybersecurity Training Lab

This Docker Compose setup provides three intentionally vulnerable web applications for learning and practicing cybersecurity skills.

## ⚠️ WARNING

**These applications are INTENTIONALLY VULNERABLE!**

- Never expose these to the internet
- Only run in isolated environments
- Use for educational purposes only
- Disconnect from sensitive networks when running

## Applications

### 1. DVWA - Damn Vulnerable Web Application
- **URL**: http://localhost:8081
- **Default Login**: `admin` / `password`
- **Focus**: Classic web vulnerabilities
- **Challenges**:
  - SQL Injection
  - XSS (Reflected, Stored, DOM)
  - CSRF
  - File Inclusion
  - File Upload
  - Command Injection
  - Brute Force
  - Weak Session IDs

### 2. OWASP Juice Shop
- **URL**: http://localhost:8082
- **Focus**: Modern web app security (100+ challenges)
- **Challenges**:
  - OWASP Top 10 (2021)
  - Injection attacks
  - Broken Authentication
  - Sensitive Data Exposure
  - XXE
  - Broken Access Control
  - Security Misconfiguration
  - XSS
  - Insecure Deserialization
  - Using Components with Known Vulnerabilities
  - Insufficient Logging & Monitoring

### 3. crAPI - Completely Ridiculous API
- **URL**: http://localhost:8083
- **MailHog**: http://localhost:8025 (view emails)
- **Focus**: API Security
- **Challenges**:
  - OWASP API Security Top 10
  - Broken Object Level Authorization (BOLA)
  - Broken User Authentication
  - Excessive Data Exposure
  - Lack of Resources & Rate Limiting
  - Broken Function Level Authorization
  - Mass Assignment
  - Security Misconfiguration
  - Injection
  - Improper Assets Management
  - Insufficient Logging & Monitoring

## Quick Start

```bash
# Start all services
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f

# Stop all services
docker compose down

# Stop and remove all data
docker compose down -v
```

## Individual Services

```bash
# Start only DVWA
docker compose up -d dvwa dvwa-db

# Start only Juice Shop
docker compose up -d juice-shop

# Start only crAPI
docker compose up -d crapi-web crapi-identity crapi-community crapi-workshop crapi-postgres crapi-mongodb crapi-mailhog
```

## Resource Requirements

| Service | RAM | CPU |
|---------|-----|-----|
| DVWA + DB | ~256MB | Low |
| Juice Shop | ~512MB | Medium |
| crAPI (full) | ~1.5GB | Medium |
| **Total** | **~2.5GB** | Medium |

## DVWA Setup

After starting DVWA:

1. Go to http://localhost:8081
2. Login with `admin` / `password`
3. Click "Create / Reset Database"
4. Re-login
5. Go to "DVWA Security" to set difficulty level:
   - **Low**: No security, learn the basics
   - **Medium**: Some protection, bypass it
   - **High**: Strong protection, advanced techniques
   - **Impossible**: Secure code (for comparison)

## Juice Shop Tips

- Access the scoreboard: http://localhost:8082/#/score-board
- Challenges are hidden - explore the app!
- Use browser DevTools (F12) to find clues
- Check the Network tab for API calls
- Look at JavaScript source code

## crAPI Tips

- Register a new account to start
- Check MailHog (port 8025) for verification emails
- Use Postman or Burp Suite to test APIs
- Look for IDOR vulnerabilities
- Test rate limiting on sensitive endpoints

## Recommended Tools

### Browser Extensions
- FoxyProxy (proxy switching)
- Wappalyzer (technology detection)
- Cookie Editor

### Proxy Tools
- **Burp Suite Community** - Web security testing
- **OWASP ZAP** - Free alternative to Burp
- **mitmproxy** - CLI proxy tool

### CLI Tools
```bash
# Install common tools
sudo apt install -y \
    nmap \
    nikto \
    sqlmap \
    dirb \
    gobuster \
    hydra \
    john \
    hashcat \
    curl \
    jq
```

### API Testing
- **Postman** - API client
- **Insomnia** - REST client
- **httpie** - CLI HTTP client

## Learning Resources

### DVWA
- [DVWA GitHub](https://github.com/digininja/DVWA)
- [DVWA Solutions](https://github.com/mrudnitsky/dvwa-guide-2019)

### Juice Shop
- [Juice Shop GitHub](https://github.com/juice-shop/juice-shop)
- [Pwning OWASP Juice Shop (free book)](https://pwning.owasp-juice.shop/)
- [Juice Shop CTF Extension](https://github.com/juice-shop/juice-shop-ctf)

### crAPI
- [crAPI GitHub](https://github.com/OWASP/crAPI)
- [crAPI Solutions](https://github.com/OWASP/crAPI/blob/main/docs/challengeSolutions.md)
- [OWASP API Security Top 10](https://owasp.org/www-project-api-security/)

### General
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [PortSwigger Web Security Academy](https://portswigger.net/web-security)
- [HackTheBox](https://www.hackthebox.com/)
- [TryHackMe](https://tryhackme.com/)

## Troubleshooting

### Services won't start
```bash
# Check logs
docker compose logs <service-name>

# Restart specific service
docker compose restart <service-name>

# Rebuild containers
docker compose up -d --force-recreate
```

### Port conflicts
Edit `docker-compose.yml` and change the port mappings:
```yaml
ports:
  - "9081:80"  # Change 8081 to 9081
```

### Out of memory
```bash
# Run only one app at a time
docker compose down
docker compose up -d juice-shop  # Just Juice Shop
```

### Reset to clean state
```bash
# Remove all data and start fresh
docker compose down -v
docker compose up -d
```

## Network Isolation

For extra security, run in an isolated Docker network:

```bash
# The compose file already creates an isolated network
# Containers can only communicate within 'cybersec-lab' network
```

For maximum isolation, use a VM or separate machine.

## License

- DVWA: GPL v3
- Juice Shop: MIT
- crAPI: Apache 2.0

## Auto-Start on Boot (Optional)

If you want the lab to start automatically when your machine boots:

```bash
# Copy the systemd service
cp ~/dotfiles/systemd/seclab.service ~/.config/systemd/user/

# Reload systemd
systemctl --user daemon-reload

# Enable auto-start
systemctl --user enable seclab.service

# Start now
systemctl --user start seclab.service
```

⚠️ **Warning**: Only enable auto-start on isolated machines!
These are vulnerable applications and should not run on machines connected to untrusted networks.
