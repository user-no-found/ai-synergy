# AI协同方案架构索引

本文件供 ai-agent 快速定位和修改全局配置。

## 一、整体架构

```
用户 → Claude 主对话（全局控制器）
              │
              ├─→ 循环A（规划阶段）
              │     ├─→ plan-agent（生成/修订草案）
              │     ├─→ analysis-agent（分析草案）
              │     └─→ neutral-agent（独立分析）
              │
              └─→ 循环B（执行阶段）
                    ├─→ impl.md 任务表
                    ├─→ 编程子代理（python/rust/c/ui-agent）
                    ├─→ build-agent（编译）
                    └─→ plan-agent review（代码审核）
```

### 自动化控制

Claude 主对话作为全局控制器：
- 识别新项目需求，自动创建 Record/ 目录
- 使用 Task 工具调用三个核心子代理
- 根据子代理返回结果决定下一步操作
- 仅在需要用户输入时暂停询问

### 三方独立思考

plan-agent、analysis-agent、neutral-agent 三个核心子代理：
- 各自独立思考，基于技术事实做判断
- 可以互相否定对方的结论
- 可以否定用户的决定（需写明理由）
- 技术上有严重问题时坚持异议
- **均为固定成员**，每轮讨论都参与

## 二、循环A（规划阶段 - 自动化）

### 自动化流程图

```
用户提出新项目需求
        │
        ▼
Claude 主对话：创建 Record/，写入需求
        │
        ▼
┌───────────────────────────────────────┐
│            循环A 开始                  │
│                                       │
│  ┌─→ Task: plan-agent (生成/修订草案)  │
│  │           │                        │
│  │           ▼                        │
│  │   Task: analysis-agent (分析草案)   │
│  │           │                        │
│  │           ▼                        │
│  │   Task: neutral-agent (独立分析)    │
│  │           │                        │
│  │           ▼                        │
│  │   Claude 检查三方结果：              │
│  │     ├─ has_objection → 继续循环 ──┘│
│  │     ├─ need_info → 询问用户        │
│  │     └─ 三方无分歧 → 询问用户确认    │
│  │                                    │
└──┴────────────────────────────────────┘
        │
        ▼ 用户同意草案
Task: plan-agent (定稿) → 结束循环A
```

### 子代理返回格式

每个子代理执行完成后返回：

```yaml
status: success | need_info | has_objection
objections:           # 分歧列表（如有）
  - target: "plan-agent | analysis-agent | neutral-agent | user"
    content: "分歧内容"
    reason: "分歧原因"
questions:            # 需要用户澄清的问题（如有）
  - "问题1"
  - "问题2"
summary: "本轮工作摘要"
```

### 暂停点（需要用户输入）

| 情况 | 处理 |
|------|------|
| 需求不清楚 | AskUserQuestion 询问澄清 |
| 缺少关键信息 | AskUserQuestion 询问补充 |
| 多个技术方案 | AskUserQuestion 让用户选择 |
| 三方无分歧 | AskUserQuestion：同意草案/再分析一轮 |

### 执行顺序

| 顺序 | 执行者 | 模式/动作 | 说明 |
|------|--------|-----------|------|
| 1 | Claude 主对话 | 创建 Record/ | 识别新项目，初始化目录 |
| 2 | plan-agent | mode: draft | 生成初始草案 |
| 3 | analysis-agent | - | 分析草案 |
| 4 | neutral-agent | - | 独立分析 |
| 5 | Claude 主对话 | 检查结果 | 决定继续循环/询问用户/定稿 |
| ... | (循环) | ... | 直到三方无分歧且用户同意 |
| N | plan-agent | mode: finalize | 定稿方案 |

## 三、循环B（执行阶段）

### 完整流程

```
编程子代理完成 → build-agent 编译
        │
        ├─→ 有错误 → plan-agent(fix) → 原子代理修复 → 重新编译（循环）
        │
        └─→ 无错误 → plan-agent(review) 代码审核
                │
                ├─→ 有问题 → plan-agent(fix) → 修复 → 重新编译 → 循环
                │
                └─→ 无问题 → 询问用户：安全分析？
                        │
                        ├─→ 是 → sec-agent 分析
                        │       │
                        │       ├─→ 有问题 → plan-agent(fix) → 循环
                        │       │
                        │       └─→ 无问题 → plan-agent(complete) → git push
                        │
                        └─→ 否 → plan-agent(complete) → git push
```

### plan-agent 模式

