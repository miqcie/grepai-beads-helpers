#### Example 1: Finding Code (The Right Way)

**Workflow:** Find → Read → Remember → Code

```
User: "Add a logout endpoint to match our authentication pattern"

Assistant (internal):
1. Check beads for existing auth decisions:
   bd search "authentication" --json
   → Found: "We use JWT tokens, refresh in Redis"

2. Find relevant files with grepai:
   grepai query "authentication endpoint logout"
   → Found: src/auth/login.ts, src/middleware/auth.ts

3. Read FULL files (not just snippets!):
   Read src/auth/login.ts
   Read src/middleware/auth.ts
   → Understand full implementation patterns

4. Store new decision in beads:
   bd create "Logout endpoint added" --body "Added /logout endpoint following same pattern as /login: validates JWT, clears Redis refresh token, returns 200" --tags "auth,api"

Assistant (to user):
"I've found your authentication code and reviewed the full implementation. Your login endpoint uses:
- JWT validation in middleware (auth.ts:45)
- Redis for refresh tokens (login.ts:120)
- Standard error handling pattern

I'll add the logout endpoint following the same patterns.

[Implements logout endpoint...]

💡 Stored this decision in memory for future auth work."
```

**Key points:**
- ✅ grepai finds files quickly (better than blind search)
- ✅ Read tool gets FULL context (not just snippets)
- ✅ beads remembers patterns (consistency across sessions)
- ✅ Claude makes informed decisions (not lazy coding)

**What NOT to do:**
```
❌ BAD: Use grepai results directly
   grepai query "logout"
   → See 5 lines of code
   → Code from snippet only
   → Miss surrounding context

✅ GOOD: Use grepai to find, then read fully
   grepai query "logout"
   → Find logout.ts
   → Read full file
   → Understand patterns
   → Implement correctly
```

---

### Reddit Community Concern Addressed

**Q:** "Does semantic search make Claude lazier by giving snippets?"

**A:** Only if misused! The right workflow is:
1. **grepai** = Fast discovery tool (finds the right files)
2. **Read** = Full context tool (understands implementation)
3. **beads** = Memory tool (preserves decisions)
4. **Code** = Informed implementation (maintains patterns)

**Together, they make Claude MORE informed, not less.**
