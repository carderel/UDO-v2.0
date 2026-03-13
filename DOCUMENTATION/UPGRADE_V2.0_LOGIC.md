# UDO Upgrade Tool v2.0 - Logic Implementation Guide

## Overview
Both `upgrade.sh` (Bash) and `upgrade.ps1` (PowerShell) have been updated to support the v2.0 directory structure with three operational modes:
1. **Fresh Install** - Create new v2.0 structure from scratch
2. **v4.x Migration** - Migrate existing v4.x to v2.0 structure (with full data preservation)
3. **v2.0 Upgrade** - Update framework only, preserving project data
4. **v4.x In-Place Upgrade** - Keep v4.x structure but update files (backward compatible)

---

## Detection Logic

### Automatic Detection
Scripts detect installation type based on directory structure:

```bash
# Bash pseudocode
if [ -d "./UDO Framework" ] && [ -d "./UDO Project" ]; then
    INSTALL_TYPE="v2.0"
elif [ -d "./UDO" ]; then
    INSTALL_TYPE="v4.x"
else
    INSTALL_TYPE="fresh"
fi
```

```powershell
# PowerShell pseudocode
if ((Test-Path "./UDO Framework") -and (Test-Path "./UDO Project")) {
    $INSTALL_TYPE = "v2.0"
} elseif (Test-Path "./UDO") {
    $INSTALL_TYPE = "v4.x"
} else {
    $INSTALL_TYPE = "fresh"
}
```

### Force Flags
- `upgrade.sh --fresh` - Force fresh installation
- `upgrade.sh --migrate` - Force v4.x to v2.0 migration
- `upgrade.ps1 -Fresh` - PowerShell equivalent
- `upgrade.ps1 -Migrate` - PowerShell equivalent

---

## Mode 1: Fresh Install

**Triggered when:** No UDO installation exists OR `--fresh` flag used

**Operations:**
1. Create directory structure:
   - `UDO/UDO Framework/` - Framework system files
   - `UDO/UDO Project/` - Project data and templates
2. Copy framework files:
   - All system files (ORCHESTRATOR.md, COMMANDS.md, etc.)
   - Framework folders (.bridge/, .templates/, .takeover/, .tools/, .rules/)
3. Create project templates:
   - `PROJECT_META.json` - Project metadata
   - `PROJECT_STATE.json` - Project state
4. Create folder structure:
   - `.memory/` (canonical, working, disposable)
   - `.project-catalog/` (sessions, decisions, agents, etc.)
   - `.outputs/` (.evidence subdirectory)
   - `.checkpoints/`, `.agents/`, `.rules/`
   - `User Uploads/`
5. Initialize `.gitkeep` files for git compatibility

**User Prompt:**
```
Will CREATE (new v2.0 structure):
  + UDO/UDO Framework/
  + UDO/UDO Project/
  + UDO/UDO Project/User Uploads/

Will COPY:
  • All framework files to UDO Framework/
  • Project templates to UDO Project/

[UDO v2.0 Directory Structure diagram]

Create new v2.0 structure? [y/N]
```

**Next Steps Message:**
```
✓ UDO v2.0 fresh install created

Next steps:
  1. cd UDO
  2. Edit UDO/Project/PROJECT_META.json to define your project
  3. Edit UDO/Project/PROJECT_STATE.json to set initial state
  4. Start your LLM CLI from the UDO Project folder

⚠️  IMPORTANT: Your LLM must be run from within the UDO Project directory for proper context loading.
```

---

## Mode 2: v4.x Migration to v2.0

**Triggered when:** `./UDO` exists (v4.x detected) AND user chooses migration OR `--migrate` flag used

**Operations:**
1. Create backup: `.udo-backup-[timestamp]/` (preserves old structure)
2. Create new directory: `UDO/`
3. Move v4.x content:
   - Copy all `./UDO/*` to `UDO/UDO Project/`
   - Preserves all data: .memory/, .project-catalog/, .outputs/, etc.
4. Create framework structure: `UDO/UDO Framework/`
5. Copy framework files to new location
6. Create User Uploads folder (if missing)
7. Update PROJECT_META.json:
   - Set `udo_version: "2.0"`
   - Preserve other fields

