# ai-agent 诊断模板

## 问题定位指南

### 循环A 问题

| 问题类型 | 可能涉及文件 |
|----------|-------------|
| 草案生成问题 | plan-agent.md (mode: draft) |
| 分析不准确 | analysis-agent.md, neutral-agent.md |
| 定稿流程问题 | plan-agent.md (mode: finalize) |
| 环境检查问题 | plan-agent skills/plan-finalize |
| 子代理检查问题 | plan-agent skills/plan-finalize |

### 循环B 问题

| 问题类型 | 可能涉及文件 |
|----------|-------------|
| 编程子代理问题 | python-agent.md, rust-agent.md 等 |
| 编译问题 | build-agent.md |
| 代码审核问题 | plan-agent.md (mode: review) |
| 安全分析问题 | sec-agent.md |
| 归档提交问题 | plan-agent.md (mode: complete) |
| 修复分配问题 | plan-agent.md (mode: fix) |

### 全局问题

| 问题类型 | 可能涉及文件 |
|----------|-------------|
| 流程控制问题 | ~/.claude/CLAUDE.md |
| 架构描述问题 | ~/ai-synergy/ARCHITECTURE.md |
| 子代理缺失 | sub-agent.md, MANAGED.yaml |
| 环境安装问题 | env-agent.md |

## 常见问题模式

### 1. 步骤越权
**症状**：某子代理执行了不属于它的操作
**检查**：子代理的 scope 定义、硬性规则、CLAUDE.md 调用逻辑

### 2. 循环卡死
**症状**：流程在某个循环中无法退出
**检查**：循环退出条件、子代理返回格式、Claude 主对话判断逻辑

### 3. 状态不一致
**症状**：impl.md/state.json 状态与实际不符
**检查**：状态更新时机、子代理返回后的处理逻辑

### 4. Git 操作问题
**症状**：本地/远程 git 操作混乱
**检查**：Git 操作规则表、各子代理的 git 权限

## 修改方案模板

```markdown
## 修改方案

### 方案ID: option-{n}

### 问题描述
{问题描述}

### 根本原因
{根本原因分析}

### 修改内容

#### 文件1: {路径}
- 旧内容
+ 新内容

### 风险评估
- 风险等级：{low | medium | high}
- 影响范围：{影响范围}
- 回滚方法：{回滚方法}

### 验证方法
- {验证步骤1}
- {验证步骤2}
```

## 变更记录格式

写入 `~/ai-synergy/CHANGES/{date}-{seq}.md`：

```markdown
# 变更记录

日期：{ISO8601}
触发：用户反馈流程问题
方案：option-{n}

## 问题描述
{问题描述}

## 修改内容
- {文件1}: {修改描述}
- {文件2}: {修改描述}

## 验证结果
- {验证结果}
```
