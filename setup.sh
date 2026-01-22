#!/bin/bash

# setup.sh - One-command setup for grepai and beads
# For Claude Code users who want semantic search and persistent memory
#
# Usage: ./setup.sh [options]
# Options:
#   --skip-go         Skip Go installation check
#   --skip-grepai     Skip grepai installation
#   --skip-beads      Skip beads installation
#   --skip-claude-md  Skip CLAUDE.md configuration
#   --non-interactive Run without prompts (uses defaults)

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SKIP_GO=false
SKIP_GREPAI=false
SKIP_BEADS=false
SKIP_CLAUDE_MD=false
NON_INTERACTIVE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --skip-go)
      SKIP_GO=true
      shift
      ;;
    --skip-grepai)
      SKIP_GREPAI=true
      shift
      ;;
    --skip-beads)
      SKIP_BEADS=true
      shift
      ;;
    --skip-claude-md)
      SKIP_CLAUDE_MD=true
      shift
      ;;
    --non-interactive)
      NON_INTERACTIVE=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--skip-go] [--skip-grepai] [--skip-beads] [--skip-claude-md] [--non-interactive]"
      exit 1
      ;;
  esac
done

# Helper functions
print_header() {
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

ask_yes_no() {
  if [ "$NON_INTERACTIVE" = true ]; then
    return 0  # Default to yes in non-interactive mode
  fi

  while true; do
    read -p "$1 (y/n): " yn
    case $yn in
      [Yy]* ) return 0;;
      [Nn]* ) return 1;;
      * ) echo "Please answer yes or no.";;
    esac
  done
}

# Detect OS and shell
detect_environment() {
  print_header "🔍 Detecting Environment"

  # Detect OS
  OS=$(uname -s)
  case "$OS" in
    Darwin*)
      OS_TYPE="macOS"
      PACKAGE_MANAGER="brew"
      ;;
    Linux*)
      OS_TYPE="Linux"
      if command -v apt-get &> /dev/null; then
        PACKAGE_MANAGER="apt"
      elif command -v yum &> /dev/null; then
        PACKAGE_MANAGER="yum"
      elif command -v brew &> /dev/null; then
        PACKAGE_MANAGER="brew"
      else
        PACKAGE_MANAGER="unknown"
      fi
      ;;
    *)
      OS_TYPE="Unknown"
      PACKAGE_MANAGER="unknown"
      ;;
  esac

  print_info "OS: $OS_TYPE"
  print_info "Package Manager: $PACKAGE_MANAGER"

  # Detect shell
  CURRENT_SHELL=$(basename "$SHELL")
  print_info "Shell: $CURRENT_SHELL"

  # Determine shell config file
  case "$CURRENT_SHELL" in
    zsh)
      SHELL_CONFIG="$HOME/.zshrc"
      ;;
    bash)
      if [ -f "$HOME/.bash_profile" ]; then
        SHELL_CONFIG="$HOME/.bash_profile"
      else
        SHELL_CONFIG="$HOME/.bashrc"
      fi
      ;;
    *)
      SHELL_CONFIG="$HOME/.profile"
      ;;
  esac

  print_info "Shell config: $SHELL_CONFIG"
  echo ""
}

# Check and install Go
check_go() {
  if [ "$SKIP_GO" = true ]; then
    print_info "Skipping Go check (--skip-go)"
    return 0
  fi

  print_header "📦 Checking Go Installation"

  if command -v go &> /dev/null; then
    GO_VERSION=$(go version | awk '{print $3}')
    print_success "Go is installed: $GO_VERSION"
    echo ""
    return 0
  fi

  print_warning "Go is not installed"
  echo ""

  if ! ask_yes_no "Install Go now?"; then
    print_info "Skipping Go installation. You'll need to install it manually."
    echo ""
    return 1
  fi

  echo ""
  print_info "Installing Go..."

  case "$PACKAGE_MANAGER" in
    brew)
      brew install go
      ;;
    apt)
      sudo apt-get update
      sudo apt-get install -y golang-go
      ;;
    yum)
      sudo yum install -y golang
      ;;
    *)
      print_error "Cannot automatically install Go on this system"
      print_info "Please visit: https://go.dev/doc/install"
      return 1
      ;;
  esac

  if command -v go &> /dev/null; then
    print_success "Go installed successfully"
  else
    print_error "Go installation failed"
    return 1
  fi

  echo ""
}

