//
//  CS+Health.swift
//  helloSwift
//
//  Created by Corkine on 2022/11/12.
//

import Foundation
import Combine

struct HMUploadDateData: Codable {
    var time: String
    var activeEnergy: Double
    var basalEnergy: Double
    var standTime: Int
    var exerciseTime: Int
    var mindful: Double
}

extension CyberService {
    fileprivate struct UploadAddShort: Codable {
        var keyword: String
        var redirectURL: String
        var note: String = "由 CyberMe iOS 添加"
        var override: Bool = false
    }
    func addShortLink(keyword:String, originUrl:String, focus: Bool,
                      callback: @escaping (Bool) -> Void = { _ in }) {
        let data = UploadAddShort(keyword: keyword, redirectURL: originUrl, override: focus)
        uploadJSON(api: CyberService.goAddUrl, data: data) {
            response, error in
            print("upload create shortlink action: data: \(data)," +
                  "response: \(response.debugDescription)," +
                  "error: \(error?.localizedDescription ?? "nil")")
            callback(response?.status ?? -1 > 0)
        }
    }
    fileprivate struct UploadNote: Codable {
        var content: String
        var from: String = "由 CyberMe iOS 添加"
        var liveSeconds: Int
        var id: Int?
    }
    func addNote(content:String,
                 id: Int? = nil,
                 liveSeconds: Int = 60 * 60,
                 callback: @escaping (Bool) -> Void = { _ in }) {
        let data = UploadNote(content: content, liveSeconds: liveSeconds, id: id)
        uploadJSON(api: CyberService.noteAddUrl, data: data) {
            response, error in
            print("upload create note action: data: \(data)," +
                  "response: \(response.debugDescription)," +
                  "error: \(error?.localizedDescription ?? "nil")")
            callback(response?.status ?? -1 > 0)
        }
    }
    func addTrackExpress(no:String,
                         overwrite:Bool,
                         name:String?,
                         callback: @escaping (SimpleResult?) -> Void = { _ in }) {
        let url = CyberService.addTrackExpress(no: no, name: name, rewriteIfExist: overwrite)
        loadJSON(from: url, for: SimpleResult.self) { response, error in
            print("upload add track express action: \(url)," +
                  "response: \(response.debugDescription)," +
                  "error: \(error?.localizedDescription ?? "nil")")
            callback(response)
        }
    }
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
    
    func refreshAndUploadHealthInfoPublisher() -> AnyPublisher<([Float]?,ISummary.FitnessItem?),Never> {
        let publisher = PassthroughSubject<([Float]?,ISummary.FitnessItem?),TimeOut>()
        self.healthManager?.withPermission {
            self.healthManager?.fetchWidgetData { data, err in
                if let data = data {
                    publisher.send((self.healthManager!.healthBodyMassData2ChartData(data: data), nil))
                } else {
                    print("not fetched widget data")
                    publisher.send((nil, nil))
                }
            }
            self.healthManager?.fetchWorkoutData { sumType in
                self.uploadHealth(data:
                                    [HMUploadDateData(time: Date.dateFormatter.string(from: .today),
                                                      activeEnergy: sumType.0,
                                                      basalEnergy: sumType.1,
                                                      standTime: sumType.2,
                                                      exerciseTime: sumType.3,
                                                      mindful: sumType.4)])
                print("updating fitness with healthKit value: \(sumType)")
                publisher.send((nil,
                    ISummary.FitnessItem(active: sumType.0,
                                         rest: sumType.1,
                                         stand: sumType.2,
                                         exercise: sumType.3,
                                         mindful: sumType.4,
                                         goalActive: 500)))
            }
        }
        return publisher
                .collect(2)
                .timeout(.seconds(5), scheduler: DispatchQueue.global(qos: .background), customError: { timeout })
                .map { items in
                    let bodyMass = items.compactMap(\.0).first
                    let fitnessItem = items.compactMap(\.1).first
                    return (bodyMass, fitnessItem)
                }
                .replaceError(with: (nil, nil))
                .first()
                .eraseToAnyPublisher()
    }
    
    func refreshAndUploadHealthInfo() {
        self.healthManager?.withPermission {
            self.healthManager?.fetchWidgetData { data, err in
                if let data = data {
                    DispatchQueue.main.async {
                        self.bodyMass = self.healthManager!.healthBodyMassData2ChartData(data: data)
                    }
                } else {
                    print("not fetched data")
                }
            }
            self.healthManager?.fetchWorkoutData { sumType in
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
        }
    }
}
