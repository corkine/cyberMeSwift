//
//  TimeUtil.swift
//  helloSwift
//
//  Created by corkine on 2022/10/13.
//

import Foundation

enum TimeUtil {
    static var needCheckCard: Bool {
        let date = Date()
        let hour = Calendar.current.component(.hour, from: date)
        return (hour >= 7 && hour < 9) || (hour >= 17 && hour < 22)
    }
    static func getDate(off:Int = 0, format:String = "yyyy-MM-dd") -> String {
        var dayComponent = DateComponents()
        dayComponent.day = off
        let calendar = Calendar.current
        let day = calendar.date(byAdding: dayComponent, to: Date())!
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let currentTime: String = formatter.string(from: day)
        return currentTime
    }
    static var javaLikeFormat = "yyyy-MM-dd'T'HH:mm:ss"
    static func getWeedayFromeDate(date: Date, withMonth: Bool = false) -> String {
        let calendar = Calendar.current
        let dateComponets = calendar.dateComponents([Calendar.Component.year,Calendar.Component.month,Calendar.Component.weekday,Calendar.Component.day], from: date)
        //获取到今天是周几 1(星期天) 2(星期一) 3(星期二) 4(星期三) 5(星期四) 6(星期五) 7(星期六)
        let weekDay = dateComponets.weekday
        var weekDayStr = ""
        switch weekDay {
        case 1:
            weekDayStr = "周日"
        case 2:
            weekDayStr = "周一"
        case 3:
            weekDayStr = "周二"
        case 4:
            weekDayStr = "周三"
        case 5:
            weekDayStr = "周四"
        case 6:
            weekDayStr = "周五"
        case 7:
            weekDayStr = "周六"
        default:
            weekDayStr = ""
        }
        return withMonth ? "\(dateComponets.day!) 日 \(weekDayStr)" : weekDayStr
    }
}

extension Date {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar.current
        return formatter
    }()
    var weekday: Int {
        let res = Calendar.current.component(.weekday, from: self)
        if res == 1 { return 7 }
        else { return res - 1 }
    }
    var hour: Int {
        Calendar.current.component(.hour, from: self)
    }
    static var today: Date {
        Calendar.current.startOfDay(for: Date())
    }
    static var yesterday: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    }
}

