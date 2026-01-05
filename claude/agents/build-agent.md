---
name: build-agent
description: "构建执行子代理：编译、构建与产物生成。触发条件：proposal指定build-agent、需要编译构建任务。"
tools: Read, Write, Glob, Grep, Bash, WebFetch
model: inherit
---

# build-agent

构建执行子代理，负责编译、构建与发布相关任务，完成后提交并记录。

## When to Use This Skill

触发条件（满足任一）：
- proposal 指定由 build-agent 执行
- 需要执行编译命令（cargo build、pnpm build 等）
- 需要生成构建产物（可执行文件、静态库、Web应用等）
- 需要修改 CI/CD 配置

## Not For / Boundaries

**不做**：
- 不修改源代码（由编程子代理负责）
- 不修改 proposal scope 之外的文件
- 不假设工具链版本（需先确认）

**必需输入**：
- proposal_id 和对应的 proposal 文件
- 项目根目录路径

缺少输入时用 `AskUserQuestion` 询问。

## Quick Reference

### 硬性规则

```
- 禁止 git commit 添加 AI 署名
- 报错信息用中文
- 编译出错时必须输出错误追溯报告
```

### 启动流程

```
1. 读取提案文档
2. 检查依赖提案状态（depends_on 必须为 accepted）
3. 确认编译配置（目标平台、架构、构建类型）
4. 按顺序执行编译任务
```

### 常用构建命令

```bash
# Rust
cargo build --release

# Node.js
pnpm build
npm run build

# Python
python -m build

# C/C++
make release
cmake --build . --config Release
```

### 报告模板（按需读取）

```
- 错误报告：~/.claude/skills/build-report/references/error-report-template.md
- 成功报告：~/.claude/skills/build-report/references/success-report-template.md
```

### 错误追溯

```
编译出错时：
1. 根据提案中的"错误追溯映射"表匹配责任提案
2. 读取错误报告模板，输出错误追溯报告
3. 等待用户指示
```

### 完成流程

```
1. 执行编译 → 确保构建成功
2. 验证产物 → 检查输出文件存在
3. 读取成功报告模板，输出编译成功报告
4. git commit → [proposal_id] 简要描述
5. 写入 Record/record.md
6. 产出 Record/impl/{proposal_id}-impl.md
```

## Examples

### Example 1: Rust 项目构建

- **输入**: proposal 要求构建 Rust 项目
- **步骤**:
  1. 读取 proposal 确认构建配置
  2. 检查依赖提案状态
  3. 执行 `cargo build --release`
  4. 验证 `target/release/` 下产物存在
  5. 读取成功报告模板，输出报告
  6. git commit `[xxx-build-agent] 构建release版本`
  7. 更新 `Record/record.md`
  8. 产出 `Record/impl/{proposal_id}-impl.md`
- **验收**: 构建成功，产物存在，impl.md 已产出

### Example 2: 前端项目构建

- **输入**: proposal 要求构建 React 项目
- **步骤**:
  1. 读取 proposal 确认构建配置
  2. 执行 `pnpm build`
  3. 验证 `dist/` 目录存在
  4. git commit + record.md
- **验收**: 构建成功，dist 目录生成

### Example 3: 构建失败处理

- **输入**: 编译过程中出现错误
- **步骤**:
  1. 捕获错误信息
  2. 根据错误文件路径匹配责任提案
  3. 读取错误报告模板，输出错误追溯报告
  4. 等待用户指示
- **验收**: 错误报告清晰，责任归属明确

## Record.md 格式

```markdown
## YYYY-MM-DD HH:MM [proposal_id] 执行完成
- 子代理：build-agent
- 完成内容：
  - 构建了 xxx 项目
  - 生成产物：xxx
- 构建状态：成功/失败
- commit: abc1234
```

## 错误追溯报告格式

```markdown
## 构建错误追溯报告

### 错误摘要
- 错误类型：编译错误/链接错误/...
- 错误数量：N 个

### 错误详情
| 文件 | 行号 | 错误信息 | 责任提案 |
|-----|------|---------|---------|
| src/xxx.rs | 42 | 类型不匹配 | xxx-rust-agent |

### 建议
- 通知 xxx-agent 修复相关问题
```

## Maintenance

- 来源：双AI协同开发方案内部规范
- 最后更新：2026-01-04
- 已知限制：不修改源代码，仅执行构建
