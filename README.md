# CyberMe Client for iOS、iPadOS & watchOS by Swift

另参见： [Android Client by Flutter](https://github.com/corkine/cyberMeFlutter)

另参见： [FontEnd Client by ClojureScript](https://github.com/corkine/cyberMe) | [OpenSource Version](https://github.com/corkine/openCyberMe)

另参见： [BackEnd Server by Clojure](https://github.com/corkine/cyberMe) | [OpenSource Version](https://github.com/corkine/openCyberMe)

CyberMe iOS 客户端程序。后端基于 status.mazhangjing.com 和 cyber.mazhangjing.com API 提供服务。

> 此仓库基于 SwiftUI 5 和 Xcode 14 开发，Target 为 iOS 14

![](https://static2.mazhangjing.com/cyber/202210/53c2bcf4_图片.png)

## 特性

![](https://static2.mazhangjing.com/20221124/2cf8_Snipaste_2022-11-24_10-20-21.png)

### 桌面组件与快捷菜单

提供当日工作状态、打卡状态、周报完成状态、健身完成状态、当日 TODO 待办事项和天气与昨日与明日的温差的展示。根据时间和状态不同，显示的内容存在差异。允许直接跳转到支付宝健康码、云上协同打卡界面、调用快捷指令执行 Health 健康数据上传等动作。

提供同步 HCM、同步 Microsoft Graph(TODO) 的快捷菜单。

### 待办、HCM 打卡、周计划、饮食和体重管理

提供 Microsoft TODO 待办事项、周计划、当天 HCM 打卡信息等数据的查看。

提供和 Apple Health 交互的体重记录和趋势查看、目标激励。

提供基于 Core Data 的饮食管理。可以随手“入账”高热量食物、饮品的消费，并且在近期通过运动锻炼来将其“抵账”。

### 其他

代码库还包括一些 SwiftUI 与 Swift 特性示例应用（小游戏、图书管理、景点介绍）。
