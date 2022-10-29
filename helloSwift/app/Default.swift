//
//  Default.swift
//  helloSwift
//
//  Created by Corkine on 2022/10/29.
//

enum Default {
    enum UrlScheme {
        static let alipayHealthApp = "alipay://platformapi/startapp?appId=2021001132656455"
        static let caiyunWeather = "caiyunapppro://weather"
        static func shortcutUrl(_ name: String) -> String { "shortcuts://run-shortcut?name=\(name)" }
    }
    static let groupName = "group.cyberme.share"
}

enum Setting {
    static let syncHealthShortcutName = "syncHealthShortcutName"
    static let hcmShortcutName = "hcmShortcutName"
    static let healthUrlScheme = "healthURL"
}

enum CyberUrl {
    static let checkCardHCM = "cyberme://checkCardHCM"
    static let checkCardIfNeed = "cyberme://checkCardIfNeed"
    static let checkCardForce = "cyberme://checkCardForce"

    static let syncTodo = "cyberme://syncTodo"
    static let syncWidget = "cyberme://syncWidget"

    static let healthCard = "cyberme://healthcard"
    static let uploadHealthData = "cyberme://uploadHealthData"

    static let showBodyMass = "cyberme://showBodyMass"
    static let showWeather = "cyberme://showWeather"
}
