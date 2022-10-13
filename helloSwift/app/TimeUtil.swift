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