# Configure PATH for Go binaries
configure_go_path() {
  print_header "🛤️  Configuring Go PATH"

  GO_BIN_PATH="$HOME/go/bin"

  # Check if $HOME/go/bin is already in PATH
  if echo "$PATH" | grep -q "$GO_BIN_PATH"; then
    print_success "Go bin directory already in PATH"
    echo ""
    return 0
  fi

  # Check if it's configured in shell config
  if grep -q 'export PATH="$HOME/go/bin:$PATH"' "$SHELL_CONFIG" 2>/dev/null; then
    print_success "Go PATH already configured in $SHELL_CONFIG"
    print_info "Reload your shell: source $SHELL_CONFIG"
    echo ""
    return 0
  fi

  print_warning "Go bin directory not in PATH"

  if ! ask_yes_no "Add \$HOME/go/bin to PATH in $SHELL_CONFIG?"; then
    print_info "Skipping PATH configuration"
    print_warning "You'll need to add this manually:"
    echo '  export PATH="$HOME/go/bin:$PATH"'
    echo ""
    return 1
  fi

  # Add to shell config
  echo "" >> "$SHELL_CONFIG"
  echo "# Go binaries (added by grepai-beads-helpers setup)" >> "$SHELL_CONFIG"
  echo 'export PATH="$HOME/go/bin:$PATH"' >> "$SHELL_CONFIG"

  # Add to current session
  export PATH="$HOME/go/bin:$PATH"

  print_success "Added to $SHELL_CONFIG"
  print_info "Reload your shell: source $SHELL_CONFIG"
  echo ""
}

# Install grepai
install_grepai() {
  if [ "$SKIP_GREPAI" = true ]; then
    print_info "Skipping grepai (--skip-grepai)"
    return 0
  fi

  print_header "🔍 Installing grepai"

  # Check if already installed
  if command -v grepai &> /dev/null || [ -f "$HOME/go/bin/grepai" ]; then
    print_success "grepai is already installed"
    if [ -f "$HOME/go/bin/grepai" ]; then
      GREPAI_PATH="$HOME/go/bin/grepai"
      GREPAI_VERSION=$($GREPAI_PATH --help 2>&1 | head -1 || echo "unknown version")
      print_info "Location: $GREPAI_PATH"
    fi
    echo ""
    return 0
  fi

  print_info "Installing grepai from source..."

  # Install grepai
  if go install github.com/yoanbernabeu/grepai/cmd/grepai@latest; then
    print_success "grepai installed successfully"
    print_info "Location: $HOME/go/bin/grepai"
  else
    print_error "grepai installation failed"
    return 1
  fi

  echo ""
}

# Install beads
install_beads() {
  if [ "$SKIP_BEADS" = true ]; then
    print_info "Skipping beads (--skip-beads)"
    return 0
  fi

  print_header "🔮 Installing beads"

  # Check if already installed
  if command -v bd &> /dev/null || [ -f "$HOME/go/bin/beads" ] || [ -f "$HOME/go/bin/bd" ]; then
    print_success "beads is already installed"
    if [ -f "$HOME/go/bin/bd" ]; then
      print_info "Location: $HOME/go/bin/bd"
    elif [ -f "$HOME/go/bin/beads" ]; then
      print_info "Location: $HOME/go/bin/beads"
    fi
    echo ""

    # Check if initialized
    if [ -d "$HOME/.beads" ]; then
      print_success "beads memory directory exists: ~/.beads/"
    else
      print_warning "beads not initialized yet"
      if ask_yes_no "Initialize beads in your home directory?"; then
        cd "$HOME"
        if [ -f "$HOME/go/bin/bd" ]; then
          "$HOME/go/bin/bd" init
        elif [ -f "$HOME/go/bin/beads" ]; then
          "$HOME/go/bin/beads" init
        fi
        print_success "beads initialized"
      fi
    fi
    echo ""
    return 0
  fi

  print_info "Installing beads from source..."

  # Install beads
  if go install github.com/steveyegge/beads/cmd/bd@latest; then
    print_success "beads installed successfully"
    print_info "Location: $HOME/go/bin/bd"
  else
    print_error "beads installation failed"
    return 1
  fi

  echo ""

  # Initialize beads
  print_info "Initializing beads..."

  if ask_yes_no "Initialize beads in your home directory (~/.beads)?"; then
    cd "$HOME"
    "$HOME/go/bin/bd" init
    print_success "beads initialized"
    print_info "Memory stored in: ~/.beads/"
  else
    print_info "Skipping beads initialization"
    print_info "Run later: cd ~ && bd init"
  fi

  echo ""
}

