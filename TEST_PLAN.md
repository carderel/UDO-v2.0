# UDO Upgrade v2.0 - Test Plan

## Test Environment Setup

### Prerequisites
- Bash or PowerShell (depending on platform)
- Network access to download from GitHub
- Write access to test directories
- `jq` (for JSON validation in test scripts)
- Git (for .gitkeep verification)

### Test Directories
```
/tmp/udo-test-{scenario}/
```

---

## Test Scenario 1: Fresh Install

### Setup
```bash
mkdir -p /tmp/udo-test-fresh
cd /tmp/udo-test-fresh
cp path/to/upgrade.sh .
```

### Test Case 1.1: Auto-Detect Fresh Installation
**Command:** `./upgrade.sh`
**User Input:** `y` (confirm)

**Expected:**
- [ ] Script detects "fresh" installation type
- [ ] Displays "Will CREATE (new v2.0 structure)"
- [ ] Shows structure diagram
- [ ] Creates `UDO/` directory
- [ ] Creates `UDO/UDO Framework/` directory
- [ ] Creates `UDO/UDO Project/` directory

**Validation:**
```bash
# Run validation script
./validate-upgrade.sh

# Manual checks
test -d "UDO/UDO Framework" && echo "✓ Framework dir created"
test -d "UDO/UDO Project" && echo "✓ Project dir created"
test -f "UDO/UDO Framework/ORCHESTRATOR.md" && echo "✓ Framework files present"
test -f "UDO/UDO Project/PROJECT_META.json" && echo "✓ Project template created"
ls -la "UDO/UDO Project/.memory/" | grep gitkeep && echo "✓ Gitkeep files present"
```

### Test Case 1.2: Force Fresh Installation
**Command:** `./upgrade.sh --fresh`
**User Input:** `y` (confirm)

**Expected:**
- [ ] Script respects `--fresh` flag
- [ ] Creates v2.0 structure (even if one existed)
- [ ] Shows "Creating new v2.0 installation"
- [ ] Completes successfully

**Validation:**
```bash
cd /tmp/udo-test-fresh-force
./upgrade.sh --fresh -y
test -d "UDO/UDO Framework" && echo "✓ Framework created with flag"
test -f "UDO/UDO Project/PROJECT_STATE.json" && echo "✓ State template created"
```

### Test Case 1.3: Fresh Install with Auto-Yes
**Command:** `./upgrade.sh --fresh -y`
**User Input:** None (auto-confirm)

**Expected:**
- [ ] Script skips confirmation prompt
- [ ] Creates v2.0 structure
- [ ] Completes without user interaction
- [ ] All files present

**Validation:**
```bash
cd /tmp/udo-test-fresh-auto
./upgrade.sh --fresh -y
jq . "UDO/UDO Project/PROJECT_META.json" | grep "udo_version.*2.0"
```

---

## Test Scenario 2: v4.x Migration to v2.0

### Setup
```bash
# Create v4.x structure
mkdir -p /tmp/udo-test-migrate/UDO
cd /tmp/udo-test-migrate/UDO

# Create typical v4.x folders
mkdir -p .memory/canonical .memory/working
mkdir -p .project-catalog/sessions .project-catalog/decisions
mkdir -p .outputs/.evidence .checkpoints .agents .rules

# Create typical v4.x files
echo "4.7" > VERSION
echo '{"status": "active"}' > PROJECT_STATE.json
cp /path/to/ORCHESTRATOR.md .
cp /path/to/COMMANDS.md .

cd ..
cp /path/to/upgrade.sh .
```

### Test Case 2.1: Interactive Migration Choice
**Command:** `./upgrade.sh`
**User Input:** `1` (choose migrate), then `y` (confirm)

**Expected:**
- [ ] Script detects v4.x installation
- [ ] Displays migration options
- [ ] Shows "Will MIGRATE (v4.x → v2.0)" when option 1 selected
- [ ] Creates `.udo-backup-[timestamp]/` backup
- [ ] Creates `UDO/UDO Framework/` with latest files
- [ ] Moves old UDO content to `UDO/UDO Project/`
- [ ] Preserves all `.memory/` files
- [ ] Preserves all `.project-catalog/` files
- [ ] Updates PROJECT_META.json with v2.0 version

