# dev-env-script

One-command installer for development tools on macOS and Windows.

## What it installs

| Tool | macOS | Windows |
|------|-------|---------|
| Python | Homebrew | Winget |
| Node.js (LTS) | Homebrew | Winget |
| Git | Homebrew | Winget |
| Gemini CLI | npm | npm |
| cc-mirror | npx | npx |

## macOS

```bash
./install-dev-env-macos.sh
```

Requires: macOS, internet connection

## Windows

```powershell
# Open PowerShell as Administrator
.\install-dev-env-windows.ps1
```

Requires: Windows 10/11, internet connection, Winget (included in Windows 11, or install App Installer from Microsoft Store for Windows 10)

## What happens

1. Installs package manager (Homebrew/Winget) if missing
2. Installs Python, Node.js, Git
3. Installs Gemini CLI via npm
4. Installs cc-mirror via npx
5. Logs everything to `~/dev-env-install.log`

## After install

1. Restart your terminal
2. Set your Minimax API key as environment variable
3. Run cc-mirror quick start command

## Minimax API Key Setup

**macOS/Linux:**
```bash
export MINIMAX_API_KEY='your-minimax-key'
npx cc-mirror quick --provider minimax --api-key "$MINIMAX_API_KEY"
```

**Windows (PowerShell):**
```powershell
$env:MINIMAX_API_KEY = "your-minimax-key"
npx cc-mirror quick --provider minimax --api-key $env:MINIMAX_API_KEY
```

**Or run interactively:**
```bash
npx cc-mirror
```

## API Keys

- **Minimax**: Get from your Minimax dashboard
- **Gemini CLI**: Uses its own configuration (`gemini api-key set`)

## Uninstall

Manual removal:

**macOS:**
```bash
brew uninstall python node git
npm uninstall -g @google/gemini-cli
```

**Windows:**
```powershell
winget uninstall Python.Python.3.12 OpenJS.NodeJS.LTS Git.Git
npm uninstall -g @google/gemini-cli
```