# Verify Ollama installation (for grepai embeddings)
check_ollama() {
  print_header "🦙 Checking Ollama (for grepai embeddings)"

  if command -v ollama &> /dev/null; then
    print_success "Ollama is installed"

    # Check if service is running
    if ollama list &> /dev/null; then
      print_success "Ollama service is running"

      # List available models
      print_info "Available models:"
      ollama list | tail -n +2 | awk '{print "  - " $1}'
    else
      print_warning "Ollama is installed but not running"
      print_info "Start with: ollama serve"
    fi
  else
    print_warning "Ollama not installed"
    print_info "grepai can use OpenAI instead (requires OPENAI_API_KEY)"
    print_info ""
    print_info "To install Ollama:"
    case "$PACKAGE_MANAGER" in
      brew)
        print_info "  brew install ollama"
        ;;
      *)
        print_info "  Visit: https://ollama.com/"
        ;;
    esac
  fi

  echo ""
}

# Add CLAUDE.md configuration
configure_claude_md() {
  if [ "$SKIP_CLAUDE_MD" = true ]; then
    print_info "Skipping CLAUDE.md configuration (--skip-claude-md)"
    return 0
  fi

  print_header "📝 CLAUDE.md Configuration"

  CLAUDE_MD="$HOME/.claude/CLAUDE.md"

  if [ ! -f "$CLAUDE_MD" ]; then
    print_info "No CLAUDE.md found at ~/.claude/CLAUDE.md"

    if ! ask_yes_no "Create CLAUDE.md with auto-usage rules for grepai and beads?"; then
      print_info "Skipping CLAUDE.md creation"
      echo ""
      return 0
    fi

    # Create .claude directory if it doesn't exist
    mkdir -p "$HOME/.claude"

    # Create CLAUDE.md with basic rules
    cat > "$CLAUDE_MD" << 'EOF'
# Claude Code Configuration

## Efficiency Tools - Automatic Usage Rules

### CRITICAL: Use These Tools Automatically

#### 1. Semantic Code Search (grepai)
**Tool:** grepai (semantic code search using vector embeddings)
**Auto-use when:**
- User asks: "find...", "where is...", "show me...", "locate..."
- Searching for patterns, implementations, or features across codebase
- Need to understand "what code does X" vs exact text matching

**Behavior:** Try grepai FIRST if project is indexed (check for .grepai/ directory). Fall back to Grep with notice if not indexed.

**Setup per project:**
```bash
cd project && grepai init --provider ollama --backend gob
```

#### 2. Memory System (beads)
**Tool:** bd (git-backed persistent memory for AI agents)
**Auto-use when:**
- Session start: Query for active context with `bd search "active" --json`
- User asks: "What did we decide...", "Where is...", "Remind me..."
- Before planning: Load relevant architectural decisions
- Tracking multi-step work with dependencies

**Behavior:** Automatic queries, no user confirmation needed.

**Common commands:**
```bash
bd create "Memory title" --body "Details"  # Store new memory
bd search "keyword" --json                  # Query memories
bd ready                                     # Show actionable items
bd show <id>                                # View memory details
```

### Detection Patterns

| User Input Pattern | Auto-Use Tool |
|-------------------|---------------|
| "find\|locate\|where is" + code reference | grepai (if indexed) |
| "we decided\|last time\|previously" | bd search |
| "what's the status of..." | bd ready |

### Fallback Strategy

1. Try tool automatically
2. If tool fails/missing, use default method + notify user once
3. Never block on missing tool - degrade gracefully

Example:
```
❌ Bad: "grepai is not installed. Please install it first."
✅ Good: "Using Grep (run 'grepai init' for semantic search). Results:..."
```

---
**Tools installed by:** https://github.com/miqcie/grepai-beads-helpers
EOF

    print_success "Created CLAUDE.md with auto-usage rules"
    print_info "Location: $CLAUDE_MD"
  else
    print_success "CLAUDE.md already exists"

    # Check if it already has our rules
    if grep -q "grepai-beads-helpers" "$CLAUDE_MD" 2>/dev/null; then
      print_success "Auto-usage rules already configured"
    else
      print_warning "CLAUDE.md exists but doesn't have grepai/beads rules"

      if ask_yes_no "Append auto-usage rules to existing CLAUDE.md?"; then
        cat >> "$CLAUDE_MD" << 'EOF'

## Efficiency Tools - Automatic Usage Rules

### CRITICAL: Use These Tools Automatically

#### 1. Semantic Code Search (grepai)
**Tool:** grepai (semantic code search using vector embeddings)
**Auto-use when:**
- User asks: "find...", "where is...", "show me...", "locate..."
- Searching for patterns, implementations, or features across codebase

**Behavior:** Try grepai FIRST if project is indexed (.grepai/ directory exists)

#### 2. Memory System (beads)
**Tool:** bd (git-backed persistent memory for AI agents)
**Auto-use when:**
- Session start: Query for active context
- User asks about previous decisions or context

**Common commands:**
```bash
bd create "title" --body "details"  # Store memory
bd search "keyword" --json          # Query memories
bd ready                             # Show actionable items
```

---
**Tools installed by:** https://github.com/miqcie/grepai-beads-helpers
EOF
        print_success "Appended auto-usage rules to CLAUDE.md"
      fi
    fi
  fi

  echo ""
}

