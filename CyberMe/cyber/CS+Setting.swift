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
    // MARK: - Token -
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
    
    func getLoginToken() -> String {
        return Self.userDefault.string(forKey: "cyber-token") ?? ""
    }
    
    func setLoginToken(user:String, pass:String) {
        guard let passToken = genToken(password: pass, expiredSeconds: 60 * 60 * 24 * 10) else {
            print("error to set token for user \(user)")
            return
        }
        let allToken = (user + ":" + passToken).data(using: .utf8)?.base64EncodedString()
        print("gen token \(String(describing: allToken))")
        Self.userDefault.set(allToken, forKey: "cyber-token")
    }
    
    // MARK: - Settings -
    var settings: [String:String] {
        get {
            let res = Self.userDefault.dictionary(forKey: "settings")
            return res as? [String:String] ?? [:]
        }
        set {
            Self.userDefault.set(newValue, forKey: "settings")
        }
    }
    
    // MARK: - FootCount -
    func setFoodCount(_ count: Int) {
        Self.userDefault.set(count, forKey: "foodCount")
    }
    
    func getFoodCount() -> Int {
        Self.userDefault.integer(forKey: "foodCount")
    }
    
    // MARK: - More -
    static var autoUpdateHealthInfo: Bool {
        get {
            userDefault.bool(forKey: "autoUpdateHealthInfo")
        }
        set {
            userDefault.set(newValue, forKey: "autoUpdateHealthInfo")
        }
    }
    
    static var widgetBG: String {
        get {
            userDefault.string(forKey: "widgetBG") ?? "mountain"
        }
        set {
            userDefault.set(newValue, forKey: "widgetBG")
        }
    }
    
    static var slowApi: Bool {
        get {
            userDefault.bool(forKey: "slowApi")
        }
        set {
            userDefault.set(newValue, forKey: "slowApi")
        }
    }
    
    static var gpsPeriod: Int {
        get {
            userDefault.integer(forKey: "gpsPeriod")
        }
        set {
            userDefault.set(newValue < 0 ? 0 : newValue, forKey: "gpsPeriod")
        }
    }
}
