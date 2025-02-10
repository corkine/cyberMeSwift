//
//  CS+Health.swift
//  helloSwift
//
//  Created by Corkine on 2022/11/12.
//

import Foundation
import Combine
import HealthKit

extension CyberService {
  fileprivate struct HMUploadDateData: Codable {
    var time: String
    var activeEnergy: Double
    var basalEnergy: Double
    var standTime: Int
    var exerciseTime: Int
    var mindful: Double
  }
  /// 健身数据上传
  fileprivate func uploadHealth(data: [HMUploadDateData]) {
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
  /// 体重数据上传
  func uploadBodyMass(value: Double) {
    uploadJSON(api: CyberService.uploadBodyMassUrl,
               data: UploadBodyMassData(date: TimeUtil.getDate(),
                                        value: value)) { resp, err in
      print("upload body mass: \(value)" +
            ", resp: \(resp?.message ?? "没有返回消息")" +
            ", err: \(err?.localizedDescription ?? "没有错误")")
    }
  }
  
  func refreshAndUploadHealthInfo() async {
    guard let healthManager = self.healthManager else { return }
    
    do {
      try await healthManager.requestHealthKitPermission()
      
      async let bodyMassDataTask: [HKQuantitySample]? = healthManager.fetchWidgetData()
      async let bodyMassUploadTask: [HealthManager.UploadBodyMass]? = healthManager.fetchBodyMassData()
      
      // 处理 bodyMassData
      if let data = try await bodyMassDataTask {
        await MainActor.run {
          self.bodyMass = healthManager.healthBodyMassData2ChartData(data: data)
        }
      }
      
      // 处理 bodyMassUploadData
      if let data = try await bodyMassUploadTask, !data.isEmpty {
        print("upload bodyMass value: \(data)")
        let res = try await self.uploadJSON(api: CyberService.uploadBodyMassNewUrl, data: data)
      }
      
      healthManager.fetchWorkoutData { sumType in
        self.uploadHealth(data:
                            [HMUploadDateData(time: Date.dateFormatter.string(from: .today),
                                              activeEnergy: sumType.0,
                                              basalEnergy: sumType.1,
                                              standTime: sumType.2,
                                              exerciseTime: sumType.3,
                                              mindful: sumType.4)])
        DispatchQueue.main.async {
          print("updating fitness with healthKit value: \(sumType)")
          var sd = self.summaryData
          sd.fitness = ISummary.FitnessItem(active: sumType.0,
                                            rest: sumType.1,
                                            stand: sumType.2,
                                            exercise: sumType.3,
                                            mindful: sumType.4,
                                            goalActive: 500, storeLevel: .local)
          self.updateSummary(sum: sd)
        }
      }
      
    } catch {
      print("Error refreshing and uploading health info: \(error)")
    }
  }
  
  
}
