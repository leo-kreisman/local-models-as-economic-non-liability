<# : batch launcher
@echo off
setlocal
title OpenCode + Ollama Cloud Setup

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$scriptContent = [System.IO.File]::ReadAllText('%~f0'); Invoke-Expression $scriptContent"
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Setup encountered an issue.
)
echo.
echo Press any key to exit...
pause >nul
exit /b %ERRORLEVEL%
#>

# =========================================================================
# PowerShell Setup Script: OpenCode + Ollama Cloud Models
# =========================================================================

$ErrorActionPreference = "Stop"
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]'Tls12,Tls13'
} catch {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "       OpenCode + Ollama Cloud Setup for Windows         " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# -------------------------------------------------------------------------
# Step 1: Prompt & Register OLLAMA_API_KEY
# -------------------------------------------------------------------------
Write-Host "[1/4] Configuring OLLAMA_API_KEY..." -ForegroundColor Yellow

$ApiKey = $env:OLLAMA_API_KEY
if ($ApiKey) {
    $masked = $ApiKey.Substring(0, [Math]::Min(6, $ApiKey.Length)) + "..."
    $useExisting = Read-Host "Found existing OLLAMA_API_KEY ($masked). Use this? (Y/n)"
    if ($useExisting -match '^[nN]') {
        $ApiKey = $null
    }
}

while (-not $ApiKey) {
    $ApiKey = Read-Host "Enter your OLLAMA_API_KEY"
    if (-not $ApiKey) {
        Write-Host "API key cannot be empty. Please enter a valid key." -ForegroundColor Red
    }
}

$ApiKey = $ApiKey.Trim()

# Set in current session
$env:OLLAMA_API_KEY = $ApiKey

# Set permanently in Windows User Environment Variables
[System.Environment]::SetEnvironmentVariable("OLLAMA_API_KEY", $ApiKey, [System.EnvironmentVariableTarget]::User)
Write-Host "  -> OLLAMA_API_KEY successfully registered in User Environment Variables." -ForegroundColor Green


# -------------------------------------------------------------------------
# Step 2: Install OpenCode CLI
# -------------------------------------------------------------------------
Write-Host ""
Write-Host "[2/4] Checking OpenCode CLI installation..." -ForegroundColor Yellow

$opencodeCmd = Get-Command "opencode" -ErrorAction SilentlyContinue

if ($opencodeCmd) {
    Write-Host "  -> OpenCode is already installed at: $($opencodeCmd.Source)" -ForegroundColor Green
} else {
    Write-Host "  -> OpenCode not found in PATH. Proceeding with installation..." -ForegroundColor Cyan

    $installed = $false

    # Option A: Check if npm is available
    $npmCmd = Get-Command "npm" -ErrorAction SilentlyContinue
    if ($npmCmd) {
        Write-Host "  -> npm found. Installing opencode-ai globally via npm..." -ForegroundColor Cyan
        try {
            cmd.exe /c "npm install -g opencode-ai"
            $installed = $true
            Write-Host "  -> Successfully installed opencode-ai via npm!" -ForegroundColor Green
        } catch {
            Write-Warning "npm install failed. Falling back to standalone binary download..."
        }
    }

    # Option B: Download standalone binary if npm not present or failed
    if (-not $installed) {
        Write-Host "  -> Downloading official standalone OpenCode binary from GitHub..." -ForegroundColor Cyan
        $installDir = Join-Path $env:LOCALAPPDATA "Programs\opencode"
        if (-not (Test-Path $installDir)) {
            New-Item -ItemType Directory -Path $installDir -Force | Out-Null
        }

        $zipPath = Join-Path $env:TEMP "opencode-windows-x64.zip"
        $downloadUrl = "https://github.com/anomalyco/opencode/releases/latest/download/opencode-windows-x64.zip"

        Write-Host "  -> Downloading: $downloadUrl" -ForegroundColor Gray
        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing

        Write-Host "  -> Extracting archive to $installDir..." -ForegroundColor Gray
        Expand-Archive -Path $zipPath -DestinationPath $installDir -Force
        Remove-Item -Path $zipPath -Force -ErrorAction SilentlyContinue

        # Add to User PATH if not already there
        $userPath = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User)
        if ($userPath -notlike "*$installDir*") {
            $newUserPath = "$installDir;" + $userPath.TrimEnd(';')
            [System.Environment]::SetEnvironmentVariable("PATH", $newUserPath, [System.EnvironmentVariableTarget]::User)
            Write-Host "  -> Added $installDir to User PATH." -ForegroundColor Green
        }

        # Add to current process PATH
        $env:PATH = "$installDir;" + $env:PATH
        Write-Host "  -> Standalone OpenCode installed successfully." -ForegroundColor Green
    }
}