# Verify installations
verify_installations() {
  local all_good=true

  # Verify Go
  if ! command -v go &> /dev/null; then
    print_warning "Go not found in PATH"
    all_good=false
  fi

  # Verify grepai
  if [ ! -f "$HOME/go/bin/grepai" ]; then
    print_warning "grepai not installed at $HOME/go/bin/grepai"
    all_good=false
  elif ! "$HOME/go/bin/grepai" --help &> /dev/null; then
    print_warning "grepai installed but not working correctly"
    all_good=false
  fi

  # Verify beads
  if [ ! -f "$HOME/go/bin/bd" ]; then
    print_warning "beads not installed at $HOME/go/bin/bd"
    all_good=false
  elif ! "$HOME/go/bin/bd" --help &> /dev/null; then
    print_warning "beads installed but not working correctly"
    all_good=false
  fi

  # Verify beads initialized
  if [ ! -d "$HOME/.beads" ]; then
    print_info "beads not initialized yet (run: cd ~ && bd init)"
  fi

  return $([ "$all_good" = true ] && echo 0 || echo 1)
}

# Print summary
print_summary() {
  print_header "✅ Setup Complete"

  echo "Installed tools:"

  if command -v go &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Go: $(go version | awk '{print $3}')"
  else
    echo -e "  ${RED}✗${NC} Go: Not found"
  fi

  if command -v grepai &> /dev/null || [ -f "$HOME/go/bin/grepai" ]; then
    echo -e "  ${GREEN}✓${NC} grepai: $HOME/go/bin/grepai"
  else
    echo -e "  ${RED}✗${NC} grepai: Not installed"
  fi

  if command -v bd &> /dev/null || [ -f "$HOME/go/bin/bd" ]; then
    echo -e "  ${GREEN}✓${NC} beads: $HOME/go/bin/bd"
  else
    echo -e "  ${RED}✗${NC} beads: Not installed"
  fi

  echo ""
  echo "Next steps:"
  echo ""
  echo "1. Reload your shell:"
  echo "   source $SHELL_CONFIG"
  echo ""
  echo "2. Index your projects with grepai:"
  echo "   cd ~/GitHub/your-project"
  echo "   grepai init --provider ollama --backend gob"
  echo ""
  echo "   Or bulk index all projects:"
  echo "   ./index-all-projects.sh"
  echo ""
  echo "3. Start using beads for memory:"
  echo "   bd create \"My first memory\" --body \"Details about the project\""
  echo "   bd search \"project\""
  echo ""
  echo "4. Claude Code will now automatically use these tools when relevant!"
  echo ""

  print_info "Documentation: https://github.com/miqcie/grepai-beads-helpers"
  echo ""
}

# Main execution
main() {
  clear

  echo ""
  print_header "🚀 grepai + beads Setup for Claude Code"
  echo ""
  echo "This script will install and configure:"
  echo "  • grepai - Semantic code search using vector embeddings"
  echo "  • beads - Git-backed persistent memory for AI agents"
  echo "  • CLAUDE.md auto-usage rules (optional)"
  echo ""

  if [ "$NON_INTERACTIVE" = false ]; then
    if ! ask_yes_no "Continue with setup?"; then
      echo "Setup cancelled."
      exit 0
    fi
    echo ""
  fi

  # Run setup steps
  detect_environment
  check_go || { print_error "Go installation required. Exiting."; exit 1; }
  configure_go_path
  install_grepai
  install_beads
  check_ollama
  configure_claude_md

  # Verify all installations before showing summary
  verify_installations || print_warning "Some installations may need attention"

  print_summary
}

# Run main function
main