| 模式 | 触发条件 | 职责 |
|------|----------|------|
| `fix` | 编译/审核/安全有错误 | 分配修复提案（谁写谁修） |
| `review` | 编译成功 | 代码审核（屎山检查） |
| `complete` | 审核/分析通过 | 归档 + git push（远程） |

### Git 操作规则

| 阶段 | 操作 | 范围 |
|------|------|------|
| 编程子代理完成 | git commit | 本地 |
| 修复子代理完成 | git commit | 本地 |
| plan-agent 小任务归档 | git commit | 本地 |
| plan-agent(complete) | git push | **远程**（唯一） |

## 三-A、环境安装自动化

### 触发时机

plan-agent 定稿阶段（mode: finalize）执行环境检查时，检测到环境缺失。

### 流程图

```
plan-agent 环境检查
        │
        ├─→ 环境完备 → 继续定稿
        │
        └─→ 环境缺失 → 创建 Record/env.md → 返回 need_env
                │
                ▼
        Claude 主对话：Task 启动 env-agent
                │
                ▼
        env-agent 读取 Record/env.md
                │
                ├─→ 用户级安装 → 执行 → 打钩 [√]
                │
                └─→ 需要 sudo → 收集命令列表
                        │
                        ▼
        Claude 主对话检查结果：
                │
                ├─→ success → 重新调用 plan-agent 环境检查
                │
                ├─→ need_sudo → AskUserQuestion 让用户执行
                │       └─→ 用户确认 → 重新调用 env-agent
                │
                └─→ failed → AskUserQuestion 询问处理
```

### env.md 任务文件

由 plan-agent 创建于 `Record/env.md`：

```markdown
# 环境安装任务

## 任务清单

- [ ] Rust 工具链 (rustup)
- [√] Node.js 18+ (nvm)      ← env-agent 安装后打钩
- [ ] libssl-dev (系统包)

## 安装说明

| 环境 | 安装方式 | 是否需要 sudo |
|------|----------|---------------|
| Rust | rustup | 否 |
| libssl-dev | apt | 是 |
```

### sudo 规则（严格）

- env-agent **禁止**自动执行 sudo 命令
- 必须返回 `need_sudo` 状态和命令列表
- Claude 主对话用 AskUserQuestion 让用户手动执行
- 禁止任何绕过 sudo 的技巧

## 三-B、子代理创建自动化

### 触发时机

plan-agent 定稿阶段（mode: finalize）执行子代理检查时，检测到子代理缺失。

### 流程图

```
plan-agent 子代理检查
        │
        ├─→ 子代理完备 → 继续定稿
        │
        └─→ 子代理缺失 → 创建 Record/sub.md → 返回 need_sub
                │
                ▼
        Claude 主对话：Task 启动 sub-agent
                │
                ▼
        sub-agent 读取 Record/sub.md
                │
                ├─→ 逐项创建子代理 → 打钩 [√]
                │
                └─→ 返回结果
                        │
                        ▼
        Claude 主对话检查结果：
                │
                ├─→ success → 重新调用 plan-agent 子代理检查
                │
                └─→ failed → AskUserQuestion 询问处理
```

### sub.md 任务文件

由 plan-agent 创建于 `Record/sub.md`：

```markdown
# 子代理创建任务

## 任务清单

- [ ] data-agent (数据处理)
- [√] test-agent (测试执行)  ← sub-agent 创建后打钩

## 子代理说明

| 名称 | 职责 | 所需工具 |
|------|------|----------|
| data-agent | 数据处理 | Read, Write, Glob, Grep, Bash |
```

### 质量门禁

- 子代理必须通过质量门禁（总分>=24/32）
- 创建后自动同步到镜像目录
- 创建后自动更新登记表 registry.yaml

### 禁止凑合替代

- 需要`c-agent`但只有`rust-agent` → 必须创建
- 需要`data-agent`但只有`python-agent` → 必须创建

## 三-C、编程子代理并发调用

### 触发时机

plan-agent 创建 openspec 提案后，生成 impl.md，Claude 主对话按依赖分组并发调用编程子代理。

### Claude 记忆文件

Claude 主对话维护 `Record/Memory/memory.md`，记录整个过程的上下文。

### 流程图

```
plan-agent 创建 openspec 提案
        │
        ▼
plan-agent 创建 Record/impl.md（含依赖分组）
        │
        ▼
Claude 主对话：更新 memory.md，解析分组
        │
        ▼
阶段1（无依赖，并发）：
  1. 更新 impl.md 打钩 [√]
  2. 并发 Task 调用：
     ├─→ python-agent-01
     └─→ rust-agent-01
        │
        ▼ 子代理完成返回
Claude 主对话：
  1. 更新 impl.md 加删除线 ~~[√]~~
  2. 检查阶段1是否全部完成
        │
        ▼ 阶段1全部完成
阶段2（依赖阶段1，并发）...
        │
        ▼ 所有阶段完成
Task 调用 build-agent 编译构建
```

