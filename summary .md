# Security Lab 01: Failed Login Investigation

This lab simulates a basic log analysis to detect failed SSH login attempts.

### 🧰 Tools Used:
- grep
- awk
- sort
- uniq
- nmap (for host checking)

### 🧾 Findings:
- No brute-force activity detected.
- 192.168.1.23 is unreachable.
- 10.0.0.55 shows filtered ports (possible legitimate host).

### 🛡️ Recommendations:
1. Use fail2ban or sshguard.
2. Prefer SSH key authentication.
3. Monitor logs regularly.