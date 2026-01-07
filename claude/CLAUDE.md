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

当用户表达以下意图时，自动进入项目规划流程：
- "我要做一个..."
- "帮我开发..."
- "新项目：..."
- "开始一个项目..."
- 或其他明确的新项目需求

### 自动化流程（Claude 主对话作为控制器）

```
1. 创建 Record/ 目录结构
2. 写入用户需求到 Record/plan/draft-plan.md
3. 进入循环A（三方讨论）
```

### 循环A 执行逻辑

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
        ├─→ 有问题（需澄清/缺信息）→ AskUserQuestion 询问用户
        │
        ├─→ 有分歧 → 继续下一轮循环
        │
        └─→ 三方无分歧 → 询问用户：同意草案 / 再分析一轮？
                │
                ├─→ 同意 → Task 启动 plan-agent（定稿）→ 结束循环A
                │
                └─→ 再分析 → 继续下一轮循环
```

### 子代理返回格式

每个子代理执行完成后，必须返回结构化结果：

```yaml
status: success | need_info | has_objection
objections: []        # 分歧列表（如有）
questions: []         # 需要用户澄清的问题（如有）
summary: "..."        # 本轮工作摘要
```

### 暂停点（需要用户输入）

| 情况 | 处理 |
|------|------|
| 需求不清楚 | AskUserQuestion 询问澄清 |
| 缺少关键信息 | AskUserQuestion 询问补充 |
| 多个技术方案 | AskUserQuestion 让用户选择 |
| 三方无分歧 | AskUserQuestion：同意草案/再分析一轮 |

### Record 目录结构

```
项目根目录/
└── Record/
    ├── plan/
    │   ├── draft-plan.md           # 草案（含各方分析章节）
    │   ├── {version}-discussion.md # 归档的讨论记录
    │   └── {version}-final.md      # 确定方案
    ├── Memory/                     # 记忆目录
    │   ├── memory.md               # Claude 主对话记忆
    │   ├── plan-agent.md
    │   ├── analysis-agent.md
    │   ├── neutral-agent.md
    │   └── ...
    ├── env.md                      # 环境安装任务（临时）
    ├── sub.md                      # 子代理创建任务（临时）
    ├── impl.md                     # 实现任务表（编程子代理）
    ├── state.json                  # 项目状态机
    └── record.md                   # 事件日志
```

---

## 环境安装自动化

### 触发条件

plan-agent 在定稿阶段（mode: finalize）执行环境检查时，检测到环境缺失。

### 自动化流程

```
plan-agent 环境检查
        │
        ├─→ 环境完备 → 继续定稿流程
        │
        └─→ 环境缺失 → 创建 Record/env.md → 返回 need_env
                │
                ▼
        Claude 主对话收到 need_env
                │
                ▼
        Task 启动 env-agent
                │
                ▼
        env-agent 读取 Record/env.md
                │
                ├─→ 逐项安装（用户级）
                │   └─→ 安装成功 → 更新 env.md 打钩 [√]
                │
                ├─→ 需要 sudo → 收集命令列表
                │
                └─→ 返回结果
                        │
                        ▼
        Claude 主对话检查结果：
                │
                ├─→ success → 重新调用 plan-agent 环境检查
                │
                ├─→ need_sudo → AskUserQuestion 让用户执行
                │       │
                │       └─→ 用户确认执行完成 → 重新调用 env-agent
                │
                └─→ failed → AskUserQuestion 询问处理方式
```

### env.md 任务文件格式

```markdown
# 环境安装任务

创建时间：{ISO8601}
项目根目录：{project_root}

## 任务清单

- [ ] Rust 工具链 (rustup)
- [ ] Node.js 18+ (nvm)
- [ ] libssl-dev (系统包)

## 安装说明

| 环境 | 安装方式 | 是否需要 sudo |
|------|----------|---------------|
| Rust | rustup | 否 |
| Node.js | nvm | 否 |
| libssl-dev | apt | 是 |
```

### env-agent 返回格式

```yaml
status: success | need_sudo | failed
sudo_commands:        # 需要用户执行的 sudo 命令
  - "sudo apt install libssl-dev"
failed_items:         # 安装失败的项目
  - item: "环境名"
    reason: "失败原因"
summary: "本次安装摘要"
```

### sudo 命令处理

**严格规则**：env-agent 禁止自动执行 sudo 命令，必须返回让用户手动执行。

```
env-agent 返回 need_sudo
        │
        ▼