# -------------------------------------------------------------------------
# Step 3: Fetch Available Ollama Cloud Models
# -------------------------------------------------------------------------
Write-Host ""
Write-Host "[3/4] Fetching available Ollama Cloud models..." -ForegroundColor Yellow

$modelList = @()
$tagsUrl = "https://ollama.com/api/tags"

try {
    Write-Host "  -> Querying $tagsUrl..." -ForegroundColor Gray
    $tagsResponse = Invoke-RestMethod -Uri $tagsUrl -Method Get -TimeoutSec 10
    if ($tagsResponse.models) {
        foreach ($m in $tagsResponse.models) {
            if ($m.name) {
                $modelList += $m.name
            }
        }
    }
} catch {
    Write-Warning "Could not reach $tagsUrl: $($_.Exception.Message)"
}

# Fallback models if API call returned no models or failed
if ($modelList.Count -eq 0) {
    Write-Host "  -> Using predefined cloud model catalog..." -ForegroundColor Yellow
    $modelList = @(
        "glm-5.2",
        "nemotron-3-ultra",
        "kimi-k2.6",
        "deepseek-v4.1-flash",
        "gpt-oss:120b",
        "gemma4:31b",
        "deepseek-v4-pro:0813",
        "nemotron-3-nano:30b",
        "kimi-k2.7-code",
        "gpt-oss:20b",
        "minimax-m3",
        "glm-5.3",
        "glm-5.3-flash",
        "kimi-k3",
        "mistral-large-3:675b",
        "minimax-m2.7",
        "nemotron-3-super"
    )
}

Write-Host "  -> Found $($modelList.Count) Ollama Cloud models:" -ForegroundColor Cyan
foreach ($name in $modelList) {
    Write-Host "     - $name" -ForegroundColor Gray
}


# -------------------------------------------------------------------------
# Step 4: Configure OpenCode (opencode.json & auth.json)
# -------------------------------------------------------------------------
Write-Host ""
Write-Host "[4/4] Writing OpenCode configuration..." -ForegroundColor Yellow

$modelsMap = [ordered]@{}
foreach ($modelName in $modelList) {
    $modelsMap[$modelName] = [ordered]@{
        name = $modelName
    }
}

$defaultModel = if ($modelList -contains "glm-5.3") { "ollama/glm-5.3" } elseif ($modelList -contains "deepseek-v4.1-flash") { "ollama/deepseek-v4.1-flash" } else { "ollama/$($modelList[0])" }

# Destination config directories
$configDir = Join-Path $env:USERPROFILE ".config\opencode"
$altConfigDir = Join-Path $env:USERPROFILE ".opencode"
$authDir = Join-Path $env:USERPROFILE ".local\share\opencode"

