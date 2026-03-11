# UDO Upgrade Tool v2.0 - PowerShell Version
# Downloads latest UDO and safely merges with existing installation
# Supports fresh install, v4.x migration, and v2.0 upgrade modes

param(
    [switch]$Yes,
    [switch]$Migrate,
    [switch]$Fresh
)

$ErrorActionPreference = "Stop"

$REPO_URL = "https://github.com/carderel/UDO-No-Script-Complete"
$MANIFEST_URL = "https://raw.githubusercontent.com/carderel/UDO-Upgrade-Kit/main/MANIFEST.json"

Write-Host ""
Write-Host "╔═══════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║       UDO Upgrade Tool v2.0           ║" -ForegroundColor Blue
Write-Host "╚═══════════════════════════════════════╝" -ForegroundColor Blue
Write-Host ""

# Detect installation type
$INSTALL_TYPE = $null
$FORCE_MIGRATE = $Migrate
$FORCE_FRESH = $Fresh

if ((Test-Path "./UDO Framework") -and (Test-Path "./UDO Project")) {
    $INSTALL_TYPE = "v2.0"
} elseif (Test-Path "./UDO") {
    $INSTALL_TYPE = "v4.x"
} else {
    $INSTALL_TYPE = "fresh"
}

# Handle force flags
if ($FORCE_FRESH) {
    $INSTALL_TYPE = "fresh"
    Write-Host "-Fresh flag: Creating new v2.0 installation" -ForegroundColor Yellow
} elseif ($FORCE_MIGRATE) {
    if ($INSTALL_TYPE -eq "v4.x") {
        Write-Host "-Migrate flag: Migrating v4.x to v2.0" -ForegroundColor Yellow
    } elseif ($INSTALL_TYPE -eq "fresh") {
        Write-Host "Error: No existing UDO installation to migrate" -ForegroundColor Red
        exit 1
    }
}

Write-Host "Installation type: $INSTALL_TYPE" -ForegroundColor Blue

# Initialize paths based on install type
$FRAMEWORK_PATH = $null
$PROJECT_PATH = $null
$UDO_PATH = $null
$CURRENT_VERSION = "unknown"

if ($INSTALL_TYPE -eq "v2.0") {
    $FRAMEWORK_PATH = "./UDO Framework"
    $PROJECT_PATH = "./UDO Project"
    if (Test-Path "$FRAMEWORK_PATH/VERSION") {
        $CURRENT_VERSION = (Get-Content "$FRAMEWORK_PATH/VERSION" -Raw).Trim()
    }
} elseif ($INSTALL_TYPE -eq "v4.x") {
    $UDO_PATH = "./UDO"
    if (Test-Path "$UDO_PATH/VERSION") {
        $CURRENT_VERSION = (Get-Content "$UDO_PATH/VERSION" -Raw).Trim()
    }
} elseif ($INSTALL_TYPE -eq "fresh") {
    $CURRENT_VERSION = "fresh"
}

Write-Host "Current version: $CURRENT_VERSION" -ForegroundColor Blue

# Download latest
Write-Host ""
Write-Host "Downloading latest version..."
$TEMP_DIR = New-Item -ItemType Directory -Path (Join-Path $env:TEMP "udo-upgrade-$(Get-Random)")
$zipPath = Join-Path $TEMP_DIR "latest.zip"
Invoke-WebRequest -Uri "$REPO_URL/archive/refs/heads/main.zip" -OutFile $zipPath -UseBasicParsing
Expand-Archive -Path $zipPath -DestinationPath $TEMP_DIR

$LATEST_PATH = Join-Path $TEMP_DIR "UDO-No-Script-Complete-main/UDO"
if (-not (Test-Path $LATEST_PATH)) {
    Write-Host "Error: Could not find UDO folder in downloaded archive" -ForegroundColor Red
    Remove-Item -Recurse -Force $TEMP_DIR
    exit 1
}

