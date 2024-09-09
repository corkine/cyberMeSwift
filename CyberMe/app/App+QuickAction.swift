//
//  App+QuickAction.swift
//  CyberMe
//
//  Created by Corkine on 2024/9/9.
//

import Foundation
import SwiftUI
import UIKit

extension CyberApp {
  func addDynamicQuickActions() {
      UIApplication.shared.shortcutItems = [
          UIApplicationShortcutItem(
              type: "hcmCheckCard",
              localizedTitle: "HCM 打卡",
              localizedSubtitle: nil,
              icon:UIApplicationShortcutIcon(systemImageName: "checkmark.square")
          ),
          UIApplicationShortcutItem(
              type: "flutterApps-dynamic",
              localizedTitle: AppDelegate.lastRoute["name"] ?? "最后应用",
              localizedSubtitle: nil,
              icon:UIApplicationShortcutIcon(systemImageName: "clock")
          ),
          UIApplicationShortcutItem(
              type: "flutterApps",
              localizedTitle: "Flutter 应用",
              localizedSubtitle: nil,
              icon:UIApplicationShortcutIcon(systemImageName: "bird")
          ),
      ]
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
      case "flutterApps-dynamic":
          AppDelegate.openFlutterApp(route: AppDelegate.lastRoute["route"] ?? "/menu")
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
