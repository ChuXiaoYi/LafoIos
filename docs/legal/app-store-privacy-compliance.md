# Lafo 隐私与合规检查

检查日期：2026-05-10

## App Store Connect URL 准备

- 隐私政策页面草稿：`docs/legal/privacy-policy.md`
- 用户协议页面草稿：`docs/legal/terms-of-use.md`
- 医疗免责声明页面草稿：`docs/legal/medical-disclaimer.md`
- 隐私政策当前可用公网 URL：`https://cdn.jsdelivr.net/gh/ChuXiaoYi/LafoIos@main/docs/legal/privacy-policy.md`
- 用户协议当前可用公网 URL：`https://cdn.jsdelivr.net/gh/ChuXiaoYi/LafoIos@main/docs/legal/terms-of-use.md`
- 医疗免责声明当前可用公网 URL：`https://cdn.jsdelivr.net/gh/ChuXiaoYi/LafoIos@main/docs/legal/medical-disclaimer.md`
- GitHub Pages 预期 URL：`https://chuxiaoyi.github.io/LafoIos/privacy-policy.html`
- GitHub Pages 预期 URL：`https://chuxiaoyi.github.io/LafoIos/terms-of-use.html`
- GitHub Pages 预期 URL：`https://chuxiaoyi.github.io/LafoIos/medical-disclaimer.html`

当前 jsDelivr CDN URL 已公开可访问，可先用于 App Store Connect。GitHub Pages URL 需要在仓库 Settings -> Pages 中启用 `gh-pages` 分支后才会生效。

## 当前合规边界

- Lafo 第一版不要求注册或登录。
- Lafo 第一版默认将排便记录保存在设备本地。
- Lafo 第一版不上传用户排便记录。
- Lafo 第一版不接入第三方广告追踪。
- Lafo 第一版不使用 HealthKit。
- Lafo 不提供医学诊断、治疗建议、疾病判断或医疗服务。
- Lafo 不应出现疾病治疗或疾病诊断类营销表述。

## 上架前需要填写

- Privacy Policy URL：`https://cdn.jsdelivr.net/gh/ChuXiaoYi/LafoIos@main/docs/legal/privacy-policy.md`
- Terms of Use URL：`https://cdn.jsdelivr.net/gh/ChuXiaoYi/LafoIos@main/docs/legal/terms-of-use.md`
- Support URL：待上架主体确认。
- Contact Email：待上架主体确认。
