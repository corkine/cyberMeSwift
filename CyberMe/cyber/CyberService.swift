//
//  CyberService.swift
//  helloSwift
//
//  Created by corkine on 2022/9/15.
//

import CoreLocation
import Foundation
import Combine
import SwiftUI
import WidgetKit
import HealthKit

struct CyberResult<Item:Decodable>: Decodable {
    var message: String
    var status: Int
    var data: Item?
}

typealias SimpleResult = CyberResult<Int>

//@MainActor
class CyberService: ObservableObject {
    
    var subs = Set<AnyCancellable>()
    
    static let userDefault = UserDefaults(suiteName: "group.cyberme.share")!
    
    @Published var summaryData = ISummary.default
    @Published var gaming = false
    @Published var landing = false
    @Published var readme = false
    
    // MARK: - 食物 -
    @Published var foodCount = 0
    
    // MARK: - 提示 -
    @Published var alertInfomation: String?
    @Published var syncTodoNow = false
    
    // MARK: - 登录 -
    var token: String = "" {
        didSet {
            if token != "" {
                self.fetchSummary()
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
    @Published var showLogin = false
    
    // MARK: - 设置 -
    var settings: [String:String] = [:] {
        didSet {
            print("settings now set to \(settings)")
        }
    }
    @Published var showSettings = false
    
    // MARK: - 体重 -
    @Published var showBodyMassSheet = false
    
    var healthManager: HealthManager?
    
    init() {
        self.token = getLoginToken() ?? ""
        self.settings = getSettings() ?? [:]
        self.foodCount = getFoodCount()
        if HKHealthStore.isHealthDataAvailable() {
            healthManager = HealthManager()
        }
    }
    
    @Published var bodyMass: [Float] = []
    
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
                let updateUI = {
                    DispatchQueue.main.async {
                        print("updating fitness with healthKit value: \(sumType)")
                        self.summaryData.fitness =
                        ISummary.FitnessItem(active: sumType.0,
                                             rest: sumType.1,
                                             stand: sumType.2,
                                             exercise: sumType.3,
                                             mindful: sumType.4,
                                             goalActive: 500)
                    }
                }
                self.$summaryData
                    //如果有来自服务器的旧数据插入，那么新数据等待在其后更新它
                    .first(where: { s in Int(s.fitness.active) < Int(sumType.0) && !s.isDemo })
                    .timeout(.seconds(5), scheduler: DispatchQueue.global(qos: .background))
                    .sink(receiveCompletion: { _ in
                        print("finished waiting for summaryData change")
                    }, receiveValue: { _ in
                        updateUI()
                    })
                    .store(in: &self.subs)
                updateUI()
            }
        }
    }
    
    // MARK: - 节流 -
    var lastUpdate = 0.0
    
    var updateCacheAndNeedAction: Bool {
        let now = Date().timeIntervalSince1970
        let res = now - lastUpdate
        let result =  res > 60
        if result {
            lastUpdate = now
        }
        return result
    }
    
    // MARK: - API -
    enum FetchError: Error {
        case badRequest, badJSON, urlParseError
    }
    
    enum NetworkError: String, Error {
        case invalidURL
        case invalidResponse
        case canNotDecode
    }
    
    func loadJSON<T: Decodable>(from urlString: String, for type: T.Type,
                                action:@escaping (T?,Error?) -> Void) {
        guard let url = URL(string: CyberService.baseUrl + urlString) else {
            print("url \(urlString) not a valid url!")
            return
        }
        //print("requesting for \(CyberService.baseUrl + urlString)")
        var request = URLRequest(url: url)
        request.setValue("Basic \(self.token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                //print("response is \(String(describing: String(data: data, encoding: .utf8)))")
                if let response = try? JSONDecoder().decode(T.self, from: data) {
                    DispatchQueue.main.async {
                        //print("response is \(response)")
                        action(response, nil)
                    }
                    return
                } else {
                    DispatchQueue.main.async {
                        action(nil, NetworkError.canNotDecode)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    action(nil, NetworkError.invalidResponse)
                }
            }
        }.resume()
    }
    
    func uploadJSON<T:Encodable> (api: String, data: T,
                                  action:@escaping (SimpleResult?,Error?) -> Void = {_,_ in }) {
        guard let url = URL(string: CyberService.baseUrl + api) else {
            print("url \(api) not a valid url!")
            return
        }
        var request = URLRequest(url: url)
        request.setValue("Basic \(self.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "Post"
        let jsonData = try! JSONEncoder().encode(data)
        URLSession.shared.uploadTask(with: request, from: jsonData) { data, response, error in
            if let data = data {
                if let response = try? JSONDecoder().decode(SimpleResult.self, from: data) {
                    action(response, error)
                } else {
                    action(nil, error)
                }
            } else {
                action(nil, error)
            }
        }.resume()
    }
    
    func postEmpty(from urlString: String, action:@escaping (SimpleResult?,Error?) -> Void) {
        guard let url = URL(string: CyberService.baseUrl + urlString) else {
            print("url \(urlString) not a valid url!")
            return
        }
        var request = URLRequest(url: url)
        request.setValue("Basic \(self.token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "Post"
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let response = try? JSONDecoder().decode(SimpleResult.self, from: data) {
                    DispatchQueue.main.async {
                        action(response, nil)
                    }
                    return
                } else {
                    DispatchQueue.main.async {
                        action(nil, NetworkError.canNotDecode)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    action(nil, NetworkError.invalidResponse)
                }
            }
        }.resume()
    }
}