**Data Preserved:**
- ✓ `.memory/` - All AI memory (canonical, working, disposable)
- ✓ `.project-catalog/` - Session history, decisions, agents, handoff logs
- ✓ `.outputs/` - All output evidence
- ✓ `.checkpoints/` - Backup checkpoints
- ✓ `.agents/` - Agent definitions
- ✓ `.rules/` - Custom rules
- ✓ `PROJECT_STATE.json` - Project state (if exists)
- ✓ `PROJECT_META.json` - Project metadata (updated with v2.0 version)
- ✓ All other project files

**User Prompt:**
```
UDO v4.x detected at ./UDO

Options:
  1) Migrate to v2.0 (creates UDO Framework/ and UDO Project/, preserves all data)
  2) Upgrade in-place (keep current v4.x structure, backward compatible)

Choose option [1 or 2] (default: 2):
```

**Migration Prompt:**
```
Will MIGRATE (v4.x → v2.0):
  ↦ ./UDO/ → ./UDO/UDO Project/
  ✓ Create ./UDO/UDO Framework/
  ✓ Preserve .project-catalog/, .memory/, .outputs/, etc.
  ✓ Create User Uploads/

[UDO v2.0 Directory Structure diagram]
```

**Completion Message:**
```
✓ Upgraded from [version] to v2.0
✓ All data preserved in UDO/UDO Project/
✓ Backup saved to: .udo-backup-[timestamp]/

Next steps:
  1. Review UDO/UDO Project/PROJECT_META.json
  2. Review migration in UDO/UDO Project/
  3. Start your LLM CLI from the UDO Project folder

⚠️  IMPORTANT: Your LLM must be run from within the UDO Project directory for proper context loading.

If something went wrong, restore from backup:
  rm -rf UDO && mv .udo-backup-[timestamp] UDO
```

---

## Mode 3: v4.x In-Place Upgrade

**Triggered when:** `./UDO` exists (v4.x detected) AND user chooses in-place upgrade (default option 2)

**Operations:**
1. Create backup: `.udo-backup-[timestamp]/`
2. Update framework files in `./UDO/` directly
3. Preserve all project data in `./UDO/`
4. Keep v4.x directory structure unchanged

**Rationale:** Allows gradual migration - users can upgrade immediately and migrate to v2.0 structure later using `upgrade.sh --migrate`

**Completion Message:**
```
✓ Upgraded from [version]
✓ v4.x structure preserved (backward compatible)
✓ Backup saved to: .udo-backup-[timestamp]/

To migrate to v2.0 structure:
  ./upgrade.sh --migrate
```

---

## Mode 4: v2.0 Upgrade

**Triggered when:** Both `./UDO Framework/` and `./UDO Project/` exist

**Operations:**
1. Create backup: `.udo-backup-[timestamp]/` (only of Framework/)
2. Update `UDO Framework/` only:
   - All system files (ORCHESTRATOR.md, COMMANDS.md, VERSION, etc.)
   - Framework folders (.bridge/, .templates/, .takeover/, .tools/, .rules/)
   - README files
3. Preserve `UDO Project/` completely untouched
4. Ensure `UDO Project/User Uploads/` exists (create if missing)

**Framework Update List:**
- ORCHESTRATOR.md
- COMMANDS.md
- START_HERE.md
- REASONING_CONTRACT.md
- DEVILS_ADVOCATE.md
- AUDIENCE_ANTICIPATION.md
- EVIDENCE_PROTOCOL.md
- TEACH_BACK_PROTOCOL.md
- HANDOFF_PROMPT.md
- OVERSIGHT_DASHBOARD.md
- CAPABILITIES.json
- VERSION
- README.md
- .bridge/ (entire folder)
- .templates/ (entire folder)
- .takeover/agent-templates/ (entire folder)
- .tools/ (entire folder)
- .rules/ (entire folder)
- .outputs/.evidence/ (if missing)
- .inputs/ (if missing)

