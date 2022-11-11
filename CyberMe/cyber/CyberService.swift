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

struct ISummary: Hashable {
    struct TodoItem: Codable, Hashable, Identifiable {
        var time:String
        var title:String
        var list:String
        var status:String
        var finish_at:String?
        var create_at:String
        var importance:String
        var id:String { title }
        static var `default`: TodoItem = TodoItem(time: "2022-10-13", title: "待办事项 A", list: "🍚 工作", status: "completed", create_at: "2022-10-13", importance: "high")
    }
    struct MovieItem: Codable, Hashable, Identifiable {
        var name:String
        var url:String
        var data:[String]
        var last_update:String
        var id:String { url }
    }
    struct FitnessItem: Codable, Hashable {
        var active: Double
        var rest: Double
        var stand: Int?
        var exercise: Int?
        var goalActive: Double
        enum CodingKeys: String, CodingKey {
            case active, rest, stand, exercise, goalActive = "goal-active"
        }
    }
    struct WorkItem: Codable, Hashable {
        var NeedWork: Bool
        var OffWork: Bool
        var NeedMorningCheck: Bool
        var SignIn: [SignIn]
        var WorkHour: Double?
        var NeedDiaryReport: Bool?
        var NeedWeekLearn: Bool?
        var Policy: WorkItemPolicy?
        struct WorkItemPolicy: Codable, Hashable {
            var exist: Bool
            var pending: Int
            var failed: Int
            var success: Int
        }
        struct SignIn: Codable, Hashable {
            var source: String
            var time: String //2022-11-07T08:28:29
            var timeSimple: String {
                if time.contains("T") {
                    let a = time.split(separator: "T")
                    let b = a[1].split(separator: ":")
                    return "\(b[0]):\(b[1])"
                } else {
                    return time
                }
            }
        }
    }
    struct BlueItem: Codable, Hashable {
        var UpdateTime: String
        var IsTodayBlue: Bool
        var WeekBlueCount: Int
        var MonthBlueCount: Int
        var MaxNoBlueDay: Int
        var Day120BalanceDay: Int
        var MaxNoBlueDayFirstDay: String
        var MarvelCount: Int
    }
    struct CleanItem: Codable, Hashable {
        var MorningBrushTeeth: Bool
        var NightBrushTeeth: Bool
        var MorningCleanFace: Bool
        var NightCleanFace: Bool
        var HabitCountUntilNow: Int
        var HabitHint: String
        var MarvelCount: Int
    }
    struct WeekPlanItem: Codable, Hashable {
        var id: String
        var name: String
        var category: String
        var progress: Double?
        var description: String?
        var lastUpdate: String?
        var logs: [WeekPlanLog]
        struct WeekPlanLog: Codable, Hashable {
            var id: String
            var name: String
            var update: String
            var itemId: String?
            var progressTo: Double?
            var progressFrom: Double?
            var progressDelta: Double?
            enum CodingKeys: String, CodingKey {
                case id, name, update, itemId = "item-id",
                progressTo = "progress-to",
                progressFrom = "progress-from",
                progressDelta = "progress-delta"
            }
        }
        enum CodingKeys: String, CodingKey {
            case id, name, category, progress, description,
            lastUpdate = "last-update", logs
        }
    }
    var todo: [String:[TodoItem]]
    var movie: [MovieItem]
    var fitness: FitnessItem
    var work: WorkItem
    var blue: BlueItem
    var clean: CleanItem
    var weekPlan: [WeekPlanItem]
    enum CodingKeys: String, CodingKey {
        case todo, movie, fitness, work, blue, clean, weekPlan
    }
}

