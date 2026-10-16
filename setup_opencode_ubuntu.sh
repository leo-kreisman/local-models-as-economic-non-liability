#!/usr/bin/env bash
# ==============================================================================
# OpenCode + Ollama Cloud Setup Script for Ubuntu / Debian Linux
# ==============================================================================
# 1. Prompts for and permanently registers OLLAMA_API_KEY in ~/.bashrc & ~/.profile.
# 2. Installs OpenCode CLI (via official curl installer or npm fallback).
# 3. Fetches live cloud models from https://ollama.com/api/tags.
# 4. Configures OpenCode (~/.config/opencode/opencode.json & auth.json).
# ==============================================================================

set -euo pipefail

# ANSI Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
GRAY='\033[0;90m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${CYAN}${BOLD}==========================================================${NC}"
echo -e "${CYAN}${BOLD}       OpenCode + Ollama Cloud Setup for Ubuntu           ${NC}"
echo -e "${CYAN}${BOLD}==========================================================${NC}"
echo ""

# ------------------------------------------------------------------------------
# Parse arguments
# ------------------------------------------------------------------------------
API_KEY="${OLLAMA_API_KEY:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -k|--api-key)
      API_KEY="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: ./setup_opencode_ubuntu.sh [options]"
      echo ""
      echo "Options:"
      echo "  -k, --api-key <key>   Specify the Ollama API key non-interactively"
      echo "  -h, --help            Show this help message"
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      exit 1
      ;;
  esac
done

# ------------------------------------------------------------------------------
# Step 1: Prompt & Register OLLAMA_API_KEY
# ------------------------------------------------------------------------------
echo -e "${YELLOW}${BOLD}[1/4] Configuring OLLAMA_API_KEY...${NC}"

if [ -n "$API_KEY" ]; then
  masked_key="${API_KEY:0:6}..."
  read -r -p "Found existing OLLAMA_API_KEY ($masked_key). Use this? [Y/n] " use_existing || true
  if [[ "$use_existing" =~ ^[nN] ]]; then
    API_KEY=""
  fi
fi

while [ -z "$API_KEY" ]; do
  read -r -s -p "Enter your OLLAMA_API_KEY: " API_KEY
  echo ""
  API_KEY="$(echo "$API_KEY" | xargs)"
  if [ -z "$API_KEY" ]; then
    echo -e "${RED}API key cannot be empty. Please enter a valid key.${NC}"
  fi
done

export OLLAMA_API_KEY="$API_KEY"

# Persist to ~/.bashrc, ~/.profile, and ~/.zshrc (if present)
persist_env() {
  local target_file="$1"
  [ -f "$target_file" ] || touch "$target_file"
  if grep -q "export OLLAMA_API_KEY=" "$target_file" 2>/dev/null; then
    sed -i "s|^export OLLAMA_API_KEY=.*|export OLLAMA_API_KEY=\"$API_KEY\"|" "$target_file"
  else
    echo "export OLLAMA_API_KEY=\"$API_KEY\"" >> "$target_file"
  fi
}

persist_env "$HOME/.bashrc"
persist_env "$HOME/.profile"
if [ -f "$HOME/.zshrc" ]; then
  persist_env "$HOME/.zshrc"
fi

echo -e "  -> ${GREEN}OLLAMA_API_KEY registered permanently in ~/.bashrc and ~/.profile.${NC}"

# ------------------------------------------------------------------------------
# Step 2: Install OpenCode CLI
# ------------------------------------------------------------------------------
echo ""
echo -e "${YELLOW}${BOLD}[2/4] Checking OpenCode CLI installation...${NC}"

# Ensure ~/.local/bin is in PATH for the current session and persistent configs
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

if ! grep -q 'PATH=.*\$HOME/\.local/bin' "$HOME/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi

if command -v opencode >/dev/null 2>&1; then
  echo -e "  -> ${GREEN}OpenCode is already installed at: $(command -v opencode)${NC}"