**Validation:**
```bash
# Check structure
test -d "UDO/UDO Framework" && echo "✓ Framework created"
test -d "UDO/UDO Project" && echo "✓ Project created"

# Check data preservation
test -f "UDO/UDO Project/.memory/canonical/.gitkeep" && echo "✓ Memory preserved"
test -f "UDO/UDO Project/.project-catalog/sessions/.gitkeep" && echo "✓ Catalog preserved"
test -f "UDO/UDO Project/.outputs/.evidence/.gitkeep" && echo "✓ Outputs preserved"
test -f "UDO/UDO Project/PROJECT_STATE.json" && echo "✓ State preserved"

# Check version update
jq '.udo_version' "UDO/UDO Project/PROJECT_META.json" | grep "2.0" && echo "✓ Version updated"

# Check backup
test -d ".udo-backup-"* && echo "✓ Backup created"
```

### Test Case 2.2: Force Migration
**Command:** `./upgrade.sh --migrate`
**User Input:** `y` (confirm)

**Expected:**
- [ ] Script skips "choose migration type" prompt
- [ ] Displays "Migrating v4.x to v2.0"
- [ ] Performs migration
- [ ] Same result as 2.1

**Validation:**
```bash
./upgrade.sh --migrate -y
test -d "UDO/UDO Framework" && echo "✓ Forced migration works"
jq '.udo_version' "UDO/UDO Project/PROJECT_META.json" | grep "2.0"
```

### Test Case 2.3: Migration with Auto-Yes
**Command:** `./upgrade.sh --migrate -y`
**User Input:** None (auto-confirm both prompts)

**Expected:**
- [ ] Script skips all prompts
- [ ] Performs migration immediately
- [ ] Creates backup
- [ ] All data preserved

**Validation:**
```bash
cd /tmp/udo-test-migrate-auto
# Setup v4.x structure...
./upgrade.sh --migrate -y
# Verify all checks pass
```

### Test Case 2.4: Backup Creation Verification
**Command:** `./upgrade.sh --migrate -y`
**Post-action:** Examine backup

**Expected:**
- [ ] `.udo-backup-[timestamp]/` directory created
- [ ] Backup contains all original v4.x files
- [ ] Backup is usable for restoration

**Validation:**
```bash
# List backup contents
ls -la ".udo-backup-"*

# Check restore command works
rm -rf UDO
mv .udo-backup-* UDO
test -f "UDO/VERSION" && echo "✓ Restore would work"
```

---

## Test Scenario 3: v4.x In-Place Upgrade

### Setup
```bash
# Create v4.x structure with data
mkdir -p /tmp/udo-test-upgrade-inplace/UDO
cd /tmp/udo-test-upgrade-inplace/UDO

mkdir -p .memory/canonical .memory/working
mkdir -p .project-catalog/sessions
mkdir -p .outputs

echo "4.6" > VERSION
echo '{"status": "active"}' > PROJECT_STATE.json

cd ..
cp /path/to/upgrade.sh .
```

### Test Case 3.1: Interactive In-Place Upgrade
**Command:** `./upgrade.sh`
**User Input:** `2` (choose in-place), then `y` (confirm)

**Expected:**
- [ ] Script detects v4.x installation
- [ ] Displays migration options
- [ ] Shows "Will UPGRADE (v4.x in-place)" when option 2 selected
- [ ] Creates `.udo-backup-[timestamp]/` backup
- [ ] Updates framework files in `UDO/`
- [ ] Preserves v4.x directory structure
- [ ] Does NOT create UDO Framework/ or UDO Project/
- [ ] All data remains in `UDO/`

**Validation:**
```bash
# Check structure unchanged
test ! -d "UDO/UDO Framework" && echo "✓ No Framework dir (v4.x mode)"
test ! -d "UDO/UDO Project" && echo "✓ No Project dir (v4.x mode)"
test -f "UDO/VERSION" && echo "✓ Files still in UDO root"
test -d "UDO/.memory" && echo "✓ Data still in UDO/"

# Check version updated
cat UDO/VERSION | grep "4.7\|4.8"
```

