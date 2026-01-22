# grepai-beads-helpers

Automation scripts for [grepai](https://github.com/yoanbernabeu/grepai) (semantic code search) and [beads](https://github.com/steveyegge/beads) (AI agent memory). Built to eliminate boring, repetitive setup tasks.

## What This Solves

**The Problem:** Setting up grepai across 20+ projects or initializing beads manually is tedious, time-consuming, and easy to forget.

**The Solution:** One-command automation that handles bulk operations for you.

## Tools Covered

- **[grepai](https://github.com/yoanbernabeu/grepai)** - Semantic code search using vector embeddings. Search by what code *does*, not just what it's called.
- **[beads](https://github.com/steveyegge/beads)** - Git-backed persistent memory for AI agents. Track tasks, dependencies, and context across sessions.

## Scripts

### 🔍 `index-all-projects.sh`

Bulk-initialize grepai for all projects in `~/GitHub/` and `~/projects/`.

**What it does:**
- Finds all project directories
- Initializes grepai with Ollama embeddings + GOB storage
- Skips already-indexed projects
- Shows summary of what was indexed

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
- [grepai](https://github.com/yoanbernabeu/grepai) installed
- [Ollama](https://ollama.com/) running with `nomic-embed-text` model

```bash
# Install prerequisites
brew install ollama
ollama pull nomic-embed-text
ollama serve

# Install grepai
go install github.com/yoanbernabeu/grepai/cmd/grepai@latest
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

### Different Embeddings Provider

Change from Ollama to OpenAI:

```bash
# In the script, change:
"$GREPAI" init --yes --provider openai --backend gob
```

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
