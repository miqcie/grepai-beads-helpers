# grepai-beads-helpers

Automation scripts for [grepai](https://github.com/yoanbernabeu/grepai) (semantic code search) and [beads](https://github.com/steveyegge/beads) (AI agent memory). Built to eliminate boring, repetitive setup tasks.

## What This Solves

**The Problem:** Setting up grepai across 20+ projects or initializing beads manually is tedious, time-consuming, and easy to forget.

**The Solution:** One-command automation that handles bulk operations for you.

## Tools Covered

- **[grepai](https://github.com/yoanbernabeu/grepai)** - Semantic code search using vector embeddings. Search by what code *does*, not just what it's called. ✅ Scripts available now
- **[beads](https://github.com/steveyegge/beads)** - Git-backed persistent memory for AI agents. Track tasks, dependencies, and context across sessions. 🚧 Scripts coming soon

## Scripts

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

For grepai scripts (available now):
- [Go](https://go.dev/doc/install) 1.21+ (required for grepai installation)
- [grepai](https://github.com/yoanbernabeu/grepai) installed
- **Embeddings provider** (choose one):
  - [Ollama](https://ollama.com/) with cloud or local models
  - [OpenAI](https://openai.com/) with API key
  - Any [Ollama-compatible provider](https://github.com/ollama/ollama?tab=readme-ov-file#community-integrations)

For beads scripts (coming soon):
- [beads](https://github.com/steveyegge/beads) installed
- Git initialized in home directory (for memory persistence)

```bash
# Install Go (if not already installed)
brew install go

# Ensure ~/go/bin is in your PATH
echo 'export PATH="$HOME/go/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Install grepai
go install github.com/yoanbernabeu/grepai/cmd/grepai@latest

# Install embeddings provider (pick one):

## Option A: Ollama (recommended if using Claude Code)
brew install ollama
brew services start ollama
# Use your existing Ollama models, or:
ollama pull nomic-embed-text  # For local embeddings

## Option B: OpenAI
# Just set OPENAI_API_KEY environment variable

# Install beads (optional, for future scripts)
go install github.com/steveyegge/beads/cmd/bd@latest
cd ~ && bd init
```

## Installation

```bash
# Clone this repo
git clone https://github.com/miqcie/grepai-beads-helpers.git
cd grepai-beads-helpers

# Make scripts executable
chmod +x *.sh

# Run what you need
./index-all-projects.sh
```

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

- [ ] `setup-beads.sh` - Automated beads initialization with git integration
- [ ] `migrate-progress-to-beads.sh` - Convert PROGRESS.md files to beads memories
- [ ] `watch-all-projects.sh` - Start grepai watch daemons for all indexed projects
- [ ] Auto-detection of which projects need indexing (based on recent changes)

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
