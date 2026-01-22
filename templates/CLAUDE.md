# Claude Code Configuration

> **Note:** This file should be placed at `~/.claude/CLAUDE.md` for Claude Code to automatically load these instructions.
>
> The setup script can create this automatically, or you can copy it manually.

## Efficiency Tools - Automatic Usage Rules

### CRITICAL: Use These Tools Automatically

#### 1. Semantic Code Search (grepai)

**Tool:** grepai - Semantic code search using vector embeddings

**What it does:** Unlike grep (exact text matching), grepai indexes the *meaning* of your code using vector embeddings, enabling natural language searches like "find authentication logic" or "where is error handling".

**Auto-use when:**
- User asks: "find...", "where is...", "show me...", "locate..."
- Searching for patterns, implementations, or features across codebase
- Need to understand "what code does X" vs exact text matching
- Looking for similar code patterns or functionality

**Behavior:**
1. Check if project is indexed (`.grepai/` directory exists)
2. If indexed: Use grepai FIRST, fall back to Grep only if grepai fails
3. If not indexed: Use Grep with a one-time notice: "💡 Run 'grepai init' for semantic search"

**Setup per project:**
```bash
cd project
grepai init --provider ollama --backend gob
# Or use OpenAI: grepai init --provider openai --backend gob
```

**Common grepai commands:**
```bash
grepai query "find authentication code"    # Semantic search
grepai query "error handling patterns"     # Find by what code does
grepai watch --background                  # Keep index updated
grepai list                                # Show indexed files
```

---

#### 2. Memory System (beads)

**Tool:** bd - Git-backed persistent memory for AI agents

**What it does:** Stores structured memories (tasks, decisions, context) in a git-backed database at `~/.beads/`. Unlike files that you have to remember to read, beads provides semantic search and automatic context retrieval.

**Auto-use when:**
- **Session start:** Query for active context with `bd search "active" --json`
- User asks: "What did we decide...", "Where is...", "Remind me..."
- Before planning: Load relevant architectural decisions
- Tracking multi-step work with dependencies
- User says: "Remember this for next time..."

**Behavior:**
- Automatic queries, no user confirmation needed
- Results are loaded silently and used for context
- Store new memories when user mentions decisions or important context

**Common commands:**
```bash
# Store memories
bd create "Memory title" --body "Detailed information about decision/context"
bd create "Bug fix" --body "Fixed auth issue by..." --tags "bug,auth"

# Query memories
bd search "keyword" --json          # Search by keyword
bd search "authentication"          # Find all auth-related memories
bd ready                            # Show actionable items (tasks marked as ready)

# View and manage
bd show <id>                        # View memory details
bd update <id> --status "done"      # Update memory status
bd close <id>                       # Mark as complete
bd list --limit 10                  # List recent memories
```

**Memory structure:**
```json
{
  "title": "Short description",
  "body": "Detailed information",
  "tags": ["tag1", "tag2"],
  "status": "active|done|blocked",
  "dependencies": ["other-memory-id"]
}
```

---

### Detection Patterns

Automatically use these tools when you see these patterns in user messages:

| User Input Pattern | Auto-Use Tool | Example Action |
|-------------------|---------------|----------------|
| "find\|locate\|where is" + code | grepai (if indexed) | `grepai query "user query"` |
| "we decided\|last time\|previously" | bd search | `bd search "decision" --json` |
| "what's the status of..." | bd ready | `bd ready` |
| "remember this\|save this" | bd create | `bd create "title" --body "..."` |
| "show me all\|list" + past context | bd list | `bd list --limit 20` |

---

### Fallback Strategy

**Rule:** Never block on missing tools. Degrade gracefully.

1. **Try tool automatically** (if installed and appropriate)
2. **If tool fails/missing:** Use default method + notify user once
3. **Never say:** "Tool X is not installed. Please install it first."

**Good examples:**
```
✅ "Using Grep for search (run 'grepai init' in this project for semantic search). Results:..."
✅ "Storing in project notes (install beads for git-backed memory: go install github.com/steveyegge/beads/cmd/bd@latest)"
✅ "Searched codebase with Grep. For semantic search across all projects, consider installing grepai."
```

**Bad examples:**
```
❌ "grepai is not installed. Please install it first."
❌ "I cannot search without grepai."
❌ "Error: beads command not found."
```

---

### Integration Examples

#### Example 1: Finding Code
```
User: "Where is the authentication logic?"

Assistant (internal):
1. Check if .grepai/ exists in current project
2. If yes: Run `grepai query "authentication logic"`
3. If no: Run `grep -r "authentication" --include="*.js" --include="*.ts"`

Assistant (to user):
"Found authentication logic in src/auth/login.ts:45 and src/middleware/auth.ts:12.

[Show results...]

💡 Tip: This project isn't indexed yet. Run 'grepai init' for semantic search across your entire codebase."
```

#### Example 2: Remembering Decisions
```
User: "We decided to use JWT for auth instead of sessions. Remember this."

Assistant (internal):
1. Run: bd create "Auth decision: JWT over sessions" --body "Team decided to use JWT tokens for authentication instead of server-side sessions. Reasons: stateless, better for microservices, easier horizontal scaling." --tags "auth,architecture,decision"

Assistant (to user):
"Noted. I've stored this decision in memory and will reference it when working on authentication features."
```

#### Example 3: Session Start Context Loading
```
Assistant (internal - every session start):
1. Run: bd search "active" --json
2. Run: bd search "in-progress" --json
3. Run: bd ready --json
4. Load results into context silently

Assistant (to user):
"Welcome back! I see you're working on:
- JWT authentication implementation (active)
- Migrating database to PostgreSQL (in-progress)

What would you like to work on?"
```

---

## Tool Installation Status

> The setup script tracks what's installed. Update this section after running setup.

- [ ] **grepai** - Installed at `~/go/bin/grepai`
- [ ] **beads** - Installed at `~/go/bin/bd`
- [ ] **Ollama** - Running for embeddings (alternative: OpenAI)

---

## Configuration Details

**grepai:**
- Embeddings provider: Ollama (local) or OpenAI (cloud)
- Storage backend: GOB (fast, local)
- Index location: `.grepai/` in each project root

**beads:**
- Memory location: `~/.beads/`
- Backend: Git (automatic versioning and backup)
- Push to remote: Optional (recommended for backup)

---

**Installed by:** [grepai-beads-helpers](https://github.com/miqcie/grepai-beads-helpers)
**Documentation:** See repository README for detailed setup and usage

---

## Troubleshooting

### grepai not found
```bash
# Check installation
ls -la ~/go/bin/grepai

# If missing, reinstall
go install github.com/yoanbernabeu/grepai/cmd/grepai@latest

# Ensure PATH includes ~/go/bin
echo $PATH | grep "go/bin"

# Add to PATH if missing
echo 'export PATH="$HOME/go/bin:$PATH"' >> ~/.zshrc  # or ~/.bashrc
source ~/.zshrc
```

### beads not found
```bash
# Check installation
ls -la ~/go/bin/bd

# If missing, reinstall
go install github.com/steveyegge/beads/cmd/bd@latest

# Initialize if needed
cd ~ && bd init
```

### grepai index errors
```bash
# Check Ollama is running (if using Ollama)
ollama list

# If Ollama not running
ollama serve

# Re-initialize project
rm -rf .grepai
grepai init --provider ollama --backend gob
```

### beads git errors
```bash
# Ensure git is initialized
cd ~/.beads
git status

# If not a git repo
cd ~/.beads && git init && git add . && git commit -m "Initial commit"
```
