//
//  CarPlay.swift
//  CyberMe
//
//  Created by Corkine on 2024/7/2.
//

import Foundation
import CarPlay


class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    private var interfaceController: CPInterfaceController?

    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        setInformationTemplate()
    }

    private func setInformationTemplate() {
        Task.detached {
            var items: [CPInformationItem] = []
            var status = ""
            var lastCheck = "打卡";
            let (dashboard, error) = await CyberService.fetchDashboard(location: nil)
            if let dashboard = dashboard {
                print(dashboard)
                items = dashboard.todo.map { todo in
                    CPInformationItem(title: todo.isFinished ? "" : "未完成", detail: todo.title)
                }
                let temp = "\(String(format: "%.1f", dashboard.tempInfo?.low ?? 0))°C ~ \(String(format: "%.1f", dashboard.tempInfo?.high ?? 0))°C"
                items.insert(CPInformationItem(title: temp, detail:dashboard.weatherInfo), at: 0)
                status = dashboard.workStatus + " "
                let last = dashboard.cardCheck.last
                lastCheck = last == nil ? lastCheck : (last! + " 打卡")
            } else {
                print("error fetch data \(String(describing: error))")
                items = [CPInformationItem(title: "加载失败", detail: error?.localizedDescription ?? "")]
            }
            let infoTemplate = CPInformationTemplate(
                title: "\(status) \(await self.getFormattedDateString())",
                layout: .leading,
                items: items,
                actions: [CPTextButton(title: "刷新", textStyle: .normal, handler: { btn in
                    Task.detached {
                        await self.setInformationTemplate()
                    }
                }), CPTextButton(title: lastCheck, textStyle: lastCheck == "打卡" ? .normal : .confirm)])
            let _ = try? await self.interfaceController?.setRootTemplate(infoTemplate, animated: true)
        }
    }
    
    func getFormattedDateString() -> String {
        let date = Date()
        let calendar = Calendar.current
        let dayOfMonth = calendar.component(.day, from: date)
        let weekday = calendar.component(.weekday, from: date)
        
        // 获取中文的星期几名称
        let weekdayString: String
        switch weekday {
        case 1:
            weekdayString = "周日"
        case 2:
            weekdayString = "周一"
        case 3:
            weekdayString = "周二"
        case 4:
            weekdayString = "周三"
        case 5:
            weekdayString = "周四"
        case 6:
            weekdayString = "周五"
        case 7:
            weekdayString = "周六"
        default:
            weekdayString = ""
        }
        
        // 组合成最终的字符串
        let formattedString = "\(dayOfMonth) 日 \(weekdayString)"
        return formattedString
    }
}
