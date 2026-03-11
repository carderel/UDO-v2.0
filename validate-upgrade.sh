#!/bin/bash
# UDO Upgrade Validation Script
# Validates that upgrade operations completed successfully

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

INSTALL_TYPE=""
ERRORS=0
WARNINGS=0

echo ""
echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   UDO Upgrade Validation Tool         ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
echo ""

# Detect installation type
if [ -d "./UDO Framework" ] && [ -d "./UDO Project" ]; then
    INSTALL_TYPE="v2.0"
elif [ -d "./UDO" ]; then
    INSTALL_TYPE="v4.x"
else
    echo -e "${RED}No UDO installation found${NC}"
    exit 1
fi

echo -e "Installation type: ${BLUE}$INSTALL_TYPE${NC}"
echo ""

# Validation function
check_file() {
    local file=$1
    local label=$2
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $label"
        return 0
    else
        echo -e "${RED}✗${NC} $label (missing: $file)"
        ((ERRORS++))
        return 1
    fi
}

check_dir() {
    local dir=$1
    local label=$2
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓${NC} $label"
        return 0
    else
        echo -e "${RED}✗${NC} $label (missing: $dir)"
        ((ERRORS++))
        return 1
    fi
}

check_json() {
    local file=$1
    local label=$2
    if [ -f "$file" ]; then
        if jq empty "$file" 2>/dev/null; then
            echo -e "${GREEN}✓${NC} $label (valid JSON)"
            return 0
        else
            echo -e "${YELLOW}⚠${NC} $label (invalid JSON)"
            ((WARNINGS++))
            return 1
        fi
    else
        echo -e "${RED}✗${NC} $label (missing: $file)"
        ((ERRORS++))
        return 1
    fi
}

if [ "$INSTALL_TYPE" = "v2.0" ]; then
    echo -e "${YELLOW}Validating v2.0 structure...${NC}"
    echo ""

    # Check framework structure
    echo "Framework Files:"
    check_file "UDO Framework/ORCHESTRATOR.md" "ORCHESTRATOR.md"
    check_file "UDO Framework/START_HERE.md" "START_HERE.md"
    check_file "UDO Framework/COMMANDS.md" "COMMANDS.md"
    check_file "UDO Framework/VERSION" "VERSION"
    check_file "UDO Framework/CAPABILITIES.json" "CAPABILITIES.json"

    echo ""
    echo "Framework Folders:"
    check_dir "UDO Framework/.bridge" ".bridge/"
    check_dir "UDO Framework/.templates" ".templates/"
    check_dir "UDO Framework/.takeover" ".takeover/"
    check_dir "UDO Framework/.tools" ".tools/"
    check_dir "UDO Framework/.rules" ".rules/"

    echo ""
    echo "Project Files:"
    check_json "UDO Project/PROJECT_META.json" "PROJECT_META.json"
    check_json "UDO Project/PROJECT_STATE.json" "PROJECT_STATE.json"

    echo ""
    echo "Project Data Folders:"
    check_dir "UDO Project/.memory/canonical" ".memory/canonical/"
    check_dir "UDO Project/.memory/working" ".memory/working/"
    check_dir "UDO Project/.project-catalog/sessions" ".project-catalog/sessions/"
    check_dir "UDO Project/.project-catalog/decisions" ".project-catalog/decisions/"
    check_dir "UDO Project/.outputs" ".outputs/"
    check_dir "UDO Project/.checkpoints" ".checkpoints/"
    check_dir "UDO Project/.agents" ".agents/"
    check_dir "UDO Project/.rules" ".rules/"
    check_dir "UDO Project/User Uploads" "User Uploads/"

    echo ""
    echo "Version Check:"
    if [ -f "UDO Framework/VERSION" ]; then
        version=$(cat "UDO Framework/VERSION")
        echo -e "${GREEN}✓${NC} Framework version: $version"
    fi

    if [ -f "UDO Project/PROJECT_META.json" ]; then
        udo_version=$(jq -r '.udo_version' "UDO Project/PROJECT_META.json" 2>/dev/null || echo "unknown")
        if [ "$udo_version" = "2.0" ]; then
            echo -e "${GREEN}✓${NC} Project udo_version: 2.0"
        else
            echo -e "${YELLOW}⚠${NC} Project udo_version: $udo_version (expected: 2.0)"
            ((WARNINGS++))
        fi
    fi

elif [ "$INSTALL_TYPE" = "v4.x" ]; then
    echo -e "${YELLOW}Validating v4.x structure...${NC}"
    echo ""

    echo "System Files:"
    check_file "UDO/ORCHESTRATOR.md" "ORCHESTRATOR.md"
    check_file "UDO/START_HERE.md" "START_HERE.md"
    check_file "UDO/COMMANDS.md" "COMMANDS.md"
    check_file "UDO/VERSION" "VERSION"

    echo ""
    echo "Data Folders:"
    check_dir "UDO/.memory" ".memory/"
    check_dir "UDO/.project-catalog" ".project-catalog/"
    check_dir "UDO/.outputs" ".outputs/"
    check_dir "UDO/.checkpoints" ".checkpoints/"

    echo ""
    echo "Version Check:"
    if [ -f "UDO/VERSION" ]; then
        version=$(cat "UDO/VERSION")
        echo -e "${GREEN}✓${NC} Version: $version"
    fi

fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"

if [ $ERRORS -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
        echo -e "${GREEN}✓ All validations passed!${NC}"
        exit 0
    else
        echo -e "${YELLOW}⚠ Validation completed with $WARNINGS warning(s)${NC}"
        exit 0
    fi
else
    echo -e "${RED}✗ Validation failed with $ERRORS error(s), $WARNINGS warning(s)${NC}"
    echo ""
    echo "Issues to address:"
    echo "1. Check file permissions"
    echo "2. Verify download was complete"
    echo "3. Check disk space"
    echo "4. Re-run upgrade if needed"
    exit 1
fi
