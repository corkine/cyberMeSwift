//
//  App+QuickAction.swift
//  CyberMe
//
//  Created by Corkine on 2024/9/9.
//

import Foundation
import SwiftUI
import UIKit

struct QuickActionConstants {
  static let userDefaultsKey = "savedQuickActions"
}

extension UserDefaults {
  func setQuickActions(_ quickActions: [(String, String)]) {
    let data = quickActions.map { ["id": $0.0, "name": $0.1] }
    set(data, forKey: QuickActionConstants.userDefaultsKey)
  }
  
  func getQuickActions() -> [(String, String)] {
    guard let data = array(forKey: QuickActionConstants.userDefaultsKey) as? [[String: String]] else {
      return []
    }
    return data.compactMap { dict in
      guard let id = dict["id"], let name = dict["name"] else { return nil }
      return (id, name)
    }
  }
}

extension CyberApp {
  func addDynamicQuickActions() {
    var shortcutItems = [UIApplicationShortcutItem]()
    
    shortcutItems.append(
      UIApplicationShortcutItem(
        type: "hcmCheckCard",
        localizedTitle: "HCM 打卡",
        localizedSubtitle: nil,
        icon: UIApplicationShortcutIcon(systemImageName: "checkmark.square")
      )
    )
    
    let savedQuickActions = UserDefaults.standard.getQuickActions()
    
    for (id, name) in savedQuickActions.prefix(2) {
      shortcutItems.append(
        UIApplicationShortcutItem(
          type: "flutterApps-user",
          localizedTitle: name,
          localizedSubtitle: nil,
          icon: UIApplicationShortcutIcon(systemImageName: "app"),
          userInfo: ["id": id as NSString]
        )
      )
    }
    
    UIApplication.shared.shortcutItems = shortcutItems
  }
  
  func handleQuickAction() {
    guard let shortcutItem = appDelegate.shortcutItem else { return }
    switch shortcutItem.type {
    case "alert":
      CyberService.userDefault.set(true, forKey: "alert")
      //Dashboard.updateWidget(inSeconds: 0)
      UIApplication.shared.open(URL(string:Default.UrlScheme.shortcutUrl(
        Default.UrlScheme.alertShortcutName))!)
      break
    case "noAlert":
      CyberService.userDefault.set(false, forKey: "alert")
      //Dashboard.updateWidget(inSeconds: 0)
      UIApplication.shared.open(URL(string:Default.UrlScheme.shortcutUrl(
        Default.UrlScheme.noAlertShortcutName))!)
      break
    case "hcmCheckCard":
      if let name = cyberService.settings[Setting.hcmShortcutName], name != "" {
        let url = URL(string: Default.UrlScheme.shortcutUrl(name))!
        UIApplication.shared.open(url)
      }
      break
    case "syncTodo":
      cyberService.syncTodo = true
      cyberService.syncTodo {
        cyberService.syncTodo = false
        cyberService.fetchSummary()
        Dashboard.updateWidget(inSeconds: 0)
      }
      break
    case "checkCardForce":
      cyberService.checkCard(isForce: true) {
        Dashboard.updateWidget(inSeconds: 0)
      }
      break
    case "flutterApps":
      AppDelegate.openFlutterApp(route: "/menu")
      break
    case "flutterApps-user":
      if let id = shortcutItem.userInfo?["id"] as? String {
        AppDelegate.openFlutterApp(route: "/app/\(id)")
      } else {
        AppDelegate.openFlutterApp(route: "/menu")
      }
    case "addLog":
      break
    case "foodBalanceAdd":
      cyberService.goToView = .foodBalanceAdd
      break
    case "bodyMassManage":
      cyberService.showBodyMassView(withFetch: true)
      break
    case "todayDiary":
      cyberService.showLastDiary = true
      break
    default:
      break
    }
    AppDelegate.shortcutItem = nil
  }
}
