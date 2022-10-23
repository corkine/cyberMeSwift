//
//  CS+Token.swift
//  helloSwift
//
//  Created by Corkine on 2022/10/19.
//

import Foundation
import SwiftUI
import UIKit
import CommonCrypto
import CryptoKit

extension CyberService {
    func genToken(password:String, expiredSeconds: Int) -> String? {
        let willExpired = Int(Date().timeIntervalSince1970 * 1000) + Int(expiredSeconds * 1000)
        let first = password + "::" + String(willExpired)
        let firstT = base64EncodedSHA1Hash(from: first) ?? ""
        let final = (firstT + "::" + String(willExpired)).data(using: .utf8)?.base64EncodedString()
        return final
    }

    func base64EncodedSHA1Hash(from: String, using encoding: String.Encoding = .utf8) -> String? {
        guard let data = from.data(using: encoding) else { return nil }
        let hash = Data(Insecure.SHA1.hash(data: data))
        return hash.base64EncodedString()
    }
    
    func getLoginToken() -> String? {
        let res = userDefault.string(forKey: "cyber-token")
        if res == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showLogin = true
            }
        }
        return res
    }
    
    func setLoginToken(user:String, pass:String) {
        guard let passToken = genToken(password: pass, expiredSeconds: 60 * 60 * 24 * 10) else {
            print("error to set token for user \(user)")
            showLogin = true
            return
        }
        let allToken = (user + ":" + passToken).data(using: .utf8)?.base64EncodedString()
        print("gen token \(String(describing: allToken))")
        userDefault.set(allToken, forKey: "cyber-token")
        token = allToken!
        showLogin = false
    }
    
    func clearLoginToken() {
        userDefault.removeObject(forKey: "cyber-token")
        showLogin = true
    }
}