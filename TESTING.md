# Testing Guide

This guide helps contributors test the setup script (`setup.sh`) in various environments.

## Quick Testing Checklist

Before submitting changes, verify:

- [ ] Bash syntax is valid: `bash -n setup.sh`
- [ ] Script is executable: `ls -la setup.sh` shows `-rwxr-xr-x`
- [ ] README examples are up-to-date
- [ ] CLAUDE.md template is syntactically correct
- [ ] All flags work: `--skip-*`, `--non-interactive`
- [ ] Tested on at least one clean environment

## Testing Strategies

### 1. Syntax Validation (Local, Fast)

```bash
# Check bash syntax
bash -n setup.sh

# Check for common issues with shellcheck (if installed)
shellcheck setup.sh

# Verify executability
test -x setup.sh && echo "✓ Executable" || echo "✗ Not executable"
```

### 2. Dry Run Testing (Local, Safe)

Test the script's logic without actually installing anything:

```bash
# Run in non-interactive mode with all skips
./setup.sh --non-interactive --skip-go --skip-grepai --skip-beads --skip-claude-md

# This will:
# ✓ Test environment detection
# ✓ Test output formatting
# ✓ Test command-line flag parsing
# ✗ Skip actual installations
```

### 3. Docker Testing (Isolated, Clean Environment)

Test on a fresh Ubuntu container:

```bash
# Create test container
docker run -it --rm -v $(pwd):/workspace ubuntu:22.04 bash

# Inside container:
cd /workspace
apt-get update
apt-get install -y git curl

# Run setup
./setup.sh --non-interactive

# Verify installations
~/go/bin/grepai --help
~/go/bin/bd --help
ls -la ~/.beads/
cat ~/.claude/CLAUDE.md
```

Test on fresh macOS-like container (using uraimo/run-on-arch-action for arm64):

```bash
# For macOS testing, use actual macOS VM or GitHub Actions
# See .github/workflows/test.yml for CI setup
```

### 4. VM Testing (Full Environment)

**macOS Testing (Parallels, VMware, or VirtualBox):**

```bash
# On fresh macOS VM:
git clone https://github.com/miqcie/grepai-beads-helpers.git
cd grepai-beads-helpers
./setup.sh

# Verify:
which grepai
which bd
cat ~/.claude/CLAUDE.md
echo $PATH | grep "go/bin"
```

**Linux Testing (VirtualBox, Multipass):**

```bash
# Ubuntu
multipass launch --name test-ubuntu 22.04
multipass shell test-ubuntu

# Inside VM:
git clone https://github.com/miqcie/grepai-beads-helpers.git
cd grepai-beads-helpers
./setup.sh

# Verify installations
~/go/bin/grepai --help
~/go/bin/bd --help
```

## Manual Test Cases

### Test Case 1: Fresh Install (Nothing Installed)

**Setup:**
- Clean system with no Go, grepai, or beads

**Steps:**
```bash
./setup.sh
```

**Expected:**
- ✅ Installs Go (or prompts to install)
- ✅ Installs grepai to ~/go/bin/
- ✅ Installs beads to ~/go/bin/
- ✅ Adds PATH to shell config
- ✅ Initializes ~/.beads/
- ✅ Creates ~/.claude/CLAUDE.md (if user confirms)
- ✅ Shows helpful next steps

**Verify:**
```bash
which grepai  # Should show ~/go/bin/grepai
which bd      # Should show ~/go/bin/bd
ls ~/.beads/  # Should exist
cat ~/.claude/CLAUDE.md  # Should have auto-usage rules
```

---

### Test Case 2: Partial Install (Go Already Installed)

**Setup:**
- System with Go installed but no grepai/beads

**Steps:**
```bash
./setup.sh
```

**Expected:**
- ✅ Detects existing Go
- ✅ Skips Go installation
- ✅ Installs grepai and beads
- ✅ Configures PATH
- ✅ Initializes beads

---

### Test Case 3: Already Fully Installed

**Setup:**
- System with Go, grepai, and beads already installed

**Steps:**
```bash
./setup.sh
```

**Expected:**
- ✅ Detects all tools are installed
- ✅ Shows "already installed" messages
- ✅ Checks beads initialization
- ✅ Offers to create CLAUDE.md if missing
- ✅ Exits gracefully

---

### Test Case 4: Non-Interactive Mode

**Setup:**
- Fresh system

**Steps:**
```bash
./setup.sh --non-interactive
```

**Expected:**
- ✅ No prompts for confirmation
- ✅ Uses default choices (yes to everything)
- ✅ Completes installation automatically

---

### Test Case 5: Selective Installation

**Setup:**
- Fresh system

**Steps:**
```bash
# Install only grepai
./setup.sh --skip-beads --skip-claude-md

# Install only beads
./setup.sh --skip-grepai --skip-claude-md
```

**Expected:**
- ✅ Only installs requested tools
- ✅ Skips marked components
- ✅ Still configures PATH correctly