Claude 主对话：AskUserQuestion
"以下命令需要 sudo 权限，请手动执行后确认：
- sudo apt install libssl-dev
- sudo apt install pkg-config

执行完成后请回复'已完成'"
        │
        ▼
用户确认 → 重新调用 env-agent 验证安装
```

---

## 子代理创建自动化

### 触发条件

plan-agent 在定稿阶段（mode: finalize）执行子代理检查时，检测到子代理缺失。

### 自动化流程

```
plan-agent 子代理检查
        │
        ├─→ 子代理完备 → 继续定稿流程
        │
        └─→ 子代理缺失 → 创建 Record/sub.md → 返回 need_sub
                │
                ▼
        Claude 主对话收到 need_sub
                │
                ▼
        Task 启动 sub-agent
                │
                ▼
        sub-agent 读取 Record/sub.md
                │
                ├─→ 逐项创建子代理
                │   └─→ 创建成功 → 更新 sub.md 打钩 [√]
                │
                └─→ 返回结果
                        │
                        ▼
        Claude 主对话检查结果：
                │
                ├─→ success → 重新调用 plan-agent 子代理检查
                │
                └─→ failed → AskUserQuestion 询问处理方式
```

### sub.md 任务文件格式

```markdown
# 子代理创建任务

创建时间：{ISO8601}
项目根目录：{project_root}

## 任务清单

- [ ] data-agent (数据处理)
- [ ] test-agent (测试执行)

## 子代理说明

| 名称 | 职责 | 所需工具 |
|------|------|----------|
| data-agent | 数据处理与转换 | Read, Write, Glob, Grep, Bash |
| test-agent | 测试执行与报告 | Read, Write, Glob, Grep, Bash |
```

### sub-agent 返回格式

```yaml
status: success | failed
created_agents:       # 成功创建的子代理
  - name: "data-agent"
    quality_score: 26
failed_agents:        # 创建失败的子代理
  - name: "special-agent"
    reason: "质量评分未达标"
summary: "本次创建摘要"
```

### 禁止凑合替代

- 需要`c-agent`但只有`rust-agent` → 必须创建 c-agent
- 需要`data-agent`但只有`python-agent` → 必须创建 data-agent
- 子代理必须通过质量门禁（总分>=24）

---

## 编程子代理并发调用

### 触发条件

plan-agent 定稿完成后，创建 openspec 提案，然后 Claude 主对话并发调用编程子代理。

### Claude 记忆文件

Claude 主对话在整个过程中维护自己的记忆文件：`Record/Memory/memory.md`

格式同子代理记忆文件，用于回溯上下文。

### impl.md 任务表

由 plan-agent 创建提案后生成 `Record/impl.md`：

```markdown
# 实现任务表

创建时间：{ISO8601}
项目根目录：{project_root}
plan_version：{plan_version}

## 任务清单

- [ ] python-agent-01: 数据处理模块 (proposal: data-proc-python-agent, 依赖: 无)
- [ ] rust-agent-01: 核心算法 (proposal: core-algo-rust-agent, 依赖: 无)
- [ ] python-agent-02: API接口 (proposal: api-impl-python-agent, 依赖: python-agent-01)
- [ ] ui-agent-01: 前端界面 (proposal: frontend-ui-agent, 依赖: python-agent-02)

## 分组

### 阶段1（无依赖）
- python-agent-01
- rust-agent-01

### 阶段2（依赖阶段1）
- python-agent-02

### 阶段3（依赖阶段2）
- ui-agent-01
```

### 状态更新规则

| 状态 | 标记 | 操作者 |
|------|------|--------|
| 待执行 | `- [ ]` | 初始状态 |
| 执行中 | `- [√]` | Claude 并发调用后打钩 |
| 已完成 | `~~- [√] ...~~` | 子代理完成后 Claude 加删除线 |

示例：
```markdown
- ~~[√] python-agent-01: 数据处理模块~~ ← 已完成（删除线）
- [√] rust-agent-01: 核心算法           ← 执行中
- [ ] python-agent-02: API接口          ← 待执行
```

### 自动化流程

```
plan-agent 创建 openspec 提案
        │
        ▼
plan-agent 创建 Record/impl.md（含依赖分组）
        │
        ▼
Claude 主对话：
  1. 更新 Record/Memory/memory.md 记录当前状态
  2. 解析 impl.md 分组
        │
        ▼
