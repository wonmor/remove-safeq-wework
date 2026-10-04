#!/bin/bash
# Removes YSoft SafeQ Client. Run with: sudo bash ~/remove-safeq.sh
set -u
if [ "$(id -u)" -ne 0 ]; then echo "Run this with sudo."; exit 1; fi
U=${SUDO_USER:-johnseong}; HOMEDIR=$(eval echo "~$U"); UIDN=$(id -u "$U")
echo "== 1. Stopping"
launchctl bootout system/com.ysoft.safeqclientcore >/dev/null 2>&1 && echo "   stopped com.ysoft.safeqclientcore"
launchctl bootout "gui/$UIDN/com.ysoft.safeqclient" >/dev/null 2>&1 && echo "   stopped com.ysoft.safeqclient"
pkill -f 'safeqclient' 2>/dev/null; sleep 1
echo "== 2. Print queues that use the SafeQ driver"
for q in $(lpstat -p 2>/dev/null | awk '/^printer/{print $2}'); do
  if grep -qil 'safeq\|ysoft\|hcp' "/etc/cups/ppd/$q.ppd" 2>/dev/null || lpstat -v "$q" 2>/dev/null | grep -qi 'safeq\|ysoft\|hcpportmon'; then
    lpadmin -x "$q" && echo "   removed print queue $q"
  fi
done
echo "== 3. Removing files"
PATHS=(
  "/Applications/safeqclient.app"
  "/Library/LaunchAgents/com.ysoft.safeqclient.plist"
  "/Library/LaunchDaemons/com.ysoft.safeqclientcore.plist"
  "/Library/Preferences/com.ysoft.safeqclient.plist"
  "/Library/safeqclientcore"
  "/usr/libexec/cups/filter/hcpflatten"
  "/usr/libexec/cups/backend/hcpportmon"
  "$HOMEDIR/Library/Application Support/safeqclient"
  "$HOMEDIR/Library/Preferences/com.ysoft.safeqclient.plist"
  "$HOMEDIR/Library/Caches/com.ysoft.safeqclient"
  "$HOMEDIR/Library/Logs/safeqclient"
)
for p in "${PATHS[@]}"; do { [ -e "$p" ] || [ -L "$p" ]; } && rm -rf "$p" && echo "   removed $p"; done
for pkg in $(pkgutil --pkgs 2>/dev/null | grep -iE 'safeq|ysoft'); do pkgutil --forget "$pkg" >/dev/null 2>&1 && echo "   forgot $pkg"; done
echo "== 4. Verification"
LEFT=0
for p in "${PATHS[@]}"; do { [ -e "$p" ] || [ -L "$p" ]; } && { echo "   STILL PRESENT: $p"; LEFT=1; }; done
ps -axo comm | grep -qi safeq && { echo "   process still running"; LEFT=1; }
[ $LEFT -eq 0 ] && echo "   All clean." || echo "   Some items remain."
