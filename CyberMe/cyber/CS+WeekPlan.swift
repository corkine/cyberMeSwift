//
//  CS+WeekPlan.swift
//  helloSwift
//
//  Created by Corkine on 2022/11/12.
//
import Foundation

/// 周计划查询项目
struct WeekPlanAddLog: Codable, Hashable {
    var planId: String? //for post
    var name: String
    var progressDelta: Double
    var description: String?
    enum CodingKeys: String, CodingKey {
        case planId
        case name
        case progressDelta = "progress-delta"
        case description
    }
}

extension CyberService {
    /// 添加周计划项目
    func addLog(_ log: WeekPlanAddLog, action:@escaping () -> Void = {}) {
        uploadJSON(api: CyberService.addLogUrl(log.planId!), data: log) { [self] data, err in
            if let data = data {
                if data.status <= 0 {
                    self.alertInfomation = data.message
                } else {
                    action()
                }
            } else if let err = err {
                alertInfomation = "上传日志出错：\(err.localizedDescription)"
            }
        }
    }
    /// 删除周计划项目
    func removeLog(_ itemId: String, _ logId: String, action:@escaping () -> Void = {}) {
        postEmpty(from: CyberService.removeLogUrl(itemId, logId), action: { [self] data, err in
            if let data = data {
                if data.status <= 0 {
                    self.alertInfomation = data.message
                } else {
                    action()
                }
            } else if let err = err {
                alertInfomation = "删除日志出错：\(err.localizedDescription)"
            }
        })
    }
    fileprivate struct EditItem: Codable {
        var id: String
        var name: String
        var description: String
        var progressDelta: Double?
        var update: String?
        var toStart: Bool?
        var toEnd: Bool?
        enum CodingKeys: String, CodingKey {
            case id, name, description,
                 progressDelta = "progress-delta", update,
                 toStart = "to-start", toEnd = "to-end"
        }
    }
    /// 修改周计划项目
    func editItem(id:String, name:String, desc:String,
                  action:@escaping (Error?) -> Void = {_ in }) {
        uploadJSON(api: CyberService.editWeekPlanItemUrl,
                   data: EditItem(id: id, name: name, description: desc, progressDelta: nil)) {
            data, err in
            if let data = data {
                DispatchQueue.main.async {
                    action(data.status <= 0 ? CyberError(message: data.message) : nil)
                }
            } else if let err = err {
                DispatchQueue.main.async {
                    action(err)
                }
            }
        }
    }
    enum EditLogActionType {
        case notMove, toStart, toEnd
    }
    /// 修改周计划日志
    func editLog(itemId:String, id:String, name:String,
                 desc:String, delta: Double?, update: String?,
                 type:EditLogActionType = .notMove,
                 action:@escaping (Error?) -> Void = {_ in }) {
        uploadJSON(api: CyberService.editLogUrl(itemId),
                   data: EditItem(id: id, name: name, description: desc,
                                  progressDelta: delta, update: update,
                                  toStart: type == .toStart ? true : nil,
                                  toEnd: type == .toEnd ? true: nil)) {
            data, err in
            if let data = data {
                DispatchQueue.main.async {
                    action(data.status <= 0 ? CyberError(message: data.message) : nil)
                }
            } else if let err = err {
                DispatchQueue.main.async {
                    action(err)
                }
            }
        }
    }
}

struct CyberError: Error {
    var message: String
}
