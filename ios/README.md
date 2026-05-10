# Lafo iOS

这里是 Lafo 当前 SwiftUI 本地 MVP。首版 App 以本地记录为主，不需要登录、不需要手机号或 Apple 登录，也不需要连接后端服务。

## 打开与构建

1. 用 Xcode 打开 `ios/Lafo.xcodeproj`。
2. 选择 `Lafo` scheme。
3. 选择任意 iOS Simulator 或真机目标。
4. 点击 Run，或在仓库根目录运行：

```bash
xcodebuild -project ios/Lafo.xcodeproj -scheme Lafo -destination generic/platform=iOS build
```

如本机首次使用 Xcode，需要先接受 Xcode license。

## 主要页面

- 首次欢迎：说明本地存储、生活记录定位和免责声明。
- 今日：查看今日次数、连续记录、最近记录，并通过「我拉了 💩」快速新增。
- 记录：选择时间、便便状态，可选感受、腹痛程度和备注。
- 日历：按月回看每天记录，查看、编辑或删除单条记录。
- 趋势：查看本周、本月、常见状态、常见时间段等轻量统计。
- 伙伴：展示 Lafo 小肠肠、连续记录反馈和解锁状态。
- 我的：提醒设置、CSV 导出、隐私政策、用户协议、免责声明、清空本地数据。

## 本地隐私边界

- 记录保存在设备本地，不作为首版流程上传服务器。
- App 不要求账号、手机号、Apple 登录或云同步。
- 用户可在「我的」中导出 CSV 或清空本地数据。
- Lafo 仅用于生活记录和习惯观察，不提供诊断、治疗建议或医疗结论；如持续不适，请咨询专业医生。

## 后端说明

仓库中的 `backend/` 是早期 legacy/scaffold，不是当前 iOS 本地 MVP 的必需运行路径。当前 iOS 流程应以本地数据、SwiftUI 页面和设备端隐私边界为准。
