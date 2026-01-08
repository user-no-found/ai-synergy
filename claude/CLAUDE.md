## 核心规则（最高优先级）

- 禁止git commit中添加AI署名（Co-Authored-By、Signed-off-by等）
- 当用户打断对话时，立即停止当前操作，根据新输入重新规划
- 代码注释、报错信息用中文
- **禁止时间周期估算**：不输出"X周完成"、"预计X天"等时间规划

## 上下文控制（必须遵守）

- 默认不加载与当前任务无关的规则/文档
- 只加载"够用的最小信息"；不确定时先询问用户
- 读取外部材料后先做摘要：用3-7条要点记录结论，后续优先引用摘要

## 交互规则

- 通过 `AskUserQuestion` 与用户交互
- 需求不明确时询问澄清
- 多方案时询问选择
- 完成前请求反馈

### AskUserQuestion 选项规范

当询问"谁来执行某操作"时：
- 选项1：Claude执行（如需 sudo 等权限，说明需要用户确认）
- 选项2：已自行完成（在选项描述中提供命令，用户选择即表示已完成）

### 环境安装后处理

用户确认安装完成后，必须：
1. 验证安装是否成功（执行版本检查或相关命令）
2. 更新 `~/environment.md` 记录已安装的环境

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

### 初始化流程

```
1. 创建 Record/ 目录结构（含 Memory/、plan/ 子目录）
2. 创建 Record/Memory/claude.md（主对话记忆）
3. 写入用户需求到 Record/plan/draft-plan.md（只含需求和当前草案）
4. 进入循环A（三方顺序讨论）
```

### 讨论记录结构（分离存储，避免累积）

```
Record/plan/
├── draft-plan.md          # 只保留：用户需求 + 当前最新草案
├── round-1/               # 第1轮讨论（独立目录）
│   ├── plan-agent.md      # plan-agent 本轮意见
│   ├── analysis-agent.md  # analysis-agent 本轮意见
│   └── neutral-agent.md   # neutral-agent 本轮意见
├── round-2/               # 第2轮讨论
│   └── ...
└── v1.0-final.md          # 定稿方案
```

### 循环A 执行逻辑（必须严格顺序执行，禁止并行）

```
第一轮（创建草案）:
  Task: plan-agent（mode: draft）→ 创建初始草案
        │
        ▼
  Task: analysis-agent → 分析草案，写入意见
        │
        ▼
  Task: neutral-agent → 独立分析，写入意见

后续轮次（讨论循环）:
  Task: plan-agent（mode: discuss）
        │ 读取两方意见
        │ 同意的：修改草案
        │ 不同意的：写明理由
        ▼
  Task: analysis-agent → 分析讨论，发表新意见
        │
        ▼
  Task: neutral-agent → 分析讨论，发表新意见
        │
        ▼
  Claude 检查三方结果：
        │
        ├─→ need_info → **必须用 AskUserQuestion** 询问用户 → 用户回答后继续循环
        │
        ├─→ has_objection（任一方有异议）→ 继续下一轮讨论
        │
        └─→ 三方全部同意 → AskUserQuestion：确认草案 / 再讨论？
                │
                ├─→ 确认 → Task: plan-agent（mode: finalize）
                │       ├─→ need_env → Task: env-agent → 重新检查
                │       ├─→ need_sub → Task: sub-agent → 重新检查
                │       └─→ success → 结束循环A，进入循环B
                │
                └─→ 再讨论 → 继续下一轮
```

### 记忆管理（必须执行）

**Claude 主对话**：每轮讨论后更新 `Record/Memory/claude.md`
**子代理**：每次调用时读取并更新自己的记忆文件：
- `Record/Memory/plan-agent.md`
- `Record/Memory/analysis-agent.md`
- `Record/Memory/neutral-agent.md`

### 子代理返回格式

```yaml
status: success | need_info | has_objection
agree_with: []        # 同意的观点列表
objections:           # 异议列表
  - target: "plan-agent | analysis-agent | neutral-agent | user"
    issue: "具体问题"
    reason: "反对理由"
questions: []         # 需要用户澄清的问题
summary: "..."        # 本轮工作摘要
```

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
