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
        uploadJSON(api: CyberService.uploadHealthUrl, data: data) { response, error in
            print("""
                  upload health action:
                    data: \(data),
                    response: \(String(describing: response)),
                    error: \(String(describing: error?.localizedDescription))
                  """)
            return
        }
    }
}