阶段1（无依赖，并发）：
  1. 更新 impl.md 打钩 [√]
  2. 并发 Task 调用：
     ├─→ python-agent-01 (proposal: data-proc)
     └─→ rust-agent-01 (proposal: core-algo)
        │
        ▼ 子代理完成返回
Claude 主对话：
  1. 更新 impl.md 加删除线 ~~[√]~~
  2. 更新 memory.md 记录完成
  3. 检查阶段1是否全部完成
        │
        ▼ 阶段1全部完成
阶段2（依赖阶段1，并发）：
  1. 更新 impl.md 打钩 [√]
  2. 并发 Task 调用...
        │
        ▼ 所有阶段完成
Task 调用 build-agent 编译构建
```

### 编程子代理返回格式

```yaml
status: success | failed
proposal_id: "data-proc-python-agent"
slot: "python-agent-01"
commit_hash: "abc123..."      # 本地提交的 hash
files_changed:                # 修改的文件列表
  - "src/data/processor.py"
  - "src/data/utils.py"
summary: "完成数据处理模块实现"
```

### 失败处理

```
子代理返回 failed
        │
        ▼
Claude 主对话：
  1. 更新 impl.md 标记失败（不加删除线）
  2. AskUserQuestion 询问处理方式：
     - 重试该子代理
     - 跳过继续
     - 终止执行
```

### 多身份调用命名规则

同一子代理多次调用时分配编号：
- python-agent-01, python-agent-02, python-agent-03
- rust-agent-01, rust-agent-02
- ui-agent-01

---

## 编译自动化

### 触发条件

所有编程子代理完成后（impl.md 中所有任务都有删除线），Claude 主对话自动调用 build-agent。

### 自动化流程

```
所有编程子代理完成（impl.md 全部 ~~[√]~~）
        │
        ▼
Claude 主对话：Task 启动 build-agent
        │
        ▼
build-agent 执行编译
        │
        ├─→ success → 更新 impl.md 标记编译完成
        │             → 进入代码审核阶段
        │
        └─→ failed → 返回错误列表（含责任槽位）
                │
                ▼
        Claude 主对话：分析错误
                │
                ├─→ 重新调用对应编程子代理修复
                │
                └─→ 修复后重新调用 build-agent
```

### build-agent 返回格式

```yaml
status: success | failed
build_type: "release | debug"
artifacts:                    # 生成的产物
  - "target/release/app"
errors:                       # 编译错误（如有）
  - file: "src/main.rs"
    line: 42
    message: "类型不匹配"
    responsible_slot: "rust-agent-01"
summary: "编译完成/编译失败"
```

### 编译失败处理

```
build-agent 返回 failed
        │
        ▼
Claude 主对话：
  1. 解析 errors 列表
  2. 按 responsible_slot 分组
  3. 重新调用对应编程子代理修复：
     ├─→ Task: rust-agent-01 (修复 src/main.rs:42)
     └─→ Task: python-agent-01 (修复 src/data.py:23)
        │
        ▼ 修复完成
  4. 重新调用 build-agent
```

### impl.md 编译状态

编译完成后在 impl.md 末尾追加：

```markdown
## 编译状态

- 状态：成功
- 时间：2026-01-08T15:30:00+08:00
- 产物：
  - target/release/my-app
  - dist/index.html
```

---

## 循环B 完整流程（执行阶段）

### 流程概览

```
编程子代理完成 → build-agent 编译
        │
        ├─→ 有错误 → plan-agent 分配修复提案 → 原子代理修复 → 重新编译（循环）
        │
        └─→ 无错误 → plan-agent 代码审核（屎山检查）
                │
                ├─→ 有问题 → plan-agent 分配修复提案 → 原子代理修复 → 重新编译 → 循环
                │
                └─→ 无问题 → AskUserQuestion：是否进行安全分析？
                        │
                        ├─→ 是 → sec-agent 安全分析
                        │       │
                        │       ├─→ 有问题 → plan-agent 分配修复 → 循环
                        │       │
                        │       └─→ 无问题 → plan-agent 归档 + git push（远程）
                        │
                        └─→ 否 → plan-agent 归档 + git push（远程）
```

### 编译错误修复流程

```
build-agent 返回 failed（含错误列表）
        │
        ▼
Claude 主对话：Task 调用 plan-agent（mode: fix）
        │
        ▼
