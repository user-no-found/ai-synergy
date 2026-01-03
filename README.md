# AI-Synergy

Codex + Claude 双AI协同开发方案的可移植配置镜像。

## 概述

本仓库是"AI协同方案"的全局配置镜像，用于：
- 跨设备迁移AI协同环境
- 版本控制全局配置
- 回滚错误变更

## 架构

```
Codex（规划/审核）  <--用户中转-->  Claude（分析/执行）
       ↓                              ↓
   Skills x8                      Skills x2
                                  Agents x11
```

### 双循环工作流

**循环A（规划阶段）**
```
project-bootstrap → draft-plan-review → plan-revision → revision-confirm → plan-finalize
     Codex              Claude              Codex           Claude            Codex
```

**循环B（执行阶段）**
```
plan-confirm → 子代理执行 → build-agent → code-review → project-complete
    Codex        Claude        Claude        Codex           Codex
```

## 目录结构

```
ai-synergy/
├── README.md           # 本文件
├── ARCHITECTURE.md     # 架构索引（ai-agent定位用）
├── MANAGED.yaml        # 管理对象白名单
├── PATHS.yaml          # 镜像路径映射
├── CHANGES/            # 变更记录（回滚用）
├── claude/
│   ├── CLAUDE.md       # Claude全局指令
│   ├── skills/         # Claude skills
│   └── agents/         # Claude子代理定义
└── codex/
    ├── AGENTS.md       # Codex全局指令
    └── skills/         # Codex skills
```

## 快速开始

### 新设备部署

#### 步骤1：克隆仓库

```bash
git clone https://github.com/user-no-found/ai-synergy.git ~/ai-synergy
```

#### 步骤2：手动恢复配置

由于新设备没有 ai-agent，需要先手动恢复基础配置：

```bash
# 创建目录
mkdir -p ~/.claude/agents ~/.claude/skills ~/.codex/skills

# 恢复 Claude 配置
cp ~/ai-synergy/claude/CLAUDE.md ~/.claude/CLAUDE.md
cp -r ~/ai-synergy/claude/agents/* ~/.claude/agents/
cp -r ~/ai-synergy/claude/skills/* ~/.claude/skills/

# 恢复 Codex 配置
cp ~/ai-synergy/codex/AGENTS.md ~/.codex/AGENTS.md
cp -r ~/ai-synergy/codex/skills/* ~/.codex/skills/
```

#### 步骤3：验证

```bash
# 检查 ai-agent 是否存在
cat ~/.claude/agents/ai-agent.md | head -5

# 检查 Codex skills
ls ~/.codex/skills/
```

#### 步骤4：后续维护

配置恢复后，后续变更由 ai-agent 统一管理：
- 在 Claude 中启动 ai-agent
- ai-agent 会读取 `~/ai-synergy/ARCHITECTURE.md` 了解架构
- 修改配置时，ai-agent 输出变更提案 → 用户确认 → 应用并同步镜像

### 日常使用

配置由 `ai-agent` 统一管理：
- 修改配置 → ai-agent 输出变更提案 → 用户确认 → 应用并同步镜像
- 出现问题 → ai-agent 读取 CHANGES/ 执行回滚

## Skills 清单

### Codex Skills

| Skill | 触发条件 |
|-------|---------|
| project-bootstrap | 用户开始新项目 |
| plan-revision | Codex评估Claude分析 |
| plan-finalize | 用户确认方案（6步） |
| plan-confirm | 用户开始执行（5步） |
| code-review | 编译通过后（7步） |
| project-complete | 项目完成（6步） |
| build-report | build-agent输出报告 |
| agents-registry | 子代理登记表 |

### Claude Skills

| Skill | 触发条件 |
|-------|---------|
| draft-plan-review | Claude复审Codex草案 |
| revision-confirm | Claude确认Codex修订 |

## 子代理清单

| 子代理 | 职责 |
|--------|------|
| python-agent | Python实现 |
| rust-agent | Rust实现 |
| c-agent | C语言实现 |
| ui-agent | 前端UI实现 |
| doc-agent | 文档更新 |
| build-agent | 编译构建 |
| sec-agent | 安全审查 |
| env-agent | 环境安装 |
| ai-agent | 全局治理 |
| sub-agent | 子代理管理 |
| skill-designer | Skill设计 |

## 核心规则

- **Git操作**：子代理本地commit，仅project-complete允许push
- **冲突预防**：proposal中的`allowed_paths`确保文件排他，`depends_on`确保串行依赖
- **变更门禁**：ai-agent修改前必须输出提案并等待用户确认

## 回滚

如果配置出现问题：

```
1. 让 ai-agent 读取 ~/ai-synergy/CHANGES/{timestamp}-{change_id}/
2. 执行 rollback.md 中的回滚步骤
3. 或直接从镜像恢复：cp ~/ai-synergy/... ~/.codex/... 或 ~/.claude/...
```

## License

MIT
