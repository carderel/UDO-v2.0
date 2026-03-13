# UDO Documentation

Welcome! This folder explains the **UDO (Universal Dynamic Orchestrator) framework** and how to use it.

## New to UDO?

**Start here, in order:**

1. **[QUICK_START.md](QUICK_START.md)** — Install UDO and run your first session (10 minutes)
2. **[FOLDER_GUIDE.md](FOLDER_GUIDE.md)** — Understand what each folder does and when to use it
3. **[UDO/START_HERE.md](../UDO/START_HERE.md)** — Begin actual work (read by AI agent at session start)

## What is UDO?

UDO gives AI assistants persistent memory, structure, and accountability across sessions.

**Without UDO:** Every AI session starts fresh. Context is lost, decisions are forgotten, handoffs are chaos.

**With UDO:** Sessions are connected. AI reads previous work, maintains state, logs decisions, and hands off cleanly to the next session.

## The 3-Layer Structure

UDO splits concerns into 3 layers to keep things clear:

| Layer | Folder | Purpose |
|-------|--------|---------|
| **Learning** | `DOCUMENTATION/` | Understand how UDO works (you are here) |
| **Tooling** | `TOOLS/` | Skills and capabilities (coming soon) |
| **Framework** | `UDO/` | The actual orchestration engine |

When you're ready to work, you spend time in `UDO/`. When you're confused about setup or structure, come back to `DOCUMENTATION/`.

## Key Concepts

- **Sessions** — Discrete AI work periods that are logged and tracked
- **State** — Current goal, phase, todos, blockers (in `PROJECT_STATE.json`)
- **Checkpoints** — Snapshots of progress for recovery if context is lost
- **Agents** — Specialized AI personas for specific task types
- **Memory** — Persistent facts, working notes, and temporary scratchpad
- **Hard Stops** — Absolute rules that govern protocol compliance

See [FOLDER_GUIDE.md](FOLDER_GUIDE.md) for details on each folder and what it manages.

## Troubleshooting

**"Where do I read START_HERE?"**
- If you're NEW to UDO: Read `QUICK_START.md` first (this folder)
- If you're RESUMING work: Read `UDO/START_HERE.md` (inside the framework folder)

**"Which folder should I edit?"**
- See [FOLDER_GUIDE.md](FOLDER_GUIDE.md) for detailed role of each folder

**"What does the AI read at session start?"**
- `UDO/START_HERE.md` — This is the entry point for AI agents

**"Where do my session logs go?"**
- `UDO/.project-catalog/sessions/` — All session logs are stored here

## Quick Links

- **[QUICK_START.md](QUICK_START.md)** — Setup and first session
- **[FOLDER_GUIDE.md](FOLDER_GUIDE.md)** — Complete folder reference
- **[UDO/ORCHESTRATOR.md](../UDO/ORCHESTRATOR.md)** — Full UDO protocol (advanced)
- **[UDO/HARD_STOPS.md](../UDO/HARD_STOPS.md)** — Absolute rules
- **[UDO/PROJECT_STATE.json](../UDO/PROJECT_STATE.json)** — Current project state

---

**Ready to get started?** → Open [QUICK_START.md](QUICK_START.md)
