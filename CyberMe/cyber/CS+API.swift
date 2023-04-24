//
//  CS+API.swift
//  helloSwift
//
//  Created by Corkine on 2022/10/19.
//

import Foundation

extension CyberService {
    static var baseUrl = CyberService.endpoint
    static let summaryUrl = "cyber/client/ios-summary?day=5"
    static let dashboardUrl = "cyber/client/ios-widget"
    static let uploadBodyMassUrl = "cyber/client/ios-body-mass"
    static let uploadHealthUrl = "cyber/fitness/appUpload"
    static let checkCardUrl = "cyber/check/now?plainText=false&preferCacheSuccess=true"
    static let checkCardForce = "cyber/check/now?plainText=false&useCache=false"
    static let forceWorkUrl = "cyber/dashboard/today-work-info"
    static let syncTodoUrl = "cyber/todo/sync"
    static let hcmAutoLoginUrl = "cyber/check/set_token_auto"
    static let ticketUrl = "cyber/ticket/recent"
    static let noticeUrl = "cyber/notice?message="
    static let goAddUrl = "cyber/go/add"
    static let noteAddUrl = "cyber/note"
    static let markMovieWatched = "cyber/movie/url-update"
    static let gptSimpleQuestion = "cyber/gpt/simple-question"
    static let deleteTrackExpress = "cyber/express/delete?no="
    static func addTrackExpress(no:String,name:String?,addToWaitList:Bool = false,rewriteIfExist:Bool = false) -> String {
        let origin = "cyber/express/track?no=\(no)&addToWaitList=\(addToWaitList)&rewriteIfExist=\(rewriteIfExist ? "true" : "false")&note=\(name ?? "📦")"
        return origin.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? origin
    }
    static func trackUrl(lo:Double, la:Double, by:String) -> String {
        return "cyber/location?lo=\(lo)&la=\(la)&by=\(urlencode(by))"
    }
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
    static func urlencode(_ string: String) -> String {
        var allowedQueryParamAndKey = NSCharacterSet.urlQueryAllowed
        allowedQueryParamAndKey.remove(charactersIn: "!*'\"();:@&=+$,/?%#[]% ")
        return string.addingPercentEncoding(withAllowedCharacters: allowedQueryParamAndKey) ?? string
    }
}