---

### Test Case 6: CLAUDE.md Already Exists

**Setup:**
- System with existing ~/.claude/CLAUDE.md

**Steps:**
```bash
# Create existing CLAUDE.md
mkdir -p ~/.claude
echo "# My existing config" > ~/.claude/CLAUDE.md

# Run setup
./setup.sh
```

**Expected:**
- ✅ Detects existing CLAUDE.md
- ✅ Offers to append (not overwrite)
- ✅ Preserves existing content if user declines

---

### Test Case 7: Error Handling

**Setup:**
- Simulate failures

**Steps:**
```bash
# No internet connection
# OR
# No disk space
# OR
# Permission errors
./setup.sh
```

**Expected:**
- ✅ Shows clear error messages
- ✅ Suggests solutions
- ✅ Exits gracefully
- ✅ Doesn't leave partial installations

---

## Platform-Specific Tests

### macOS (Homebrew)

```bash
# Test with Homebrew
./setup.sh

# Verify:
which go    # Should be from Homebrew if installed by script
which grepai
brew list go  # Should show Go if installed via brew
```

### Linux (apt - Ubuntu/Debian)

```bash
# Test on Ubuntu
./setup.sh

# Verify:
which go
dpkg -l | grep golang  # Should show Go package
```

### Linux (yum - CentOS/RHEL)

```bash
# Test on CentOS
./setup.sh

# Verify:
which go
yum list installed | grep golang
```

---

## Automated Testing (Future)

### ShellCheck Integration

```bash
# Install shellcheck
brew install shellcheck  # macOS
# OR
sudo apt-get install shellcheck  # Ubuntu

# Run checks
shellcheck setup.sh
```

### BATS (Bash Automated Testing System)

```bash
# Install BATS
npm install -g bats

# Create test file: tests/setup.bats
bats tests/setup.bats
```

Example BATS test:

```bash
#!/usr/bin/env bats

@test "setup.sh is executable" {
  [ -x "./setup.sh" ]
}

@test "setup.sh has valid bash syntax" {
  bash -n setup.sh
}

@test "help flag works" {
  run ./setup.sh --help
  [ "$status" -eq 0 ]
}
```

---

## CI/CD Testing (GitHub Actions)

See `.github/workflows/test.yml` for automated testing on:
- Ubuntu 22.04
- macOS (latest)
- Multiple shell configurations (bash, zsh)

---

## Common Issues & Debugging

### Issue: "Go not found" after installation

**Debug:**
```bash
# Check if Go was installed
ls -la /usr/local/go/bin/go  # Linux
ls -la /opt/homebrew/bin/go  # macOS Homebrew

# Check PATH
echo $PATH | grep go

# Reload shell
source ~/.zshrc  # or ~/.bashrc
```

### Issue: "Permission denied" during install

**Debug:**
```bash
# Check if sudo is available
which sudo

# Check if user has sudo rights
sudo -v

# Try manual install
go install github.com/yoanbernabeu/grepai/cmd/grepai@latest
```

### Issue: Setup script hangs

**Debug:**
```bash
# Run with debugging
bash -x setup.sh

# Check for network issues
curl -I https://github.com

# Check disk space
df -h
```

---

## Reporting Test Results

When reporting issues, include:

1. **Environment:**
   - OS: `uname -a`
   - Shell: `echo $SHELL`
   - Go version: `go version` (if installed)

2. **Setup command:**
   ```bash
   ./setup.sh --non-interactive  # or whatever flags you used
   ```

3. **Output:**
   ```
   [Paste full output here]
   ```

4. **Error messages:**
   ```
   [Paste any errors here]
   ```

5. **Verification:**
   ```bash
   which grepai
   which bd
   ls -la ~/.beads/
   cat ~/.zshrc | grep "go/bin"
   ```

---

## Test Coverage Goals

- [ ] macOS with Homebrew
- [ ] macOS without Homebrew
- [ ] Ubuntu 22.04 LTS
- [ ] Ubuntu 24.04 LTS
- [ ] Debian 11
- [ ] CentOS 8
- [ ] Fedora (latest)
- [ ] Arch Linux
- [ ] WSL2 (Ubuntu)
- [ ] Fresh installs
- [ ] Partial installs
- [ ] Re-runs (idempotency)
- [ ] All command-line flags
- [ ] Interactive and non-interactive modes

---

## Contributing Test Cases

Found a bug? Add a test case:

1. Document the scenario in this file
2. Add steps to reproduce
3. Add expected behavior
4. Submit PR with the test case

Example:

```markdown
### Test Case X: Your Scenario

**Setup:**
- Describe initial state

**Steps:**
\`\`\`bash
./setup.sh [flags]
\`\`\`

**Expected:**
- What should happen

**Actual:**
- What actually happened (if bug)
```

---

**Need help testing?** Open an issue with the `testing` label.
