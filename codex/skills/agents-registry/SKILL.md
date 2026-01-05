---
name: agents-registry
description: 子代理登记表。触发：需要确认子代理存在性、分工、能力边界时使用；按需读取 references/registry.yaml。
metadata:
  short-description: Claude 子代理登记表（按需读取）
  tags: [agents, registry, governance]
---

# agents-registry

子代理登记表，管理与查询 Claude 子代理清单（name/role/状态/职责边界）。

## When to Use This Skill

- 需要确认子代理存在性
- 需要进行子代理分工
- 需要校验 role 能力边界
- plan-finalize 步骤3（子代理确认）

## Not For / Boundaries

**不做**：
- 不创建子代理（由 Sub-agent 负责）
- 不修改子代理定义（由 ai-agent 负责）
- 不执行代码（由具体子代理负责）

**必需输入**：无特殊输入要求，按需读取 registry.yaml。

## Quick Reference

### 硬性规则

```
- 仅在需要时读取 registry.yaml，避免上下文污染
- 读取后先用 3-7 条要点做摘要
- 禁止凑合替代：缺 role 就阻塞，不允许用相近 role 顶替
- 运行槽位（如 python-agent-01/02）仅用于分工标记
```

### 使用流程

```
1. 确定需要查询的子代理类型
2. 读取 references/registry.yaml
3. 用 3-7 条要点做摘要
4. 进行存在性确认或分工判断
5. 缺失则阻塞，告知用户启动 Sub-agent 创建
```

### 数据来源与更新

```
- 数据来源：用户在 Claude 中实际创建的子代理
- 更新方式：由 Sub-agent 在创建/补齐子代理后更新 registry.yaml
```

## Examples

### Example 1: 确认子代理存在

- **输入**: plan-finalize 需要确认 rust-agent 是否存在
- **步骤**: 读取 registry.yaml → 查找 rust-agent → 确认存在
- **验收**: 返回"rust-agent 存在，可用于 Rust 实现任务"

### Example 2: 子代理缺失

- **输入**: 方案需要 go-agent 但不存在
- **步骤**: 读取 registry.yaml → 查找 go-agent → 未找到 → 阻塞
- **验收**: 输出"go-agent 不存在，请启动 Sub-agent 创建"

### Example 3: 分工查询

- **输入**: 需要确定哪些子代理可以处理前端任务
- **步骤**: 读取 registry.yaml → 筛选前端相关 role → 返回 ui-agent
- **验收**: 返回"ui-agent 可处理前端 UI 实现"

## References

- `references/registry.yaml` - 子代理登记表数据

## Maintenance

- 来源：双AI协同开发方案
- 最后更新：2026-01-05
- 已知限制：仅查询，不创建或修改子代理