$LATEST_VERSION = if (Test-Path "$LATEST_PATH/VERSION") { (Get-Content "$LATEST_PATH/VERSION" -Raw).Trim() } else { "unknown" }
Write-Host "Latest version:  $LATEST_VERSION" -ForegroundColor Blue

if ($INSTALL_TYPE -ne "fresh" -and $CURRENT_VERSION -eq $LATEST_VERSION) {
    Write-Host ""
    Write-Host "You're already on the latest version!" -ForegroundColor Green
    Remove-Item -Recurse -Force $TEMP_DIR
    exit 0
}

# System files to always update (relative to framework)
$SYSTEM_FILES = @(
    "ORCHESTRATOR.md", "COMMANDS.md", "START_HERE.md",
    "REASONING_CONTRACT.md", "DEVILS_ADVOCATE.md", "AUDIENCE_ANTICIPATION.md",
    "EVIDENCE_PROTOCOL.md", "TEACH_BACK_PROTOCOL.md", "HANDOFF_PROMPT.md",
    "OVERSIGHT_DASHBOARD.md", "CAPABILITIES.json", "VERSION", "README.md"
)

# Framework folders to update
$FRAMEWORK_FOLDERS = @(
    ".bridge", ".templates", ".takeover/agent-templates", ".tools", ".rules"
)

# Data files to preserve if modified
$DATA_FILES = @(
    "PROJECT_STATE.json", "PROJECT_META.json",
    "LESSONS_LEARNED.md", "HARD_STOPS.md", "NON_GOALS.md"
)

# Data folders - never touch contents (relative to project)
$DATA_FOLDERS = @(
    ".memory/canonical", ".memory/working", ".memory/disposable",
    ".project-catalog/sessions", ".project-catalog/decisions",
    ".project-catalog/agents", ".project-catalog/errors",
    ".project-catalog/handoffs", ".project-catalog/archive",
    ".project-catalog/history",
    ".outputs", ".checkpoints", ".agents"
)

# Utility function to create project structure
function New-ProjectStructure {
    param([string]$ProjPath)

    @(
        "$ProjPath/.memory/canonical",
        "$ProjPath/.memory/working",
        "$ProjPath/.memory/disposable",
        "$ProjPath/.project-catalog/sessions",
        "$ProjPath/.project-catalog/decisions",
        "$ProjPath/.project-catalog/agents",
        "$ProjPath/.project-catalog/errors",
        "$ProjPath/.project-catalog/handoffs",
        "$ProjPath/.project-catalog/archive",
        "$ProjPath/.project-catalog/history",
        "$ProjPath/.outputs/.evidence",
        "$ProjPath/.checkpoints",
        "$ProjPath/.agents",
        "$ProjPath/.rules",
        "$ProjPath/User Uploads"
    ) | ForEach-Object {
        if (-not (Test-Path $_)) {
            New-Item -ItemType Directory -Path $_ -Force | Out-Null
        }
    }

    @(
        "$ProjPath/.memory/.gitkeep",
        "$ProjPath/.project-catalog/.gitkeep",
        "$ProjPath/.outputs/.gitkeep",
        "$ProjPath/.checkpoints/.gitkeep",
        "$ProjPath/.agents/.gitkeep",
        "$ProjPath/.rules/.gitkeep",
        "$ProjPath/User Uploads/.gitkeep"
    ) | ForEach-Object {
        if (-not (Test-Path $_)) {
            New-Item -ItemType File -Path $_ -Force | Out-Null
        }
    }
}

