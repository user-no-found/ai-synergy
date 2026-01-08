## 核心规则（最高优先级）

- 禁止git commit中添加AI署名（Co-Authored-By、Signed-off-by等）
- 当用户打断对话时，立即停止当前操作，根据新输入重新规划
- 代码注释、报错信息用中文

## 上下文控制（必须遵守）

- 默认不加载与当前任务无关的规则/文档
- 只加载"够用的最小信息"；不确定时先询问用户
- 读取外部材料后先做摘要：用3-7条要点记录结论，后续优先引用摘要

## 交互规则

- 通过 `AskUserQuestion` 与用户交互
- 需求不明确时询问澄清
- 多方案时询问选择
- 完成前请求反馈

## 编程规则

- 注释符号后不跟空格（`//注释`）
- 模块化编程
- 使用 `context7` 查询第三方库最新文档
- 不假设语言版本，需确认
- Rust：使用完整路径，不用use（宏/trait例外）

## 工具优先级

1. MCP工具优先
2. `github`/`gitee` 查看源码
3. `context7` 查询文档

---

## 自动化项目规划（循环A）

### 新项目识别

当用户表达以下意图时，**必须**自动进入项目规划流程：
- "我要做一个..."
- "帮我开发..."
- "新项目：..."
- "开始一个项目..."
- 或其他明确的新项目需求

### 自动化流程

```
1. 创建 Record/ 目录结构
2. 写入用户需求到 Record/plan/draft-plan.md
3. 进入循环A（三方讨论）
```

### 循环A 执行逻辑（必须严格执行）

```
循环开始:
  │
  ├─→ Task 启动 plan-agent（生成/修订草案）
  │         │
  │         ▼
  ├─→ Task 启动 analysis-agent（分析草案）
  │         │
  │         ▼
  ├─→ Task 启动 neutral-agent（独立分析）
  │         │
  │         ▼
  └─→ 检查三方结果：
        │
        ├─→ need_info → AskUserQuestion 询问用户 → 继续循环
        │
        ├─→ has_objection → 继续下一轮循环
        │
        └─→ 三方无分歧 → AskUserQuestion：同意草案 / 再分析一轮？
                │
                ├─→ 同意 → Task 启动 plan-agent（mode: finalize）
                │       │
                │       ├─→ need_env → Task 启动 env-agent → 重新检查
                │       ├─→ need_sub → Task 启动 sub-agent → 重新检查
                │       └─→ success → 结束循环A，进入循环B
                │
                └─→ 再分析 → 继续下一轮循环
```

### 子代理返回格式

```yaml
status: success | need_info | has_objection
objections: []        # 分歧列表
questions: []         # 需要用户澄清的问题
summary: "..."        # 本轮工作摘要
```

**详细流程**：查看 ~/ai-synergy/ARCHITECTURE.md 或 skills/loop-a/

---

## 执行阶段（循环B）

### 触发条件

循环A 结束后，plan-agent 已创建 impl.md 任务表。

### 循环B 执行逻辑（必须严格执行）

```
impl.md 任务表
        │
        ▼
按依赖分组并发调用编程子代理（更新 impl.md 状态）
        │
        ▼ 全部完成
Task: build-agent 编译
        │
        ├─→ failed → Task: plan-agent(fix) → 修复子代理 → 重新编译（循环）
        │
        └─→ success → Task: plan-agent(review) 代码审核
                │
                ├─→ has_issues → Task: plan-agent(fix) → 修复 → 重新编译（循环）
                │
                └─→ no_issues → AskUserQuestion：是否安全分析？
                        │
                        ├─→ 是 → Task: sec-agent
                        │       ├─→ has_issues → 修复循环
                        │       └─→ no_issues → 归档
                        │
                        └─→ 否 → Task: plan-agent(complete) → git push（远程）
```

### impl.md 状态更新

| 状态 | 标记 |
|------|------|
| 待执行 | `- [ ]` |
| 执行中 | `- [√]` |
| 已完成 | `~~- [√] ...~~` |

**详细流程**：查看 ~/ai-synergy/ARCHITECTURE.md 或 skills/loop-b/

---

## 子代理清单

### 核心子代理（三方协作，每轮都参与）

| 子代理 | 职责 | 调用方式 |
|--------|------|----------|
| plan-agent | 生成/修订/定稿草案 | Task 工具 |
| analysis-agent | 分析草案，技术评估 | Task 工具 |
| neutral-agent | 独立分析，第三方视角 | Task 工具 |

### 实现子代理

| 子代理 | 职责 |
|--------|------|
| python-agent | Python代码实现 |
| rust-agent | Rust代码实现 |
| c-agent | C语言实现 |
| ui-agent | 前端界面实现 |
| doc-agent | 文档更新 |

### 辅助子代理

| 子代理 | 职责 |
|--------|------|
| build-agent | 编译构建 |
| sec-agent | 安全审查 |
| env-agent | 环境安装 |
| sub-agent | 子代理管理 |
| ai-agent | 全局治理 |

---

## Git 操作规则

| 阶段 | 操作 | 范围 |
|------|------|------|
| 编程子代理完成 | git commit | 本地 |
| 修复子代理完成 | git commit | 本地 |
| plan-agent(complete) | git push | **远程**（唯一） |

---

## 用户异议处理

当用户提出流程问题（越权、循环卡死、状态不一致、Git问题等）时：

```
Task 调用 ai-agent（mode: diagnose）
        │
        ▼
返回诊断结果 + 修改方案选项
        │
        ▼
AskUserQuestion 让用户选择方案
        │
        ▼
Task 调用 ai-agent（mode: fix）→ 执行修改 + 同步镜像
```

---

## 详细文档索引

| 内容 | 位置 |
|------|------|
| 架构总览 | ~/ai-synergy/ARCHITECTURE.md |
| 子代理定义 | ~/.claude/agents/ |
| Skills | ~/.claude/skills/ |
