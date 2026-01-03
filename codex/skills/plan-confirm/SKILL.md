---
name: plan-confirm
description: 方案确认导航。触发：用户查看确定方案后通知"确认方案"或"开始执行"时使用；初始化openspec、创建提案、输出子代理任务清单与分工；按需读取 references。
metadata:
  short-description: 确认方案后初始化openspec并创建提案
  tags:
    - workflow
    - planning
    - openspec
    - execution
---

# 方案确认（Plan Confirm）

用于在用户确认确定方案后，初始化openspec、创建提案、输出子代理任务清单与分工，正式进入循环B（执行阶段）。

## 前置条件（必须满足）

- `plan-finalize` 已完成，确定方案已生成
- `Record/state.json` 中 `active_plan_version` 已冻结
- 环境与子代理检查已通过

## 核心流程（必须按顺序）

1. **确认前置状态**：读取 `Record/state.json` 确认 `active_plan_version` 存在
2. **初始化 OpenSpec**：执行 `openspec init --tools none`
3. **创建提案**：按确定方案中的任务拆分创建 proposal
4. **输出任务清单**：告知用户需要启动哪些子代理、各做什么工作

## References（按步骤加载）

| 步骤 | 触发条件 | 文件 |
|------|---------|------|
| 1 | 确认前置状态 | `references/step1-check-state.md` |
| 2 | 初始化 OpenSpec 和 Git | `references/step2-init-openspec.md` |
| 3 | 创建提案 | `references/step3-create-proposal.md` |
| 4 | 输出任务清单 | `references/step4-output-tasklist.md` |
| 5 | 用户问题处理 | `references/step5-handle-questions.md` |

**模板文件**（按需加载）：
- 提案模板 -> `references/proposal-template.md`
- 编译提案模板 -> `references/build-proposal-template.md`