extension ISummary: Decodable {
    init(from decoder: Decoder) throws {
        let f = try decoder.container(keyedBy: CodingKeys.self)
        self.todo = try f.decode([String:[TodoItem]].self, forKey: .todo)
        self.movie = try f.decode([MovieItem].self, forKey: .movie)
        
        let fit = try f.nestedContainer(keyedBy: FitnessItem.CodingKeys.self, forKey: .fitness)
        let a = try fit.decode(Double.self, forKey: .active)
        let r = try fit.decode(Double.self, forKey: .rest)
        let s = try fit.decodeIfPresent(Int.self, forKey: .stand)
        let e = try fit.decodeIfPresent(Int.self, forKey: .exercise)
        let g = try fit.decode(Double.self, forKey: .goalActive)
        //self.fitness = try f.decode(FitnessItem.self, forKey: .fitness)
        self.fitness = FitnessItem(active: a, rest: r, stand: s, exercise: e ,goalActive: g)
        
        self.work = try f.decode(WorkItem.self, forKey: .work)
        self.blue = try f.decode(BlueItem.self, forKey: .blue)
        self.clean = try f.decode(CleanItem.self, forKey: .clean)
        self.weekPlan = try f.decode([WeekPlanItem].self, forKey: .weekPlan)
    }
    static var `default`: ISummary =
    ISummary(todo: ["2022-11-11":[TodoItem.default, TodoItem.default, TodoItem.default]],
             movie: [],
             fitness: FitnessItem(active: 10, rest: 10, goalActive: 100),
             work: WorkItem(NeedWork: true, OffWork: false, NeedMorningCheck: false,
                            SignIn: [
        WorkItem.SignIn(source: "", time: "8:30"),
        WorkItem.SignIn(source: "", time: "18:30")], WorkHour: 3.4),
             blue: BlueItem(UpdateTime: "NotKnown", IsTodayBlue: true, WeekBlueCount: 10, MonthBlueCount: 10, MaxNoBlueDay: 10, Day120BalanceDay: 10, MaxNoBlueDayFirstDay: "2022-01-01", MarvelCount: 30),
             clean: CleanItem(MorningBrushTeeth: true, NightBrushTeeth: true, MorningCleanFace: true, NightCleanFace: true, HabitCountUntilNow: 30, HabitHint: "1+1?", MarvelCount: 40),
    weekPlan: [])
}

struct HMUploadDateData: Codable {
    var time: String
    var activeEnergy: Double
    var basalEnergy: Double
    var standTime: Int
    var exerciseTime: Int
}

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
    
    init() {
        self.token = getLoginToken() ?? ""
        self.settings = getSettings() ?? [:]
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
    
    func fetchSummary() {
        if syncTodoNow { return }
        guard let url = URL(string: CyberService.baseUrl + CyberService.summaryUrl) else {
            print("End point is Invalid")
            return
        }
        var request = URLRequest(url: url)
        request.setValue("Basic \(self.token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let response = try? JSONDecoder().decode(CyberResult<ISummary>.self, from: data),
                   let data = response.data {
                    DispatchQueue.main.async {
                        self.summaryData = data
                    }
                    return
                }
            }
        }.resume()
    }
    
    func uploadHealth(data: [HMUploadDateData]) {
        guard let url = URL(string: CyberService.baseUrl + CyberService.uploadHealthUrl) else {
            return
        }
        var request = URLRequest(url: url)
        request.setValue("Basic \(self.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "Post"
        URLSession.shared.uploadTask(with: request, from: try! JSONEncoder().encode(data)) { data, response, error in
            if let data = data {
                if let response = try? JSONDecoder().decode(SimpleResult.self, from: data) {
                    print("upload health result: \(response)")
                    return
                }
            }
        }.resume()
    }
    
    enum NetworkError: String, Error {
        case invalidURL
        case invalidResponse
        case canNotDecode
    }
    
    func checkCard(isForce:Bool = false,completed:@escaping ()->Void = {}) {
        loadJSON(from: isForce ? CyberService.checkCardForce :
                                CyberService.checkCardUrl, for: SimpleResult.self)
        { [weak self] data, error in
            guard let self = self else { return }
            if let error = error {
                self.alertInfomation = "打卡失败：\(error)"
            }
            if let data = data {
                self.alertInfomation = "\(data.message)"
            }
            completed()
        }
    }
    
    func syncTodo(completed:@escaping ()->Void = {}) {
        syncTodoNow = true
        loadJSON(from: CyberService.syncTodoUrl, for: SimpleResult.self)
        { [weak self] data, error in
            guard let self = self else { return }
            if let error = error {
                self.syncTodoNow = false
                DispatchQueue.main.async {
                    self.alertInfomation = "同步失败：\(error)"
                }
            }
            if let _ = data {
                self.syncTodoNow = false
            }
            completed()
        }
    }
    
    func loadJSON<T: Decodable>(from urlString: String, for type: T.Type,
                              action:@escaping (T?,Error?) -> Void) {
        guard let url = URL(string: CyberService.baseUrl + urlString) else { return }
        //print("requesting for \(baseUrl + urlString)")
        var request = URLRequest(url: url)
        request.setValue("Basic \(self.token)", forHTTPHeaderField: "Authorization")
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
}
