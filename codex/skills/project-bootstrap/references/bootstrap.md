# 项目启动落盘（bootstrap）

## 目标

当用户说“开始一个项目/我的需求是…”时，先把项目的“规划入口文件”与 Record 目录结构落盘，形成后续循环A/循环B的统一锚点。

## 步骤（必须按顺序）

1) 确认项目根目录
   - 明确告知用户：默认项目根目录 = 当前工作目录（CWD）
   - 用一句话询问用户确认：是否把 `Record/` 写入当前目录
   - 若用户说“不是”，要求用户给出正确项目根目录路径后再继续

2) 创建 Record 目录结构（项目内）
   - `Record/plan/`
   - `Record/design/`
   - `Record/impl/`
   - `Record/review/`
   - `Record/release/`
   - `Record/locks/`

3) 生成并落盘“预定清单（草案）”
   - 文件路径固定：`Record/plan/draft-plan.md`
   - 内容必须包含：
     - 需求摘要（3-7条要点）
     - 循环A/循环B的预期步骤（只写最小闭环）
     - 环境检查：对照 `~/environment.md`，列出缺失项（如有）
     - 子代理需求：按 role 列出需要的 Claude 子代理与并行运行槽位（例如 `python-agent` 需要 2 个运行槽位）
     - 子代理存在性确认：引用 `~/.codex/skills/agents-registry/references/registry.yaml` 的核对结论（已存在/缺失/需调整）
     - 初版 scope 轮廓（allowed_paths/forbidden_patterns/dependencies/max_review_rounds 的最小版本）
     - 用户确认选项（三选一）：同意执行 / 需要调整 / 暂停取消

4) 初始化项目级状态机文件（可选但推荐）
   - 文件路径固定：`Record/state.json`
   - 在"规划确认通过"之前，`active_plan_version` 必须为空字符串或 null
   - 其余字段按 `最终版方案.md` 的最小结构写入（只写必要字段）

5) 创建项目记录文件
   - 文件路径固定：`Record/record.md`
   - 写入初始内容（见 templates.md）
   - 追加第一条记录：
     ```markdown
     ## YYYY-MM-DD HH:MM 需求提出
     {用户需求摘要，3-7条要点}
     ```

6) 输出"下一步指令"
   - 告知用户：请先审阅 `Record/plan/draft-plan.md`
   - 需要修改则在此对话中提出，Codex 更新该文件后再进入规划确认（冻结 `v1`）
