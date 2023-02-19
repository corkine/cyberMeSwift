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
    
    class Setting: ObservableObject {
        typealias CS = CyberService
        let service: CyberService
        @Published var widgetBG: WidgetBackground
        @Published var autoUpdateHealthInfo: Bool
        @Published var slowApi: Bool
        @Published var gpsPeriod: Int
        @Published var username: String
        @Published var password: String = ""
        @Published var hcmShortcutName: String
        init(service: CyberService) {
            self.service = service
            widgetBG = WidgetBackground(rawValue: CyberService.widgetBG)!
            autoUpdateHealthInfo = CyberService.autoUpdateHealthInfo
            slowApi = CyberService.slowApi
            gpsPeriod = CyberService.gpsPeriod
            username = service.settings["username"] ?? ""
            hcmShortcutName = service.settings["hcmShortcutName"] ?? "checkCardHCM"
        }
        func saveToCyber() {
            print("saving to cyber \(self)")
            var needUploadWidget = false
            var needUpdateDashboard = false
            if widgetBG.rawValue != CS.widgetBG {
                CS.widgetBG = widgetBG.rawValue
                needUploadWidget = true
            }
            if autoUpdateHealthInfo != CS.autoUpdateHealthInfo {
                CS.autoUpdateHealthInfo = autoUpdateHealthInfo
            }
            if slowApi != CS.slowApi {
                CS.slowApi = slowApi
            }
            if gpsPeriod != CS.gpsPeriod {
                CS.gpsPeriod = gpsPeriod
            }
            if username != "" && password != "" {
                service.setLoginToken(user: username, pass: password)
                service.settings.updateValue(username, forKey: "username")
                needUploadWidget = true
                needUpdateDashboard = true
            }
            let storedName = service.settings["hcmShortcutName"]
            if storedName == nil || storedName! != hcmShortcutName {
                service.settings.updateValue(hcmShortcutName, forKey: "hcmShortcutName")
            }
            
            if needUpdateDashboard {
                service.fetchSummary()
            }
            if needUploadWidget {
                Dashboard.updateWidget(inSeconds: 0)
            }
        }
    }
    
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
    
    static func ofUserDefault<T>(t: T.Type, key: String, defaultValue: T? = nil) -> T {
        if t == Bool.self {
            return userDefault.bool(forKey: key) as! T
        } else if t == String.self {
            return userDefault.string(forKey: key) as! T
        } else if t == Int.self {
            return userDefault.integer(forKey: key) as! T
        } else {
            return userDefault.object(forKey: key) as! T
        }
    }
    
    // MARK: - FootCount -
    func setBlanceCount(_ count: Int) {
        Self.userDefault.set(count, forKey: "blanceCount")
    }
    
    func getBlanceCount() -> Int {
        Self.userDefault.integer(forKey: "blanceCount")
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
