---
name: agents-registry
description: 管理与查询 Claude 子代理清单（name/role/状态/职责边界）。在进行“子代理存在性确认、分工、禁止凑合替代”时触发读取 references/registry.yaml；平时不加载。
metadata:
  short-description: Claude 子代理登记表（按需读取）
  tags:
    - agents
    - registry
    - governance
    - workflow
---

# 子代理登记表（Codex）

## 使用方式（按需读取，避免上下文污染）

1) 仅在需要做“子代理存在性确认/分工/role 能力边界校验”时读取 `references/registry.yaml`
2) 读取后先用 3-7 条要点做摘要，再进入分工或阻塞判断

## 数据来源与更新

- 数据来源：用户在 Claude 中实际创建的子代理
- 更新方式：由 `Sub-agent`（Claude 子代理）在创建/补齐子代理后更新 `references/registry.yaml`

