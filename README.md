# remove-safeq-wework

Removes the **YSoft SafeQ Client** (the "WeWork Print" add-on that WeWork and many offices and schools install on macOS) completely: the root daemon, the login agent, the app, the CUPS port-monitor backend, the print queue, and all leftover files.

**한국어:** 위워크(WeWork) 등 사무실·학교에서 설치해주는 **YSoft SafeQ 프린터 클라이언트**를 맥에서 완전히 지우는 스크립트입니다. root 데몬, 로그인 에이전트, 앱, CUPS 백엔드, 프린터 큐, 남은 파일까지 모두 삭제합니다.

## Why

SafeQ installs more than a printer. After one "WeWork Print" setup your Mac is left with:

| Piece | Where |
|---|---|
| Root daemon `safeqclientcore`, started at boot | `/Library/LaunchDaemons/com.ysoft.safeqclientcore.plist`, `/Library/safeqclientcore/` |
| Login agent `safeqclient` | `/Library/LaunchAgents/com.ysoft.safeqclient.plist`, `/Applications/safeqclient.app` |
| A 100 MB CUPS backend `hcpportmon` | `/usr/libexec/cups/backend/hcpportmon` |
| CUPS filter `hcpflatten` (older versions) | `/usr/libexec/cups/filter/hcpflatten` |
| The `WeWork_Print` queue routed through `hcpportmon://` | CUPS |
| Preference and support files | `/Library/Preferences`, `~/Library/Preferences`, `~/Library/Application Support/safeqclient` |

The vendor ships an uninstall script inside the app, but it runs with root's `$HOME`, so it misses the per-user files, and it does not remove the print queue or the backend.

## Usage

```bash
curl -fsSL https://raw.githubusercontent.com/wonmor/remove-safeq-wework/main/remove-safeq.sh | sudo bash
```

Or clone and read it first (it is 40 lines):

```bash
git clone https://github.com/wonmor/remove-safeq-wework.git
sudo bash remove-safeq-wework/remove-safeq.sh
```

The script:

1. Stops the daemon and the login agent with `launchctl bootout`, then kills leftovers.
2. Deletes any CUPS print queue whose PPD or device URI references SafeQ or `hcpportmon` (so your own printers are untouched).
3. Removes every file in the table above and forgets the package receipts.
4. Verifies and prints `All clean.` or lists what remains.

Needs `sudo`. Tested on macOS 26 (Apple Silicon) with SafeQ Client 3.x.

## Reinstalling later

Your office's SafeQ portal will give you the installer again when you need it. Nothing here blocks reinstalling.

## License

MIT
