//
//  CS+Health.swift
//  helloSwift
//
//  Created by Corkine on 2022/11/12.
//

import Foundation

struct HMUploadDateData: Codable {
    var time: String
    var activeEnergy: Double
    var basalEnergy: Double
    var standTime: Int
    var exerciseTime: Int
    var mindful: Double
}

extension CyberService {
    func uploadHealth(data: [HMUploadDateData]) {
        uploadJSON(api: CyberService.uploadHealthUrl, data: data) { response, error in
            print("upload health action: data: \(data)," +
                  "response: \(response?.message ?? "nil")," +
                  "error: \(error?.localizedDescription ?? "nil")")
        }
    }
    fileprivate struct UploadBodyMassData: Codable {
        var date: String
        var value: Double
    }
    func uploadBodyMass(value: Double) {
        uploadJSON(api: CyberService.uploadBodyMassUrl,
                   data: UploadBodyMassData(date: TimeUtil.getDate(),
                                            value: value)) { resp, err in
            print("upload body mass: \(value)" +
                  ", resp: \(resp?.message ?? "没有返回消息")" +
                  ", err: \(err?.localizedDescription ?? "没有错误")")
        }
    }
}