### impl.md 任务表

由 plan-agent 创建于 `Record/impl.md`：

```markdown
# 实现任务表

## 任务清单

- ~~[√] python-agent-01: 数据处理模块~~ ← 已完成（删除线）
- [√] rust-agent-01: 核心算法           ← 执行中
- [ ] python-agent-02: API接口          ← 待执行

## 分组

### 阶段1（无依赖）
- python-agent-01
- rust-agent-01

### 阶段2（依赖阶段1）
- python-agent-02
```

### 状态更新规则

| 状态 | 标记 | 操作者 |
|------|------|--------|
| 待执行 | `- [ ]` | 初始状态 |
| 执行中 | `- [√]` | Claude 调用后打钩 |
| 已完成 | `~~- [√] ...~~` | 子代理完成后加删除线 |

### 多身份调用

同一子代理多次调用时分配编号：
- python-agent-01, python-agent-02, python-agent-03
- rust-agent-01, rust-agent-02

## 三-D、编译自动化

### 触发时机

所有编程子代理完成后（impl.md 中所有任务都有删除线），Claude 主对话自动调用 build-agent。

### 流程图

```
所有编程子代理完成（impl.md 全部 ~~[√]~~）
        │
        ▼
Claude 主对话：Task 启动 build-agent
        │
        ▼
build-agent 执行编译
        │
        ├─→ success → 更新 impl.md → 进入代码审核
        │
        └─→ failed → 返回错误列表（含责任槽位）
                │
                ▼
        Claude 主对话：
                │
                ├─→ 重新调用对应编程子代理修复
                │
                └─→ 修复后重新调用 build-agent
```

### build-agent 返回格式

```yaml
status: success | failed
artifacts: ["target/release/app"]
errors:
  - file: "src/main.rs"
    line: 42
    message: "类型不匹配"
    responsible_slot: "rust-agent-01"
```

### 编译失败自动修复

1. 解析 errors 列表
2. 按 responsible_slot 分组
3. 重新调用对应编程子代理修复
4. 修复后重新调用 build-agent

## 四、核心子代理（三方协作）

**调用方式**：仅由 Claude 主对话通过 Task 工具调用，不响应用户直接触发。

### plan-agent
- 职责：生成/修订/定稿草案
- 目录：`~/.claude/agents/plan-agent/`
- 模式：
  - `mode: draft` - 生成或修订草案
  - `mode: finalize` - 定稿方案
- 内部 Skills（定稿时使用）：
  - `plan-finalize` - 方案定稿
  - `plan-confirm` - 方案确认
  - `code-review` - 代码审核
  - `project-complete` - 项目完成

### analysis-agent
- 职责：分析草案，提供技术评估和风险分析
- 目录：`~/.claude/agents/analysis-agent/`
- 输出：写入 draft-plan.md 的"analysis-agent 分析"章节

### neutral-agent
- 职责：独立分析，提供第三方视角评估
- 目录：`~/.claude/agents/neutral-agent/`
- 输出：写入 draft-plan.md 的"neutral-agent 分析"章节
- **注意**：固定成员，每轮讨论都参与（非可选仲裁）

## 五、实现子代理清单

**调用方式**：仅由 Claude 主对话通过 Task 工具调用，不响应用户直接触发。

| 子代理 | 文件 | 职责 |
|--------|------|------|
| python-agent | ~/.claude/agents/python-agent.md | Python实现 |
| rust-agent | ~/.claude/agents/rust-agent.md | Rust实现 |
| c-agent | ~/.claude/agents/c-agent.md | C语言实现 |
| ui-agent | ~/.claude/agents/ui-agent.md | 前端UI实现 |

## 六、辅助子代理清单

| 子代理 | 文件 | 职责 | 调用方式 |
|--------|------|------|----------|
| env-agent | ~/.claude/agents/env-agent.md | 环境安装 | Claude Task 调用 |
| sub-agent | ~/.claude/agents/sub-agent.md | 子代理管理 | Claude Task 调用 |
| build-agent | ~/.claude/agents/build-agent.md | 编译构建 | Claude Task 调用 |
| doc-agent | ~/.claude/agents/doc-agent.md | 文档更新 | Claude Task 调用 |
| sec-agent | ~/.claude/agents/sec-agent.md | 安全审查 | Claude Task 调用 |
| ai-agent | ~/.claude/agents/ai-agent.md | 全局治理 | Claude Task 调用（用户异议时）|

