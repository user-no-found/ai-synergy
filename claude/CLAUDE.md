## 核心规则（最高优先级）

- 禁止git commit中添加AI署名（Co-Authored-By、Signed-off-by等）
- 当用户打断对话时，立即停止当前操作，根据新输入重新规划
- **禁止时间周期估算**：不输出"X周完成"、"预计X天"等时间规划

## 上下文控制（必须遵守）

- 默认不加载与当前任务无关的规则/文档
- 只加载"够用的最小信息"；不确定时先询问用户
- 读取外部材料后先做摘要：用3-7条要点记录结论，后续优先引用摘要

## 交互规则

- 通过 `AskUserQuestion` 与用户交互
- 需求不明确时询问澄清
- 多方案时询问选择

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

1. 创建 Record/ 目录结构（含 Memory/、plan/ 子目录）
2. 创建 Record/Memory/claude.md（主对话记忆）
3. 写入用户需求到 Record/plan/draft-plan.md
4. 进入循环A（三方顺序讨论）

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
  Task: plan-agent（mode: discuss）→ 读取意见，修改草案
        │
        ▼
  Task: analysis-agent → 分析讨论，发表新意见
        │
        ▼
  Task: neutral-agent → 分析讨论，发表新意见
        │
        ▼
  Claude 检查三方结果：
        │
        ├─→ need_info → AskUserQuestion 询问用户 → 继续循环
        │
        ├─→ has_objection → 继续下一轮讨论
        │
        └─→ 三方全部同意 → AskUserQuestion：确认草案 / 再讨论？
                │
                ├─→ 确认 → Task: plan-agent（mode: finalize）→ 结束循环A
                │
                └─→ 再讨论 → 继续下一轮
```

### 记忆管理

**Claude 主对话**：每轮讨论后更新 `Record/Memory/claude.md`

---

## 执行阶段（循环B）

### 触发条件

循环A 结束后，plan-agent 已创建 impl.md 任务表。

### 循环B 执行逻辑

**阶段完成后直接进入下一阶段，无需询问用户确认**

```
impl.md 任务表
        │
        ▼
按依赖分组，同组任务并行调用（一个消息多个 Task）
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
                        ├─→ 是 → Task: sec-agent → 修复循环或归档
                        │
                        └─→ 否 → Task: plan-agent(complete) → git push

```

---

## Git 操作规则

| 阶段 | 操作 | 范围 |
|------|------|------|
| 编程子代理完成 | git commit | 本地 |
| 修复子代理完成 | git commit | 本地 |
| plan-agent(complete) | git push | **远程**（唯一） |

---

## 用户异议处理

当用户提出流程问题（越权、循环卡死、状态不一致、Git问题等）时，Task 调用 ai-agent（mode: diagnose）。
