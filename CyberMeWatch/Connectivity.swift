//
//  Connectivity.swift
//  CyberMe
//
//  Created by Corkine on 2024/9/7.
//

import Foundation
import WatchConnectivity
import WidgetKit

final class Connectivity: NSObject, ObservableObject {
  
  @Published var activated: Bool = false
  
  static let shared = Connectivity()
  
  override private init() {
    super.init()
    #if !os(watchOS)
    guard WCSession.isSupported() else { return }
    #endif
    WCSession.default.delegate = self
    WCSession.default.activate()
  }
  
  private func canSendToPeer() -> Bool {
    guard WCSession.default.activationState == .activated else { return false }
    #if os(watchOS)
    guard WCSession.default.isCompanionAppInstalled else { return false }
    #else
    guard WCSession.default.isWatchAppInstalled else { return false }
    #endif
    return true
  }
  
  /// watchOS 检查 Token，如果不存在，要求发送
  public func ensureHaveToken(callback: @escaping () -> Void) {
    #if os(watchOS)
    if UserDefaults(suiteName: CyberService.watchShareKey)!
      .string(forKey: CyberService.tokenKey)?.isEmpty ?? true {
      if canSendToPeer() {
        WCSession.default.sendMessage(
          ["action": "require-token"],
          replyHandler: { data in
            guard let token = data["token"] as? String else {
              print("no token from iPhone responsed")
              return
            }
            print("setting token \(token) from iPhone")
            UserDefaults(suiteName: CyberService.watchShareKey)!
              .setValue(token, forKey: CyberService.tokenKey)
            callback()
          },
          errorHandler: { err in
            print("send require token to iPhone error \(err.localizedDescription)")
          })
      } else {
        print("can't send to peer")
      }
    } else {
      callback()
    }
    #endif
  }
  
  public func requestReloadWatchWidgetTimeline() {
    #if os(iOS)
    if canSendToPeer() {
      print("sending reload timeline...")
      try? WCSession.default.updateApplicationContext(["action": "reload-timeline"])
    } else {
      print("can't send to peer")
    }
    #endif
  }
  
  typealias OptionalHandler<T> = ((T) -> Void)?

  private func optionalMainQueueDispatch<T>(handler: OptionalHandler<T>) ->
  OptionalHandler<T> {
    guard let handler = handler else { return nil }
    return { item in Task { @MainActor in handler(item) } }
  }
}

extension Connectivity: WCSessionDelegate {
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    print("active done \(String(describing: error?.localizedDescription)), status \(WCSession.default.activationState)")
    if activationState == .activated {
      self.activated = true
    }
  }
  
  #if os(iOS)
  func sessionDidBecomeInactive(_ session: WCSession) {
  }
  func sessionDidDeactivate(_ session: WCSession) {
    WCSession.default.activate()
  }
  #endif
  
  func session(_ session: WCSession,
              didReceiveUserInfo userInfo: [String : Any] = [:]) {

  }
  
  func session(_ session: WCSession,
               didReceiveApplicationContext applicationContext: [String : Any]) {
    guard let action = applicationContext["action"] as? String else {
      print("no handler to handle applicationContext: \(applicationContext)")
      return
    }
    #if os(watchOS)
    if action == "reload-timeline" {
      print("watchOS reload all timeliens called")
      WidgetCenter.shared.reloadAllTimelines()
      return
    }
    #endif
  }
  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any],
               replyHandler: @escaping ([String : Any]) -> Void) {
    guard let action = message["action"] as? String else {
      print("receiving no action, skip handle it")
      replyHandler(["msg": "no-action"])
      return
    }
    #if os(iOS)
    if action == "require-token" {
      let token = UserDefaults(suiteName: CyberService.iosShareKey)!
        .string(forKey: CyberService.tokenKey) ?? ""
      if !token.isEmpty {
        print("sending token \(token) to watchOS")
        replyHandler(["token": token])
      } else {
        print("iOS have no token!")
        replyHandler(["msg": "no-token"])
      }
      return
    }
    #else
    #endif
    replyHandler(["msg": "not-impl"])
  }
  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    print("receiving \(message), skip it")
  }
  
  func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
  }
  
  func session(_ session: WCSession, didReceiveMessageData messageData: Data,
               replyHandler: @escaping (Data) -> Void) {
  }
}