**User Prompt:**
```
Will UPGRADE (v2.0 structure):
  ✓ Update UDO Framework/ only
  ✓ Preserve UDO Project/ data exactly as-is
  ✓ Check User Uploads/ folder exists

Will ADD (new files):
  [list of new files if any]

Will UPDATE (system files):
  [list of system files being updated]

Proceed with upgrade? [y/N]
```

**Completion Message:**
```
✓ Upgraded from [version] to [latest]
✓ UDO Framework/ updated
✓ UDO Project/ data preserved
✓ Backup saved to: .udo-backup-[timestamp]/

If something went wrong, restore from backup:
  rm -rf UDO/UDO\ Framework && mv .udo-backup-[timestamp] UDO/UDO\ Framework
```

---

## Utility Functions

### Bash: `create_project_structure()`
Creates all required folders and .gitkeep files for a project directory.

```bash
create_project_structure() {
    local proj_path=$1
    mkdir -p "$proj_path/.memory/canonical"
    mkdir -p "$proj_path/.memory/working"
    mkdir -p "$proj_path/.memory/disposable"
    # ... creates all 15+ subdirectories
    # ... creates .gitkeep files for git compatibility
}
```

### Bash: `display_structure_diagram()`
Displays the v2.0 directory structure:
```
UDO/
├── UDO Framework/
│   ├── ORCHESTRATOR.md
│   ├── START_HERE.md
│   ├── COMMANDS.md
│   ├── .bridge/
│   ├── .templates/
│   ├── .takeover/
│   ├── .tools/
│   └── .rules/
└── UDO Project/
    ├── PROJECT_META.json
    ├── PROJECT_STATE.json
    ├── ORCHESTRATOR.md (project-specific)
    ├── .memory/
    ├── .project-catalog/
    ├── .outputs/
    ├── .checkpoints/
    ├── .agents/
    └── User Uploads/
```

### Bash: `update_framework_files()`
Updates all framework files in target directory.

### PowerShell: `New-ProjectStructure`
PowerShell equivalent of Bash `create_project_structure()`.

### PowerShell: `Show-StructureDiagram`
PowerShell equivalent of Bash `display_structure_diagram()`.

### PowerShell: `Update-FrameworkFiles`
PowerShell equivalent of Bash `update_framework_files()`.

---

## Template Files Created

### PROJECT_META.json (v2.0 Fresh Install)
```json
{
  "project_name": "Your Project Name",
  "project_description": "Add your project description",
  "udo_version": "2.0",
  "created": "now",
  "ai_platform": "claude-desktop",
  "custom_settings": {}
}
```

### PROJECT_STATE.json (v2.0 Fresh Install)
```json
{
  "status": "active",
  "last_updated": "now",
  "session_count": 0,
  "handoff_ready": false,
  "critical_state": {}
}
```

### v4.x Migration - PROJECT_META.json Update
```json
{
  "...existing fields...": "preserved",
  "udo_version": "2.0"
}
```

---

## Backup Strategy

### Backup Location
- `./udo-backup-[YYYYMMDD-HHMMSS]/` (e.g., `.udo-backup-20260310-143022/`)

### What Gets Backed Up
- **v4.x Migration:** Entire `./UDO/` directory before migration
- **v4.x In-Place Upgrade:** Entire `./UDO/` directory before update
- **v2.0 Upgrade:** Only `./UDO/UDO Framework/` (project data not touched)

### Restoration
**For v4.x modes:**
```bash
rm -rf UDO && mv .udo-backup-[timestamp] UDO
```

**For v2.0 upgrade:**
```bash
rm -rf "UDO/UDO Framework" && mv .udo-backup-[timestamp] "UDO/UDO Framework"
```

---

## Cross-Platform Behavior

### Identical Behavior Between Bash and PowerShell
Both scripts:
- ✓ Detect installation type using same logic
- ✓ Handle all four modes identically
- ✓ Create same folder structures
- ✓ Create same template files (as JSON)
- ✓ Preserve same data on migration
- ✓ Create backups before destructive operations
- ✓ Display same structure diagrams
- ✓ Provide same user prompts and messages

### Platform-Specific Implementation Details
**Bash (Linux/macOS):**
- Uses `mkdir -p` for recursive directory creation
- Uses `cp -R` for recursive copy
- Uses `find` for README discovery
- Uses `sed` for JSON field updates (with .bak fallback)
- Uses ANSI color codes for output

