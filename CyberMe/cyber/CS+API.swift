//
//  CS+API.swift
//  helloSwift
//
//  Created by Corkine on 2022/10/19.
//

import Foundation

extension CyberService {
    static let baseUrl = "https://cyber.mazhangjing.com/"
    static let summaryUrl = "cyber/client/ios-summary?day=5"
    static let dashboardUrl = "cyber/client/ios-widget"
    static let uploadHealthUrl = "cyber/fitness/appUpload"
    static let checkCardUrl = "cyber/check/now?plainText=false&preferCacheSuccess=true"
    static let checkCardForce = "cyber/check/now?plainText=false&useCache=false"
    static let syncTodoUrl = "cyber/todo/sync"
    static func addLogUrl(_ itemId: String) -> String {
        return "cyber/week-plan/update-item/\(itemId)/add-log"
    }
    static func removeLogUrl(_ itemId: String, _ logId: String) -> String {
        return "cyber/week-plan/update-item/\(itemId)/remove-log/\(logId)"
    }
    static func editLogUrl(_ itemId: String) -> String {
        return "cyber/week-plan/update-item/\(itemId)/update-log"
    }
    static let editWeekPlanItemUrl = "cyber/week-plan/modify-item"
}
