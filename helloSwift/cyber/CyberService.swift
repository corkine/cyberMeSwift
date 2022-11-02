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

struct HMUploadDateData: Codable {
    var time: String
    var activeEnergy: Double
    var basalEnergy: Double
    var standTime: Int
    var exerciseTime: Int
}

//@MainActor
class CyberService: ObservableObject {
    
    var subs = Set<AnyCancellable>()
    
    let userDefault = UserDefaults(suiteName: "group.cyberme.share")!
    
    @Published var summaryData = Summary.defaultSummary
    @Published var gaming = false
    @Published var landing = false
    @Published var readme = false
    
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
    
    // MARK: - API -
    enum FetchError: Error {
        case badRequest, badJSON, urlParseError
    }
    
    func fetchSummary() {
        if syncTodoNow { return }
        print("fetching summary")
        guard let url = URL(string: CyberService.baseUrl + CyberService.summaryUrl) else {
            print("End point is Invalid")
            return
        }
        var request = URLRequest(url: url)
        request.setValue("Basic \(self.token)", forHTTPHeaderField: "Authorization")
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
                if let response = try? JSONDecoder().decode(SimpleMessage.self, from: data) {
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
    
    struct SimpleMessage: Codable {
        var status: Int
        var message: String
    }
    
    func checkCard(isForce:Bool = false,completed:@escaping ()->Void = {}) {
        loadJSON(from: isForce ? CyberService.checkCardForce :
                                CyberService.checkCardUrl, for: SimpleMessage.self)
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
        print("syncing todo")
        syncTodoNow = true
        loadJSON(from: CyberService.syncTodoUrl, for: SimpleMessage.self)
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
    
    func loadJSON<T: Codable>(from urlString: String, for type: T.Type,
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
