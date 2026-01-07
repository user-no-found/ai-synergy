# 子代理记忆模板

## 唯一实例子代理模板

用于：plan-agent、analysis-agent、neutral-agent、build-agent、sec-agent、env-agent、doc-agent

文件名：`Record/Memory/{agent-name}.md`

```markdown
# {agent-name} 记忆

## 基本信息
- 项目名：
- 项目根目录：
- 首次启动：YYYY-MM-DD HH:MM
- 最后更新：YYYY-MM-DD HH:MM

## 当前状态
- 阶段：planning | executing | reviewing | completed
- 当前任务：
- 阻塞项：

## 关键决策
| 时间 | 决策 | 原因 | 相关方 |
|------|------|------|--------|
| YYYY-MM-DD | ... | ... | 用户/plan-agent/analysis-agent |

## 技术要点
- ...

## 待处理事项
- [ ] ...

## 会话记录摘要
### YYYY-MM-DD HH:MM
- 做了什么：
- 结论：
- 下一步：
```

## 多实例子代理模板

用于：python-agent、rust-agent、c-agent、ui-agent

文件名：`Record/Memory/{agent-name}-{nn}.md`（如 python-agent-01.md）

```markdown
# {agent-name}-{nn} 记忆

## 基本信息
- 项目名：
- 项目根目录：
- 实例编号：{nn}
- proposal_id：
- 首次启动：YYYY-MM-DD HH:MM
- 最后更新：YYYY-MM-DD HH:MM

## 任务分配
- 负责模块：
- 允许路径：
- 禁止路径：
- 依赖子代理：

## 当前状态
- 阶段：implementing | testing | completed
- 当前任务：
- 阻塞项：

## 实现记录
| 时间 | 文件 | 变更 | 说明 |
|------|------|------|------|
| YYYY-MM-DD | src/xxx.py | 新增 | 实现xxx功能 |

## 技术要点
- ...

## 待处理事项
- [ ] ...

## 会话记录摘要
### YYYY-MM-DD HH:MM
- 做了什么：
- 结论：
- 下一步：
```

## 启动时行为

1. 检查 `Record/Memory/` 目录是否存在，不存在则创建
2. 检查对应记忆文件是否存在：
   - 唯一实例：`Record/Memory/{agent-name}.md`
   - 多实例：`Record/Memory/{agent-name}-{nn}.md`
3. 不存在则根据模板创建
4. 存在则读取记忆，恢复上下文
5. 执行过程中实时更新记忆文件