### Test Case 3.2: Default to In-Place Upgrade
**Command:** `./upgrade.sh`
**User Input:** (press Enter without choosing)

**Expected:**
- [ ] Script defaults to option 2 (in-place)
- [ ] Performs in-place upgrade
- [ ] Same result as 3.1

**Validation:**
```bash
./upgrade.sh -y
test ! -d "UDO/UDO Framework"
```

### Test Case 3.3: Later Migration from v4.x
**Command:** `./upgrade.sh --migrate -y`
**Prerequisites:** Previous in-place upgrade completed

**Expected:**
- [ ] Script recognizes v4.x structure
- [ ] Migrates to v2.0 structure
- [ ] Preserves all data in UDO/UDO Project/
- [ ] Creates UDO/UDO Framework/ with latest files

**Validation:**
```bash
# First do in-place upgrade
./upgrade.sh -y

# Then migrate
./upgrade.sh --migrate -y

# Verify v2.0 structure
test -d "UDO/UDO Framework" && echo "✓ Migration from v4.x worked"
test -f "UDO/UDO Project/PROJECT_STATE.json"
```

---

## Test Scenario 4: v2.0 Upgrade

### Setup
```bash
# Create v2.0 structure
mkdir -p /tmp/udo-test-v2-upgrade/UDO/"UDO Framework" UDO/"UDO Project"
cd /tmp/udo-test-v2-upgrade

# Framework files
echo "4.7" > "UDO/UDO Framework/VERSION"
echo '{}' > "UDO/UDO Framework/CAPABILITIES.json"
mkdir -p "UDO/UDO Framework/.bridge" "UDO/UDO Framework/.templates"

# Project files
mkdir -p "UDO/UDO Project/.memory/canonical"
mkdir -p "UDO/UDO Project/.project-catalog/sessions"
mkdir -p "UDO/UDO Project/User Uploads"
echo '{"udo_version": "2.0"}' > "UDO/UDO Project/PROJECT_META.json"
echo '{"status": "active"}' > "UDO/UDO Project/PROJECT_STATE.json"

cp /path/to/upgrade.sh .
```

### Test Case 4.1: Upgrade v2.0 Framework Only
**Command:** `./upgrade.sh`
**User Input:** `y` (confirm)

**Expected:**
- [ ] Script detects v2.0 structure
- [ ] Displays "Will UPGRADE (v2.0 structure)"
- [ ] Shows "Update UDO Framework/ only"
- [ ] Shows "Preserve UDO Project/ data exactly as-is"
- [ ] Creates `.udo-backup-[timestamp]/` (of Framework only)
- [ ] Updates `UDO/UDO Framework/` files
- [ ] Does NOT touch `UDO/UDO Project/` files
- [ ] Ensures `User Uploads/` exists in project

**Validation:**
```bash
# Check structure preserved
test -d "UDO/UDO Framework" && echo "✓ Framework dir exists"
test -d "UDO/UDO Project" && echo "✓ Project dir exists"

# Check framework updated
ls "UDO/UDO Framework/ORCHESTRATOR.md" && echo "✓ Framework files updated"

# Check project untouched (file timestamps should be original)
stat "UDO/UDO Project/PROJECT_STATE.json" | grep "Modify"

# Check User Uploads exists
test -d "UDO/UDO Project/User Uploads" && echo "✓ User Uploads exists"

# Check backup is Framework only
test -d ".udo-backup-"* && echo "✓ Framework backup created"
```

### Test Case 4.2: v2.0 Upgrade with Auto-Yes
**Command:** `./upgrade.sh -y`
**User Input:** None

**Expected:**
- [ ] Script skips confirmation
- [ ] Updates Framework
- [ ] Preserves Project
- [ ] Completes

**Validation:**
```bash
./upgrade.sh -y
test -f "UDO/UDO Framework/VERSION" && echo "✓ Framework upgraded"
```

