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
}

extension Date {
    var weekday: Int {
        let res = Calendar.current.component(.weekday, from: self)
        if res == 1 { return 7 }
        else { return res - 1 }
    }
    var hour: Int {
        Calendar.current.component(.hour, from: self)
    }
}
