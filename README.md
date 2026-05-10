# Lafo

Lafo / 拉否 是一个 iOS 本地优先的轻量排便生活记录 App。当前 MVP 聚焦「快速记录、日历回看、简单趋势、伙伴陪伴、隐私可控」，不需要登录，不需要手机号或 Apple 登录，也不依赖云端同步。

一句话介绍：Lafo，让每一次轻松都有记录。

## 当前 MVP 范围

- `ios/`: SwiftUI 本地 MVP，首版 App 的主要交付路径。
- `docs/lafo-mvp-local-prd.md`: 本地优先 MVP 的产品范围、页面和验收标准。
- `docs/superpowers/plans/`: 实施计划与任务拆分。
- `backend/`: legacy/scaffold，仅保留早期 FastAPI 后端骨架；不是首版 App 的必需路径。

## 产品边界

- 数据默认保存在用户手机本地。
- 不要求登录、账号体系、云同步、社区或广告。
- 不做诊断、治疗建议或医疗结论。
- Lafo 仅用于生活记录和习惯观察；如持续不适，请咨询专业医生。

## iOS

SwiftUI 源码位于 `ios/LafoApp`，Xcode 工程位于 `ios/Lafo.xcodeproj`。打开和构建方式见 `ios/README.md`。

## Backend

`backend/` 目前只是 legacy/scaffold，用于保留早期 API 探索代码。首版本地 MVP 不需要运行后端即可使用核心 App 流程。

如需查看旧后端测试或开发命令，可在后续后端工作中单独处理，避免把它作为当前 iOS MVP 的启动前置条件。
