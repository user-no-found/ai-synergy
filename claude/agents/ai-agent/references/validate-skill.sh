#!/bin/bash
# Skill/子代理验证脚本
# 用法: ./validate-skill.sh <path> [--strict]

set -e

SKILL_PATH="$1"
STRICT_MODE="$2"

if [ -z "$SKILL_PATH" ]; then
    echo "用法: ./validate-skill.sh <skill-path> [--strict]"
    exit 1
fi

# 查找入口文件
if [ -f "$SKILL_PATH/SKILL.md" ]; then
    ENTRY_FILE="$SKILL_PATH/SKILL.md"
elif [ -f "$SKILL_PATH" ] && [[ "$SKILL_PATH" == *.md ]]; then
    ENTRY_FILE="$SKILL_PATH"
else
    echo "错误: 找不到 SKILL.md 或 .md 文件"
    exit 1
fi

echo "验证: $ENTRY_FILE"
echo "================================"

SCORE=0
ERRORS=()

# 检查 frontmatter
check_frontmatter() {
    if grep -q "^---" "$ENTRY_FILE" && grep -q "^name:" "$ENTRY_FILE"; then
        echo "[✓] frontmatter 存在"
        SCORE=$((SCORE + 2))
    else
        echo "[✗] frontmatter 缺失"
        ERRORS+=("缺少 frontmatter (name, description)")
    fi
}

# 检查 description
check_description() {
    if grep -q "^description:" "$ENTRY_FILE"; then
        echo "[✓] description 存在"
        SCORE=$((SCORE + 2))
    else
        echo "[✗] description 缺失"
        ERRORS+=("缺少 description")
    fi
}

# 检查 When to Use
check_when_to_use() {
    if grep -q "## When to Use" "$ENTRY_FILE"; then
        echo "[✓] When to Use 存在"
        SCORE=$((SCORE + 2))
    else
        echo "[✗] When to Use 缺失"
        ERRORS+=("缺少 When to Use This Skill 章节")
    fi
}

# 检查 Boundaries
check_boundaries() {
    if grep -q "## Not For\|Boundaries" "$ENTRY_FILE"; then
        echo "[✓] Boundaries 存在"
        SCORE=$((SCORE + 2))
    else
        echo "[✗] Boundaries 缺失"
        ERRORS+=("缺少 Not For / Boundaries 章节")
    fi
}

# 检查 Quick Reference
check_quick_reference() {
    if grep -q "## Quick Reference" "$ENTRY_FILE"; then
        echo "[✓] Quick Reference 存在"
        SCORE=$((SCORE + 2))
    else
        echo "[✗] Quick Reference 缺失"
        ERRORS+=("缺少 Quick Reference 章节")
    fi
}

# 检查 Examples
check_examples() {
    EXAMPLE_COUNT=$(grep -c "### Example" "$ENTRY_FILE" || echo 0)
    if [ "$EXAMPLE_COUNT" -ge 3 ]; then
        echo "[✓] Examples >= 3 ($EXAMPLE_COUNT 个)"
        SCORE=$((SCORE + 4))
    elif [ "$EXAMPLE_COUNT" -ge 1 ]; then
        echo "[~] Examples < 3 ($EXAMPLE_COUNT 个)"
        SCORE=$((SCORE + 2))
        ERRORS+=("示例数量不足 (需要 >= 3)")
    else
        echo "[✗] Examples 缺失"
        ERRORS+=("缺少 Examples 章节")
    fi
}

# 检查 Maintenance
check_maintenance() {
    if grep -q "## Maintenance" "$ENTRY_FILE"; then
        echo "[✓] Maintenance 存在"
        SCORE=$((SCORE + 2))
    else
        echo "[✗] Maintenance 缺失"
        ERRORS+=("缺少 Maintenance 章节")
    fi
}

# 执行检查
check_frontmatter
check_description
check_when_to_use
check_boundaries
check_quick_reference
check_examples
check_maintenance

echo "================================"
echo "总分: $SCORE / 18 (基础检查)"

if [ "$STRICT_MODE" == "--strict" ]; then
    if [ "$SCORE" -lt 14 ]; then
        echo "状态: 不通过 (严格模式要求 >= 14)"
        echo ""
        echo "错误:"
        for err in "${ERRORS[@]}"; do
            echo "  - $err"
        done
        exit 1
    fi
fi

if [ "$SCORE" -ge 14 ]; then
    echo "状态: 通过"
else
    echo "状态: 需改进"
    echo ""
    echo "建议修复:"
    for err in "${ERRORS[@]}"; do
        echo "  - $err"
    done
fi
