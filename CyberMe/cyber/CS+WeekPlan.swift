//
//  CS+WeekPlan.swift
//  helloSwift
//
//  Created by Corkine on 2022/11/12.
//

/// 周计划查询项目
struct WeekPlanAddLog: Codable, Hashable {
    var planId: String? //for post
    var name: String
    var progressDelta: Double
    var description: String?
    enum CodeKey: String, CodingKey {
        case name, progressDelta = "progress-delta",
        description, update
    }
}

extension CyberService {
    /// 添加周计划项目
    func addLog(_ log: WeekPlanAddLog, action:@escaping () -> Void = {}) {
        uploadJSON(api: CyberService.addLogUrl(log.planId!), data: log) { [self] data, err in
            print(data ?? "No Result")
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
}
