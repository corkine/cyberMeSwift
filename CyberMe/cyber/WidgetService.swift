//
//  WebService.swift
//  helloSwift
//
//  Created by corkine on 2022/10/12.
//

import Foundation
import WidgetKit

enum WidgetBackground: String, CaseIterable, Identifiable {
    case blue, mountain
    var id: Self { self }
}

struct Dashboard: Codable {
    var workStatus:String
    var offWork:Bool
    var cardCheck:[String]
    var weatherInfo: String?
    var tempInfo: Temp?
    var tempFutureInfo: Temp?
    /// 返回气温和是否是昨天气温的说明
    var tempSmartInfo: (Temp?,Bool) { Date().hour >= 19 ? (tempFutureInfo, false) : (tempInfo, true) }
    var fitnessInfo: Fitness?
    var todo:[Todo]
    var tickets:[Ticket]
    var updateAt: Int64
    var needDiaryReport: Bool
    var needPlantWater: Bool
    struct Ticket: Codable {
        var orderNo:String?
        var date:String?
        var start:String?
        var end:String?
        var trainNo:String?
        var siteNo:String?
        var checkNo:String?
        var originData:String?
        var id:String?
        var isUncomming:Bool {
            guard let d = TimeUtil.format(fromStr: date) else {
                return true
            }
            return Date().timeIntervalSince1970 < d.timeIntervalSince1970
        }
        var description:String {
            let date = date == nil ? "" : TimeUtil.formatTo(fromStr: date!) + " "
            let start = start == nil ? "" : start! + " "
            let train = trainNo == nil ? "火车 " : trainNo! + ", "
            let check = checkNo == nil ? "" : ", " + checkNo! + "检票 "
            return "\(date)\(start)\(train)\(siteNo ?? "")\(check)"
        }
        static let `default` = Ticket(orderNo: "ET101",
                                      date: "2023-01-11T17:00:00",
                                      start: "武汉站",
                                      end: "郑州东",
                                      trainNo: "G507",
                                      siteNo: "6车12A号",
                                      checkNo: "14B",
                                      originData: "原始信息",
                                      id: "AQMkADA")
    }
    struct Todo: Codable,Hashable,Identifiable {
        var title:String
        var isFinished:Bool
        var id:String { title }
    }
    struct Temp: Codable {
        var high: Double
        var low: Double
        var diffHigh: Double?
        var diffLow: Double?
    }
    struct Fitness: Codable {
        var active: Double
        var rest: Double
        var stand: Int?
        var exercise: Int?
        var mindful: Double?
        var goalActive: Double
        var goalCut: Double
        enum CodingKeys: String, CodingKey {
            case active
            case rest
            case goalActive = "goal-active"
            case goalCut = "goal-cut"
        }
    }
}

extension Dashboard {
    static var lastUpdate = Date()
    static func updateWidget(inSeconds inSec: Int64) {
        //print("updating widget call")
        let now = Date()
        if now.timeIntervalSince(lastUpdate) >= Double(inSec) {
            lastUpdate = now
            print("updating widget action call")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    static let demoTodo = [Todo(title: "吃饭", isFinished: false),
                           Todo(title: "睡觉", isFinished: false),
                           Todo(title: "打豆豆", isFinished: true),
                           Todo(title: "提醒事项", isFinished: false)]
    static let demo = Dashboard(workStatus: "🟡", offWork: true, cardCheck: ["8:20","17:31"], weatherInfo: "", tempInfo: Temp(high: 23.0, low: 15.0, diffHigh: 4.2, diffLow: 3.1),
                                todo: demoTodo, tickets: [Ticket.default], updateAt:
                                    Int64(Date().timeIntervalSince1970), needDiaryReport: false, needPlantWater: true)
    static func failed(error:Error?) -> Dashboard {
        Dashboard(workStatus: "🟡", offWork: true, cardCheck: ["8:20","17:31"], weatherInfo: "请求失败：\(String(describing: error))",
                  todo: demoTodo, tickets: [], updateAt:
                    Int64(Date().timeIntervalSince1970), needDiaryReport: false, needPlantWater: true)
    }
}

extension CyberService {
    static var dashboard: Dashboard?
    
    static func fetchDashboard(completion:@escaping (Dashboard?, Error?) -> Void) {
        let token = UserDefaults(suiteName: "group.cyberme.share")!
            .string(forKey: "cyber-token") ?? ""
        if dashboard != nil {
            print("fetch dashboard data from bg")
            completion(dashboard, nil)
            dashboard = nil
        } else {
            guard let url = URL(string: baseUrl + dashboardUrl) else {
                print("End point is Invalid")
                return
            }
            var request = URLRequest(url: url)
            print("requesting for \(request)")
            request.setValue("Basic \(token)", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    if let response = try? JSONDecoder().decode(Dashboard.self, from: data) {
                        //print("decoding from \(data)")
                        completion(response, nil)
                    } else {
                        //print("decoding from \(data) failed")
                        completion(nil, error)
                    }
                }
                if let error = error {
                    completion(nil, error)
                }
            }.resume()
        }
    }
}

class BackgroundManager : NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    
    var completionHandler: (() -> Void)? = nil
    
    var token = UserDefaults(suiteName: "group.cyberme.share")!
        .string(forKey: "cyber-token") ?? ""
    
    lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "CyberMeWidget")
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    func update() {
        guard let url = URL(string: CyberService.baseUrl + CyberService.dashboardUrl) else {
            print("End point is Invalid")
            return
        }
        var request = URLRequest(url: url)
        print("requesting for \(request)")
        request.setValue("Basic \(token)", forHTTPHeaderField: "Authorization")
        let task = urlSession.downloadTask(with: request)
        task.resume()
    }
    
    func urlSession(_ session: URLSession ,downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        print(location)
        if let data = FileManager.default.contents(atPath: location.path) {
            if let response = try? JSONDecoder().decode(Dashboard.self, from: data) {
                print("bg decoding from \(data)")
                CyberService.dashboard = response
            } else {
                print("bg decoding from \(data) failed")
            }
        }
    }
    
    func  urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        self.completionHandler!()
        WidgetCenter.shared.reloadTimelines(ofKind: "CyberMeWidget")
        print("Background update")
    }
}
