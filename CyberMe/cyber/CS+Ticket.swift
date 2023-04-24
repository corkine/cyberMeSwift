//
//  TicketBusiness.swift
//  CyberMe
//
//  Created by Corkine on 2023/4/24.
//

import Foundation

extension CyberService {
    struct TicketInfo: Decodable, Identifiable {
        var id: String
        var orderNo: String?
        var start: String?
        var startFull: String? {
            start == nil ? nil : start!.hasSuffix("站") ? start! : start! + "站"
        }
        var end: String?
        var endFull: String? {
            end == nil ? nil : end!.hasSuffix("站") ? end! : end! + "站"
        }
        var date: String?
        var trainNo: String?
        var siteNo: String?
        var siteNoFull: String? {
            siteNo == nil ? nil : siteNo!.hasSuffix("号") ? siteNo! : siteNo! + "号"
        }
        var originData: String?
        var isUncomming:Bool {
            guard let d = TimeUtil.format(fromStr: date) else {
                return true
            }
            return Date().timeIntervalSince1970 < d.timeIntervalSince1970
        }
        var dateFormat:String {
            if let date = TimeUtil.format(fromStr: date ?? "") {
                let diff = TimeUtil.diffDay(startDate: Date.today, endDate: date)
                var format = "yyyy-MM-dd"
                switch diff {
                    case 0: format = "今天"
                    case 1: format = "明天"
                    case 2: format = "后天"
                    case -1: format = "昨天"
                    case -2: format = "前天"
                    default: break
                }
                let formatter = DateFormatter()
                formatter.dateFormat = "\(format) HH:mm"
                let currentTime: String = formatter.string(from: date)
                return currentTime
            }
            return date ?? "未知日期"
        }
    }
    
    func recentTicket(completed:@escaping ([TicketInfo])->Void = {_ in }) {
        loadJSON(from: CyberService.ticketUrl, for: CyberResult<[TicketInfo]>.self) { res, err in
            if let res = res {
                let data = res.data ?? []
                completed(data)
            }
        }
    }
}
