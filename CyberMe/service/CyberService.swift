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

struct SimpleResult: Decodable {
  var message: String
  var status: Int
}

struct TimeOut: Error { }

let timeout = TimeOut()

//@MainActor
class CyberService: ObservableObject {
  
  var subs = Set<AnyCancellable>()
  
  static let userDefault = UserDefaults(suiteName: Default.groupName)!
  
  // MARK: - 面板 -
  @Published var summaryData = ISummary.default
  
  func updateSummary(sum:ISummary) {
    var sum = sum
    if sum.fitness.storeLevel.rawValue < summaryData.fitness.storeLevel.rawValue {
      print("setting summaryData with old storeLevel fitness data detected.")
      sum.fitness = summaryData.fitness
      summaryData = sum
    } else {
      summaryData = sum
    }
  }
  
  // MARK: - 小程序 -
  enum ShowingApp: String, CaseIterable {
    case gaming, landing, readme, mainApp
  }
  @Published var app: ShowingApp = .mainApp
  
  // MARK: - 跳转 -
  enum GoToView: String, CaseIterable {
    case foodBalanceAdd
  }
  @Published var goToView: GoToView?
  
  // MARK: - Sheet -
  @Published var showGoView: Bool = false
  var originUrl = ""
  
  @Published var showAddNoteView: Bool = false
  var noteContent = ""
  
  @Published var showGptQuestionView: Bool = false
  @Published var showGptTranslateView: Bool = false
  var questionContent = ""
  
  @Published var showLastDiary: Bool = false
  
  @Published var showExpressTrack: Bool = false
  var expressTrackFromAutoDetect = false
  
  @Published var showStoryBook: Bool = false
  
  @Published var showTicketView: Bool = false
  
  @Published var showBodyMassView: Bool = false
  
  @Published var showDapenti: Bool = false
  
  var bodyMassShowWithFetch = false
  
  func showBodyMassView(withFetch: Bool = false) {
    showBodyMassView = true
    bodyMassShowWithFetch = withFetch
  }
  
  // MARK: - 平衡 -
  @Published var balanceCount = 0
  
  // MARK: - 提示 -
  @Published var alertInfomation: String?
  
  // MARK: - HealthKit: BodyMass -
  var healthManager: HealthManager?
  
  init() {
    self.balanceCount = getBlanceCount()
    if HKHealthStore.isHealthDataAvailable() {
      healthManager = HealthManager()
    }
  }
  
  @Published var bodyMass: [Float] = []
  
  // MARK: - 节流 -
  var lastUpdate = 0.0
  
  var settingDirty = false
  
  var updateCacheAndNeedAction: Bool {
    let now = Date().timeIntervalSince1970
    let res = now - lastUpdate
    let result =  res > 60
    if result {
      lastUpdate = now
    }
    return result
  }
  
  // MARK: - Sync -
  @Published var syncTodo = false
  
  // MARK: - URLRequest API -
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
    request.setValue("Basic \(self.getLoginToken())", forHTTPHeaderField: "Authorization")
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
    request.setValue("Basic \(self.getLoginToken())", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "Post"
    let jsonData = try! JSONEncoder().encode(data)
    URLSession.shared.uploadTask(with: request, from: jsonData) { data, response, error in
      if let data = data {
        if let response = try? JSONDecoder().decode(SimpleResult.self, from: data) {
          action(response, error)
        } else {
          print("can't decode post result to simpleResult")
          action(nil, error)
        }
      } else {
        action(nil, error)
      }
    }.resume()
  }
  
  func uploadJSON<T: Encodable>(api: String, data: T) async throws -> SimpleResult {
    guard let url = URL(string: CyberService.baseUrl + api) else {
      throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.setValue("Basic \(self.getLoginToken())", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    
    let jsonData = try JSONEncoder().encode(data)
    
    let (responseData, _) = try await URLSession.shared.upload(for: request, from: jsonData)
    
    return try JSONDecoder().decode(SimpleResult.self, from: responseData)
  }
  
  func uploadJSON<T:Encodable,E:Decodable>(api:String, data:T, decodeFor:E.Type) async -> (CyberResult<E>?, Error?) {
    let url = URL(string: CyberService.baseUrl + api)!
    var request = URLRequest(url: url)
    request.setValue("Basic \(self.getLoginToken())", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "Post"
    do {
      let jsonData = try JSONEncoder().encode(data)
      let (data, _) = try await URLSession.shared.upload(for: request, from: jsonData)
      let result = try JSONDecoder().decode(CyberResult<E>.self, from: data)
      return (result, nil)
    } catch {
      return (nil, error)
    }
  }
  
  func postEmpty(from urlString: String, action:@escaping (SimpleResult?,Error?) -> Void) {
    guard let url = URL(string: CyberService.baseUrl + urlString) else {
      print("url \(urlString) not a valid url!")
      return
    }
    var request = URLRequest(url: url)
    request.setValue("Basic \(self.getLoginToken())", forHTTPHeaderField: "Authorization")
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