### Test Case 4.3: v2.0 Already Latest Version
**Command:** `./upgrade.sh`
**User Input:** `y`
**Setup:** v2.0 installation already at latest version (VERSION file matches download)

**Expected:**
- [ ] Script detects "already latest version"
- [ ] Exits without changes
- [ ] No backup created
- [ ] No upgrade performed

**Validation:**
```bash
# Get current version
current=$(cat "UDO/UDO Framework/VERSION")

# Run upgrade
./upgrade.sh -y 2>&1 | grep "already on the latest"

# Verify nothing changed
test ! -d ".udo-backup-"* && echo "✓ No backup created"
```

---

## Test Scenario 5: Edge Cases & Error Handling

### Test Case 5.1: Corrupted Project Files
**Setup:** v2.0 installation with malformed JSON

```bash
mkdir -p "/tmp/udo-test-corrupt/UDO/UDO Framework" "UDO/UDO Project"
echo "{ invalid json" > "UDO/UDO Project/PROJECT_META.json"
```

**Command:** `./upgrade.sh`

**Expected:**
- [ ] Script still runs
- [ ] Warns about invalid JSON (validation script)
- [ ] Still updates Framework
- [ ] Creates backup before any changes

### Test Case 5.2: Missing User Uploads
**Setup:** v2.0 installation without User Uploads folder

**Command:** `./upgrade.sh`

**Expected:**
- [ ] Script detects missing `User Uploads/`
- [ ] Creates it during upgrade
- [ ] Creates `.gitkeep` file

**Validation:**
```bash
test -d "UDO/UDO Project/User Uploads" && echo "✓ User Uploads created"
test -f "UDO/UDO Project/User Uploads/.gitkeep"
```

### Test Case 5.3: Insufficient Disk Space
**Setup:** Test directory on low-space volume

**Expected:**
- [ ] Download fails gracefully
- [ ] Error message displayed
- [ ] No partial changes
- [ ] Cleanup occurs

### Test Case 5.4: Network Interruption
**Setup:** GitHub access blocked mid-download

**Expected:**
- [ ] Download fails
- [ ] Error message
- [ ] Script exits
- [ ] No changes to existing installation

### Test Case 5.5: Read-Only Directory
**Setup:** UDO folder with read-only permissions

**Command:** `./upgrade.sh`

**Expected:**
- [ ] Script attempts backup
- [ ] Permission error displayed
- [ ] Script exits without modifying files

---

## Test Scenario 6: Cross-Platform Testing

### Windows PowerShell (PowerShell v7+)

#### Test Case 6.1: Fresh Install on Windows
**Command:** `./upgrade.ps1 -Fresh`

**Expected:**
- [ ] Same behavior as Bash version
- [ ] Creates UDO\ folder structure
- [ ] Creates UDO\UDO Framework\ directory
- [ ] Creates UDO\UDO Project\ directory
- [ ] All files present

**Validation:**
```powershell
Test-Path "UDO\UDO Framework"
Test-Path "UDO\UDO Project\PROJECT_META.json"
Get-Content "UDO\UDO Framework\VERSION"
```

#### Test Case 6.2: v4.x Migration on Windows
**Command:** `./upgrade.ps1 -Migrate -Yes`

**Expected:**
- [ ] Same migration behavior
- [ ] Proper Windows path handling
- [ ] Reserved names handled (robocopy)
- [ ] All data preserved

**Validation:**
```powershell
Test-Path "UDO\UDO Project"
Get-ChildItem "UDO\UDO Project\.memory"
```

#### Test Case 6.3: v2.0 Upgrade on Windows
**Command:** `./upgrade.ps1 -Yes`

**Expected:**
- [ ] Framework updated
- [ ] Project data untouched
- [ ] Backup created

**Validation:**
```powershell
$backup = Get-Item ".udo-backup-*" -Directory
$backup.FullName
```

### Linux/macOS (Bash)

All Bash test scenarios should pass on both Linux and macOS with identical behavior.

---

## Integration Tests

### Test Case I.1: Complete Migration Journey
**Goal:** Test entire v4.x → v2.0 journey

