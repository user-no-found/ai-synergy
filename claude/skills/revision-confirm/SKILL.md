---
name: revision-confirm
description: 修订确认导航。触发：用户通知"Codex已修订完成"或需要Claude查看Codex修订意见时使用；默认先读取项目内 `Record/plan/draft-plan.md` 的"Codex修订意见"章节，对修订结果进行分析（认可/有异议），有异议则说明并建议再次沟通，认可方案后才引导用户进入最终确认流程；按需读取 references。
---

# 修订确认（Revision Confirm）

用于Claude查看Codex的修订意见，进行分析与确认，认可后引导用户进入最终确认流程。

## 核心约束

- 必须先读取`Record/plan/draft-plan.md`，特别是"Codex修订意见"章节
- 对Codex的修订必须进行完整分析，不能跳过
- 有异议必须说明理由并建议再次沟通（回到Codex修订）
- 只有认可方案后才能引导用户进入最终确认
- 项目根目录不明确时必须先用`AskUserQuestion`询问

## References（按触发条件）

- **触发条件：** 需要分析Codex修订并确认 -> `references/confirm-workflow.md`
- **触发条件：** 需要回写确认结果 -> `references/writeback-template.md`
