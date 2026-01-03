---
name: project-bootstrap
description: 项目启动与落盘导航。触发：用户开始一个新项目/首次提出需求需要进入循环A规划时，必须先确认项目根目录（CWD）并创建 Record/ 目录结构，生成并落盘“预定清单（草案）”与确认点文件约定；默认不加载 references，按需读取。
metadata:
  short-description: 项目启动落盘与 Record 结构
  tags:
    - workflow
    - record
    - planning
    - governance
---

# 项目启动（Record Bootstrap）

用于把“开始项目”这一步标准化为可落盘、可追溯的动作，避免只在对话里说计划却不产出文件。

## 核心原则（必须遵守）

- 项目内产物必须写入“项目根目录下的 `Record/`”（禁止写入 `~/ai-synergy/`）
- 默认项目根目录 = 你启动 Codex 时的当前工作目录（CWD）；不确定时必须先询问用户确认
- 未确认项目根目录前，不得创建/修改任何项目文件（最多只输出提问）

## References（按触发条件）

- **触发条件：** 用户开始新项目/首次提出需求 -> `references/bootstrap.md`
- **触发条件：** 需要写入文件模板（预定清单/状态机）-> `references/templates.md`
