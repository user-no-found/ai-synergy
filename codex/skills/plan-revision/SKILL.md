---
name: plan-revision
description: 规划修订导航。触发：用户通知"Claude已分析完成"或需要Codex查看Claude复审结果并修订预定清单时使用；默认先读取项目内 `Record/plan/draft-plan.md` 的"Claude复审补充"章节，对分析结果进行评估（认可/不认可），不认可处必须说明理由并修订；按需读取 references。
metadata:
  short-description: Codex查看Claude分析并修订规划
  tags:
    - workflow
    - planning
    - revision
    - governance
---

# 规划修订（Plan Revision）

用于Codex查看Claude的复审分析结果，进行评估与修订，形成可供用户确认的最终规划。

## 核心原则（必须遵守）

- 必须先读取`Record/plan/draft-plan.md`，特别是"Claude复审补充"章节
- 对Claude的每项分析必须明确表态：认可/不认可/部分认可
- 不认可的点必须说明理由（中文）
- 修订后必须更新`draft-plan.md`，形成可供用户确认的版本
- 项目根目录不明确时必须先询问用户

## References（按触发条件）

- **触发条件：** 需要评估Claude分析并修订 -> `references/revision-workflow.md`
- **触发条件：** 需要回写修订结果 -> `references/writeback-template.md`
