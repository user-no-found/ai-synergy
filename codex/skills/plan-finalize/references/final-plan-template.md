# 确定方案模板

> 说明：此文件写入`Record/plan/{plan_version}-plan.md`

```markdown
---
doc_type: plan
plan_version: v1
status: finalized
finalized_at: ISO8601
project_root: "<项目根目录>"
---

# 确定方案

## 需求摘要

- ...
- ...

## 最终scope

- allowed_paths:
  - ...
- forbidden_patterns:
  - ...
- dependencies:
  - ...
- max_review_rounds: ...

## 环境确认

- status: ready
- 确认时间: ...
- 环境清单: 见 ~/environment.md

## 编译配置

### 目标平台与架构

| 平台 | 架构 | 说明 |
|-----|------|------|
| Linux | x86_64 | 主要目标 |
| Windows | x86_64 | 可选 |

### 构建类型

- [ ] Debug
- [x] Release

### 编译顺序（多语言项目）

> 如果是多语言项目，按依赖关系排序

1. Rust 核心库（被其他模块依赖）
2. Python 绑定
3. 最终可执行文件

### 其他配置

- 链接方式：静态链接 / 动态链接
- 优化级别：-O2
- 交叉编译：无 / 有（说明）
- 编译器要求：gcc >= 11 / clang >= 14 / 无特殊要求

## 子代理分工

### 分工总览

| 运行槽位 | 子代理 | proposal_id | 负责工作 |
|---------|-------|-------------|---------|
| python-agent-01 | python-agent | xxx-python-agent | 模块A实现 |
| rust-agent-01 | rust-agent | xxx-rust-agent | 核心逻辑实现 |
| build-agent-01 | build-agent | xxx-build-agent | 构建与产物输出 |

### 详细分工

#### python-agent-01（由python-agent执行）

- **负责工作**：模块A实现
- **具体任务**：
  - ...
  - ...
- **输出**：源代码（不编译）

#### rust-agent-01（由rust-agent执行）

- **负责工作**：核心逻辑实现
- **具体任务**：
  - ...
  - ...
- **输出**：源代码（不编译）

#### build-agent-01（由build-agent执行）

- **负责工作**：构建与产物输出
- **构建命令**：`cargo build --release` / `pnpm build` / ...
- **目标产物**：
  - 路径：`target/release/xxx` / `dist/` / ...
  - 类型：可执行文件 / 静态库 / Web应用 / ...
- **依赖**：所有编程子代理完成后执行

### 启动命令

> 在 Claude 对话中复制粘贴以下命令启动子代理：

**编程子代理（可并行）：**
```
使用 python-agent 执行 proposal_id: xxx-python-agent
```

```
使用 rust-agent 执行 proposal_id: xxx-rust-agent
```

**构建子代理（编程子代理完成后执行）：**
```
使用 build-agent 执行 proposal_id: xxx-build-agent
```

（根据实际分工表生成对应命令）

### 运行槽位说明

- 运行槽位（如python-agent-01/02）仅用于分工标记和提案区分
- 用户实际操作：开多个同名子代理会话
- 例如：需要python-agent-01和python-agent-02时，用户开两个`python-agent`会话

## 用户确认记录

- 确认时间: ...
- 确认方式: 用户选择"同意按当前方案执行"
- 讨论归档: Record/plan/{plan_version}-discussion.md

## 下一步

进入循环B：
1. Codex创建openspec与提案
2. 用户启动子代理执行任务
3. Codex进行代码审核
4. 用户确认审核结果
```