# Utility function to display structure diagram
function Show-StructureDiagram {
    Write-Host ""
    Write-Host "UDO v2.0 Directory Structure:" -ForegroundColor Blue
    Write-Host ""
    Write-Host "  UDO/"
    Write-Host "  ├── UDO Framework/"
    Write-Host "  │   ├── ORCHESTRATOR.md"
    Write-Host "  │   ├── START_HERE.md"
    Write-Host "  │   ├── COMMANDS.md"
    Write-Host "  │   ├── .bridge/"
    Write-Host "  │   ├── .templates/"
    Write-Host "  │   ├── .takeover/"
    Write-Host "  │   ├── .tools/"
    Write-Host "  │   └── .rules/"
    Write-Host "  └── UDO Project/"
    Write-Host "      ├── PROJECT_META.json"
    Write-Host "      ├── PROJECT_STATE.json"
    Write-Host "      ├── ORCHESTRATOR.md (project-specific)"
    Write-Host "      ├── .memory/"
    Write-Host "      ├── .project-catalog/"
    Write-Host "      ├── .outputs/"
    Write-Host "      ├── .checkpoints/"
    Write-Host "      ├── .agents/"
    Write-Host "      └── User Uploads/"
    Write-Host ""
}

Write-Host ""
if ($INSTALL_TYPE -eq "fresh") {
    Write-Host "Analyzing fresh installation..."
} elseif ($INSTALL_TYPE -eq "v4.x") {
    Write-Host "Analyzing v4.x installation for upgrade..."
} else {
    Write-Host "Analyzing v2.0 installation for upgrade..."
}
Write-Host ""

# Handle different installation scenarios
if ($INSTALL_TYPE -eq "fresh") {
    # Fresh install scenario
    Write-Host "Will CREATE (new v2.0 structure):" -ForegroundColor Green
    Write-Host "  + UDO/UDO Framework/"
    Write-Host "  + UDO/UDO Project/"
    Write-Host "  + UDO/UDO Project/User Uploads/"
    Write-Host ""
    Write-Host "Will COPY:" -ForegroundColor Yellow
    Write-Host "  • All framework files to UDO Framework/"
    Write-Host "  • Project templates to UDO Project/"
    Write-Host ""
    Show-StructureDiagram

    if (-not $Yes) {
        $response = Read-Host "Create new v2.0 structure? [y/N]"
        if ($response -notmatch "^[Yy]$") {
            Write-Host "Installation cancelled."
            Remove-Item -Recurse -Force $TEMP_DIR
            exit 0
        }
    }

} elseif ($INSTALL_TYPE -eq "v4.x") {
    # v4.x installation - offer migration or in-place upgrade
    Write-Host "UDO v4.x detected at ./UDO" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  1) Migrate to v2.0 (creates UDO Framework/ and UDO Project/, preserves all data)"
    Write-Host "  2) Upgrade in-place (keep current v4.x structure, backward compatible)"
    Write-Host ""

    if ($Migrate) {
        $MIGRATE_CHOICE = "1"
    } else {
        if (-not $Yes) {
            $input_choice = Read-Host "Choose option [1 or 2] (default: 2)"
            $MIGRATE_CHOICE = if ($input_choice) { $input_choice } else { "2" }
        } else {
            $MIGRATE_CHOICE = "2"
        }
    }

    if ($MIGRATE_CHOICE -eq "1") {
        Write-Host ""
        Write-Host "Will MIGRATE (v4.x → v2.0):" -ForegroundColor Green
        Write-Host "  ↦ ./UDO/ → ./UDO/UDO Project/"
        Write-Host "  ✓ Create ./UDO/UDO Framework/"
        Write-Host "  ✓ Preserve .project-catalog/, .memory/, .outputs/, etc."
        Write-Host "  ✓ Create User Uploads/"
        Write-Host ""
        Show-StructureDiagram
        $INSTALL_TYPE = "migrate-v4"
    } else {
        Write-Host ""
        Write-Host "Will UPGRADE (v4.x in-place):" -ForegroundColor Green
        Write-Host "  ✓ Update ./UDO/ files"
        Write-Host "  ✓ Preserve all data folders"
        Write-Host "  ✓ Backward compatible mode"
        Write-Host ""
        $INSTALL_TYPE = "upgrade-v4"
    }

} else {
    # v2.0 installation - framework upgrade only
    Write-Host "Will UPGRADE (v2.0 structure):" -ForegroundColor Green
    Write-Host "  ✓ Update UDO Framework/ only"
    Write-Host "  ✓ Preserve UDO Project/ data exactly as-is"
    Write-Host "  ✓ Check User Uploads/ folder exists"
    Write-Host ""

    $ADDED = @()
    $UPDATED = @()
    foreach ($file in $SYSTEM_FILES) {
        if (Test-Path "$LATEST_PATH/$file") {
            if (Test-Path "$FRAMEWORK_PATH/$file") {
                $UPDATED += $file
            } else {
                $ADDED += $file
            }
        }
    }

    if ($ADDED.Count -gt 0) {
        Write-Host "Will ADD (new files):" -ForegroundColor Green
        $ADDED | ForEach-Object { Write-Host "  + $_" }
    }
    Write-Host ""
    Write-Host "Will UPDATE (system files):" -ForegroundColor Yellow
    $UPDATED | ForEach-Object { Write-Host "  ~ $_" }
}

