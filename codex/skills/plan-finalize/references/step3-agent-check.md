# 步骤3：子代理确认

## 执行

1. 读取`~/.codex/skills/agents-registry/references/registry.yaml`
2. 对照草案中的子代理需求，逐项检查：
   - 已存在且status=active：标记为✓
   - 不存在或status=disabled：标记为✗，记录缺失项

## 缺失处理

如果存在缺失项：
- **阻塞流程**
- 输出缺失清单（name/role）
- 告知如何启动 Sub-agent：
  ```
  请在 Claude 中执行命令：
  /agents
  选择 Sub-agent，然后告诉它创建以下子代理：{缺失清单}
  ```
- 等待通知"子代理已创建"后重新执行子代理确认

## 禁止凑合替代

- 需要`c-agent`但只有`rust-agent` → 阻塞，不允许用rust-agent写C
- 需要`python-agent`但registry中没有 → 阻塞，要求创建

## 通过条件

无缺失项时自动进入下一步。