**PowerShell (Windows):**
- Uses `New-Item -ItemType Directory` with `-Force`
- Uses `Copy-Item -Recurse -Force`
- Uses `Get-ChildItem` with filters
- Uses `ConvertFrom-Json`/`ConvertTo-Json` for JSON manipulation
- Uses `-ForegroundColor` for colored output
- Handles Windows reserved filenames (nul, con, etc.)

---

## Validation Checklist

Post-upgrade verification checklist:

### For Fresh Install
- [ ] `UDO/` directory exists
- [ ] `UDO/UDO Framework/` directory created
- [ ] `UDO/UDO Project/` directory created
- [ ] `UDO/UDO Framework/ORCHESTRATOR.md` exists
- [ ] `UDO/UDO Framework/START_HERE.md` exists
- [ ] `UDO/UDO Project/PROJECT_META.json` exists with v2.0 version
- [ ] `UDO/UDO Project/PROJECT_STATE.json` exists
- [ ] `UDO/UDO Project/.memory/` folder structure complete
- [ ] `UDO/UDO Project/.project-catalog/sessions/` exists
- [ ] `UDO/UDO Project/User Uploads/` exists
- [ ] All .gitkeep files present
- [ ] `UDO/UDO Framework/.bridge/` exists
- [ ] `UDO/UDO Framework/.templates/` exists
- [ ] No duplicate files between Framework and Project

### For v4.x Migration
- [ ] `UDO/UDO Framework/` created
- [ ] `UDO/UDO Project/` contains all v4.x data
- [ ] All original project folders preserved:
  - `.memory/` with all sessions
  - `.project-catalog/` with all history
  - `.outputs/` with all evidence
  - `.checkpoints/` with all checkpoints
  - `.agents/` with all agent definitions
  - `.rules/` with all custom rules
- [ ] `PROJECT_META.json` updated with `udo_version: "2.0"`
- [ ] `PROJECT_STATE.json` preserved
- [ ] `User Uploads/` folder exists
- [ ] `.udo-backup-[timestamp]/` created
- [ ] No files lost during migration

### For v4.x In-Place Upgrade
- [ ] `UDO/` structure unchanged (still v4.x layout)
- [ ] System files updated (ORCHESTRATOR.md, etc.)
- [ ] All project data preserved
- [ ] `.udo-backup-[timestamp]/` created
- [ ] VERSION file updated to latest

### For v2.0 Upgrade
- [ ] `UDO/UDO Framework/` updated with latest files
- [ ] `UDO/UDO Project/` untouched
  - All .memory/ files preserved
  - All .project-catalog/ files preserved
  - All .outputs/ files preserved
  - PROJECT_STATE.json unchanged
- [ ] `User Uploads/` exists in project
- [ ] `.udo-backup-[timestamp]/` contains only Framework backup
- [ ] VERSION file in Framework updated to latest
- [ ] No duplicate files between Framework and Project

### General Validation
- [ ] `VERSION` file reads correctly
- [ ] `PROJECT_META.json` is valid JSON (if exists)
- [ ] `PROJECT_STATE.json` is valid JSON (if exists)
- [ ] All folders have proper permissions
- [ ] No orphaned files or folders

---

## Test Scenarios

### Test 1: Fresh Install
**Setup:** Clean environment with no UDO folder
```bash
cd /tmp/test-fresh && ./upgrade.sh
```
**Expected:**
- Creates UDO/UDO Framework/ with all framework files
- Creates UDO/UDO Project/ with templates
- Creates all required folders (.memory/, .project-catalog/, etc.)
- Displays structure diagram
- Creates backups? No (fresh install)

### Test 2: v4.x Migration (Interactive)
**Setup:** Existing UDO/ folder with v4.x structure
```bash
cd /path/to/existing/v4x && ./upgrade.sh
# Choose option 1 (migrate)
```
**Expected:**
- Prompts for migration option
- Creates .udo-backup-[timestamp]/
- Moves UDO/ content to UDO/UDO Project/
- Creates UDO/UDO Framework/ with latest files
- Updates PROJECT_META.json with v2.0
- All data preserved

