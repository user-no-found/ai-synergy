# 模板（最小可用）

> 说明：只提供最小骨架，避免把冗长模板灌入上下文；需要时再扩展。

## `Record/plan/draft-plan.md`（最小骨架）

```markdown
---
doc_type: plan
plan_version: ""
status: draft
created_at: ISO8601
project_root: "<由用户确认的项目根目录>"
---

# 预定清单（草案）

## 需求摘要（3-7条）
- ...

## 预期流程（最小闭环）
- 循环A：规划 -> 用户确认 -> 冻结 v1
- 循环B：openspec+提案 -> 子代理执行 -> Codex审核 -> 用户确认 -> 用户手动分发

## 环境检查（对照 ~/environment.md）
- 已具备：...
- 缺失：...
- 安装负责人：用户
- 校验方式：...

## 子代理需求与分工（运行槽位）
- 需要的子代理：python-agent / rust-agent / ...
- 并行运行槽位示例：python-agent 需要 2 个运行槽位（python-agent-01 / python-agent-02），表示用户开两个同名 python-agent 会话

## 子代理存在性确认（对照 registry）
- registry: ~/.codex/skills/agents-registry/references/registry.yaml
- 核对结论：...

## scope 轮廓（初版）
- allowed_paths: ...
- forbidden_patterns: ...
- dependencies: ...
- max_review_rounds: ...

## 用户确认选项
- 同意按当前方案执行 / 需要调整后再确认 / 暂停取消
```

## `Record/state.json`（最小骨架）

```json
{
  "active_plan_version": "",
  "agents_registry_path": "~/.codex/skills/agents-registry/references/registry.yaml",
  "environment_path": "~/environment.md",
  "proposals": {}
}
```

## `Record/record.md`（项目记录）

```markdown
# 项目记录

> 记录项目重大事件，便于回溯。git相关记录包含commit hash。

<!-- 由各阶段自动追加，勿手动编辑格式 -->
```

### 记录格式

```markdown
## YYYY-MM-DD HH:MM 事件类型
内容...
```

### 事件类型

| 类型 | 触发时机 | 记录内容 |
|------|---------|---------|
| 需求提出 | project-bootstrap | 用户需求摘要 |
| 方案确定 | plan-finalize | 方案版本、任务数 |
| 子代理完成 | 子代理提交后 | commit hash、提交信息 |
| 编译结果 | build-agent完成 | 成功/失败、产出/错误摘要 |
| 代码审核 | code-review完成 | 通过/问题数 |
| 提案修改 | Codex修改提案 | 修改原因、影响范围 |
| 归档完成 | project-complete步骤2 | commit hash、归档提案数 |
| 推送远程 | project-complete步骤4 | commit hash、远程分支 |
| 阻塞事件 | 环境/子代理缺失 | 阻塞原因、解决方式 |
