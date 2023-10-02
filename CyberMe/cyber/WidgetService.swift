//
//  WebService.swift
//  helloSwift
//
//  Created by corkine on 2022/10/12.
//

import Foundation
import WidgetKit
import CoreLocation

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
            var isTomorrow = false
            if let date = TimeUtil.format(fromStr: date ?? "") {
                let diff = TimeUtil.diffDay(startDate: Date.today, endDate: date)
                if diff == 1 {
                    isTomorrow = true
                }
            }
            let prefix = isTomorrow ? "明天 " : ""
            let date = date == nil ? "" : TimeUtil.formatTo(fromStr: date!) + " "
            let start = start == nil ? "" : start! + " "
            let train = trainNo == nil ? "火车 " : trainNo! + ", "
            let check = checkNo == nil ? "" : ", " + checkNo! + "检票 "
            return "\(prefix)\(date)\(start)\(train)\(siteNo ?? "")\(check)"
        }
        static let `default` = Ticket(orderNo: "ET101",
                                      date: "2023-01-11T17:00:00",
                                      start: "武汉站",
                                      end: "武汉东",
                                      trainNo: "G507",
                                      siteNo: "6车12A号",
                                      checkNo: "14B",
                                      originData: "原始信息",
                                      id: "AQMkADA")
    }
    struct Todo: Codable,Hashable,Identifiable {
        var title:String
        var isFinished:Bool
        var create_at:String
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
        var bodyMassDay30: Double?
        enum CodingKeys: String, CodingKey {
            case active
            case rest
            case mindful
            case goalActive = "goal-active"
            case goalCut = "goal-cut"
            case bodyMassDay30 = "body-mass-day-30"
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
    static let demoTodo = [Todo(title: "吃饭", isFinished: false, create_at: "1"),
                           Todo(title: "睡觉", isFinished: false, create_at: "2"),
                           Todo(title: "打豆豆", isFinished: true, create_at: "3"),
                           Todo(title: "提醒事项", isFinished: false, create_at: "4")]
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
    
    static func sendNotice(msg:String) {
        let token = UserDefaults(suiteName: "group.mazhangjing.cyberme.share")!
            .string(forKey: "cyber-token") ?? ""
        guard let url = URL(string: baseUrl + Self.noticeUrl + Self.urlencode(msg)) else {
            print("End point is Invalid")
            return
        }
        var request = URLRequest(url: url)
        print("requesting for \(request)")
        request.setValue("Basic \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            print("send notice \(String(describing: data)), \(String(describing: response))")
        }.resume()
    }
    
    static func trackUrl(location:CLLocation, by:String) {
        let token = UserDefaults(suiteName: "group.mazhangjing.cyberme.share")!
            .string(forKey: "cyber-token") ?? ""
        guard let url = URL(string: baseUrl + Self.trackUrl(lo: location.coordinate.longitude,
                                                            la: location.coordinate.latitude,
                                                            by: by)) else {
            print("End point is Invalid")
            return
        }
        var request = URLRequest(url: url)
        request.setValue("Basic \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let resp = response {
                print("set track \(String(describing: resp))")
            } else {
                print("set track failed, no response!")
            }
        }.resume()
    }
    
    static func fetchDashboard(location: CLLocation?) async -> (Dashboard?, Error?) {
        let token = UserDefaults(suiteName: "group.mazhangjing.cyberme.share")!
            .string(forKey: "cyber-token") ?? ""
        if dashboard != nil {
            print("fetch dashboard data from bg")
            let oldDash = dashboard
            dashboard = nil
            return (oldDash, nil)
        } else {
            do {
                var urlComponents = URLComponents(string: baseUrl + dashboardUrl)!
                if let location = location {
                    let lat = location.coordinate.latitude
                    let lon = location.coordinate.longitude
                    urlComponents.queryItems = [
                        URLQueryItem(name: "location", value: "\(lat),\(lon)")
                    ]
                }
                var request = URLRequest(url: urlComponents.url!)
                request.setValue("Basic \(token)", forHTTPHeaderField: "Authorization")
                print("requesting for \(request)")
                let (data, _) = try await URLSession.shared.data(for: request)
                return (try JSONDecoder().decode(Dashboard.self, from: data), nil)
            } catch {
                return (nil, error)
            }
        }
    }
}

class BackgroundManager : NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    
    var completionHandler: (() -> Void)? = nil
    
    var token = UserDefaults(suiteName: "group.mazhangjing.cyberme.share")!
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

enum WidgetLocation {
    static var lastUpdate = 0.0
    static var updateCacheAndNeedAction: Bool {
        let now = Date().timeIntervalSince1970
        let res = now - lastUpdate
        let duration = Double(CyberService.gpsPeriod) * 60.0
        if duration == 0 { return false }
        let result =  res > duration
        if result {
            lastUpdate = now
        }
        return result
    }
    static var manager = WidgetLocationManager()
    static func fetchIfTime(handler: @escaping (CLLocation?,Error?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            if updateCacheAndNeedAction {
                print("start fetch location")
                manager.fetchLocation(handler: handler)
            } else {
                print("not spec time, skip fetch location")
            }
        }
    }
    static func fetchIfTime() async -> (CLLocation?, Error?) {
        await withUnsafeContinuation { c in
            if updateCacheAndNeedAction {
                manager.fetchLocation { l, e in
                    c.resume(returning: (l, e))
                }
            }
        }
    }
}

class WidgetLocationManager: NSObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    private var handler: ((CLLocation?,Error?) -> Void)?

    override init() {
        super.init()
        DispatchQueue.main.async {
            self.locationManager = CLLocationManager()
            self.locationManager!.delegate = self
            if self.locationManager!.authorizationStatus == .notDetermined {
                self.locationManager!.requestWhenInUseAuthorization()
            }
        }
    }
    
    func fetchLocation(handler: @escaping (CLLocation?,Error?) -> Void) {
        self.handler = handler
        self.locationManager?.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location fetched \(locations)")
        self.handler!(locations.last!, nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        self.handler!(nil, error)
    }
}