### Test 3: v4.x Migration (Force)
**Setup:** Existing UDO/ folder with v4.x structure
```bash
cd /path/to/existing/v4x && ./upgrade.sh --migrate
```
**Expected:**
- Skips interactive prompt
- Auto-chooses migration
- Same result as Test 2

### Test 4: v4.x In-Place Upgrade (Interactive)
**Setup:** Existing UDO/ folder with v4.x structure
```bash
cd /path/to/existing/v4x && ./upgrade.sh
# Choose option 2 (in-place) or press Enter
```
**Expected:**
- Prompts for upgrade option
- Creates .udo-backup-[timestamp]/
- Updates files in ./UDO/ directly
- Keeps v4.x structure intact
- User can migrate later with --migrate flag

### Test 5: v2.0 Upgrade
**Setup:** Existing v2.0 installation
```bash
cd /path/to/v2.0 && ./upgrade.sh
```
**Expected:**
- Detects v2.0 structure
- Updates UDO/UDO Framework/ only
- Creates .udo-backup-[timestamp]/ (Framework only)
- Preserves UDO/UDO Project/ completely
- Ensures User Uploads/ exists

### Test 6: Already Latest Version
**Setup:** v4.x or v2.0 installation already at latest version
```bash
cd /path/to/latest && ./upgrade.sh
```
**Expected:**
- Detects already latest
- Exits with message
- No changes made
- No backup created

### Test 7: PowerShell Equivalents
**Setup:** Same as Tests 1-6 but on Windows
```powershell
cd C:\path\to\test && ./upgrade.ps1
./upgrade.ps1 -Fresh
./upgrade.ps1 -Migrate
./upgrade.ps1 -Yes
```
**Expected:**
- Same behavior as Bash versions
- Proper Windows path handling
- Reserved filename handling via robocopy

---

## Breaking Changes

None. The scripts maintain backward compatibility:
- v4.x in-place upgrade still works
- All existing data is preserved
- Users can stay on v4.x or migrate to v2.0
- Upgrade script can be run without arguments

---

## Future Enhancements

Potential additions:
1. Validation command: `upgrade.sh --validate` - Check integrity
2. Dry-run mode: `upgrade.sh --dry-run` - Show what would change
3. Interactive migration assistant: Step-by-step guided migration
4. Rollback verification: `upgrade.sh --verify-backup` - Check backup integrity
5. Statistics: `upgrade.sh --stats` - Show what was preserved/updated

---

## Support Commands

| Command | Behavior |
|---------|----------|
| `upgrade.sh` | Auto-detect and perform appropriate operation |
| `upgrade.sh --yes` | Auto-confirm all prompts |
| `upgrade.sh --fresh` | Create new v2.0 structure |
| `upgrade.sh --migrate` | Force migration from v4.x to v2.0 |
| `upgrade.sh --yes --migrate` | Migrate without prompts |
| `upgrade.ps1` | PowerShell equivalent |
| `upgrade.ps1 -Yes` | Auto-confirm (PowerShell) |
| `upgrade.ps1 -Fresh` | Fresh install (PowerShell) |
| `upgrade.ps1 -Migrate` | Force migrate (PowerShell) |
| `upgrade.ps1 -Yes -Migrate` | Migrate without prompts (PowerShell) |

---

## File Locations

**Script locations:**
- Bash: `/Users/flackfizer/Documents/Projects/UDO-Upgrade-Kit-repo/upgrade.sh`
- PowerShell: `/Users/flackfizer/Documents/Projects/UDO-Upgrade-Kit-repo/upgrade.ps1`

**Deployed to:**
- GitHub: `carderel/UDO-Upgrade-Kit` main branch
- Used by: `carderel/UDO-No-Script-Complete` installations
- Used by: `carderel/Ultimate-UDO` installations (Ultimate version)

---

## Version History

- **v2.0** (2026-03-10): Added fresh install, v4.x migration, v2.0 upgrade modes with cross-platform support
- **v1.0** (2024-XX-XX): Initial upgrade tool for v4.x installations

