//
//  WebService.swift
//  helloSwift
//
//  Created by corkine on 2022/10/12.
//

import Foundation
import WidgetKit

struct Dashboard: Codable {
    var workStatus:String
    var cardCheck:[String]
    var weatherInfo: String?
    var todo:[Todo]
    var updateAt: Int64
    var needDiaryReport: Bool
    var needPlantWater: Bool
    struct Todo: Codable,Hashable,Identifiable {
        var title:String
        var isFinished:Bool
        var id:String { title }
    }
}

extension Dashboard {
    static var lastUpdate = Date()
    static func updateWidget(inSeconds inSec: Int64) {
        //print("updating widget call")
        let now = Date()
        if now.timeIntervalSince(lastUpdate) > Double(inSec) {
            lastUpdate = now
            print("updating widget action call")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    static let demoTodo = [Todo(title: "提醒事项1", isFinished: true),
                           Todo(title: "提醒事项2", isFinished: false),
                           Todo(title: "提醒事项3", isFinished: true),
                           Todo(title: "提醒事项4", isFinished: false)]
    static let demo = Dashboard(workStatus: "🟡", cardCheck: ["8:20","17:31"], weatherInfo: "",
                                todo: demoTodo, updateAt:
                                    Int64(Date().timeIntervalSince1970), needDiaryReport: false, needPlantWater: true)
    static func failed(error:Error?) -> Dashboard {
        Dashboard(workStatus: "🟡", cardCheck: ["8:20","17:31"], weatherInfo: "请求失败：\(String(describing: error))",
                  todo: demoTodo, updateAt:
                                        Int64(Date().timeIntervalSince1970), needDiaryReport: false, needPlantWater: true)
    }
}

extension CyberService {
    static var dashboard: Dashboard?
    
    static func fetchDashboard(completion:@escaping (Dashboard?, Error?) -> Void) {
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
            request.setValue("Basic \(self.demoToken)", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    if let response = try? JSONDecoder().decode(Dashboard.self, from: data) {
                        print("decoding from \(data)")
                        completion(response, nil)
                    } else {
                        print("decoding from \(data) failed")
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
        request.setValue("Basic \(CyberService.demoToken)", forHTTPHeaderField: "Authorization")
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