foreach ($dir in @($configDir, $altConfigDir, $authDir)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

# Prepare opencode.json content
$configFile = Join-Path $configDir "opencode.json"
$existingConfig = [ordered]@{}
if (Test-Path $configFile) {
    try {
        $raw = Get-Content -Path $configFile -Raw
        if ($raw.Trim()) {
            $existingConfig = $raw | ConvertFrom-Json
        }
    } catch {
        Write-Warning "Existing opencode.json could not be parsed as JSON, backing it up..."
        Copy-Item -Path $configFile -Destination "$configFile.bak" -Force
    }
}

# Provider structure
$providerConfig = [ordered]@{
    name    = "Ollama Cloud"
    npm     = "@ai-sdk/openai-compatible"
    env     = @("OLLAMA_API_KEY")
    options = [ordered]@{
        baseURL = "https://ollama.com/v1"
        apiKey  = $ApiKey
    }
    models  = $modelsMap
}

# Build merged config
$finalConfig = [ordered]@{
    "`$schema" = "https://opencode.ai/config.json"
}

if ($existingConfig.PSObject) {
    foreach ($prop in $existingConfig.PSObject.Properties) {
        if ($prop.Name -ne "`$schema" -and $prop.Name -ne "provider" -and $prop.Name -ne "model") {
            $finalConfig[$prop.Name] = $prop.Value
        }
    }
}

$providers = [ordered]@{}
if ($existingConfig.provider) {
    foreach ($p in $existingConfig.provider.PSObject.Properties) {
        $providers[$p.Name] = $p.Value
    }
}
$providers["ollama"] = $providerConfig
$finalConfig["provider"] = $providers

if (-not $finalConfig["model"]) {
    $finalConfig["model"] = $defaultModel
}

$jsonOutput = $finalConfig | ConvertTo-Json -Depth 10

# Save to ~/.config/opencode/opencode.json and ~/.opencode/opencode.json
Set-Content -Path $configFile -Value $jsonOutput -Encoding UTF8
Set-Content -Path (Join-Path $altConfigDir "opencode.json") -Value $jsonOutput -Encoding UTF8
Write-Host "  -> Wrote configuration to:" -ForegroundColor Green
Write-Host "     $configFile" -ForegroundColor Gray
Write-Host "     $(Join-Path $altConfigDir "opencode.json")" -ForegroundColor Gray

# Write auth.json for direct credential discovery
$authFile = Join-Path $authDir "auth.json"
$authData = [ordered]@{}
if (Test-Path $authFile) {
    try {
        $rawAuth = Get-Content -Path $authFile -Raw
        if ($rawAuth.Trim()) {
            $parsedAuth = $rawAuth | ConvertFrom-Json
            foreach ($p in $parsedAuth.PSObject.Properties) {
                $authData[$p.Name] = $p.Value
            }
        }
    } catch {
        # ignore parse error
    }
}
$authData["ollama"] = [ordered]@{
    type = "api"
    key  = $ApiKey
}
$authJsonOutput = $authData | ConvertTo-Json -Depth 10
Set-Content -Path $authFile -Value $authJsonOutput -Encoding UTF8
Write-Host "  -> Wrote credentials to $authFile" -ForegroundColor Green

# -------------------------------------------------------------------------
# Verification & Summary
# -------------------------------------------------------------------------
Write-Host ""
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "                 Setup Completed Successfully!             " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Status Summary:" -ForegroundColor Cyan
Write-Host "  [OK] OLLAMA_API_KEY is registered in User environment variables."
Write-Host "  [OK] OpenCode configured with $($modelList.Count) Ollama cloud models."
Write-Host "  [OK] Default model set to: $($finalConfig["model"])"
Write-Host ""
Write-Host "Quick Start:" -ForegroundColor Yellow
Write-Host "  1. Launch OpenCode in any project:"
Write-Host "       opencode" -ForegroundColor White
Write-Host "  2. Run with a specific cloud model:"
Write-Host "       opencode --model ollama/glm-5.3" -ForegroundColor White
Write-Host "       opencode --model ollama/deepseek-v4.1-flash" -ForegroundColor White
Write-Host "  3. In the OpenCode chat window, type /models to switch models interactively."
Write-Host ""
Write-Host "NOTE:" -ForegroundColor Magenta
Write-Host "  The current session is ready to use immediately."
Write-Host "  For already-opened Command Prompts or other apps to pick up the"
Write-Host "  OLLAMA_API_KEY environment variable, open a new terminal window"
Write-Host "  or restart your computer."
Write-Host "==========================================================" -ForegroundColor Green
