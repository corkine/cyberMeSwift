//
//  WidgetService.swift
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
    static let `default` = Ticket(
      orderNo: "ET101",
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
  var list:String
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

struct Limit: Codable {
  var plan: LimitPlan?
  var progress: LimitProgress?
  struct LimitPlan: Codable {
    var id: String
    var name: String
    var startTime: Int64
    var endTime: Int64
    var goalPoint: Int64
    var description: String
  }
  struct LimitProgress: Codable {
    var targetPoints: Int64
    var recordPoints: Int64
    var todayPoints: Int64
    var everyDayPoints: Int64
    var todayOk: Bool
    var percent: Double
  }
}

struct Car: Codable {
  var dumpTime: Int64
  var reportTime: Int64
  var status: CarStatus
  var tripStatus: CarTripStatus
  var loc: CarLoc
  var vin: String
  enum CodingKeys: String, CodingKey {
    case dumpTime = "dump-time"
    case reportTime = "report-time"
    case status
    case tripStatus = "trip-status"
    case loc
    case vin
  }
  struct CarStatus: Codable {
    var oilDistance: Double
    var inspection: Double
    var windows: String
    var parkingBrake: String
    var doors: String
    var speed: Double
    var tyre: String
    var fuelLevel: Double
    var engineType: String
    var lock: String
    var range: Double
    var oilLevel: Double
    enum CodingKeys: String, CodingKey {
      case oilDistance = "oil-distance"
      case inspection
      case windows
      case parkingBrake = "parking-brake"
      case doors
      case speed
      case tyre
      case fuelLevel = "fuel-level"
      case engineType = "engine-type"
      case lock
      case range
      case oilLevel = "oil-level"
    }
  }
  struct CarTripStatus: Codable {
    var tripHours: Double
    var fuel: Double
    var averageFuel: Double
    var mileage: Double
    enum CodingKeys: String, CodingKey {
      case tripHours = "trip-hours"
      case fuel
      case averageFuel = "average-fuel"
      case mileage
    }
  }
  struct CarLoc: Codable {
    var latitude: Int64
    var longitude: Int64
    var headDirection: Int
    var time: String
    var place: String
    enum CodingKeys: String, CodingKey {
      case latitude
      case longitude
      case headDirection = "head-direction"
      case place
      case time
    }
  }
}

struct Dashboard: Codable {
    var workStatus:String
    var offWork:Bool
    var cardCheck:[String]
    var weatherInfo: String?
    var tempInfo: Temp?
    var tempFutureInfo: Temp?
    /// 返回气温和是否是昨天气温的说明
    var tempSmartInfo: (Temp?,Bool) {
      Date().hour >= 19 ? (tempFutureInfo, false) : (tempInfo, true)
    }
    var fitnessInfo: Fitness?
    var todo:[Todo]
    var tickets:[Ticket]
    var updateAt: Int64
    var needDiaryReport: Bool
    var needPlantWater: Bool
    var car: Car?
    var limit: Limit?
}

extension Dashboard {
  static var lastUpdate = Date()
  static func updateWidget(inSeconds inSec: Int64) {
    let now = Date()
    if now.timeIntervalSince(lastUpdate) >= Double(inSec) {
      lastUpdate = now
      print("updating widget action call")
      WidgetCenter.shared.reloadAllTimelines()
      Connectivity.shared.requestReloadWatchWidgetTimeline()
    }
  }
  static let demoTodo = [
     Todo(title: "WWDC watchOS 相关 Keynote 梳理", isFinished: false, create_at: "1", list: "学习"),
     Todo(title: "Apple Developer 会员续期", isFinished: false, create_at: "2", list: "事项"),
     Todo(title: "完成健身环今日打卡", isFinished: true, create_at: "3", list: "事项"),
     Todo(title: "完成专利修改和提交", isFinished: false, create_at: "4", list: "工作"),
     Todo(title: "完成论文的修改", isFinished: false, create_at: "4", list: "工作")]
  static let demoCar =
    Car(dumpTime:1725370208035, reportTime:1725271808000,
      status: Car.CarStatus(oilDistance: 8500, inspection: 28500, windows: "closed", parkingBrake: "active", doors: "closed", speed: 0, tyre: "checked", fuelLevel: 27, engineType: "gasoline", lock: "locked", range: 110, oilLevel: 75), tripStatus: Car.CarTripStatus(tripHours: 50.05, fuel: 109.722, averageFuel: 6.8337, mileage: 1599), loc: Car.CarLoc(latitude: 34696612, longitude: 113680355, headDirection: 175, time: "2024-09-02 18:10:08", place: "河南省郑州市管城回族区贺江路"), vin: "LSVNR60C6R2022322")
  static let demo = Dashboard(
    workStatus: "🟡",
    offWork: true,
    cardCheck: ["8:20","17:31"],
    weatherInfo: "",
    tempInfo: Temp(high: 23.0, low: 15.0, diffHigh: 4.2, diffLow: 3.1),
    todo: demoTodo,
    tickets: [Ticket.default],
    updateAt: Int64(Date().timeIntervalSince1970),
    needDiaryReport: false,
    needPlantWater: true,
    car: demoCar)
  static func failed(error:Error?) -> Dashboard {
      Dashboard(workStatus: "🟡", offWork: true, cardCheck: ["8:20","17:31"], weatherInfo: "请求失败：\(String(describing: error))",
                todo: demoTodo, tickets: [], updateAt:
                  Int64(Date().timeIntervalSince1970), needDiaryReport: false, needPlantWater: true)
  }
}

extension CyberService {
  
  static let iosShareKey = "group.mazhangjing.cyberme.share"
  static let watchShareKey = "group.mazhangjing.cyberme.watch"
  static let tokenKey = "cyber-token"
  
  static var dashboard: Dashboard?
    
  static func sendNotice(msg:String) {
      let token = UserDefaults(suiteName: iosShareKey)!.string(forKey: tokenKey) ?? ""
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
      let token = UserDefaults(suiteName: iosShareKey)!.string(forKey: tokenKey) ?? ""
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
    #if os(watchOS)
    let token = UserDefaults(suiteName: watchShareKey)!.string(forKey: tokenKey) ?? ""
    #else
    let token = UserDefaults(suiteName: iosShareKey)!.string(forKey: tokenKey) ?? ""
    #endif
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
    
  #if os(watchOS)
  let token = UserDefaults(suiteName: CyberService.watchShareKey)!.string(forKey: CyberService.tokenKey) ?? ""
  #else
  let token = UserDefaults(suiteName: CyberService.iosShareKey)!.string(forKey: CyberService.tokenKey) ?? ""
  #endif
    
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
    
  func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
      self.completionHandler!()
      #if os(iOS)
      WidgetCenter.shared.reloadTimelines(ofKind: "CyberMeWidget")
      #else
      WidgetCenter.shared.reloadAllTimelines()
      #endif
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