**Steps:**
1. Create v4.x installation (Test Scenario 2 setup)
2. Create some project data (.memory/ files, .project-catalog/ sessions)
3. Run migration: `./upgrade.sh --migrate -y`
4. Verify all data preserved
5. Run validation: `./validate-upgrade.sh`
6. Run upgrade again: `./upgrade.sh -y`
7. Verify Framework updated, Project untouched

**Expected:**
- [ ] All steps complete successfully
- [ ] Validation passes each time
- [ ] Data completely preserved

### Test Case I.2: Multiple Upgrade Cycles
**Goal:** Test that script handles being run multiple times

**Steps:**
1. Fresh install: `./upgrade.sh --fresh -y`
2. Run again: `./upgrade.sh -y`
3. Check "already latest" message

**Expected:**
- [ ] First run creates structure
- [ ] Second run detects latest, exits
- [ ] No errors

### Test Case I.3: Backup Restoration
**Goal:** Verify backup-restore cycle works

**Steps:**
1. Create v4.x installation
2. Run migration: `./upgrade.sh --migrate -y`
3. Simulate error by corrupting Framework
4. Restore: `rm -rf UDO && mv .udo-backup-* UDO`
5. Verify original v4.x structure restored
6. Run migration again

**Expected:**
- [ ] Backup creation works
- [ ] Restore command works
- [ ] Can retry migration after restore

---

## Performance Testing

### Test Case P.1: Large Project Data Migration
**Setup:** v4.x installation with:
- 1000+ files in .project-catalog/
- 10000+ lines in session logs
- Large evidence files in .outputs/

**Command:** `./upgrade.sh --migrate -y`

**Expected:**
- [ ] Migration completes (reasonable time, <1 minute)
- [ ] All files preserved
- [ ] No data loss
- [ ] Backup size reasonable

### Test Case P.2: Framework with Many Files
**Setup:** v2.0 installation with complete framework

**Command:** `./upgrade.sh -y`

**Expected:**
- [ ] Upgrade completes reasonably fast
- [ ] All framework files updated
- [ ] No performance degradation

---

## Validation Checklist

### After Each Test
- [ ] Installation type detected correctly
- [ ] Appropriate folders created
- [ ] All required files present
- [ ] Folder permissions correct
- [ ] Backup created (where applicable)
- [ ] No files mysteriously deleted
- [ ] Error messages clear and actionable
- [ ] Restoration commands work

### Final Validation Script
```bash
# Run validation after any upgrade
./validate-upgrade.sh

# Check exit code
echo $?  # Should be 0 for success
```

---

## Regression Testing

Tests to run before release:
- [ ] v4.x installation created and upgradeable
- [ ] Fresh install creates valid v2.0 structure
- [ ] Migration preserves 100% of data
- [ ] v2.0 upgrade doesn't touch project
- [ ] Backups are restorable
- [ ] Both Bash and PowerShell have identical behavior
- [ ] Error messages are helpful
- [ ] No data loss in any scenario

---

## Known Limitations & Workarounds

1. **jq Requirement**: Validation script requires `jq` for JSON checking
   - Workaround: Manual JSON verification or install jq

2. **Network Dependency**: Downloads from GitHub
   - Workaround: Manual download and local copy

3. **Permissions**: Scripts respect system permissions
   - Workaround: Run with appropriate permissions

4. **Windows Reserved Names**: Handled by robocopy
   - Should be transparent to user

---

## Test Execution Report Template

```markdown
## Test Execution Report - [Date]

### Environment
- OS: [macOS/Linux/Windows]
- Shell: [bash/zsh/PowerShell]
- Network: [Connected/Offline]

### Test Results
- Fresh Install: [ ] PASS [ ] FAIL
- v4.x Migration: [ ] PASS [ ] FAIL
- v4.x In-Place Upgrade: [ ] PASS [ ] FAIL
- v2.0 Upgrade: [ ] PASS [ ] FAIL
- Edge Cases: [ ] PASS [ ] FAIL

### Issues Found
1. [Issue description]
   - Steps to reproduce
   - Expected vs actual
   - Severity: [Critical/High/Medium/Low]

### Notes
[Any additional observations]
```

