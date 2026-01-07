# AI-Synergy

个人使用的全 Claude 子代理协同开发方案。

## 概述

本仓库是"AI协同方案"的全局配置镜像，用于：
- 跨设备迁移AI协同环境
- 版本控制全局配置
- 回滚错误变更

## 架构

```
                    ┌─────────────────┐
                    │      用户       │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│  plan-agent   │   │analysis-agent│   │neutral-agent │
│   (规划)      │◄─►│   (分析)      │◄─►│   (仲裁)     │
└───────┬───────┘   └───────────────┘   └───────────────┘
        │
        │ 分配任务
        ▼
┌─────────────────────────────────────────────────────┐
│              实现子代理 & 辅助子代理                  │
│  python-agent | rust-agent | c-agent | ui-agent    │
│  build-agent | sec-agent | env-agent | doc-agent   │
└─────────────────────────────────────────────────────┘
```

### 三方独立思考

plan-agent、analysis-agent、neutral-agent 三个核心子代理：
- 各自独立思考，基于技术事实做判断
- 可以互相否定对方的结论
- 可以否定用户的决定（需写明理由）
- 技术上有严重问题时坚持异议

### 双循环工作流

**循环A（规划阶段）**
```
project-bootstrap → analysis-agent → plan-revision → analysis-agent → plan-finalize
   plan-agent        (草案复审)       plan-agent      (修订确认)       plan-agent
                         ↓                               ↓
                   neutral-agent                   neutral-agent
                   (可选：仲裁)                    (可选：仲裁)
```

**循环B（执行阶段）**
```
plan-confirm → 子代理执行 → build-agent → code-review → project-complete
 plan-agent     各实现子代理   build-agent   plan-agent     plan-agent
```

## 目录结构

```
ai-synergy/
├── README.md           # 本文件
├── ARCHITECTURE.md     # 架构索引（ai-agent定位用）
├── MANAGED.yaml        # 管理对象白名单
├── PATHS.yaml          # 镜像路径映射
├── CHANGES/            # 变更记录（回滚用）
└── claude/
    ├── CLAUDE.md       # Claude全局指令
    ├── skills/         # Claude skills（引导至子代理）
    ├── prompts/        # 可复用提示词
    └── agents/         # Claude子代理定义
        ├── plan-agent/       # 规划子代理（含内部skills）
        ├── analysis-agent/   # 分析子代理（含内部skills）
        ├── neutral-agent/    # 仲裁子代理（含内部skills）
        ├── python-agent.md   # Python实现
        ├── rust-agent.md     # Rust实现
        ├── c-agent.md        # C语言实现
        ├── ui-agent.md       # 前端UI实现
        ├── build-agent.md    # 编译构建
        ├── sec-agent.md      # 安全审查
        ├── env-agent.md      # 环境安装
        ├── doc-agent.md      # 文档更新
        ├── ai-agent.md       # 全局治理
        └── sub-agent.md      # 子代理管理
```

## 项目 Record 目录结构

每个项目在根目录下创建 `Record/` 目录：

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

## 快速开始

### 新设备部署

#### 步骤1：克隆仓库

```bash
git clone https://github.com/user-no-found/ai-synergy.git ~/ai-synergy
```

#### 步骤2：创建 ai-agent

只需手动复制一个文件：

```bash
mkdir -p ~/.claude/agents
cp ~/ai-synergy/claude/agents/ai-agent.md ~/.claude/agents/
```

#### 步骤3：启动 ai-agent 完成移植

在 Claude 中启动 ai-agent 子代理，告诉它：

```
请读取 ~/ai-synergy/ 并恢复所有配置到本机
```

ai-agent 会自动：
1. 读取 `ARCHITECTURE.md` 了解架构
2. 读取 `MANAGED.yaml` 获取管理对象清单
3. 读取 `PATHS.yaml` 获取路径映射
4. 输出恢复计划等待你确认
5. 确认后将所有配置恢复到真实位置

#### 步骤4：验证

```bash
# 检查 Claude 配置
ls ~/.claude/agents/
ls ~/.claude/skills/
```

### 日常使用

配置由 `ai-agent` 统一管理：
- 修改配置 → ai-agent 输出变更提案 → 用户确认 → 应用并同步镜像
- 出现问题 → ai-agent 读取 CHANGES/ 执行回滚

## 子代理清单

### 核心规划子代理

| 子代理 | 触发条件 | 职责 |
|--------|----------|------|
| plan-agent | 启动策划 | 项目规划、分工、门禁、审核、归档 |
| analysis-agent | 启动分析/复审草案/确认修订 | 草案复审、修订确认 |
| neutral-agent | 启动仲裁/中立分析 | 第三方中立评估与仲裁 |

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

## plan-agent 内部 Skills

| Skill | 触发条件 |
|-------|---------|
| project-bootstrap | 用户开始新项目 |
| plan-revision | 评估analysis-agent分析 |
| plan-finalize | 用户确认方案 |
| plan-confirm | 用户开始执行 |
| code-review | 编译通过后 |
| project-complete | 项目完成 |

## 独立思考原则

所有子代理都遵循独立思考原则：

```
- 【必须独立判断】基于技术事实做独立评估
- 【可以否定用户】即使是用户的决定也可以提出异议
- 【可以否定其他子代理】对其他子代理的结论可以提出异议
- 【写明理由】所有否定意见必须写明具体原因和潜在风险
- 【不盲从】不因任何一方说的就无条件接受
- 【建设性】否定时应提供替代方案或改进建议
- 【坚持原则】技术上有严重问题时，即使多方都催促也要坚持异议
```

## 核心规则

- **Git操作**：子代理本地commit，仅project-complete允许push
- **冲突预防**：proposal中的`allowed_paths`确保文件排他，`depends_on`确保串行依赖
- **变更门禁**：ai-agent修改前必须输出提案并等待用户确认

## 回滚

如果配置出现问题：

```
1. 让 ai-agent 读取 ~/ai-synergy/CHANGES/{timestamp}-{change_id}/
2. 执行 rollback.md 中的回滚步骤
3. 或直接从镜像恢复：cp ~/ai-synergy/claude/... ~/.claude/...
```

## 致谢

- [vibe-coding-cn](https://github.com/2025Emma/vibe-coding-cn) - 质量门禁、八荣八耻等开发理念参考

## License

MIT