plan-agent 分析错误，创建修复提案：
  - 根据 responsible_slot 确定原子代理
  - 创建修复提案（谁写的谁修复）
  - 返回修复任务清单
        │
        ▼
Claude 主对话：并发调用原编程子代理修复
  ├─→ Task: rust-agent-01 (修复 src/main.rs:42)
  └─→ Task: python-agent-01 (修复 src/data.py:23)
        │
        ▼ 修复完成
Claude 主对话：重新调用 build-agent
        │
        └─→ 循环直到编译成功
```

### 代码审核流程（屎山检查）

```
build-agent 返回 success
        │
        ▼
Claude 主对话：Task 调用 plan-agent（mode: review）
        │
        ▼
plan-agent 执行代码审核：
  - 代码质量：屎山代码、重复代码、过度复杂
  - 规范检查：是否符合项目编码规范
  - 越界检查：对照 scope 检查是否有越界修改
        │
        ▼
plan-agent 返回审核结果：
        │
        ├─→ has_issues → 创建修复提案 → 原子代理修复 → 重新编译 → 循环
        │
        └─→ no_issues → 继续下一步
```

### 安全分析流程（可选）

```
代码审核通过
        │
        ▼
Claude 主对话：AskUserQuestion
"代码审核通过，是否进行安全分析？"
  - 是，进行安全分析
  - 否，直接归档提交
        │
        ├─→ 是 → Task 调用 sec-agent
        │       │
        │       ▼
        │   sec-agent 执行安全分析：
        │     - 代码安全：注入、XSS、CSRF
        │     - 依赖安全：已知漏洞
        │     - 配置安全：敏感信息泄露
        │       │
        │       ▼
        │   sec-agent 返回结果：
        │       │
        │       ├─→ has_issues → plan-agent 分配修复 → 循环
        │       │
        │       └─→ no_issues → 继续归档
        │
        └─→ 否 → 继续归档
```

### 归档提交流程

```
审核/分析全部通过
        │
        ▼
Claude 主对话：Task 调用 plan-agent（mode: complete）
        │
        ▼
plan-agent 执行归档：
  1. 归档所有提案到 Record/archive/
  2. 生成 changelog
  3. git commit（本地，汇总所有子代理的提交）
  4. git push（远程）← 唯一的远程推送点
  5. 更新 state.json
        │
        ▼
返回完成报告
```

### plan-agent 模式扩展

| 模式 | 触发条件 | 职责 |
|------|----------|------|
| `draft` | 循环A | 生成/修订草案 |
| `finalize` | 用户同意草案 | 定稿方案 |
| `fix` | 编译/审核有错误 | 分配修复提案 |
| `review` | 编译成功 | 代码审核（屎山检查） |
| `complete` | 审核/分析通过 | 归档 + git push |

### Git 操作规则

| 阶段 | 操作 | 范围 |
|------|------|------|
| 编程子代理完成 | git commit | 本地 |
| 修复子代理完成 | git commit | 本地 |
| plan-agent 小任务归档 | git commit | 本地 |
| plan-agent 项目完成 | git push | **远程**（唯一） |

### sec-agent 返回格式

```yaml
status: success | has_issues
issues:
  - severity: "high | medium | low"
    type: "sql_injection | xss | ..."
    file: "src/api/user.py"
    line: 42
    description: "用户输入直接拼接到 SQL 语句"
    suggestion: "使用参数化查询"
summary: "发现 2 个高风险、3 个中风险问题"
```

### draft-plan.md 初始模板

```markdown
---
doc_type: plan
plan_version: ""
status: draft
created_at: {ISO8601}
project_root: "{项目根目录}"
---

# 预定清单（草案）

## 用户需求

{用户原始需求描述}

## 待澄清问题

<!-- 由子代理填写 -->

## plan-agent 草案

<!-- 由 plan-agent 填写 -->

## analysis-agent 分析

<!-- 由 analysis-agent 填写 -->

## neutral-agent 分析

