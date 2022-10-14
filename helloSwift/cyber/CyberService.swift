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

struct Summary: Codable, Hashable {
    var message:String
    var status:Int
    var data: SummaryData
    struct SummaryData: Codable, Hashable {
        var todo: [String:[TodoItem]]
    }
    struct TodoItem: Codable, Hashable, Identifiable {
        var time:String
        var title:String
        var list:String
        var status:String
        var finish_at:String?
        var create_at:String
        var importance:String
        var id:String {
            title
        }
    }
    static let defaultSummary = Summary(message: "Empty", status: -1, data:
                                            SummaryData(todo: [:]))
}

//@MainActor
class CyberService: ObservableObject {
    @Published var summaryData = Summary.defaultSummary
    @Published var gaming = false
    @Published var landing = false
    @Published var readme = false
    @Published var showAlertResult = false
    var alertInfomation: String?
    @Published var syncTodoNow = false
    
    enum FetchError: Error {
        case badRequest, badJSON, urlParseError
    }

    func fetchSummary() {
        guard let url = URL(string: CyberService.baseUrl + CyberService.summaryUrl) else {
            print("End point is Invalid")
            return
        }
        var request = URLRequest(url: url)
        request.setValue("Basic \(CyberService.demoToken)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let response = try? JSONDecoder().decode(Summary.self, from: data) {
                    DispatchQueue.main.async {
                        self.summaryData = response
                    }
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
    
    struct SimpleMessage: Codable {
        var status: Int
        var message: String
    }
    
    func checkCard(isForce:Bool = false) {
        CyberService.loadJSON(from: isForce ? CyberService.checkCardForce :
                                CyberService.checkCardUrl, for: SimpleMessage.self)
        { [weak self] data, error in
            guard let self = self else { return }
            if let error = error {
                self.showAlertResult = true
                self.alertInfomation = "打卡失败：\(error)"
            }
            if let data = data {
                self.showAlertResult = true
                self.alertInfomation = "\(data.message)"
            }
            Dashboard.updateWidget(inSeconds: 0)
        }
    }
    
    func syncTodo() {
        syncTodoNow = true
        CyberService.loadJSON(from: CyberService.syncTodoUrl, for: SimpleMessage.self)
        { [weak self] data, error in
            guard let self = self else { return }
            if let error = error {
                self.syncTodoNow = false
                DispatchQueue.main.async {
                    self.showAlertResult = true
                    self.alertInfomation = "同步失败：\(error)"
                }
            }
            if let data = data {
                self.syncTodoNow = false
                DispatchQueue.main.async {
                    self.showAlertResult = true
                    self.alertInfomation = "同步结果：\(data.message)"
                }
            }
            Dashboard.updateWidget(inSeconds: 0)
        }
    }
    
    static func loadJSON<T: Codable>(from urlString: String, for type: T.Type,
                                     action:@escaping (T?,Error?) -> Void) {
      guard let url = URL(string: baseUrl + urlString) else { return }
      //print("requesting for \(baseUrl + urlString)")
      var request = URLRequest(url: url)
      request.setValue("Basic \(CyberService.demoToken)", forHTTPHeaderField: "Authorization")
      URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                //print("response is \(String(describing: String(data: data, encoding: .utf8)))")
                if let response = try? JSONDecoder().decode(T.self, from: data) {
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

extension CyberService {
    static let baseUrl = "https://cyber.mazhangjing.com/"
    static let summaryUrl = "cyber/dashboard/summary?day=5"
    static let dashboardUrl = "cyber/dashboard/ioswidget"
    static let checkCardUrl = "cyber/check/now?plainText=false&preferCacheSuccess=true"
    static let checkCardForce = "cyber/check/now?plainText=false&useCache=false"
    static let syncTodoUrl = "cyber/todo/sync"
}
