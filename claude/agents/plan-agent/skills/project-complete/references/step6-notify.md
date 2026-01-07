# 步骤6：通知用户

## 执行

1. 更新 `Record/memory.md`：
   - 追加"会话摘要"章节：
     ```markdown
     ### YYYY-MM-DD 项目完成
     - **完成**：
       - {功能1}
       - {功能2}
     - **遇到的问题**：{如有}
     - **下次继续**：项目已完成
     ```
   - 更新"已完成功能"章节，勾选所有已实现功能
   - 更新"待办/已知问题"章节，标记已解决的问题

2. 追加记录到 `Record/record.md`：
   ```markdown
   ## YYYY-MM-DD HH:MM 项目完成
   版本：{plan_version}
   提交：{commit SHA}
   归档提案数：{N}
   ```

## 输出格式

```
项目已完成！

版本：{plan_version}
提交：{commit SHA}

变更摘要：
- {功能1}
- {功能2}

归档提案数：{N}
变更文件数：{N}

OpenSpec 规范已更新：openspec/specs/

已推送到远程仓库。
```
