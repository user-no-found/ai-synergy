---
name: project-complete
description: 项目完成导航。触发：用户通知"项目完成"或"可以提交了"时使用；执行归档、生成changelog、git commit+push；按需读取 references。
metadata:
  short-description: 项目完成与归档提交
  tags:
    - workflow
    - complete
    - git
---

# 项目完成 Skill

## 触发条件

用户通知"项目完成"或"可以提交了"时触发。

## 前置检查

1. 确认代码审核已通过
2. 确认安全扫描已通过或用户明确跳过
3. 确认所有提案状态为 `accepted`

## 产出

- 更新 `Record/state.json` 状态为 `completed`
- 执行 git commit + push
- 生成项目完成摘要

## References（按步骤加载）

| 步骤 | 触发条件 | 文件 |
|------|---------|------|
| 1 | 前置状态确认 | `references/step1-check-state.md` |
| 2 | 归档 OpenSpec 提案 | `references/step2-archive.md` |
| 3 | 生成变更清单 | `references/step3-changelog.md` |
| 4 | 项目完成提交与推送 | `references/step4-commit-push.md` |
| 5 | 更新项目状态 | `references/step5-update-state.md` |
| 6 | 通知用户 | `references/step6-notify.md` |
