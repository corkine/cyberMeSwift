//
//  CS+Dashboard.swift
//  helloSwift
//
//  Created by Corkine on 2022/11/12.
//

import Foundation
import Combine

enum StoreLevel: Int, CaseIterable {
    case cache, server, local
}

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
        var mindful: Double?
        var goalActive: Double
        var storeLevel: StoreLevel = .cache
        enum CodingKeys: String, CodingKey {
            case active, rest, stand, exercise, mindful, goalActive = "goal-active"
        }
        //        init(from decoder: Decoder) throws {
        //            let c = try decoder.container(keyedBy: CodingKeys.self)
        //            self.active = try c.decode(Double.self, forKey: .active)
        //            self.rest = try c.decode(Double.self, forKey: .rest)
        //            self.stand = try c.decode(Int.self, forKey: .stand)
        //            self.exercise = try? c.decode(Int.self, forKey: .exercise)
        //            self.mindful = try? c.decode(Double.self, forKey: .mindful)
        //            self.goalActive = try c.decode(Double.self, forKey: .goalActive)
        //            self.storeLevel = StoreLevel.server
        //        }
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
        var signInSort: [String] {
            let all = self.SignIn.map(\.timeSimple).sorted()
            return all.count >= 2 ? [all.first!, all.last!] : all
        }
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
    struct WeekPlanItem: Codable, Hashable, Identifiable {
        var id: String
        var name: String
        var category: String
        var progress: Double?
        var description: String?
        var lastUpdate: String?
        var logs: [WeekPlanLog]?
        struct WeekPlanLog: Codable, Hashable, Identifiable {
            var id: String
            var name: String
            var update: String
            var itemId: String?
            var description: String?
            var progressTo: Double?
            var progressFrom: Double?
            var progressDelta: Double?
            enum CodingKeys: String, CodingKey {
                case id, name, update, itemId = "item-id",
                progressTo = "progress-to",
                progressFrom = "progress-from",
                progressDelta = "progress-delta",
                description
            }
        }
        enum CodingKeys: String, CodingKey {
            case id, name, category, progress, description,
            lastUpdate = "last-update", logs
        }
        static let `default` =
        WeekPlanItem(id: "1001", name: "周计划 101", category: "learn", logs: [WeekPlanItem.WeekPlanLog(id: "101", name: "日志 101", update: "2022-01-01", progressDelta: 10),WeekPlanItem.WeekPlanLog(id: "102", name: "日志 102", update: "2022-01-02", progressDelta: 12)])
    }
    var isDemo = false
    var todo: [String:[TodoItem]]
    var movie: [MovieItem]
    var fitness: FitnessItem
    var work: WorkItem
    var blue: BlueItem?
    var clean: CleanItem?
    var weekPlan: [WeekPlanItem]
    enum CodingKeys: String, CodingKey {
        case todo, movie, fitness, work, weekPlan
    }
}

extension ISummary: Decodable {
    init(from decoder: Decoder) throws {
        let f = try decoder.container(keyedBy: CodingKeys.self)
        self.todo = try f.decode([String:[TodoItem]].self, forKey: .todo)
        self.movie = try f.decode([MovieItem].self, forKey: .movie)
        
        //        let fit = try f.nestedContainer(keyedBy: FitnessItem.CodingKeys.self, forKey: .fitness)
        //        let a = try fit.decode(Double.self, forKey: .active)
        //        let r = try fit.decode(Double.self, forKey: .rest)
        //        let s = try fit.decodeIfPresent(Int.self, forKey: .stand)
        //        let e = try fit.decodeIfPresent(Int.self, forKey: .exercise)
        //        let g = try fit.decode(Double.self, forKey: .goalActive)
        //        self.fitness = FitnessItem(active: a, rest: r, stand: s, exercise: e ,goalActive: g)
        self.fitness = try f.decode(FitnessItem.self, forKey: .fitness)
        
        self.work = try f.decode(WorkItem.self, forKey: .work)
        //self.blue = try f.decode(BlueItem.self, forKey: .blue)
        //self.clean = try f.decode(CleanItem.self, forKey: .clean)
        self.weekPlan = try f.decode([WeekPlanItem].self, forKey: .weekPlan)
    }
    static var `default`: ISummary =
    ISummary(isDemo: true,
             todo: ["2022-11-11":[TodoItem.default, TodoItem.default, TodoItem.default]],
             movie: [],
             fitness: FitnessItem(active: 10, rest: 10, goalActive: 100),
             work: WorkItem(NeedWork: true, OffWork: false, NeedMorningCheck: false,
                            SignIn: [
        WorkItem.SignIn(source: "", time: "8:30"),
        WorkItem.SignIn(source: "", time: "18:30")], WorkHour: 3.4),
             blue: BlueItem(UpdateTime: "NotKnown", IsTodayBlue: true, WeekBlueCount: 10, MonthBlueCount: 10, MaxNoBlueDay: 10, Day120BalanceDay: 10, MaxNoBlueDayFirstDay: "2022-01-01", MarvelCount: 30),
             clean: CleanItem(MorningBrushTeeth: true, NightBrushTeeth: true, MorningCleanFace: true, NightCleanFace: true, HabitCountUntilNow: 30, HabitHint: "1+1?", MarvelCount: 40),
             weekPlan: [WeekPlanItem.default, WeekPlanItem.default])
}

