//
//  TicketBusiness.swift
//  CyberMe
//
//  Created by Corkine on 2023/4/24.
//

import Foundation

extension CyberService {
    struct ParsedTicketInfo: Decodable {
        var start: String?
        var end: String?
        var date: String?
        var trainNo: String?
        var siteNo: String?
        var checkNo: String?
    }
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
        var dateParsed: Date? {
            TimeUtil.format(fromStr: date)
        }
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
    
    fileprivate struct ParseTicketInfo: Codable {
        var content: String
        var dry: Bool
    }
    
    func parseTicket(content:String, dry:Bool) async -> [ParsedTicketInfo] {
        let (res, _) = await uploadJSON(api: CyberService.ticketParseUrl,
                                        data: ParseTicketInfo(content: content, dry: dry),
                                        decodeFor: [ParsedTicketInfo].self)
        if let res = res {
            if res.status > 0 {
                return res.data ?? []
            }
        }
        return []
        
    }
    
    fileprivate struct AddTicketInfo: Codable {
        var start: String
        var end: String
        var date: String //yyyyMMdd_HH:mm
        var trainNo: String
        var siteNo: String
        var orderNo: String
        var id: String
        var originData: String
    }
    
    func addTicket(start:String, end:String, date:Date, trainNo:String, siteNo:String,
                   originData: String?,
                   callback: @escaping (SimpleResult?)->Void) {
        let url = "cyber/ticket/add"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HH:mm"
        let info = AddTicketInfo(start: start, end: end,
                                 date: dateFormatter.string(from: date),
                                 trainNo: trainNo, siteNo: siteNo,
                                 orderNo: "",
                                 id: "", originData: originData ?? "由 iOS 手动添加")
        uploadJSON(api: url, data: info) { response, error in
            print("upload add ticket action: data: \(info)," +
                  "response: \(String(describing: response))," +
                  "error: \(error?.localizedDescription ?? "nil")")
            callback(response)
        }
    }
    
    func deleteTicketByDate(date:Date,
                            isCancelled:Bool,
                            callback: @escaping (SimpleResult?)->Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HH:mm"
        let dateFormatted = dateFormatter.string(from: date)
        let url = "cyber/ticket/delete-date/\(dateFormatted)?is-canceled=\(isCancelled)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        loadJSON(from: url, for: SimpleResult.self) { response, error in
            print("delete ticket action: data: \(dateFormatted)," +
                  "response: \(String(describing: response))," +
                  "error: \(error?.localizedDescription ?? "nil")")
            callback(response)
        }
    }
}
