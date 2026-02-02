# Contributing to grepai-beads-helpers

Thank you for your interest in contributing! This project exists to eliminate boring, repetitive setup tasks for [grepai](https://github.com/yoanbernabeu/grepai) and [beads](https://github.com/steveyegge/beads).

## Philosophy

This project embodies the **automation-first mindset**:

1. **Detect tedium** - "Do this for all projects..." = automation opportunity
2. **Script it once** - Write the automation, never do it manually again
3. **Make it persistent** - Save scripts, add to PATH, create hooks
4. **Share it** - Others have the same problems

If you find yourself doing something manually more than once, that's a contribution opportunity.

## How to Contribute

### Reporting Issues

**Found a bug?** Open an issue with:
- What you expected to happen
- What actually happened
- Steps to reproduce
- Your OS and shell (macOS/Linux, bash/zsh)
- Relevant output/error messages

**Have a feature idea?** Open an issue describing:
- The repetitive task you want to automate
- How you currently do it manually
- Your proposed automation approach

### Contributing Code

1. **Fork the repository** and create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following the code style guidelines below

3. **Test your changes** on multiple scenarios (see Testing section)

4. **Commit with clear messages** (see Commit Conventions)

5. **Open a Pull Request** with:
   - Clear description of what the change does
   - Why it's needed (what problem it solves)
   - Testing performed
   - Any breaking changes

## Development Setup

### Prerequisites

- macOS or Linux
- Bash or Zsh shell
- Basic shell scripting knowledge
- Git

### Local Testing

Test scripts in a safe environment before submitting:

```bash
# Create a test directory
mkdir -p test-projects/sample-project
cd test-projects/sample-project
git init

# Test your script
../../your-script.sh

# Clean up when done
cd ../..
rm -rf test-projects/
```

**Important:** Never test destructive scripts on your actual projects first!

## Code Style

### Shell Scripts

**General Rules:**
- Use `#!/usr/bin/env bash` for portability
- Add comments explaining WHY, not WHAT (code shows what)
- Use functions for reusable logic
- Set error handling at the top: `set -e` (exit on error)
- Use `shellcheck` to validate scripts

**Variables:**
- Use `UPPER_CASE` for constants
- Use `lower_case` for local variables
- Quote variables: `"$var"` not `$var`
- Use `${var}` for clarity in complex strings

**Error Handling:**
```bash
# Good: Check if command exists before using
if ! command -v grepai &> /dev/null; then
    echo "❌ grepai not found"
    exit 1
fi

# Good: Provide helpful error messages
if [ ! -d "$HOME/GitHub" ]; then
    echo "❌ Directory not found: ~/GitHub/"
    echo "💡 Edit the script to use your project directory"
    exit 1
fi
```

**User Feedback:**
- Use emojis for visual feedback: ✓, ✗, ℹ, 🔍, 📁
- Show progress for long-running operations
- Explain what's happening: "Indexing project X..."
- Summarize results at the end

**Example:**
```bash
#!/usr/bin/env bash
set -e  # Exit on error

# Constants
readonly GREPAI=$(command -v grepai)
readonly PROJECT_DIR="$HOME/GitHub"

# Functions
index_project() {
    local dir="$1"
    local name=$(basename "$dir")

    echo "🔍 Indexing: $name"

    if [ -d "$dir/.grepai" ]; then
        echo "  ℹ Already indexed, skipping"
        return 0
    fi

    (cd "$dir" && "$GREPAI" init --yes --provider ollama --backend gob)
    echo "  ✓ Complete"
}

# Main
main() {
    if [ ! -d "$PROJECT_DIR" ]; then
        echo "❌ Directory not found: $PROJECT_DIR"
        exit 1
    fi

    for dir in "$PROJECT_DIR"/*/; do
        [ -d "$dir" ] && index_project "$dir"
    done

    echo "✅ All projects indexed"
}

main "$@"
```

### Commit Conventions

Use clear, descriptive commit messages:

**Format:**
```
Short summary (50 chars max)

Detailed explanation of what changed and why.
Focus on the motivation and context.

- Bullet points for multiple changes
- Reference issues: Fixes #123

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

**Good examples:**
- `Add watch-all-projects.sh for daemon management`
- `Fix: Handle projects with spaces in names`
- `Improve error messages in setup.sh`

**Bad examples:**
- `Update script` (what changed?)
- `Fix bug` (which bug?)
- `WIP` (not ready to commit yet)

## Project Structure

```
grepai-beads-helpers/
├── setup.sh                    # Main installation script
├── index-all-projects.sh       # Bulk project indexing
├── README.md                   # User-facing documentation
├── CONTRIBUTING.md            # This file
├── LICENSE                    # MIT License
├── examples/                  # Usage examples and guides
│   └── claude-code-workflow.md
├── test-projects/             # Local testing (gitignored)
└── .github/
    ├── ISSUE_TEMPLATE/        # Issue templates
    └── pull_request_template.md
```

## Testing Checklist

Before submitting a PR, verify:

**Functionality:**
- [ ] Script runs without errors on macOS
- [ ] Script runs without errors on Linux (if applicable)
- [ ] Works with both bash and zsh
- [ ] Handles edge cases (missing directories, already installed tools, etc.)
- [ ] Provides clear error messages for failures

**Code Quality:**
- [ ] Follows code style guidelines
- [ ] Includes helpful comments
- [ ] Uses functions for reusable logic
- [ ] Has proper error handling
- [ ] Passes `shellcheck` (if applicable)

**User Experience:**
- [ ] Clear progress indicators
- [ ] Helpful error messages
- [ ] Summary of what happened
- [ ] Documentation updated (README.md if needed)

## What Makes a Good Contribution?

**High-value contributions:**
- Automates a tedious, repetitive task
- Handles edge cases gracefully
- Provides clear user feedback
- Works across different environments
- Includes documentation and examples

**Examples of great contributions:**
- `migrate-progress-to-beads.sh` - Automates PROGRESS.md → beads migration
- `watch-all-projects.sh` - Starts grepai watch for all indexed projects
- Better error handling in existing scripts
- Support for additional shells (fish, nushell)
- Windows WSL support

## Code Review Process

1. **Automated checks**: GitHub Actions (when configured) will run shellcheck
2. **Manual review**: Maintainer will review for:
   - Code quality and style
   - User experience
   - Edge case handling
   - Documentation
3. **Feedback**: You may be asked to make changes
4. **Merge**: Once approved, your PR will be merged!

## Getting Help

- **Questions about contributing?** Open a discussion
- **Stuck on something?** Open a draft PR and ask for help
- **Want to pair program?** Mention it in an issue

## Recognition

Contributors are recognized in:
- Git commit history (Co-Authored-By tags)
- Release notes
- README credits section (for significant contributions)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
