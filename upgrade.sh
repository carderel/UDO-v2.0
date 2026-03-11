#!/bin/bash
# UDO Upgrade Tool v2.0
# Downloads latest UDO and safely merges with existing installation
# Supports fresh install, v4.x migration, and v2.0 upgrade modes

set -e

REPO_URL="https://github.com/carderel/UDO-No-Script-Complete"
MANIFEST_URL="https://raw.githubusercontent.com/carderel/UDO-Upgrade-Kit/main/MANIFEST.json"
TEMP_DIR=$(mktemp -d)
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'
AUTO_YES=false
INSTALL_TYPE=""
FORCE_MIGRATE=false
FORCE_FRESH=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes) AUTO_YES=true; shift ;;
        --migrate) FORCE_MIGRATE=true; shift ;;
        --fresh) FORCE_FRESH=true; shift ;;
        *) shift ;;
    esac
done

cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo ""
echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       UDO Upgrade Tool v2.0           ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
echo ""

# Detect installation type
detect_install_type() {
    if [ -d "./UDO Framework" ] && [ -d "./UDO Project" ]; then
        INSTALL_TYPE="v2.0"
    elif [ -d "./UDO" ]; then
        INSTALL_TYPE="v4.x"
    else
        INSTALL_TYPE="fresh"
    fi
}

detect_install_type

# Handle force flags
if [ "$FORCE_FRESH" = true ]; then
    INSTALL_TYPE="fresh"
    echo -e "${YELLOW}--fresh flag: Creating new v2.0 installation${NC}"
elif [ "$FORCE_MIGRATE" = true ]; then
    if [ "$INSTALL_TYPE" = "v4.x" ]; then
        echo -e "${YELLOW}--migrate flag: Migrating v4.x to v2.0${NC}"
    elif [ "$INSTALL_TYPE" = "fresh" ]; then
        echo -e "${RED}Error: No existing UDO installation to migrate${NC}"
        exit 1
    fi
fi

echo -e "Installation type: ${BLUE}$INSTALL_TYPE${NC}"

# Initialize paths based on install type
ORIG_DIR=$(pwd)
UDO_PATH=""
FRAMEWORK_PATH=""
PROJECT_PATH=""

if [ "$INSTALL_TYPE" = "v2.0" ]; then
    FRAMEWORK_PATH="./UDO Framework"
    PROJECT_PATH="./UDO Project"
    CURRENT_VERSION="unknown"
    if [ -f "$FRAMEWORK_PATH/VERSION" ]; then
        CURRENT_VERSION=$(cat "$FRAMEWORK_PATH/VERSION")
    fi
elif [ "$INSTALL_TYPE" = "v4.x" ]; then
    UDO_PATH="./UDO"
    CURRENT_VERSION="unknown"
    if [ -f "$UDO_PATH/VERSION" ]; then
        CURRENT_VERSION=$(cat "$UDO_PATH/VERSION")
    fi
elif [ "$INSTALL_TYPE" = "fresh" ]; then
    CURRENT_VERSION="fresh"
fi

echo -e "Current version: ${BLUE}$CURRENT_VERSION${NC}"

# Download latest
echo ""
echo "Downloading latest version..."
cd "$TEMP_DIR"
curl -fsSL "$REPO_URL/archive/refs/heads/main.zip" -o latest.zip
unzip -q latest.zip
LATEST_PATH="$TEMP_DIR/UDO-No-Script-Complete-main/UDO"

if [ ! -d "$LATEST_PATH" ]; then
    echo -e "${RED}Error: Could not find UDO folder in downloaded archive${NC}"
    exit 1
fi

LATEST_VERSION=$(cat "$LATEST_PATH/VERSION" 2>/dev/null || echo "unknown")
echo -e "Latest version:  ${BLUE}$LATEST_VERSION${NC}"

# Back to original directory
cd - > /dev/null