else
  echo -e "  -> ${CYAN}OpenCode not found in PATH. Proceeding with installation...${NC}"
  installed=false

  # Method A: Official curl installer
  echo -e "  -> ${CYAN}Running official OpenCode installer (https://opencode.ai/install)...${NC}"
  if curl -fsSL https://opencode.ai/install | bash; then
    if [ -x "$HOME/.local/bin/opencode" ] || command -v opencode >/dev/null 2>&1; then
      installed=true
      echo -e "  -> ${GREEN}OpenCode installed successfully via official script!${NC}"
    fi
  fi

  # Method B: npm fallback if curl installer failed
  if [ "$installed" = false ] && command -v npm >/dev/null 2>&1; then
    echo -e "  -> ${CYAN}Trying npm global install (opencode-ai)...${NC}"
    if npm install -g opencode-ai; then
      installed=true
      echo -e "  -> ${GREEN}OpenCode installed successfully via npm!${NC}"
    fi
  fi

  if [ "$installed" = false ]; then
    echo -e "${RED}Error: Failed to install OpenCode. Please check your internet connection or install Node.js/npm.${NC}"
    exit 1
  fi
fi

# ------------------------------------------------------------------------------
# Step 3: Fetch Ollama Cloud Models
# ------------------------------------------------------------------------------
echo ""
echo -e "${YELLOW}${BOLD}[3/4] Fetching available Ollama Cloud models...${NC}"

MODELS_JSON=""
TAGS_URL="https://ollama.com/api/tags"

# Use python3 to fetch and output JSON array of model names
if command -v python3 >/dev/null 2>&1; then
  MODELS_JSON=$(python3 - <<EOF
import urllib.request, json
tags_url = "$TAGS_URL"
fallback = [
    "glm-5.2", "nemotron-3-ultra", "kimi-k2.6", "deepseek-v4.1-flash",
    "gpt-oss:120b", "gemma4:31b", "deepseek-v4-pro:0813", "nemotron-3-nano:30b",
    "kimi-k2.7-code", "gpt-oss:20b", "minimax-m3", "glm-5.3",
    "glm-5.3-flash", "kimi-k3", "mistral-large-3:675b", "minimax-m2.7", "nemotron-3-super"
]
try:
    req = urllib.request.Request(tags_url, headers={"User-Agent": "curl/7.68.0"})
    with urllib.request.urlopen(req, timeout=10) as resp:
        data = json.loads(resp.read().decode("utf-8"))
        models = [m["name"] for m in data.get("models", []) if "name" in m]
        if not models:
            models = fallback
except Exception:
    models = fallback
print(json.dumps(models))
EOF
  )
elif command -v jq >/dev/null 2>&1; then
  RAW_MODELS=$(curl -s --connect-timeout 10 "$TAGS_URL" || true)
  if [ -n "$RAW_MODELS" ] && echo "$RAW_MODELS" | jq '.models' >/dev/null 2>&1; then
    MODELS_JSON=$(echo "$RAW_MODELS" | jq -c '[.models[].name]')
  fi
fi

if [ -z "$MODELS_JSON" ] || [ "$MODELS_JSON" = "[]" ]; then
  MODELS_JSON='["glm-5.2","nemotron-3-ultra","kimi-k2.6","deepseek-v4.1-flash","gpt-oss:120b","gemma4:31b","deepseek-v4-pro:0813","nemotron-3-nano:30b","kimi-k2.7-code","gpt-oss:20b","minimax-m3","glm-5.3","glm-5.3-flash","kimi-k3","mistral-large-3:675b","minimax-m2.7","nemotron-3-super"]'
fi

# Print discovered models
echo -e "  -> ${CYAN}Configured cloud models:${NC}"
if command -v python3 >/dev/null 2>&1; then
  python3 -c "import json; [print(f'     - {m}') for m in json.loads('''$MODELS_JSON''')]"
elif command -v jq >/dev/null 2>&1; then
  echo "$MODELS_JSON" | jq -r '.[] | "     - \(.)"'
fi

# ------------------------------------------------------------------------------
# Step 4: Configure OpenCode (opencode.json & auth.json)
# ------------------------------------------------------------------------------
echo ""
echo -e "${YELLOW}${BOLD}[4/4] Writing OpenCode configuration...${NC}"

CONFIG_DIR="$HOME/.config/opencode"
AUTH_DIR="$HOME/.local/share/opencode"

mkdir -p "$CONFIG_DIR"
mkdir -p "$AUTH_DIR"

CONFIG_FILE="$CONFIG_DIR/opencode.json"
AUTH_FILE="$AUTH_DIR/auth.json"

