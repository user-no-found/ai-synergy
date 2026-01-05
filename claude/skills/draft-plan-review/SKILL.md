---
name: draft-plan-review
description: 复审 Codex 生成的"预定清单（草案）"。触发：用户让你复审/分析/补全 Codex 的项目规划草案时使用；读取 draft-plan.md 并回写分析结果。
metadata:
  short-description: Claude复审Codex草案
  tags: [workflow, planning, review]
---

# draft-plan-review

预定清单复审，Claude 分析 Codex 生成的草案，补充技术细节和风险评估。

## When to Use This Skill

- 用户让你复审/分析/补全 Codex 的项目规划草案
- 用户说"请 Claude 复审"/"分析一下草案"
- 循环A规划阶段的复审环节

## Not For / Boundaries

**不做**：
- 不创建 Record 结构（由 project-bootstrap 负责）
- 不修订方案（由 plan-revision 负责）
- 不定稿方案（由 plan-finalize 负责）

**必需输入**：
- `Record/plan/draft-plan.md` 存在
- 项目根目录已确认

缺少输入时用 AskUserQuestion 询问。

## Quick Reference

### 硬性规则

```
- 优先读项目内文件：Record/plan/draft-plan.md
- 项目根目录不明确/文件不存在：必须先用 AskUserQuestion 询问
- 信息不完整时：先问清楚再改文件（避免把猜测写进文档）
- 回写目标：追加"Claude复审补充"章节到 draft-plan.md
```

### 执行步骤

```
1. 确认项目根目录
2. 读取 Record/plan/draft-plan.md
3. 分析草案内容（技术可行性、风险、遗漏）
4. 不清楚处用 AskUserQuestion 询问
5. 回写分析结果到"Claude复审补充"章节
6. 更新 record.md + memory.md
7. 告知用户复审完成，引导进入 plan-revision
```

## Examples

### Example 1: 正常复审

- **输入**: 用户说"请复审 Codex 的草案"
- **步骤**: 读取 draft-plan.md → 分析 → 回写"Claude复审补充" → 告知用户
- **验收**: draft-plan.md 包含"Claude复审补充"章节

### Example 2: 信息不完整

- **输入**: 草案缺少技术栈信息
- **步骤**: 读取 draft-plan.md → 发现缺失 → AskUserQuestion 询问 → 回写
- **验收**: 用户回答后，draft-plan.md 包含完整分析

### Example 3: 项目根目录不明确

- **输入**: 用户说"复审草案"但未指定项目
- **步骤**: AskUserQuestion 询问项目根目录 → 读取 → 分析 → 回写
- **验收**: 确认项目后正常完成复审

## References

- `references/review-workflow.md` - 复审流程与输出结构
- `references/writeback-template.md` - 回写模板

## Maintenance

- 来源：双AI协同开发方案
- 最后更新：2026-01-05
- 已知限制：仅复审分析，不修订方案