extension CyberService {
    func setDashboardDataIfNeed() {
        if self.updateCacheAndNeedAction || !Self.slowApi {
            self.fetchSummary()
            self.refreshAndUploadHealthInfo()
            //        let summaryPublisher = self.fetchSummaryPublisher()?.share()
            //        guard let summaryPublisher = summaryPublisher else { return }
            //        if Self.autoUpdateHealthInfo {
            //            self.refreshAndUploadHealthInfoPublisher()
            //                .zip(summaryPublisher)
            //                .receive(on: DispatchQueue.main)
            //                .sink { _ in
            //                    print("finished fetch zipped dashboard data...")
            //                } receiveValue: { (tuple, summary) in
            //                    let (bm, fit) = tuple
            //                    var summary = summary
            //                    if let fit = fit { summary.fitness = fit }
            //                    self.bodyMass = bm ?? []
            //                    self.summaryData = summary
            //                }
            //                .store(in: &self.subs)
            //        } else {
            //            summaryPublisher
            //                .receive(on: DispatchQueue.main)
            //                .handleEvents(receiveCompletion: {_ in
            //                    print("finished fetch dashboard data(just summary)...")
            //                })
            //                .assign(to: \.summaryData, on: self)
            //                .store(in: &self.subs)
            //        }
        }
    }
    
    func fetchSummaryPublisher() -> AnyPublisher<ISummary,Never>? {
        if syncTodoNow { return nil }
        guard let url = URL(string: CyberService.baseUrl + CyberService.summaryUrl) else {
            print("End point is Invalid")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Basic \(self.token)", forHTTPHeaderField: "Authorization")
        let publisher = PassthroughSubject<ISummary,Never>()
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(CyberResult<ISummary>.self, from: data)
                    if let data = response.data {
                        print("setting summaryData from WebServer: active is \(data.fitness.active)")
                        publisher.send(data)
                        //DispatchQueue.main.async {
                        //    self.summaryData = data
                        //    print("setting summaryData from WebServer: active is \(data.fitness.active)")
                        //}
                    } else {
                        self.alertInfomation = "解码 Summary 数据出错"
                    }
                } catch {
                    print("error decode: \(error)")
                    self.alertInfomation = "解码 Summary 数据出错: \(error.localizedDescription)"
                }
            } else {
                self.alertInfomation = error?.localizedDescription ?? "获取 Summary 数据出错"
            }
        }.resume()
        return publisher
            .first()
            .timeout(.seconds(10), scheduler: DispatchQueue.main)
            .replaceEmpty(with: ISummary.default)
            .eraseToAnyPublisher()
    }
    
    func fetchSummary() {
        if syncTodoNow { return  }
        guard let url = URL(string: CyberService.baseUrl + CyberService.summaryUrl) else {
            print("End point is Invalid")
            return
        }
        var request = URLRequest(url: url)
        request.setValue("Basic \(self.token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(CyberResult<ISummary>.self, from: data)
                    if var data = response.data {
                        DispatchQueue.main.async {
                            data.fitness.storeLevel = .server
                            self.summaryData = data
                        }
                    } else {
                        self.alertInfomation = "解码 Summary 数据出错"
                    }
                } catch {
                    print("error decode: \(error)")
                    self.alertInfomation = "解码 Summary 数据出错: \(error.localizedDescription)"
                }
            } else {
                self.alertInfomation = error?.localizedDescription ?? "获取 Summary 数据出错"
            }
        }.resume()
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
    
    fileprivate struct ForceWork: Encodable {
        var forceWork: Bool
        var cleanForce: Bool
    }
    
    func forceWork(work:Bool = false, clean:Bool = false, completed:@escaping ()->Void = {}) {
        uploadJSON(api: CyberService.forceWorkUrl,
                   data: ForceWork(forceWork: work, cleanForce: clean)) {
            result, error in
            if let result = result, error == nil {
                print("forceWork result: \(result)")
                completed()
            }
            if let error = error {
                print("forceWork error: \(error)")
            }
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
            var isTomorrow = false
            if let date = TimeUtil.format(fromStr: date ?? "") {
                let diff = TimeUtil.diffDay(startDate: Date.today, endDate: date)
                if diff == 1 {
                    isTomorrow = true
                }
                let formatter = DateFormatter()
                formatter.dateFormat = isTomorrow ? "明天 HH:mm" : "yyyy-MM-dd HH:mm"
                let currentTime: String = formatter.string(from: date)
                return currentTime
            }
            return date ?? "未知日期"
        }
    }
    
    func recentTicket(completed:@escaping ()->Void = {}) {
        loadJSON(from: CyberService.ticketUrl, for: CyberResult<[TicketInfo]>.self) { res, err in
            if let res = res {
                let data = res.data ?? []
                self.ticketInfo = data
                completed()
            }
        }
    }
    
}
