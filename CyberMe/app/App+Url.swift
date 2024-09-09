//
//  UrlHandler.swift
//  CyberMe
//
//  Created by Corkine on 2024/9/9.
//

import Foundation
import SwiftUI

extension CyberApp {
  
  private func extractParameter(from string: String) -> String? {
      let pattern = "app=([^&]+)"
      guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
          return nil
      }
      guard let match = regex.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count)) else {
          return nil
      }
      let range = match.range(at: 1)
      if let extractedRange = Range(range, in: string) {
          return String(string[extractedRange])
      } else {
          return nil
      }
  }
  
  func handleOpenUrl(_ url: URL) {
      guard url.scheme == "cyberme" else { return }
      let input = url.description
      switch input {
      case _ where input.hasPrefix(CyberUrl.flutterApp):
          let app = extractParameter(from: input) ?? ""
          let fullRoute = "/app/\(app)"
          DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
              AppDelegate.openFlutterApp(route: fullRoute)
          }
          break
      case _ where input.hasPrefix(CyberUrl.checkCardIfNeed):
          if TimeUtil.needCheckCard {
              cyberService.checkCard {
                  Dashboard.updateWidget(inSeconds: 0)
                  cyberService.fetchSummary()
              }
          }
          break
      case _ where input.hasPrefix(CyberUrl.checkCardForce):
          cyberService.checkCard(isForce:true) {
              Dashboard.updateWidget(inSeconds: 0)
              cyberService.fetchSummary()
          }
          break
      case _ where input.hasPrefix(CyberUrl.checkCardHCM):
          if let name = cyberService.settings[Setting.hcmShortcutName], name != "" {
              let url = URL(string: Default.UrlScheme.shortcutUrl(name))!
              //暂时不再触发背景刷新
              //self.tappedCheckCard = true
              UIApplication.shared.open(url)
          } else {
              cyberService.alertInfomation = "请设置云上协同打卡的捷径名称（英文）"
          }
          break
      case _ where input.hasPrefix(CyberUrl.syncTodo):
          cyberService.syncTodo {
              cyberService.fetchSummary()
              Dashboard.updateWidget(inSeconds: 0)
          }
          break
      case _ where input.hasPrefix(CyberUrl.syncWidget):
          Dashboard.updateWidget(inSeconds: 0)
          break
      case _ where input.hasPrefix(CyberUrl.showBodyMass):
          print("calling body mass from widget...")
          cyberService.showBodyMassView(withFetch: true)
          break
      case _ where input.hasPrefix(CyberUrl.uploadHealthData):
          if let name = cyberService.settings[Setting.syncHealthShortcutName],
                 name != "" {
              let url = URL(string: Default.UrlScheme.shortcutUrl(name))!
              UIApplication.shared.open(url)
          } else {
              cyberService.alertInfomation = "请设置健身记录上传的捷径名称（英文）"
          }
          break
      case _ where input.hasPrefix(CyberUrl.showWeather):
          UIApplication.shared.open(URL(string: Default.UrlScheme.caiyunWeather)!)
          break
      case _ where input.hasPrefix(CyberUrl.showMiHome):
          UIApplication.shared.open(URL(string: Default.UrlScheme.miHome)!)
          break
      case _ where input.hasPrefix(CyberUrl.showTodoist):
          UIApplication.shared.open(URL(string: Default.UrlScheme.todoist)!)
          break
      case _ where input.hasPrefix(CyberUrl.show12306):
          UIApplication.shared.open(URL(string: Default.UrlScheme.train12306)!)
          break
      case _ where input.hasPrefix(CyberUrl.showCal):
          UIApplication.shared.open(URL(string: Default.UrlScheme.calApp)!)
          break
      case _ where input.hasPrefix(CyberUrl.showShortcut):
          UIApplication.shared.open(URL(string: Default.UrlScheme.shortcut)!)
          break
      case _ where input.hasPrefix(CyberUrl.goLink):
          print("handle add short link \(url)")
          cyberService.originUrl = url.queryOf("url") ?? ""
          cyberService.showGoView = true
      case _ where input.hasPrefix(CyberUrl.addNoteLink):
          print("handle add note link \(url)")
          cyberService.noteContent = url.queryOf("content") ?? ""
          cyberService.showAddNoteView = true
      case _ where input.hasPrefix(CyberUrl.gptQuestion):
          if let question = url.queryOf("question"),
             let decodeQuestion = question.fromBase64() {
              cyberService.questionContent = "AUTO" + decodeQuestion
              print("handle gpt question \(cyberService.questionContent)")
              cyberService.showGptQuestionView = true
          } else if let translate = url.queryOf("translate"),
                    let decodeTraslate = translate.fromBase64() {
              cyberService.questionContent = "AUTO" + decodeTraslate
              print("handle gpt translate \(cyberService.questionContent)")
              cyberService.showGptTranslateView = true
          }
      case _ where input.hasPrefix(CyberUrl.showLastDiary):
          cyberService.showLastDiary = true
      default:
          print("no handler for \(url)")
      }
  }
}


