---
name: draft-plan-review
description: 复审 Codex 生成的“预定清单（草案）”。触发：用户让你复审/分析/补全 Codex 的项目规划草案时使用；默认先读取项目内 `Record/plan/draft-plan.md`，不清楚处先 AskUserQuestion，得到答复后再把分析与补充回写到该文件；按需读取 references。
---

# 预定清单复审（Claude）

## 核心约束

- 优先读项目内文件：`Record/plan/draft-plan.md`
- 如果项目根目录不明确/文件不存在：必须先用 `AskUserQuestion` 询问项目根目录或文件路径
- 信息不完整时：先问清楚再改文件（避免把猜测写进文档）
- 回写目标：把复审结论与补充内容写回 `Record/plan/draft-plan.md`（追加“Claude复审补充”章节）

## References（按触发条件）

- 需要复审流程与输出结构 -> `references/review-workflow.md`
- 需要回写模板 -> `references/writeback-template.md`
