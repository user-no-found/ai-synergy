# AI协同方案架构索引

本文件供 ai-agent 快速定位和修改全局配置。

## 一、整体架构

```
Codex（规划/审核）  <--用户中转-->  Claude（分析/执行）
       ↓                              ↓
   Skills x6                      Skills x2
                                  Agents x10
```

## 二、循环A（规划阶段）

| 顺序 | 执行者 | Skill | 路径 |
|------|--------|-------|------|
| 1 | Codex | project-bootstrap | ~/.codex/skills/project-bootstrap/ |
| 2 | Claude | draft-plan-review | ~/.claude/skills/draft-plan-review/ |
| 3 | Codex | plan-revision | ~/.codex/skills/plan-revision/ |
| 4 | Claude | revision-confirm | ~/.claude/skills/revision-confirm/ |
| 5 | Codex | plan-finalize | ~/.codex/skills/plan-finalize/ |

## 三、循环B（执行阶段）

| 顺序 | 执行者 | Skill | 路径 |
|------|--------|-------|------|
| 1 | Codex | plan-confirm | ~/.codex/skills/plan-confirm/ |
| 2 | Claude | 子代理执行 | ~/.claude/agents/*.md |
| 3 | Codex | code-review | ~/.codex/skills/code-review/ |
| 4 | Codex | project-complete | ~/.codex/skills/project-complete/ |

## 四、Codex Skills 清单

### project-bootstrap
- 触发：用户开始新项目
- 文件：
  - `SKILL.md`
  - `references/bootstrap.md`
  - `references/templates.md`

### draft-plan-review（Claude）
- 触发：用户让Claude复审草案
- 文件：
  - `SKILL.md`
  - `references/review-workflow.md`
  - `references/writeback-template.md`

### plan-revision
- 触发：用户通知Codex查看Claude分析
- 文件：
  - `SKILL.md`
  - `references/revision-workflow.md`
  - `references/writeback-template.md`

### revision-confirm（Claude）
- 触发：用户通知Claude查看Codex修订
- 文件：
  - `SKILL.md`
  - `references/confirm-workflow.md`
  - `references/writeback-template.md`

### plan-finalize
- 触发：用户确认方案
- 文件：
  - `SKILL.md`
  - `references/step1-archive-discussion.md`
  - `references/step2-env-check.md`
  - `references/step3-agent-check.md`
  - `references/step4-build-config.md`
  - `references/step5-generate-plan.md`
  - `references/step6-output.md`
  - `references/final-plan-template.md`

### plan-confirm
- 触发：用户确认开始执行
- 文件：
  - `SKILL.md`
  - `references/step1-check-state.md`
  - `references/step2-init-openspec.md`
  - `references/step3-create-proposal.md`
  - `references/step4-output-tasklist.md`
  - `references/step5-handle-questions.md`
  - `references/proposal-template.md`
  - `references/build-proposal-template.md`
  - `references/security-scan-proposal-template.md`

### code-review
- 触发：编译通过后
- 文件：
  - `SKILL.md`
  - `references/step1-check-state.md`
  - `references/step2-archive-impl.md`
  - `references/step3-collect-scope.md`
  - `references/step4-execute-review.md`
  - `references/step5-generate-report.md`
  - `references/step6-create-fix-proposal.md`
  - `references/step7-re-review.md`
  - `references/review-checklist.md`
  - `references/review-report-template.md`

### project-complete
- 触发：项目完成
- 文件：
  - `SKILL.md`
  - `references/step1-check-state.md`
  - `references/step2-archive.md`
  - `references/step3-changelog.md`
  - `references/step4-commit-push.md`
  - `references/step5-update-state.md`
  - `references/step6-notify.md`

### build-report
- 触发：build-agent需要输出报告
- 文件：
  - `SKILL.md`
  - `references/error-report-template.md`
  - `references/success-report-template.md`

### agents-registry
- 触发：需要查询子代理登记
- 文件：
  - `SKILL.md`
  - `references/registry.yaml`

## 五、Claude 子代理清单

| 子代理 | 文件 | 职责 |
|--------|------|------|
| python-agent | ~/.claude/agents/python-agent.md | Python实现 |
| rust-agent | ~/.claude/agents/rust-agent.md | Rust实现 |
| c-agent | ~/.claude/agents/c-agent.md | C语言实现 |
| ui-agent | ~/.claude/agents/ui-agent.md | 前端UI实现 |
| doc-agent | ~/.claude/agents/doc-agent.md | 文档更新 |
| build-agent | ~/.claude/agents/build-agent.md | 编译构建 |
| sec-agent | ~/.claude/agents/sec-agent.md | 安全审查 |
| env-agent | ~/.claude/agents/env-agent.md | 环境安装 |
| ai-agent | ~/.claude/agents/ai-agent.md | 全局治理 |
| Sub-agent | ~/.claude/agents/sub-agent.md | 子代理管理 |

## 六、全局配置

| 配置 | 路径 | 说明 |
|------|------|------|
| Claude全局指令 | ~/.claude/CLAUDE.md | Claude Code全局规则 |
| Codex全局指令 | ~/.codex/AGENTS.md | OpenAI Codex全局规则 |

## 七、Git操作时机

| 阶段 | 操作 | 位置 |
|------|------|------|
| plan-confirm步骤2 | git init + commit | 初始化 |
| 子代理完成任务 | git commit（本地） | 各子代理 |
| project-complete步骤2 | git commit（归档） | Codex |
| project-complete步骤4 | git push（唯一） | Codex |

## 八、镜像同步规则

修改任何文件后，必须同步更新镜像：

| 真实路径 | 镜像路径 |
|----------|----------|
| ~/.codex/skills/* | ~/ai-synergy/codex/skills/* |
| ~/.codex/AGENTS.md | ~/ai-synergy/codex/AGENTS.md |
| ~/.claude/skills/* | ~/ai-synergy/claude/skills/* |
| ~/.claude/agents/* | ~/ai-synergy/claude/agents/* |
| ~/.claude/CLAUDE.md | ~/ai-synergy/claude/CLAUDE.md |

## 九、修改检查清单

修改前必须确认：
- [ ] 影响哪些skill/子代理
- [ ] 是否需要更新步骤文件
- [ ] 是否需要更新模板文件
- [ ] 是否影响git操作流程
- [ ] 是否需要更新MANAGED.yaml
- [ ] 是否需要更新PATHS.yaml
- [ ] 镜像是否同步
