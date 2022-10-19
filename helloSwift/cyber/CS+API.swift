//
//  CS+API.swift
//  helloSwift
//
//  Created by Corkine on 2022/10/19.
//

import Foundation

extension CyberService {
    static let baseUrl = "https://cyber.mazhangjing.com/"
    static let summaryUrl = "cyber/dashboard/summary?day=5"
    static let dashboardUrl = "cyber/dashboard/ioswidget"
    static let checkCardUrl = "cyber/check/now?plainText=false&preferCacheSuccess=true"
    static let checkCardForce = "cyber/check/now?plainText=false&useCache=false"
    static let syncTodoUrl = "cyber/todo/sync"
}