Write-Host ""

# Confirm unless -Yes flag
if (-not $Yes -and $INSTALL_TYPE -ne "fresh" -and $INSTALL_TYPE -ne "migrate-v4" -and $INSTALL_TYPE -ne "upgrade-v4") {
    $response = Read-Host "Proceed with upgrade? [y/N]"
    if ($response -notmatch "^[Yy]$") {
        Write-Host "Upgrade cancelled."
        Remove-Item -Recurse -Force $TEMP_DIR
        exit 0
    }
} elseif ($Yes) {
    Write-Host "Auto-confirming (-Yes flag)" -ForegroundColor Yellow
}

# Utility function to update framework files
function Update-FrameworkFiles {
    param([string]$FrameworkDest)

    # Update system files
    foreach ($file in $SYSTEM_FILES) {
        if (Test-Path "$LATEST_PATH/$file") {
            Copy-Item -Force "$LATEST_PATH/$file" "$FrameworkDest/$file"
        }
    }

    # Update README files in subfolders
    Get-ChildItem -Path $LATEST_PATH -Filter "README.md" -Recurse | ForEach-Object {
        $relPath = $_.FullName.Substring($LATEST_PATH.Length + 1)
        $targetPath = Join-Path $FrameworkDest $relPath
        $targetDir = Split-Path $targetPath -Parent
        if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }
        Copy-Item -Force $_.FullName $targetPath
    }

    # Update framework folders
    foreach ($folder in $FRAMEWORK_FOLDERS) {
        if (Test-Path "$LATEST_PATH/$folder") {
            $destFolder = Join-Path $FrameworkDest $folder
            if (-not (Test-Path $destFolder)) { New-Item -ItemType Directory -Path $destFolder -Force | Out-Null }
            Copy-Item -Force -Recurse "$LATEST_PATH/$folder/*" "$destFolder/" -ErrorAction SilentlyContinue
        }
    }

    # Create new folders if missing
    @(".outputs/.evidence", ".takeover", ".tools", ".inputs") | ForEach-Object {
        if ((Test-Path "$LATEST_PATH/$_") -and (-not (Test-Path "$FrameworkDest/$_"))) {
            New-Item -ItemType Directory -Path "$FrameworkDest/$_" -Force | Out-Null
            Copy-Item -Force -Recurse "$LATEST_PATH/$_/*" "$FrameworkDest/$_/" -ErrorAction SilentlyContinue
        }
    }
}

