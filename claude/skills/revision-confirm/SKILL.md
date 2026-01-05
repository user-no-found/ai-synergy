---
name: revision-confirm
description: 修订确认导航。触发：您通知"Codex已修订完成"或需要Claude查看Codex修订意见时使用；读取 draft-plan.md 的"Codex修订意见"章节，分析后引导下一步。
metadata:
  short-description: Claude确认Codex修订
  tags: [workflow, planning, confirm]
---

# revision-confirm

修订确认，Claude 分析 Codex 的修订意见，认可后引导用户进入 plan-finalize。

## When to Use This Skill

- 用户通知"Codex已修订完成"
- 用户说"请 Claude 查看修订"/"确认一下修订"
- 循环A规划阶段的修订确认环节

## Not For / Boundaries

**不做**：
- 不修改草案的 status 字段（由 Codex 管理）
- 不写入"用户最终确认"或类似确认结果
- 不代替 Codex 执行 plan-finalize 的任何操作
- 不修订方案（由 plan-revision 负责）

**必需输入**：
- `Record/plan/draft-plan.md` 存在且包含"Codex修订意见"章节
- 项目根目录已确认

缺少输入时用 AskUserQuestion 询问。

## Quick Reference

### 硬性规则

```
- 必须先读取 Record/plan/draft-plan.md 的"Codex修订意见"章节
- 对 Codex 修订必须进行完整分析，不能跳过
- 有异议必须说明理由并建议再次沟通（回到 Codex 修订）
- 只有认可方案后才能引导用户进入 plan-finalize
- 项目根目录不明确时必须先用 AskUserQuestion 询问
```

### 执行步骤

```
1. 确认项目根目录
2. 读取 Record/plan/draft-plan.md 的"Codex修订意见"章节
3. 分析修订内容（是否解决问题、是否引入新问题）
4. 输出分析结论（认可/有异议）
5. 有异议 → 说明理由，建议再次沟通
6. 认可 → 更新 record.md + memory.md，引导用户进入 plan-finalize
```

## Examples

### Example 1: 认可修订

- **输入**: 用户说"Codex修订完成了，请确认"
- **步骤**: 读取"Codex修订意见" → 分析 → 认可 → 引导 plan-finalize
- **验收**: 输出"修订方案认可，请将草案交给Codex执行plan-finalize"

### Example 2: 有异议

- **输入**: Codex 修订未解决关键问题
- **步骤**: 读取"Codex修订意见" → 分析 → 发现问题 → 说明异议
- **验收**: 输出异议理由，建议"请将异议反馈给Codex再次修订"

### Example 3: 项目根目录不明确

- **输入**: 用户说"确认修订"但未指定项目
- **步骤**: AskUserQuestion 询问项目根目录 → 读取 → 分析 → 输出结论
- **验收**: 确认项目后正常完成分析

## References

- `references/confirm-workflow.md` - 确认流程与分析要点
- `references/writeback-template.md` - 回写模板

## Maintenance

- 来源：双AI协同开发方案
- 最后更新：2026-01-05
- 已知限制：仅分析确认，不修改草案状态
