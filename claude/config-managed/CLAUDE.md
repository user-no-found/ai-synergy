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

## Skills（按需使用）

- OpenSpec工作流：`~/.claude/skills/openspec-workflow/SKILL.md`
- 预定清单复审：`~/.claude/skills/draft-plan-review/SKILL.md`
- 修订确认（Codex修订后触发）：`~/.claude/skills/revision-confirm/SKILL.md`