# Perform operations based on installation type
if ($INSTALL_TYPE -eq "fresh") {
    Write-Host "Creating v2.0 structure..."
    New-Item -ItemType Directory -Path "UDO" -Force | Out-Null
    New-ProjectStructure "UDO/UDO Framework"
    New-ProjectStructure "UDO/UDO Project"

    # Copy all framework files
    Write-Host "Copying framework files..."
    Update-FrameworkFiles "UDO/UDO Framework"

    # Create project template files
    Write-Host "Creating project template files..."
    @{
        project_name = "Your Project Name"
        project_description = "Add your project description"
        udo_version = "2.0"
        created = "now"
        ai_platform = "claude-desktop"
        custom_settings = @{}
    } | ConvertTo-Json | Out-File -FilePath "UDO/UDO Project/PROJECT_META.json" -Encoding UTF8

    @{
        status = "active"
        last_updated = "now"
        session_count = 0
        handoff_ready = $false
        critical_state = @{}
    } | ConvertTo-Json | Out-File -FilePath "UDO/UDO Project/PROJECT_STATE.json" -Encoding UTF8

    Write-Host "✓ Fresh v2.0 structure created" -ForegroundColor Green

} elseif ($INSTALL_TYPE -eq "migrate-v4") {
    # Create backup before migration
    $BACKUP_DIR = ".udo-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Write-Host ""
    Write-Host "Creating backup at $BACKUP_DIR..."
    Copy-Item -Recurse -Force "UDO" "$BACKUP_DIR"

    Write-Host "Migrating UDO v4.x to v2.0..."

    # Create new structure
    New-Item -ItemType Directory -Path "UDO" -Force | Out-Null
    New-Item -ItemType Directory -Path "UDO/UDO Project" -Force | Out-Null

    # Copy existing UDO content to UDO/UDO Project
    if (Test-Path "UDO") {
        Get-ChildItem -Path "$BACKUP_DIR" | ForEach-Object {
            Copy-Item -Recurse -Force $_.FullName "UDO/UDO Project/$($_.Name)" -ErrorAction SilentlyContinue
        }
    }

    # Create framework structure
    New-ProjectStructure "UDO/UDO Framework"

    # Copy framework files
    Write-Host "Installing framework files..."
    Update-FrameworkFiles "UDO/UDO Framework"

    # Create User Uploads if missing
    if (-not (Test-Path "UDO/UDO Project/User Uploads")) {
        New-Item -ItemType Directory -Path "UDO/UDO Project/User Uploads" -Force | Out-Null
        New-Item -ItemType File -Path "UDO/UDO Project/User Uploads/.gitkeep" -Force | Out-Null
    }

    # Update PROJECT_META.json with v2.0 version
    $metaPath = "UDO/UDO Project/PROJECT_META.json"
    if (Test-Path $metaPath) {
        $meta = Get-Content $metaPath -Raw | ConvertFrom-Json
        $meta.udo_version = "2.0"
        $meta | ConvertTo-Json | Out-File -FilePath $metaPath -Encoding UTF8
    } else {
        @{
            project_name = "Migrated Project"
            project_description = "Migrated from v4.x"
            udo_version = "2.0"
            created = "migrated"
            ai_platform = "claude-desktop"
        } | ConvertTo-Json | Out-File -FilePath $metaPath -Encoding UTF8
    }

    Write-Host "✓ Migration complete" -ForegroundColor Green
    Write-Host "All data preserved in ./UDO/UDO Project/" -ForegroundColor Blue

} elseif ($INSTALL_TYPE -eq "upgrade-v4") {
    # Create backup before upgrade
    $BACKUP_DIR = ".udo-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Write-Host ""
    Write-Host "Creating backup at $BACKUP_DIR..."
    Copy-Item -Recurse -Force "UDO" "$BACKUP_DIR"

    Write-Host "Upgrading UDO v4.x in-place..."
    Update-FrameworkFiles "./UDO"

    Write-Host "✓ Upgrade complete (v4.x mode)" -ForegroundColor Green
    Write-Host "To migrate to v2.0 structure later, run: ./upgrade.ps1 -Migrate"

} else {
    # v2.0 upgrade
    $BACKUP_DIR = ".udo-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Write-Host ""
    Write-Host "Creating backup at $BACKUP_DIR..."
    Copy-Item -Recurse -Force "UDO/UDO Framework" "$BACKUP_DIR"

    Write-Host "Upgrading UDO Framework..."
    Update-FrameworkFiles "$FRAMEWORK_PATH"

    # Ensure User Uploads exists in project
    if (-not (Test-Path "$PROJECT_PATH/User Uploads")) {
        New-Item -ItemType Directory -Path "$PROJECT_PATH/User Uploads" -Force | Out-Null
        New-Item -ItemType File -Path "$PROJECT_PATH/User Uploads/.gitkeep" -Force | Out-Null
    }

    Write-Host "✓ Framework upgraded" -ForegroundColor Green
    Write-Host "UDO Project/ data unchanged" -ForegroundColor Blue
}