# Write opencode.json using python3 (or jq fallback)
if command -v python3 >/dev/null 2>&1; then
  python3 - <<EOF
import json, os

config_file = "$CONFIG_FILE"
api_key = """$API_KEY"""
model_list = json.loads('''$MODELS_JSON''')

existing_config = {}
if os.path.exists(config_file):
    try:
        with open(config_file, "r", encoding="utf-8") as f:
            existing_config = json.load(f)
    except Exception:
        existing_config = {}

models_map = {m: {"name": m} for m in model_list}

default_model = "ollama/glm-5.3" if "glm-5.3" in model_list else f"ollama/{model_list[0]}"

provider_config = {
    "name": "Ollama Cloud",
    "npm": "@ai-sdk/openai-compatible",
    "env": ["OLLAMA_API_KEY"],
    "options": {
        "baseURL": "https://ollama.com/v1",
        "apiKey": api_key
    },
    "models": models_map
}

if "provider" not in existing_config:
    existing_config["provider"] = {}
existing_config["provider"]["ollama"] = provider_config

if "$schema" not in existing_config:
    existing_config["$schema"] = "https://opencode.ai/config.json"

if "model" not in existing_config or not existing_config["model"]:
    existing_config["model"] = default_model

with open(config_file, "w", encoding="utf-8") as f:
    json.dump(existing_config, f, indent=2, ensure_ascii=False)

# Write auth.json
auth_file = "$AUTH_FILE"
existing_auth = {}
if os.path.exists(auth_file):
    try:
        with open(auth_file, "r", encoding="utf-8") as f:
            existing_auth = json.load(f)
    except Exception:
        existing_auth = {}

existing_auth["ollama"] = {
    "type": "api",
    "key": api_key
}

with open(auth_file, "w", encoding="utf-8") as f:
    json.dump(existing_auth, f, indent=2, ensure_ascii=False)
EOF

else
  # Minimal fallback write if python3 is not available
  cat <<EOF > "$CONFIG_FILE"
{
  "\$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "name": "Ollama Cloud",
      "npm": "@ai-sdk/openai-compatible",
      "env": ["OLLAMA_API_KEY"],
      "options": {
        "baseURL": "https://ollama.com/v1",
        "apiKey": "$API_KEY"
      },
      "models": {
        "glm-5.3": { "name": "glm-5.3" }
      }
    }
  },
  "model": "ollama/glm-5.3"
}
EOF

  cat <<EOF > "$AUTH_FILE"
{
  "ollama": {
    "type": "api",
    "key": "$API_KEY"
  }
}
EOF
fi

echo -e "  -> ${GREEN}Wrote OpenCode configuration to: $CONFIG_FILE${NC}"
echo -e "  -> ${GREEN}Wrote OpenCode credentials to: $AUTH_FILE${NC}"

# ------------------------------------------------------------------------------
# Summary & Next Steps
# ------------------------------------------------------------------------------
echo ""
echo -e "${GREEN}${BOLD}==========================================================${NC}"
echo -e "${GREEN}${BOLD}              Setup Completed Successfully!               ${NC}"
echo -e "${GREEN}${BOLD}==========================================================${NC}"
echo ""
echo -e "${CYAN}Summary:${NC}"
echo -e "  [OK] OLLAMA_API_KEY registered in environment variables."
echo -e "  [OK] OpenCode CLI installed and configured."
echo -e "  [OK] Ollama Cloud provider wired to https://ollama.com/v1."
echo ""
echo -e "${YELLOW}Quick Start:${NC}"
echo -e "  1. Reload your environment variables:"
echo -e "       ${BOLD}source ~/.bashrc${NC}"
echo -e "  2. Launch OpenCode:"
echo -e "       ${BOLD}opencode${NC}"
echo -e "  3. Or launch with a specific model:"
echo -e "       ${BOLD}opencode --model ollama/glm-5.3${NC}"
echo -e "       ${BOLD}opencode --model ollama/deepseek-v4.1-flash${NC}"
echo ""
echo -e "${MAGENTA}NOTE:${NC} Current terminal is already active. For other open terminals to read"
echo -e "the new environment variable, run ${BOLD}source ~/.bashrc${NC} or restart your shell."
echo -e "${GREEN}${BOLD}==========================================================${NC}"
