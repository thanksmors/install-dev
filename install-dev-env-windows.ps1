# Windows Development Environment Installer
# Installs: Python, Node.js, Git, Gemini CLI, and cc-mirror
#
# Usage: .\install-dev-env-windows.ps1
#
# Requirements: Windows 10/11, internet connection, admin rights
# Assumes: Nothing installed (full environment setup)
#

$ErrorActionPreference = "Stop"

$LOG_FILE = "$env:USERPROFILE\dev-env-install.log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Host $logEntry
    Add-Content -Path $LOG_FILE -Value $logEntry
}

function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# ============ Pre-flight ============
function Check-Windows {
    Write-Log "Checking OS..."
    if ($env:OS -ne "Windows_NT") {
        throw "This script is for Windows only."
    }
    $version = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuild
    Write-Log "Windows detected (Build $version)"
}

function Check-Admin {
    Write-Log "Checking admin rights..."
    if (-not (Test-Admin)) {
        Write-Log "WARNING: Not running as Administrator. Some installs may fail." "WARN"
        Write-Log "Run PowerShell as Administrator for best results." "WARN"
    } else {
        Write-Log "Admin rights confirmed"
    }
}

# ============ Winget ============
function Check-Winget {
    Write-Log "Checking Winget..."
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if ($winget) {
        Write-Log "Winget found: $($winget.Version)"
        try {
            winget --version | Out-Null
            Write-Log "Winget is functional"
        } catch {
            throw "Winget is installed but not functional. Update Windows Store apps."
        }
    } else {
        Write-Log "Winget not found. Installing..."
        $appInstaller = Get-AppxPackage -Name "Microsoft.DesktopAppInstaller" -ErrorAction SilentlyContinue
        if (-not $appInstaller) {
            Write-Log "Installing App Installer (Winget prerequisite)..."
            Start-Process "ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1"
            Write-Log "Please install 'App Installer' from Microsoft Store, then restart this script." "WARN"
            throw "App Installer required. Install from Microsoft Store and retry."
        } else {
            Write-Log "App Installer found, version $($appInstaller.Version)"
        }
    }
}

# ============ Core Tools ============
function Install-CoreTools {
    Write-Log "Installing Python, Node.js, Git via Winget..."
    $apps = @(
        "Python.Python.3.12",
        "OpenJS.NodeJS.LTS",
        "Git.Git"
    )

    foreach ($app in $apps) {
        Write-Log "Installing $app..."
        try {
            winget install --id $app --accept-source-agreements --accept-package-agreements --silent 2>&1 | Out-Null
            Write-Log "Installed $app"
        } catch {
            Write-Log "Failed to install $app. Try installing manually." "WARN"
        }
    }
}

function Verify-CoreTools {
    Write-Log "Verifying installations..."
    $tools = @{
        "python" = "python --version"
        "node" = "node --version"
        "git" = "git --version"
        "pip" = "pip --version"
        "npm" = "npm --version"
    }

    foreach ($tool in $tools.Keys) {
        $cmd = Get-Command $tool -ErrorAction SilentlyContinue
        if ($cmd) {
            try {
                $version = Invoke-Expression $tools[$tool] 2>&1 | Select-Object -First 1
                Write-Log "$tool : $version"
            } catch {
                Write-Log "$tool : found but version check failed" "WARN"
            }
        } else {
            Write-Log "$tool : not found in PATH (restart PowerShell)" "WARN"
        }
    }
}

# ============ Gemini CLI ============
function Install-GeminiCLI {
    Write-Log "Installing Gemini CLI via npm..."
    if (Get-Command gemini -ErrorAction SilentlyContinue) {
        Write-Log "Gemini CLI already installed"
    } else {
        try {
            npm install -g @google/gemini-cli 2>&1 | Out-Null
            if (Get-Command gemini -ErrorAction SilentlyContinue) {
                Write-Log "Gemini CLI installed"
            } else {
                Write-Log "Gemini CLI install may have failed. Check npm output." "WARN"
            }
        } catch {
            Write-Log "Failed to install Gemini CLI: $_" "WARN"
        }
    }
}

# ============ cc-mirror (Minimax) ============
function Install-CcMirror {
    Write-Log "Installing cc-mirror (Minimax variant)..."
    Write-Host ""
    Write-Host "=== cc-mirror (Minimax) ===" -ForegroundColor Yellow
    Write-Host "Reference: https://github.com/numman-ali/cc-mirror"
    Write-Host ""

    $minimaxKey = $env:MINIMAX_API_KEY
    if ($minimaxKey) {
        Write-Log "MINIMAX_API_KEY found in environment"
        try {
            npx cc-mirror quick --provider minimax --api-key $minimaxKey 2>&1 | Out-Null
        } catch {
            Write-Log "cc-mirror setup had issues" "WARN"
        }
    } else {
        Write-Host "To configure cc-mirror with Minimax:"
        Write-Host "  1. Get your Minimax API key"
        Write-Host '  2. Run: $env:MINIMAX_API_KEY = "your-key-here"'
        Write-Host '  3. Run: npx cc-mirror quick --provider minimax --api-key $env:MINIMAX_API_KEY'
        Write-Host ""
        Write-Host "Or run interactively: npx cc-mirror"
    }
}

# ============ Refresh Environment ============
function Refresh-Environment {
    Write-Log "Refreshing environment variables..."
    Write-Host ""
    Write-Host "IMPORTANT: Restart PowerShell/terminal to update PATH." -ForegroundColor Yellow
}

# ============ Summary ============
function Show-Summary {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  Windows Installation Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Installed:"
    Write-Host "  - Python (via Winget)"
    Write-Host "  - Node.js (via Winget)"
    Write-Host "  - Git (via Winget)"
    Write-Host "  - Gemini CLI (via npm)"
    Write-Host "  - cc-mirror (via npx)"
    Write-Host ""
    Write-Host "Log: $LOG_FILE"
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Restart PowerShell/terminal"
    Write-Host "  2. Configure cc-mirror with Minimax API key"
    Write-Host ""
    Write-Host "cc-mirror Quick Start:"
    Write-Host '  $env:MINIMAX_API_KEY = "your-minimax-key"'
    Write-Host '  npx cc-mirror quick --provider minimax --api-key $env:MINIMAX_API_KEY'
    Write-Host ""
}

# ============ Main ============
function Main {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host "  Windows Development Environment Setup" -ForegroundColor Blue
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host ""
    Write-Host "Will install:"
    Write-Host "  - Python"
    Write-Host "  - Node.js"
    Write-Host "  - Git"
    Write-Host "  - Gemini CLI"
    Write-Host "  - cc-mirror"
    Write-Host ""

    "=== Windows Dev Environment Install - $(Get-Date) ===" | Set-Content -Path $LOG_FILE

    try {
        Check-Windows
        Check-Admin
        Check-Winget
        Install-CoreTools
        Verify-CoreTools
        Install-GeminiCLI
        Install-CcMirror
        Refresh-Environment
        Show-Summary
    } catch {
        Write-Log "FATAL: $_" "ERROR"
        Write-Host ""
        Write-Host "Installation failed: $_" -ForegroundColor Red
        Write-Host "Check log: $LOG_FILE"
        exit 1
    }
}

Main