# Cleanup
Remove-Item -Recurse -Force $TEMP_DIR

Write-Host ""
Write-Host "╔═══════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║       Complete!                       ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

if ($INSTALL_TYPE -eq "fresh") {
    Write-Host "✓ UDO v2.0 fresh install created" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  1. cd UDO"
    Write-Host "  2. Edit UDO/Project/PROJECT_META.json to define your project"
    Write-Host "  3. Edit UDO/Project/PROJECT_STATE.json to set initial state"
    Write-Host "  4. Start your LLM CLI from the UDO Project folder"
    Write-Host ""
    Write-Host "⚠️  IMPORTANT: Your LLM must be run from within the UDO Project directory for proper context loading." -ForegroundColor Yellow
} elseif ($INSTALL_TYPE -eq "migrate-v4") {
    Write-Host "✓ Upgraded from $CURRENT_VERSION to v2.0" -ForegroundColor Green
    Write-Host "✓ All data preserved in UDO/UDO Project/"
    if ($BACKUP_DIR) { Write-Host "✓ Backup saved to: $BACKUP_DIR" -ForegroundColor Blue }
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  1. Review UDO/UDO Project/PROJECT_META.json"
    Write-Host "  2. Review migration in UDO/UDO Project/"
    Write-Host "  3. Start your LLM CLI from the UDO Project folder"
    Write-Host ""
    Write-Host "⚠️  IMPORTANT: Your LLM must be run from within the UDO Project directory for proper context loading." -ForegroundColor Yellow
} elseif ($INSTALL_TYPE -eq "upgrade-v4") {
    Write-Host "✓ Upgraded from $CURRENT_VERSION" -ForegroundColor Green
    Write-Host "✓ v4.x structure preserved (backward compatible)" -ForegroundColor Green
    if ($BACKUP_DIR) { Write-Host "✓ Backup saved to: $BACKUP_DIR" -ForegroundColor Blue }
    Write-Host ""
    Write-Host "To migrate to v2.0 structure:"
    Write-Host "  ./upgrade.ps1 -Migrate"
} else {
    Write-Host "✓ Upgraded from $CURRENT_VERSION to $LATEST_VERSION" -ForegroundColor Green
    Write-Host "✓ UDO Framework/ updated" -ForegroundColor Green
    Write-Host "✓ UDO Project/ data preserved" -ForegroundColor Green
    if ($BACKUP_DIR) { Write-Host "✓ Backup saved to: $BACKUP_DIR" -ForegroundColor Blue }
}

Write-Host ""
if ($BACKUP_DIR) {
    Write-Host "If something went wrong, restore from backup:"
    if ($INSTALL_TYPE -eq "migrate-v4" -or $INSTALL_TYPE -eq "upgrade-v4") {
        Write-Host "  Remove-Item -Recurse UDO; Move-Item $BACKUP_DIR UDO"
    } else {
        Write-Host "  Remove-Item -Recurse 'UDO/UDO Framework'; Move-Item $BACKUP_DIR 'UDO/UDO Framework'"
    }
}
