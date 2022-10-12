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
    static let baseUrl = "https://cyber.mazhangjing.com/cyber"
    static let demoToken = "Y29ya2luZTphR2xNU1UY3lOekV5T0RFNE1nPT0="
    static let summaryUrl = "/dashboard/summary?day=5"
    static let dashboardUrl = "/dashboard/ioswidget"
    enum FetchError: Error {
        case badRequest, badJSON, urlParseError
    }
//    func fetch<T:Decodable>(_ serviceUrl:String, token:String) async throws -> T  {
//        guard let url = URL(string: baseUrl + serviceUrl) else { throw FetchError.urlParseError }
//        var urlReq = URLRequest(url: url)
//        urlReq.setValue("Basic \(token)", forHTTPHeaderField: "Authorization")
//        let (data, response) = try await
//            URLSession.shared.data123(from: urlReq)
//        guard (response as? HTTPURLResponse)?.statusCode == 200
//        else { throw FetchError.badRequest }
//        return try JSONDecoder().decode(T.self, from: data)
//    }
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
    static func fetchDashboard(completion:@escaping (Dashboard?, Error?) -> Void) {
        guard let url = URL(string: baseUrl + dashboardUrl) else {
            print("End point is Invalid")
            return
        }
        var request = URLRequest(url: url)
        print("requesting for \(request)")
        request.setValue("Basic \(self.demoToken)", forHTTPHeaderField: "Authorization")
        //        let conf = URLSessionConfiguration.background(withIdentifier: "cyber.dashboard")
        //        conf.allowsCellularAccess = true
        //        conf.allowsExpensiveNetworkAccess = true
        //        conf.allowsConstrainedNetworkAccess = true
        //        let session = URLSession(configuration: conf)
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

extension URLSession {
    func data123(from url: URLRequest) async throws -> (Data, URLResponse) {
         try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: url) { data, response, error in
                 guard let data = data, let response = response else {
                     let error = error ?? URLError(.badServerResponse)
                     return continuation.resume(throwing: error)
                 }

                 continuation.resume(returning: (data, response))
             }

             task.resume()
        }
    }
}
