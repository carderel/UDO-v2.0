# UDO v2.0: Universal Dynamic Orchestrator

**Multi-LLM Safe Session Orchestration Framework**

UDO v2.0 solves a critical problem: **AIs accidentally working in framework code instead of project code**.

This release introduces architectural separation with `/UDO Framework/` (immutable reference) and `/UDO Project/` (isolated working context) to make scope unambiguous at the filesystem level.

## What's New in v2.0

- ✅ **Framework/Project Separation**: Dual-folder architecture prevents scope confusion
- ✅ **Multi-LLM Safety**: Concurrent AI coordination with conflict detection (HS-UDO-015)
- ✅ **Session Transcripts**: Write-once, append-only raw session exchanges for data recovery
- ✅ **Conflict Detection**: Automatic detection of simultaneous modifications across AIs
- ✅ **Framework Immutability**: Hard stops prevent Framework contamination (HS-UDO-014)
- ✅ **Real-time Persistence**: Transcripts written after each response (guarantees max data loss is current in-progress response)

## Quick Start

### For New Projects
```bash
cd /path/to/your/project
git clone https://github.com/carderel/UDO-v2.0.git UDO
cd UDO
./upgrade.sh --fresh
```

### For v4.x Migrations
```bash
cd /path/to/existing/v4x/project
git clone https://github.com/carderel/UDO-v2.0.git UDO-temp
./UDO-temp/upgrade.sh --migrate
# Follows prompts to migrate your existing UDO v4.x structure
```

## Directory Structure

```
UDO/
├── UDO Framework/              ← Read-only immutable reference
│   ├── ORCHESTRATOR.md        (main specification)
│   ├── START_HERE.md          (entry point for new AIs)
│   ├── HARD_STOPS.md          (mandatory protocol rules)
│   ├── COMMANDS.md            (session commands and shortcuts)
│   └── [45+ framework files]
│
└── UDO Project/               ← Your isolated working context
    ├── PROJECT_STATE.json    (current goal, phase, todos)
    ├── PROJECT_META.json     (project identity)
    ├── .project-catalog/     (sessions, decisions, history)
    ├── .memory/              (canonical, working, disposable)
    ├── .outputs/             (deliverables)
    ├── User Uploads/         (provided materials)
    └── [25+ project template files]
```

## The Problem v2.0 Solves

**Before v2.0:** AIs would accidentally work in the framework repo (modifying shared rules) instead of their isolated project folder. This broke other projects using the same framework.

**Solution:** Filesystem-level scope enforcement. `/UDO Framework/` is visually distinct from `/UDO Project/`, making it obvious where work belongs. Hard stops (HS-UDO-014, HS-UDO-015, HS-UDO-016) prevent violations.

## Documentation

- **NEW AI?** Start with `/UDO Framework/START_HERE.md`
- **Architecture Overview?** Read `/UDO Framework/README.md`
- **Upgrading from v4.x?** See `/UDO Framework/MIGRATION-GUIDE.md`
- **Protocol Specification?** Read `/UDO Framework/ORCHESTRATOR.md`
- **Mandatory Rules?** Check `/UDO Framework/HARD_STOPS.md`

## For Framework Developers

The Framework is intentionally immutable. All customizations belong in `/UDO Project/HARD_STOPS.md` or `/UDO Project/.rules/`.

To extend the framework for your project:
1. Read `/UDO Framework/ORCHESTRATOR.md` (immutability section)
2. Add project-specific rules to `/UDO Project/HARD_STOPS.md` (HS-UDO-014 and beyond)
3. Never modify Framework files directly

## Upgrade Scripts

The repository includes intelligent upgrade scripts for both fresh and existing installations:

- **`upgrade.sh`** - Linux/macOS installation and migration
- **`upgrade.ps1`** - Windows PowerShell installation and migration

Both scripts:
- Detect fresh/v4.x/v2.0 installations automatically
- Preserve all project data during migration
- Create backups before any destructive operations
- Support unattended mode with `--yes` flag

## Multi-LLM Coordination

When multiple AIs work on the same project:

1. **Framework is shared** (all AIs read the same immutable rules)
2. **Project is isolated** (each AI works in Project context)
3. **Conflict detection is built-in** (HS-UDO-015: read PROJECT_STATE.json before updating)
4. **Session logs are separate** (no cross-AI contamination)

See `/UDO Framework/ORCHESTRATOR.md` "Concurrent AI Safety" section for details.

## Version History

| Version | Release | Major Features |
|---------|---------|---|
| v4.10   | 2026-03-10 | Session transcript enforcement (HS-UDO-013) |
| v4.9    | 2026-03-08 | Session transcript feature (append-only) |
| v2.0    | 2026-03-10 | Framework/Project separation, multi-LLM safety |

## Contributing

Found a bug or want to improve the framework? Please open an issue or submit a pull request.

## License

MIT License - See LICENSE file for details.

---

**Last Updated:** 2026-03-10
**Status:** PRODUCTION READY
**Build:** Bulletproof (100% red-team validated)
