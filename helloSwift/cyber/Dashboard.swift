//
//  WebService.swift
//  helloSwift
//
//  Created by corkine on 2022/10/12.
//

import Foundation

struct Dashboard: Codable {
    var workStatus:String
    var cardCheck:[String]
    var weatherInfo: String?
    var todo:[Todo]
    var updateAt: Int64
    var needDiaryReport: Bool
    var needPlantWater: Bool
    struct Todo: Codable,Hashable,Identifiable {
        var title:String
        var isFinished:Bool
        var id:String { title }
    }
}

extension Dashboard {
    static let demoTodo = [Todo(title: "提醒事项1", isFinished: true),
                           Todo(title: "提醒事项2", isFinished: false),
                           Todo(title: "提醒事项3", isFinished: true),
                           Todo(title: "提醒事项4", isFinished: false)]
    static let demo = Dashboard(workStatus: "🟡", cardCheck: ["8:20","17:31"], weatherInfo: "",
                                todo: demoTodo, updateAt:
                                    Int64(Date().timeIntervalSince1970), needDiaryReport: false, needPlantWater: true)
    static func failed(error:Error?) -> Dashboard {
        Dashboard(workStatus: "🟡", cardCheck: ["8:20","17:31"], weatherInfo: "请求失败：\(String(describing: error))",
                  todo: demoTodo, updateAt:
                                        Int64(Date().timeIntervalSince1970), needDiaryReport: false, needPlantWater: true)
    }
}
