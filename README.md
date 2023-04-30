# CyberMe Client for iOS

另参见： [CyberMe Client by Flutter](https://github.com/corkine/cyberMeFlutter)

另参见： [FontEnd Client by ClojureScript](https://github.com/corkine/cyberMe) | [OpenSource Version](https://github.com/corkine/OpenCyberMe)

另参见： [BackEnd Server by Clojure](https://github.com/corkine/cyberMe) | [OpenSource Version](https://github.com/corkine/OpenCyberMe)

CyberMe iOS 客户端程序。后端基于 CyberMe API 提供服务。

> 此仓库基于 SwiftUI 5 和 Xcode 14 开发，Target 为 iOS 14，但亦为 iOS 16 锁屏小组件提供了支持。

![](https://static2.mazhangjing.com/cyber/202210/53c2bcf4_图片.png)

<img src="https://files.flutter-io.cn/flutter-cn/landing/916809aa4c8f73ad70d2.svg" width="150">

## 特性

![](https://static2.mazhangjing.com/20221124/2cf8_Snipaste_2022-11-24_10-20-21.png)

### 桌面组件与快捷菜单

桌面组件会定期上报 GPS 位置到百度鹰眼以绘制轨迹地图，此外提供如下信息：

- 当日工作打卡状态：已打上班卡、下班卡、本日请假或加班
- 当日工作日报完成状态
- 当日健身、冥想完成情况
- 当日 Microsoft TODO 待办事项
- 当日和明日的 12306 车票信息
- 当日天气信息，下雨预报，白天显示和昨天的温差，晚上显示和明天的温差 
- 米家摄像头看家状态

快捷菜单提供同步 HCM、同步 Microsoft Graph(TODO)、通过快捷指令触发的米家摄像头开启和关闭功能。

### 待办、HCM 打卡、12306 车票管理、周计划、饮食和体重管理

提供 Microsoft TODO 待办事项、当天 HCM 打卡信息、12306 最近车票、Mini4K 美剧追踪通知、快递更新通知、周计划等数据的查看。

提供和 Apple Health 交互的体重记录和趋势查看、目标激励。

提供基于 Core Data 的饮食管理。可以随手“入账”高热量食物、饮品的消费，并且在近期通过运动锻炼来将其“抵账”。

### 短链、笔记、日记速查、快递追踪、GPT 集成

![](https://static2.mazhangjing.com/cyber/202304/a61972a8_What's%20New(4)-tuya.jpg)

通过分享菜单传入 URL 以创建短链接跳转。

通过分享菜单传入文本以创建私人笔记。

通过剪贴板读取快递单号以创建快递状态追踪。

通过唤醒 Siri 语音输入并通过 URLScheme 跳转到 GPT 问答获取答案。

### 故事社、嵌入 Flutter 应用

![](https://static2.mazhangjing.com/cyber/202304/05beb0eb_What's%20New%202(2)-tuya.jpg)

本应用嵌入了 Flutter 引擎，Flutter 应用参见 [CyberMe Client by Flutter](https://github.com/corkine/cyberMeFlutter)。

### macOS 菜单栏

![](https://static2.mazhangjing.com/cyber/202304/c621e517_图片.png)

提供一个 macOS 菜单栏图标，点击后执行 `netstat -rn` 显示前三条路由，提供一个按钮 `Toggle VPN` 来执行脚本，可用于提供脚本触发根据当天日期更新 Wireguard 配置文件对端端口号，脚本可通过执行 `wg-quick up/down wg0` 来创建 VPN 隧道并添加/删除路由。通过观察当前路由状态即可确定是否连接 VPN，点击按钮即可切换 VPN 连接状态。

### 其他

代码库还包括一些 SwiftUI 与 Swift 特性示例应用（小游戏、图书管理、景点介绍）。