<!-- 由 neutral-agent 填写 -->
```

---

## 子代理（全 Claude 方案）

### 核心规划子代理（由 Claude 主对话调度）

| 子代理 | 职责 | 调用方式 |
|--------|------|----------|
| plan-agent | 生成/修订/定稿草案 | Claude 用 Task 工具调用 |
| analysis-agent | 分析草案，写入意见 | Claude 用 Task 工具调用 |
| neutral-agent | 独立分析，写入意见 | Claude 用 Task 工具调用 |

### 实现子代理

| 子代理 | 触发条件 | 职责 |
|--------|----------|------|
| python-agent | Python实现任务 | Python代码实现 |
| rust-agent | Rust实现任务 | Rust代码实现 |
| c-agent | C语言实现任务 | C代码实现 |
| ui-agent | 前端UI实现任务 | 前端界面/交互实现 |

### 辅助子代理

| 子代理 | 触发条件 | 职责 |
|--------|----------|------|
| build-agent | 编译构建任务 | 编译、构建与产物生成 |
| sec-agent | 安全审查任务 | 安全风险识别、修复建议 |
| env-agent | 环境安装任务 | 安装项目依赖环境 |
| doc-agent | 文档更新任务 | 更新文档、changelog |
| ai-agent | 全局统筹 | 维护AI协同方案配置 |
| sub-agent | 子代理管理 | 创建/补齐子代理并登记 |

## 独立思考原则（所有子代理适用）

```
- 【必须独立判断】基于技术事实做独立评估
- 【可以否定用户】即使是用户的决定也可以提出异议
- 【可以否定其他子代理】对其他子代理的结论可以提出异议
- 【写明理由】所有否定意见必须写明具体原因和潜在风险
- 【不盲从】不因任何一方说的就无条件接受
- 【建设性】否定时应提供替代方案或改进建议
- 【坚持原则】技术上有严重问题时，即使多方都催促也要坚持异议
```

---

## 用户异议处理（全局治理）

### 触发条件

当用户提出以下类型的问题时，自动调用 ai-agent：
- 流程步骤越权（"xxx子代理不应该做这个"）
- 循环问题（"循环卡住了"、"循环逻辑有问题"）
- 状态不一致（"状态没更新"、"impl.md 不对"）
- Git 操作问题（"不应该 push"、"commit 有问题"）
- 子代理行为异常（"xxx子代理做了奇怪的事"）
- 流程建议（"我觉得流程应该改成..."）
- 配置问题（"CLAUDE.md 里的规则有问题"）

### 自动化流程

```
用户提出流程异议/问题
        │
        ▼
Claude 主对话识别为流程问题
        │
        ▼
Task 调用 ai-agent（mode: diagnose, issue: 用户问题）
        │
        ▼
ai-agent 返回诊断结果：
  - 问题根因
  - 影响范围
  - 修改方案选项（至少2个）
  - 推荐方案
        │
        ▼
Claude 主对话：AskUserQuestion 展示方案让用户选择
        │
        ├─→ 用户选择方案 → Task 调用 ai-agent（mode: fix）
        │       │
        │       ▼
        │   ai-agent 执行修改
        │       │
        │       ├─→ 修改真实路径 ~/.claude/
        │       │
        │       ├─→ 同步镜像 ~/ai-synergy/
        │       │
        │       └─→ 记录变更 ~/ai-synergy/CHANGES/
        │       │
        │       ▼
        │   返回修改结果 → 通知用户完成
        │
        ├─→ 用户要求更多方案 → 继续讨论
        │
        └─→ 用户决定手动处理 → 结束
```

### ai-agent 模式

| 模式 | 触发条件 | 职责 |
|------|----------|------|
| `diagnose` | 用户提出流程问题 | 诊断问题，输出修改方案 |
| `fix` | 用户选择方案后 | 执行修改，同步镜像 |
| `audit` | 定期检查或用户要求 | 审计配置一致性 |

### ai-agent 返回格式

```yaml
# mode: diagnose
status: success | need_info
diagnosis:
  problem: "问题描述"
  root_cause: "根本原因"
  affected_files: ["文件列表"]
fix_options:
  - id: "option-1"
    description: "方案描述"
    changes: [...]
    risk: "low | medium | high"
recommended: "option-1"

# mode: fix
status: success | failed
option_applied: "option-1"
changes_made: [...]
synced_to_mirror: true
```

### 问题识别关键词

| 关键词 | 问题类型 |
|--------|----------|
| "越权"、"不应该" | 步骤越权 |
| "卡住"、"死循环"、"循环" | 循环问题 |
| "状态"、"impl.md"、"state.json" | 状态不一致 |
| "git"、"push"、"commit" | Git 操作问题 |
| "流程"、"应该改成" | 流程建议 |
| "CLAUDE.md"、"规则"、"配置" | 配置问题 |
