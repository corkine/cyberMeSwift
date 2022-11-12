//
//  CS+Health.swift
//  helloSwift
//
//  Created by Corkine on 2022/11/12.
//

import Foundation

struct HMUploadDateData: Codable {
    var time: String
    var activeEnergy: Double
    var basalEnergy: Double
    var standTime: Int
    var exerciseTime: Int
}

extension CyberService {
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
}