## 七、Claude Skills（主对话可用）

| Skill | 路径 | 说明 |
|-------|------|------|
| draft-plan-review | ~/.claude/skills/draft-plan-review/ | 引导至 analysis-agent |
| revision-confirm | ~/.claude/skills/revision-confirm/ | 引导至 analysis-agent |
| build-report | ~/.claude/skills/build-report/ | build-agent 输出报告模板 |

## 八、全局配置

| 配置 | 路径 | 说明 |
|------|------|------|
| Claude全局指令 | ~/.claude/CLAUDE.md | Claude Code全局规则 |

## 九、项目 Record 目录结构

```
项目根目录/
└── Record/
    ├── plan/
    │   ├── draft-plan.md           # 草案（含各方分析章节）
    │   ├── {version}-discussion.md # 归档的讨论记录
    │   └── {version}-final.md      # 确定方案
    ├── Memory/                     # 子代理记忆目录
    │   ├── plan-agent.md           # 规划子代理记忆
    │   ├── analysis-agent.md       # 分析子代理记忆
    │   ├── neutral-agent.md        # 仲裁子代理记忆
    │   ├── build-agent.md          # 构建子代理记忆
    │   ├── python-agent-01.md      # Python实现子代理01
    │   └── ...                     # 其他子代理记忆
    ├── state.json                  # 项目状态机
    └── record.md                   # 事件日志
```

## 十、Git操作时机

| 阶段 | 操作 | 位置 |
|------|------|------|
| plan-confirm步骤2 | git init + commit | 初始化 |
| 子代理完成任务 | git commit（本地） | 各子代理 |
| project-complete步骤2 | git commit（归档） | plan-agent |
| project-complete步骤4 | git push（唯一） | plan-agent |

## 十一、镜像同步规则

修改任何文件后，必须同步更新镜像：

| 真实路径 | 镜像路径 |
|----------|----------|
| ~/.claude/skills/* | ~/ai-synergy/claude/skills/* |
| ~/.claude/agents/* | ~/ai-synergy/claude/agents/* |
| ~/.claude/CLAUDE.md | ~/ai-synergy/claude/CLAUDE.md |

## 十二、修改检查清单

修改前必须确认：
- [ ] 影响哪些skill/子代理
- [ ] 是否需要更新步骤文件
- [ ] 是否需要更新模板文件
- [ ] 是否影响git操作流程
- [ ] 是否需要更新MANAGED.yaml
- [ ] 是否需要更新PATHS.yaml
- [ ] 镜像是否同步

## 十三、用户异议处理（全局治理）

### 触发条件

当用户提出以下类型的问题时，Claude 主对话自动调用 ai-agent：
- 流程步骤越权
- 循环问题（卡死、逻辑错误）
- 状态不一致
- Git 操作问题
- 子代理行为异常
- 流程改进建议
- 配置问题

### 流程图

```
用户提出流程异议/问题
        │
        ▼
Claude 主对话：Task 调用 ai-agent（mode: diagnose）
        │
        ▼
ai-agent 返回诊断结果：
  - 问题根因
  - 影响范围
  - 修改方案选项
  - 推荐方案
        │
        ▼
Claude 主对话：AskUserQuestion 让用户选择方案
        │
        ├─→ 用户选择方案 → Task 调用 ai-agent（mode: fix）
        │       │
        │       ▼
        │   ai-agent 执行修改：
        │     - 修改 ~/.claude/ 真实路径
        │     - 同步 ~/ai-synergy/ 镜像
        │     - 记录 ~/ai-synergy/CHANGES/
        │       │
        │       ▼
        │   返回修改结果
        │
        └─→ 用户不满意 → 继续讨论或手动处理
```

### ai-agent 模式

| 模式 | 触发条件 | 职责 |
|------|----------|------|
| `diagnose` | 用户提出流程问题 | 诊断问题，输出修改方案 |
| `fix` | 用户选择方案后 | 执行修改，同步镜像 |
| `audit` | 定期检查或用户要求 | 审计配置一致性 |

### 问题定位指南

| 问题类型 | 可能涉及文件 |
|----------|-------------|
| 循环A问题 | plan-agent.md, analysis-agent.md, neutral-agent.md |
| 循环B问题 | plan-agent.md (fix/review/complete), build-agent.md, sec-agent.md |
| 全局问题 | CLAUDE.md, ARCHITECTURE.md |
| 子代理问题 | 对应子代理的 .md 文件 |