if [ "$INSTALL_TYPE" != "fresh" ] && [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    echo ""
    echo -e "${GREEN}You're already on the latest version!${NC}"
    exit 0
fi

# System files to always update (relative to framework)
SYSTEM_FILES=(
    "ORCHESTRATOR.md" "COMMANDS.md" "START_HERE.md"
    "REASONING_CONTRACT.md" "DEVILS_ADVOCATE.md" "AUDIENCE_ANTICIPATION.md"
    "EVIDENCE_PROTOCOL.md" "TEACH_BACK_PROTOCOL.md" "HANDOFF_PROMPT.md"
    "OVERSIGHT_DASHBOARD.md" "CAPABILITIES.json" "VERSION" "README.md"
)

# Framework folders to update
FRAMEWORK_FOLDERS=(
    ".bridge" ".templates" ".takeover/agent-templates" ".tools" ".rules"
)

# Data files to preserve if modified
DATA_FILES=(
    "PROJECT_STATE.json" "PROJECT_META.json"
    "LESSONS_LEARNED.md" "HARD_STOPS.md" "NON_GOALS.md"
)

# Data folders - never touch contents (relative to project)
DATA_FOLDERS=(
    ".memory/canonical" ".memory/working" ".memory/disposable"
    ".project-catalog/sessions" ".project-catalog/decisions"
    ".project-catalog/agents" ".project-catalog/errors"
    ".project-catalog/handoffs" ".project-catalog/archive"
    ".project-catalog/history"
    ".outputs" ".checkpoints" ".agents"
)

# Utility function to create project structure
create_project_structure() {
    local proj_path=$1
    mkdir -p "$proj_path"
    mkdir -p "$proj_path/.memory/canonical"
    mkdir -p "$proj_path/.memory/working"
    mkdir -p "$proj_path/.memory/disposable"
    mkdir -p "$proj_path/.project-catalog/sessions"
    mkdir -p "$proj_path/.project-catalog/decisions"
    mkdir -p "$proj_path/.project-catalog/agents"
    mkdir -p "$proj_path/.project-catalog/errors"
    mkdir -p "$proj_path/.project-catalog/handoffs"
    mkdir -p "$proj_path/.project-catalog/archive"
    mkdir -p "$proj_path/.project-catalog/history"
    mkdir -p "$proj_path/.outputs/.evidence"
    mkdir -p "$proj_path/.checkpoints"
    mkdir -p "$proj_path/.agents"
    mkdir -p "$proj_path/.rules"
    mkdir -p "$proj_path/User Uploads"
    touch "$proj_path/.memory/.gitkeep"
    touch "$proj_path/.project-catalog/.gitkeep"
    touch "$proj_path/.outputs/.gitkeep"
    touch "$proj_path/.checkpoints/.gitkeep"
    touch "$proj_path/.agents/.gitkeep"
    touch "$proj_path/.rules/.gitkeep"
    touch "$proj_path/User Uploads/.gitkeep"
}

# Utility function to display structure diagram
display_structure_diagram() {
    echo ""
    echo -e "${BLUE}UDO v2.0 Directory Structure:${NC}"
    echo ""
    echo "  UDO/"
    echo "  ├── UDO Framework/"
    echo "  │   ├── ORCHESTRATOR.md"
    echo "  │   ├── START_HERE.md"
    echo "  │   ├── COMMANDS.md"
    echo "  │   ├── .bridge/"
    echo "  │   ├── .templates/"
    echo "  │   ├── .takeover/"
    echo "  │   ├── .tools/"
    echo "  │   └── .rules/"
    echo "  └── UDO Project/"
    echo "      ├── PROJECT_META.json"
    echo "      ├── PROJECT_STATE.json"
    echo "      ├── ORCHESTRATOR.md (project-specific)"
    echo "      ├── .memory/"
    echo "      ├── .project-catalog/"
    echo "      ├── .outputs/"
    echo "      ├── .checkpoints/"
    echo "      ├── .agents/"
    echo "      └── User Uploads/"
    echo ""
}

echo ""
if [ "$INSTALL_TYPE" = "fresh" ]; then
    echo "Analyzing fresh installation..."
elif [ "$INSTALL_TYPE" = "v4.x" ]; then
    echo "Analyzing v4.x installation for upgrade..."
else
    echo "Analyzing v2.0 installation for upgrade..."
fi
echo ""

# Handle different installation scenarios
if [ "$INSTALL_TYPE" = "fresh" ]; then
    # Fresh install scenario
    echo -e "${GREEN}Will CREATE (new v2.0 structure):${NC}"
    echo "  + UDO/UDO Framework/"
    echo "  + UDO/UDO Project/"
    echo "  + UDO/UDO Project/User Uploads/"
    echo ""
    echo -e "${YELLOW}Will COPY:${NC}"
    echo "  • All framework files to UDO Framework/"
    echo "  • Project templates to UDO Project/"
    echo ""
    display_structure_diagram

    if [ "$AUTO_YES" = false ]; then
        echo -e "${YELLOW}Create new v2.0 structure? [y/N]${NC}"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "Installation cancelled."
            exit 0
        fi
    fi

elif [ "$INSTALL_TYPE" = "v4.x" ]; then
    # v4.x installation - offer migration or in-place upgrade
    echo -e "${YELLOW}UDO v4.x detected at ./UDO${NC}"
    echo ""
    echo "Options:"
    echo "  1) Migrate to v2.0 (creates UDO Framework/ and UDO Project/, preserves all data)"
    echo "  2) Upgrade in-place (keep current v4.x structure, backward compatible)"
    echo ""

    if [ "$FORCE_MIGRATE" = true ]; then
        MIGRATE_CHOICE="1"
    else
        if [ "$AUTO_YES" = false ]; then
            echo -e "${YELLOW}Choose option [1 or 2] (default: 2):${NC}"
            read -r MIGRATE_CHOICE
            if [ -z "$MIGRATE_CHOICE" ]; then
                MIGRATE_CHOICE="2"
            fi
        else
            MIGRATE_CHOICE="2"
        fi
    fi

    if [ "$MIGRATE_CHOICE" = "1" ]; then
        echo ""
        echo -e "${GREEN}Will MIGRATE (v4.x → v2.0):${NC}"
        echo "  ↦ ./UDO/ → ./UDO/UDO Project/"
        echo "  ✓ Create ./UDO/UDO Framework/"
        echo "  ✓ Preserve .project-catalog/, .memory/, .outputs/, etc."
        echo "  ✓ Create User Uploads/"
        echo ""
        display_structure_diagram
        INSTALL_TYPE="migrate-v4"
    else
        echo ""
        echo -e "${GREEN}Will UPGRADE (v4.x in-place):${NC}"
        echo "  ✓ Update ./UDO/ files"
        echo "  ✓ Preserve all data folders"
        echo "  ✓ Backward compatible mode"
        echo ""
        INSTALL_TYPE="upgrade-v4"
    fi

else
    # v2.0 installation - framework upgrade only
    echo -e "${GREEN}Will UPGRADE (v2.0 structure):${NC}"
    echo "  ✓ Update UDO Framework/ only"
    echo "  ✓ Preserve UDO Project/ data exactly as-is"
    echo "  ✓ Check User Uploads/ folder exists"
    echo ""

    ADDED=()
    UPDATED=()
    for file in "${SYSTEM_FILES[@]}"; do
        if [ -f "$LATEST_PATH/$file" ]; then
            if [ -f "$FRAMEWORK_PATH/$file" ]; then
                UPDATED+=("$file")
            else
                ADDED+=("$file")
            fi
        fi
    done

    if [ ${#ADDED[@]} -gt 0 ]; then
        echo -e "${GREEN}Will ADD (new files):${NC}"
        for file in "${ADDED[@]}"; do
            echo "  + $file"
        done
    fi
    echo ""
    echo -e "${YELLOW}Will UPDATE (system files):${NC}"
    for file in "${UPDATED[@]}"; do
        echo "  ~ $file"
    done
fi

echo ""

# Confirm unless --yes flag
if [ "$AUTO_YES" = false ] && [ "$INSTALL_TYPE" != "fresh" ] && [ "$INSTALL_TYPE" != "migrate-v4" ] && [ "$INSTALL_TYPE" != "upgrade-v4" ]; then
    echo -e "${YELLOW}Proceed with upgrade? [y/N]${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Upgrade cancelled."
        exit 0
    fi
elif [ "$AUTO_YES" = true ]; then
    echo -e "${YELLOW}Auto-confirming (--yes flag)${NC}"
fi

# Utility function to update framework files
update_framework_files() {
    local framework_dest=$1

    # Update system files
    for file in "${SYSTEM_FILES[@]}"; do
        if [ -f "$LATEST_PATH/$file" ]; then
            cp "$LATEST_PATH/$file" "$framework_dest/$file"
        fi
    done

    # Update README files in subfolders
    find "$LATEST_PATH" -name "README.md" -type f | while read -r readme; do
        rel_path=${readme#$LATEST_PATH/}
        target_dir=$(dirname "$framework_dest/$rel_path")
        mkdir -p "$target_dir"
        cp "$readme" "$framework_dest/$rel_path"
    done

    # Update framework folders
    for folder in "${FRAMEWORK_FOLDERS[@]}"; do
        if [ -d "$LATEST_PATH/$folder" ]; then
            mkdir -p "$framework_dest/$folder"
            cp -R "$LATEST_PATH/$folder/"* "$framework_dest/$folder/" 2>/dev/null || true
        fi
    done

    # Create new folders if missing
    for folder in ".outputs/.evidence" ".takeover" ".tools" ".inputs"; do
        if [ -d "$LATEST_PATH/$folder" ] && [ ! -d "$framework_dest/$folder" ]; then
            mkdir -p "$framework_dest/$folder"
            cp -R "$LATEST_PATH/$folder/"* "$framework_dest/$folder/" 2>/dev/null || true
        fi
    done
}

# Perform operations based on installation type
if [ "$INSTALL_TYPE" = "fresh" ]; then
    echo "Creating v2.0 structure..."
    mkdir -p "UDO"
    create_project_structure "UDO/UDO Framework"
    create_project_structure "UDO/UDO Project"

    # Copy all framework files
    echo "Copying framework files..."
    update_framework_files "UDO/UDO Framework"

    # Create project template files
    echo "Creating project template files..."
    cat > "UDO/UDO Project/PROJECT_META.json" << 'EOF'
{
  "project_name": "Your Project Name",
  "project_description": "Add your project description",
  "udo_version": "2.0",
  "created": "now",
  "ai_platform": "claude-desktop",
  "custom_settings": {}
}
EOF

    cat > "UDO/UDO Project/PROJECT_STATE.json" << 'EOF'
{
  "status": "active",
  "last_updated": "now",
  "session_count": 0,
  "handoff_ready": false,
  "critical_state": {}
}
EOF

    echo -e "${GREEN}✓ Fresh v2.0 structure created${NC}"

elif [ "$INSTALL_TYPE" = "migrate-v4" ]; then
    # Create backup before migration
    BACKUP_DIR="$ORIG_DIR/.udo-backup-$(date +%Y%m%d-%H%M%S)"
    echo ""
    echo "Creating backup at $BACKUP_DIR..."
    cp -R "./UDO" "$BACKUP_DIR"

    echo "Migrating UDO v4.x to v2.0..."

    # Create new directory structure
    mkdir -p "UDO"

    # Move UDO to UDO/UDO Project
    if [ -d "UDO" ] && [ -d "./UDO" ]; then
        # UDO folder exists, we need to preserve and move carefully
        mkdir -p "UDO/UDO Project"
        # Copy all content from ./UDO to UDO/UDO Project
        cp -R "./UDO/"* "UDO/UDO Project/" 2>/dev/null || true
        # Remove old UDO folder
        rm -rf "./UDO"
    else
        # Simple case: just create and move
        mkdir -p "UDO"
        if [ -d "./UDO" ]; then
            mv "./UDO" "UDO/UDO Project"
        else
            create_project_structure "UDO/UDO Project"
        fi
    fi

    # Create framework structure
    create_project_structure "UDO/UDO Framework"

    # Copy framework files
    echo "Installing framework files..."
    update_framework_files "UDO/UDO Framework"

    # Create User Uploads if missing
    if [ ! -d "UDO/UDO Project/User Uploads" ]; then
        mkdir -p "UDO/UDO Project/User Uploads"
        touch "UDO/UDO Project/User Uploads/.gitkeep"
    fi

    # Update PROJECT_META.json with v2.0 version
    if [ -f "UDO/UDO Project/PROJECT_META.json" ]; then
        sed -i.bak 's/"udo_version": "[^"]*"/"udo_version": "2.0"/' "UDO/UDO Project/PROJECT_META.json" 2>/dev/null || true
        rm -f "UDO/UDO Project/PROJECT_META.json.bak"
    else
        cat > "UDO/UDO Project/PROJECT_META.json" << 'EOF'
{
  "project_name": "Migrated Project",
  "project_description": "Migrated from v4.x",
  "udo_version": "2.0",
  "created": "migrated",
  "ai_platform": "claude-desktop"
}
EOF
    fi

    echo -e "${GREEN}✓ Migration complete${NC}"
    echo -e "${BLUE}All data preserved in ./UDO/UDO Project/${NC}"

elif [ "$INSTALL_TYPE" = "upgrade-v4" ]; then
    # Create backup before upgrade
    BACKUP_DIR="$ORIG_DIR/.udo-backup-$(date +%Y%m%d-%H%M%S)"
    echo ""
    echo "Creating backup at $BACKUP_DIR..."
    cp -R "./UDO" "$BACKUP_DIR"

    echo "Upgrading UDO v4.x in-place..."
    update_framework_files "./UDO"

    echo -e "${GREEN}✓ Upgrade complete (v4.x mode)${NC}"
    echo "To migrate to v2.0 structure later, run: ./upgrade.sh --migrate"

else
    # v2.0 upgrade
    BACKUP_DIR="$ORIG_DIR/.udo-backup-$(date +%Y%m%d-%H%M%S)"
    echo ""
    echo "Creating backup at $BACKUP_DIR..."
    cp -R "UDO/UDO Framework" "$BACKUP_DIR"

    echo "Upgrading UDO Framework..."
    update_framework_files "$FRAMEWORK_PATH"

    # Ensure User Uploads exists in project
    if [ ! -d "$PROJECT_PATH/User Uploads" ]; then
        mkdir -p "$PROJECT_PATH/User Uploads"
        touch "$PROJECT_PATH/User Uploads/.gitkeep"
    fi

    echo -e "${GREEN}✓ Framework upgraded${NC}"
    echo -e "${BLUE}UDO Project/ data unchanged${NC}"
fi

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║       Complete!                       ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
echo ""

if [ "$INSTALL_TYPE" = "fresh" ]; then
    echo -e "${GREEN}✓ UDO v2.0 fresh install created${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. cd UDO"
    echo "  2. Edit UDO/Project/PROJECT_META.json to define your project"
    echo "  3. Edit UDO/Project/PROJECT_STATE.json to set initial state"
    echo "  4. Run: claude -p ."
elif [ "$INSTALL_TYPE" = "migrate-v4" ]; then
    echo -e "${GREEN}✓ Upgraded from $CURRENT_VERSION to v2.0${NC}"
    echo -e "✓ All data preserved in UDO/UDO Project/"
    [ -n "$BACKUP_DIR" ] && echo -e "✓ Backup saved to: ${BLUE}$BACKUP_DIR${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Review UDO/UDO Project/PROJECT_META.json"
    echo "  2. Review migration in UDO/UDO Project/"
    echo "  3. Run: claude -p ."
elif [ "$INSTALL_TYPE" = "upgrade-v4" ]; then
    echo -e "${GREEN}✓ Upgraded from $CURRENT_VERSION${NC}"
    echo -e "✓ v4.x structure preserved (backward compatible)${NC}"
    [ -n "$BACKUP_DIR" ] && echo -e "✓ Backup saved to: ${BLUE}$BACKUP_DIR${NC}"
    echo ""
    echo "To migrate to v2.0 structure:"
    echo "  ./upgrade.sh --migrate"
else
    echo -e "${GREEN}✓ Upgraded from $CURRENT_VERSION to $LATEST_VERSION${NC}"
    echo -e "✓ UDO Framework/ updated${NC}"
    echo -e "✓ UDO Project/ data preserved${NC}"
    [ -n "$BACKUP_DIR" ] && echo -e "✓ Backup saved to: ${BLUE}$BACKUP_DIR${NC}"
fi

echo ""
if [ -n "$BACKUP_DIR" ]; then
    echo "If something went wrong, restore from backup:"
    if [ "$INSTALL_TYPE" = "migrate-v4" ] || [ "$INSTALL_TYPE" = "upgrade-v4" ]; then
        echo "  rm -rf UDO && mv $BACKUP_DIR UDO"
    else
        echo "  rm -rf UDO/UDO\ Framework && mv $BACKUP_DIR UDO/UDO\ Framework"
    fi
fi
