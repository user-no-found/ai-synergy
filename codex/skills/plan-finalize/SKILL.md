---
name: plan-finalize
description: 方案定稿导航。触发：用户通知"同意方案"或Claude确认无异议后用户确认时使用；归档讨论记录，确认环境（对照environment.md），确认子代理（对照registry.yaml），生成确定方案并冻结plan_version；按需读取 references。
metadata:
  short-description: 归档讨论、确认环境与子代理、生成确定方案
  tags:
    - workflow
    - planning
    - finalize
    - governance
---

# 方案定稿（Plan Finalize）

用于在用户确认方案后，归档讨论记录、确认环境与子代理、生成确定方案并冻结plan_version。

## 核心原则（必须遵守）

- 必须按顺序执行：归档 → 环境确认 → 子代理确认 → 生成确定方案
- 环境缺失时必须阻塞，告知用户启动`env-agent`安装
- 子代理缺失时必须阻塞，告知用户启动`Sub-agent`创建
- 禁止凑合替代：缺role就阻塞，不允许用相近role顶替
- 运行槽位（如python-agent-01/02）仅用于分工标记，不创建新子代理

## References（按步骤加载）

| 步骤 | 触发条件 | 文件 |
|------|---------|------|
| 1 | 归档讨论记录 | `references/step1-archive-discussion.md` |
| 2 | 环境确认 | `references/step2-env-check.md` |
| 3 | 子代理确认 | `references/step3-agent-check.md` |
| 4 | 编译配置确认 | `references/step4-build-config.md` |
| 5 | 生成确定方案 | `references/step5-generate-plan.md` |
| 6 | 输出确定方案 | `references/step6-output.md` |

**模板文件**（按需加载）：
- 确定方案模板 -> `references/final-plan-template.md`
