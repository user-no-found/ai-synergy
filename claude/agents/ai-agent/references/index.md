# AI-Agent 参考文档索引

## 文档列表

| 文档 | 用途 | 何时使用 |
|------|------|----------|
| [quality-checklist.md](./quality-checklist.md) | Skills/子代理质量门禁 | 创建/修改 skills 或子代理时 |
| [anti-patterns.md](./anti-patterns.md) | 反模式清单 | 避免常见错误 |
| [validate-skill.sh](./validate-skill.sh) | 验证脚本 | 自动化质量检查 |
| [eight-principles.md](./eight-principles.md) | 八荣八耻原则 | 全局行为准则 |

## 快速导航

### 修改 Skill 时
1. 读取 [quality-checklist.md](./quality-checklist.md) 了解质量标准
2. 参考 [anti-patterns.md](./anti-patterns.md) 避免错误
3. 修改后运行 validate-skill.sh 验证

### 修改子代理时
1. 使用 [quality-checklist.md](./quality-checklist.md) 评估
2. 参考 [anti-patterns.md](./anti-patterns.md) 识别问题
3. 确保符合 [eight-principles.md](./eight-principles.md)

### 新增 Skill/子代理时
1. 按模板创建
2. 通过质量门禁（总分>=24）
3. 运行验证脚本确认
