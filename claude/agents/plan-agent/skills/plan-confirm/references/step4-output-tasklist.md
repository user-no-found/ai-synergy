# 步骤4：输出任务清单

## 清单格式

```
## 子代理任务清单

| 运行槽位 | 子代理 | proposal_id | 负责工作 |
|---------|-------|-------------|---------|
| python-agent-01 | python-agent | add-login-python-agent | 实现登录模块 |
| build-agent-01 | build-agent | build-all-build-agent | 编译所有模块 |

## 启动顺序建议

1. 先启动无依赖的任务
2. 有依赖关系的任务按依赖顺序启动
3. 可并行的任务可同时启动
4. build-agent 最后启动

## 用户操作指引

1. 在 Claude 中启动对应子代理
2. 告知子代理 proposal_id
3. 子代理完成后通知用户
4. 编译通过后通知 Codex 进行审核
```
