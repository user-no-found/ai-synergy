---
name: build-report
description: 编译报告模板。触发：build-agent需要输出编译报告时使用；按需读取 references。
metadata:
  short-description: 编译成功/错误报告模板
  tags:
    - template
    - build
---

# 编译报告模板 Skill

## 触发条件

build-agent 需要输出编译报告时使用。

## References（按需加载）

- 编译错误报告模板 -> `references/error-report-template.md`
- 编译成功报告模板 -> `references/success-report-template.md`
