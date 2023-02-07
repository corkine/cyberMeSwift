# CyberMe Client for iOS、iPadOS & watchOS by Swift

<del>另参见： [Android Client by Flutter](https://github.com/corkine/cyberMeFlutter)</del>

另参见： [FontEnd Client by ClojureScript](https://github.com/corkine/cyberMe) | [OpenSource Version](https://github.com/corkine/OpenCyberMe)

另参见： [BackEnd Server by Clojure](https://github.com/corkine/cyberMe) | [OpenSource Version](https://github.com/corkine/OpenCyberMe)

CyberMe iOS 客户端程序。后端基于 cyber.mazhangjing.com API 提供服务。

> 此仓库基于 SwiftUI 5 和 Xcode 14 开发，Target 为 iOS 14

![](https://static2.mazhangjing.com/cyber/202210/53c2bcf4_图片.png)

## 特性

![](https://static2.mazhangjing.com/20221124/2cf8_Snipaste_2022-11-24_10-20-21.png)

### 桌面组件与快捷菜单

桌面组件桌面组件会定期上报 GPS 位置到百度鹰眼以绘制轨迹地图，此外提供如下信息：

- 日报完成状态
- 当日工作状态：已打上班卡、下班卡、本日请假或加班
- HCM 打卡时间
- 当日健身完成情况
- 当日 TODO 待办事项
- 当日和明日的 12306 车票信息
- 当日天气信息，下雨预报，白天显示和昨天的温差，晚上显示和明天的温差 
- 米家摄像头看家状态

快捷菜单提供同步 HCM、同步 Microsoft Graph(TODO)、摄像头开启和关闭动作。

### 待办、HCM 打卡、12306 车票管理、周计划、饮食和体重管理

提供 Microsoft TODO 待办事项、12306 最近车票、周计划、当天 HCM 打卡信息等数据的查看。

提供和 Apple Health 交互的体重记录和趋势查看、目标激励。

提供基于 Core Data 的饮食管理。可以随手“入账”高热量食物、饮品的消费，并且在近期通过运动锻炼来将其“抵账”。

### 其他

代码库还包括一些 SwiftUI 与 Swift 特性示例应用（小游戏、图书管理、景点介绍）。
