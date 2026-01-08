# plan-agent 草案模板

写入 `Record/plan/draft-plan.md`：

```markdown
# 项目草案

## 用户需求

{用户原始需求}

## plan-agent 草案

### 需求理解

{对用户需求的理解}

### 技术方案

{技术方案描述}

### 子代理分工

| 阶段 | 槽位 | 子代理 | 任务 | 依赖 |
|------|------|--------|------|------|
| 1 | python-agent-01 | python-agent | 数据处理 | 无 |
| 1 | rust-agent-01 | rust-agent | 核心算法 | 无 |
| 2 | python-agent-02 | python-agent | API接口 | python-agent-01 |

### 风险评估

{风险评估}
```

## 注意事项

- draft-plan.md 只保留用户需求和当前最新草案
- 每轮讨论意见写入 `round-N/plan-agent.md`
- 不在 draft-plan.md 中累积历史讨论
