---
name: code-review
description: 代码审核导航。触发：用户通知"编译通过"或"请审核代码"时使用；对所有子代理产出的代码进行质量审核、规范检查、越界检查，输出审核报告；按需读取 references。
metadata:
  short-description: 编译通过后进行代码审核
  tags:
    - workflow
    - review
    - quality
---

# 代码审核（Code Review）

用于在编译通过后，对所有子代理产出的代码进行质量审核，输出审核报告供用户确认。

## 前置条件（必须满足）

- 编译提案（`build-all-build-agent`）状态为 `accepted`
- 所有功能实现提案状态为 `accepted`

## 核心职责

1. **代码质量检查**：识别"屎山代码"、重复代码、过度复杂等问题
2. **规范检查**：是否符合项目编码规范
3. **越界检查**：对照 scope 检查是否有越界修改
4. **风险识别**：潜在的安全问题、性能问题、维护性问题

## References（按步骤加载）

| 步骤 | 触发条件 | 文件 |
|------|---------|------|
| 1 | 确认前置状态 | `references/step1-check-state.md` |
| 2 | 归档提案执行记录 | `references/step2-archive-impl.md` |
| 3 | 收集审核范围 | `references/step3-collect-scope.md` |
| 4 | 执行审核 | `references/step4-execute-review.md` |
| 5 | 生成审核报告 | `references/step5-generate-report.md` |
| 6 | 创建修复提案 | `references/step6-create-fix-proposal.md` |
| 7 | 修复后重新审核 | `references/step7-re-review.md` |

**模板文件**（按需加载）：
- 审核检查清单 -> `references/review-checklist.md`
- 审核报告模板 -> `references/review-report-template.md`
