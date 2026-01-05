# sub-agent 参考文档索引

## 文档列表

| 文档 | 用途 | 何时使用 |
|------|------|----------|
| [quality-checklist.md](./quality-checklist.md) | 子代理质量门禁 | 创建/修改子代理时评估质量 |
| [anti-patterns.md](./anti-patterns.md) | 子代理反模式 | 避免常见错误 |

## 快速导航

### 创建新子代理时
1. 阅读 [anti-patterns.md](./anti-patterns.md) 了解要避免的错误
2. 按照模板创建子代理
3. 使用 [quality-checklist.md](./quality-checklist.md) 评估质量

### 修改现有子代理时
1. 使用 [quality-checklist.md](./quality-checklist.md) 评估当前状态
2. 参考 [anti-patterns.md](./anti-patterns.md) 识别问题
3. 修复问题后重新评估

## 八荣八耻（子代理版）

- 以模糊触发为耻，以明确边界为荣
- 以文档堆砌为耻，以可用模式为荣
- 以编造事实为耻，以引用来源为荣
- 以伪代码示例为耻，以可复现为荣
- 以单文件堆积为耻，以合理拆分为荣
- 以破坏性默认为耻，以安全优先为荣
- 以术语混乱为耻，以一致命名为荣
- 以流程缺失为耻，以完整闭环为荣
