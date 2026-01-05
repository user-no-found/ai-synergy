---
name: plan-finalize
description: 方案定稿导航。触发：用户通知"同意方案"或Claude确认无异议后用户确认时使用；归档讨论、确认环境与子代理、生成确定方案并冻结plan_version。
metadata:
  short-description: 归档讨论、确认环境与子代理、生成确定方案
  tags: [workflow, planning, finalize]
---

# plan-finalize

方案定稿，归档讨论记录、确认环境与子代理、生成确定方案并冻结plan_version。

## When to Use This Skill

- 用户通知"同意方案"/"确认方案"
- Claude确认无异议后用户选择"同意"
- 循环A规划阶段完成，准备进入循环B执行

## Not For / Boundaries

**不做**：
- 不分析需求（由 draft-plan-review 负责）
- 不修订方案（由 plan-revision 负责）
- 不执行代码（由循环B子代理负责）

**必需输入**：
- `Record/plan/draft-plan.md` 已包含完整讨论记录
- 用户明确确认方案

缺少输入时阻塞并告知用户。

## Quick Reference

### 硬性规则

```
- 必须按顺序执行：归档 → 环境确认 → 子代理确认 → 生成确定方案
- 环境缺失时阻塞，告知用户启动 env-agent 安装
- 子代理缺失时阻塞，告知用户启动 Sub-agent 创建
- 禁止凑合替代：缺role就阻塞，不允许用相近role顶替
- 运行槽位（如python-agent-01/02）仅用于分工标记，不创建新子代理
```

### 执行步骤

```
1. 归档讨论记录 → draft-plan.md 复制为 {plan_version}-discussion.md
2. 环境确认 → 对照 ~/environment.md，缺失则阻塞
3. 子代理确认 → 对照 registry.yaml，缺失则阻塞
4. 编译配置确认 → 确认构建命令和目标
5. 生成确定方案 → 写入 Record/plan/{plan_version}-final.md
6. 输出确定方案 → 更新 record.md + memory.md，告知用户
```

## Examples

### Example 1: 正常定稿

- **输入**: 用户说"同意方案"
- **步骤**: 归档讨论 → 环境确认(通过) → 子代理确认(通过) → 生成确定方案
- **验收**: `{plan_version}-final.md` 生成，plan_version冻结

### Example 2: 环境缺失

- **输入**: 方案需要Rust但未安装
- **步骤**: 归档讨论 → 环境确认(失败) → 阻塞
- **验收**: 输出"请启动env-agent安装Rust环境"，不继续后续步骤

### Example 3: 子代理缺失

- **输入**: 方案需要新的子代理类型
- **步骤**: 归档讨论 → 环境确认(通过) → 子代理确认(失败) → 阻塞
- **验收**: 输出"请启动Sub-agent创建xxx子代理"，不继续后续步骤

## References

- `references/step1-archive-discussion.md` - 归档讨论记录
- `references/step2-env-check.md` - 环境确认
- `references/step3-agent-check.md` - 子代理确认
- `references/step4-build-config.md` - 编译配置确认
- `references/step5-generate-plan.md` - 生成确定方案
- `references/step6-output.md` - 输出确定方案
- `references/final-plan-template.md` - 确定方案模板

## Maintenance

- 来源：双AI协同开发方案
- 最后更新：2026-01-05
- 已知限制：仅定稿，不执行代码
