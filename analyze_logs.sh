#!/usr/bin/env bash
# analyze_logs.sh — SSH brute-force detector by Noctyr (improved)
# Usage:
#   ./analyze_logs.sh [path_to_auth.log] [threshold]
# Example:
#   ./analyze_logs.sh /home/hunter/huntops/security/auth.log 3
#   or: ./analyze_logs.sh             # uses default path and threshold=5

# default log path and threshold
DEFAULT_LOG="${HOME}/huntops/security/auth.log"
THRESHOLD_DEFAULT=5

# pick args
if [[ -n "$1" ]]; then
  LOG="$1"
else
  LOG="$DEFAULT_LOG"
fi

if [[ -n "$2" ]]; then
  THRESHOLD="$2"
else
  THRESHOLD="$THRESHOLD_DEFAULT"
fi

if [[ ! -f "$LOG" ]]; then
  echo "[!] Log file not found: $LOG"
  exit 1
fi

OUTDIR="${HOME}/security-tools"
mkdir -p "$OUTDIR"
cd "$OUTDIR" || exit 1

echo "[+] Analyzing failed SSH logins in: $LOG"
sleep 1

# extract list of failed IPs and users
grep -i "Failed password" "$LOG" | sed -E 's/.* from ([0-9.]+).*/\1/' | sort | uniq -c | sort -rn > failed_ips.txt
grep -i "Failed password" "$LOG" | sed -E 's/.*for (invalid user )?([A-Za-z0-9._-]+) from.*/\2/' | sort | uniq -c | sort -rn > failed_users.txt

# write CSVs
awk '{print $1","$2}' failed_ips.txt > ip_summary.csv
awk '{print $1","$2}' failed_users.txt > user_summary.csv

# build human-readable report
REPORT="report.txt"
echo "Security Report - $(date)" > "$REPORT"
echo "---" >> "$REPORT"
echo "Top IPs:" >> "$REPORT"
head -20 failed_ips.txt >> "$REPORT"
echo -e "\nTop Users:" >> "$REPORT"
head -20 failed_users.txt >> "$REPORT"

# suspicious threshold section
echo -e "\nSuspicious IPs (threshold >= ${THRESHOLD} attempts):" >> "$REPORT"
awk -v t="$THRESHOLD" '$1 >= t { printf("%d attempts - %s\n",$1,$2) }' failed_ips.txt >> "$REPORT"

# final notes
echo -e "\n[✓] Report saved to $(pwd)/$REPORT"
echo -e "[✓] CSVs: ip_summary.csv, user_summary.csv"

