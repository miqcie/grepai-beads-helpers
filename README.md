# grepai-beads-helpers

One-command setup for [grepai](https://github.com/yoanbernabeu/grepai) (semantic code search) and [beads](https://github.com/steveyegge/beads) (AI agent memory).

Setting up these tools across multiple projects means repeating the same steps: install Go, configure PATH, run init, reload shell. This automates all of it.

## Tools Covered

- **[grepai](https://github.com/yoanbernabeu/grepai)** - Semantic code search using vector embeddings. Search by what code *does*, not just what it's called. ✅ Available now
- **[beads](https://github.com/steveyegge/beads)** - Git-backed persistent memory for AI agents. Track tasks, dependencies, and context across sessions. ✅ Available now

## Quick Start

**New to grepai and beads?** Start here:

```bash
# Clone this repo
git clone https://github.com/miqcie/grepai-beads-helpers.git
cd grepai-beads-helpers

# Run the setup script (installs everything)
./setup.sh
```

The setup script will:
1. ✅ Check/install Go (required for grepai and beads)
2. ✅ Install grepai (semantic code search)
3. ✅ Install beads (AI agent memory)
4. ✅ Configure your shell PATH
5. ✅ Create CLAUDE.md with auto-usage rules (optional)
6. ✅ Check for Ollama (embeddings provider)

After setup, reload your shell:
```bash
source ~/.zshrc  # or ~/.bashrc
```

Then index your first project:
```bash
cd ~/your-project
grepai init --provider ollama --backend gob
```

---

## Scripts

### 🚀 `setup.sh` - One-Command Installation

**The easiest way to get started.** Installs grepai, beads, and configures Claude Code automatically.

**What it does:**
- Detects your OS (macOS/Linux) and shell (bash/zsh)
- Checks if Go is installed (installs if missing on macOS)
- Installs grepai and beads from source
- Configures `~/go/bin` in your PATH
- Initializes beads memory at `~/.beads/`
- Creates `~/.claude/CLAUDE.md` with auto-usage rules (optional)
- Verifies Ollama installation for embeddings

**Usage:**
```bash
./setup.sh
```

**Interactive mode** (default): Asks before making changes
**Non-interactive mode**: Uses defaults, no prompts
```bash
./setup.sh --non-interactive
```

**Skip specific steps:**
```bash
./setup.sh --skip-grepai           # Skip grepai installation
./setup.sh --skip-beads            # Skip beads installation
./setup.sh --skip-claude-md        # Skip CLAUDE.md configuration
./setup.sh --skip-go               # Skip Go installation check
```

**Example output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 Detecting Environment
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ℹ OS: macOS
ℹ Package Manager: brew
ℹ Shell: zsh
ℹ Shell config: /Users/you/.zshrc

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Checking Go Installation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Go is installed: go1.21.5

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 Installing grepai
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ grepai installed successfully
ℹ Location: /Users/you/go/bin/grepai

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔮 Installing beads
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ beads installed successfully
ℹ Location: /Users/you/go/bin/bd
✓ beads initialized
ℹ Memory stored in: ~/.beads/

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Setup Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next steps:

1. Reload your shell:
   source /Users/you/.zshrc

2. Index your projects with grepai:
   cd ~/GitHub/your-project
   grepai init --provider ollama --backend gob

3. Start using beads for memory:
   bd create "My first memory"
   bd search "project"
```

**Requirements:**
- macOS or Linux
- Internet connection (for downloading packages)
- Sudo access (only if installing Go via apt/yum)

---

### 🔍 `index-all-projects.sh`

Bulk-initialize grepai for all projects in `~/GitHub/` and `~/projects/`.

**What it does:**
- Finds all project directories in `~/GitHub/` and `~/projects/`
- Initializes grepai with your chosen embeddings provider (defaults to Ollama + GOB storage)
- Skips already-indexed projects
- Shows summary of what was indexed

**Configuration:** Edit the script to match your embeddings provider (see Customization section below)

**Usage:**
```bash
./index-all-projects.sh
```

**Example output:**
```
🔍 Indexing all projects with grepai...

📁 ~/GitHub/
[1] my-api
    ✓ Initialized
[2] frontend-app
    ✓ Already indexed, skipping
...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Complete
  Total:   24 projects
  Indexed: 22 new
  Skipped: 2 already indexed
```

**Prerequisites:**

> **💡 Tip:** Run `./setup.sh` to install everything automatically. The manual steps below are only needed if you prefer manual installation or want to customize your setup.

- [Go](https://go.dev/doc/install) 1.21+ (setup.sh can install this on macOS)
- [grepai](https://github.com/yoanbernabeu/grepai) (setup.sh installs this)
- [beads](https://github.com/steveyegge/beads) (setup.sh installs this)
- **Embeddings provider** (choose one):
  - [Ollama](https://ollama.com/) with cloud or local models (recommended)
  - [OpenAI](https://openai.com/) with API key
  - Any [Ollama-compatible provider](https://github.com/ollama/ollama?tab=readme-ov-file#community-integrations)

**Manual Installation (Optional):**

Only follow these steps if you're NOT using `setup.sh`:

```bash
# Install Go (if not already installed)
brew install go  # macOS
# OR: sudo apt-get install golang-go  # Ubuntu/Debian
# OR: sudo yum install golang  # CentOS/RHEL

# Ensure ~/go/bin is in your PATH
echo 'export PATH="$HOME/go/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Install grepai
go install github.com/yoanbernabeu/grepai/cmd/grepai@latest

# Install beads
go install github.com/steveyegge/beads/cmd/bd@latest
cd ~ && bd init

# Install embeddings provider (pick one):

## Option A: Ollama (recommended if using Claude Code)
brew install ollama
brew services start ollama
# Use your existing Ollama models, or:
ollama pull nomic-embed-text  # For local embeddings

## Option B: OpenAI
# Just set OPENAI_API_KEY environment variable
export OPENAI_API_KEY="sk-..."
```

---

## Installation

**Recommended: Use the automated setup script**

```bash
# Clone this repo
git clone https://github.com/miqcie/grepai-beads-helpers.git
cd grepai-beads-helpers

# Run setup (installs grepai + beads + configures everything)
./setup.sh

# Reload your shell
source ~/.zshrc  # or ~/.bashrc

# Bulk index all your projects
./index-all-projects.sh
```

**Alternative: Manual installation**

If you prefer to install tools manually or already have them installed:

```bash
# Clone this repo
git clone https://github.com/miqcie/grepai-beads-helpers.git
cd grepai-beads-helpers

# Make scripts executable
chmod +x *.sh

# Use individual scripts
./index-all-projects.sh
```

---

## Why Automate?

> **If you have to remember to do something more than once, automate it.**

Manual setup across multiple projects is:
- ❌ Boring and tedious
- ❌ Easy to forget
- ❌ Inconsistent (different configs per project)
- ❌ Time-consuming

Automation is:
- ✅ One command, done
- ✅ Consistent configuration
- ✅ Never forget a project
- ✅ More time for actual coding

## Examples

- [Claude Code Workflow](examples/claude-code-workflow.md) - Best practices for using grepai with AI agents

## Customization

### Different Directories

Edit the script to point to your project locations:

```bash
# Add custom directories
if [ -d ~/code ]; then
  echo "📁 ~/code/"
  for dir in ~/code/*/; do
    [ -d "$dir" ] && index_dir "$dir"
  done
fi
```

### Different Embeddings Providers

**Choose based on your existing setup:**

#### Use What You Already Have

If you're using Claude Code with Ollama cloud models (e.g., GLM 4.7), use those same models for grepai:

```bash
# In the script, change:
"$GREPAI" init --yes --provider ollama --backend gob
```

Then configure grepai to use your Ollama cloud model. See [Ollama's Claude Code integration docs](https://docs.ollama.com/integrations/claude-code) for model recommendations.

#### OpenAI (Cloud)

If you already have OpenAI API credits:

```bash
# Set your OpenAI API key
export OPENAI_API_KEY="sk-..."

# In the script, change:
"$GREPAI" init --yes --provider openai --backend gob
```

**Note:** Charges per embedding. See [OpenAI pricing](https://openai.com/api/pricing/).

#### Local Models (Ollama)

For completely local, private embeddings:

```bash
# Default in script - uses nomic-embed-text locally
"$GREPAI" init --yes --provider ollama --backend gob
```

### Embedding Provider Comparison

| Provider | Privacy | Cost | Setup | Best For |
|----------|---------|------|-------|----------|
| **Ollama Cloud** | Cloud | Varies | Existing Claude Code users | Consistent with current workflow |
| **Ollama Local** | Local | Free | Requires local model | Complete privacy, no API keys |
| **OpenAI** | Cloud | Pay-per-use | API key required | Already using OpenAI services |

**Recommendation:** Use whatever you're already using for Claude Code or other AI tools. Consistency simplifies your setup.

See also:
- [Ollama Community Integrations](https://github.com/ollama/ollama?tab=readme-ov-file#community-integrations)
- [Ollama Official Integrations](https://ollama.com/)

## Roadmap

- [x] `setup.sh` - One-command installation for grepai + beads + CLAUDE.md configuration ✅ **Available now**
- [ ] `migrate-progress-to-beads.sh` - Convert existing PROGRESS.md files to beads memories
- [ ] `watch-all-projects.sh` - Start grepai watch daemons for all indexed projects
- [ ] `sync-beads.sh` - Push/pull beads memory to remote git repository
- [ ] Auto-detection of which projects need indexing (based on recent git changes)

## Contributing

Pull requests welcome! Especially for:
- Beads automation scripts
- Windows/Linux compatibility improvements
- Better error handling
- New use cases

## Philosophy

These scripts embody the **automation-first mindset**:

1. **Detect tedium** - "Do this for all projects..." = automation opportunity
2. **Script it once** - Write the automation, never do it manually again
3. **Make it persistent** - Save to `~/scripts/`, add to PATH, create hooks
4. **Share it** - Others have the same problems

## License

MIT License - see [LICENSE](LICENSE)

## Credits

- [grepai](https://github.com/yoanbernabeu/grepai) by Yoan Bernabeu
- [beads](https://github.com/steveyegge/beads) by Steve Yegge
- Community contributions welcome!

## Related Projects

- [Claude Code](https://claude.ai/code) - AI coding assistant that works great with these tools
- [Ollama](https://ollama.com/) - Local LLM runtime for embeddings
- [DeepWiki for beads](https://deepwiki.com/steveyegge/beads) - Interactive beads documentation
