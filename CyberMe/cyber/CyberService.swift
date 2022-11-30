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

struct TimeOut: Error { }

let timeout = TimeOut()

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
                let _ = self.fetchSummary()
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
    
    /// DashboardView 请求 Web 服务获取待办事项、本周计划等信息，从 HealthKit 读取数据并展示
    /// （保证 HealthKit 最新数据覆盖 Web 服务的健身和体重数据）
    func setDashboardData() {
        let summaryPublisher = self.fetchSummaryPublisher()?.share()
        guard let summaryPublisher = summaryPublisher else { return }
        if Self.autoUpdateHealthInfo {
            self.refreshAndUploadHealthInfoPublisher()
                .zip(summaryPublisher)
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    print("finished fetch zipped dashboard data...")
                } receiveValue: { (tuple, summary) in
                    let (bm, fit) = tuple
                    var summary = summary
                    if let fit = fit { summary.fitness = fit }
                    self.bodyMass = bm ?? []
                    self.summaryData = summary
                }
                .store(in: &self.subs)
        } else {
            summaryPublisher
                .receive(on: DispatchQueue.main)
                .handleEvents(receiveCompletion: {_ in
                    print("finished fetch dashboard data(just summary)...")
                })
                .assign(to: \.summaryData, on: self)
                .store(in: &self.subs)
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
                    self.summaryData.fitness =
                    ISummary.FitnessItem(active: sumType.0,
                                         rest: sumType.1,
                                         stand: sumType.2,
                                         exercise: sumType.3,
                                         mindful: sumType.4,
                                         goalActive: 500)
                }
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
