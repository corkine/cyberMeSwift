//
//  Connectivity.swift
//  CyberMe
//
//  Created by Corkine on 2024/9/7.
//

import Foundation
import WatchConnectivity

final class Connectivity: NSObject, ObservableObject {
  
  static let shared = Connectivity()
  
  override private init() {
    super.init()
    #if !os(watchOS)
    guard WCSession.isSupported() else { return }
    #endif
    print("activing watch connectivity support")
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
    if UserDefaults(suiteName: "group.mazhangjing.cyberme.watch")!
      .string(forKey: "cyber-token")?.isEmpty ?? true {
      WCSession.default.sendMessage(
        ["action": "require-token"],
        replyHandler: { data in
          guard let token = data["token"] as? String else {
            print("no token from iPhone responsed")
            return
          }
          print("setting token \(token) from iPhone")
          UserDefaults(suiteName: "group.mazhangjing.cyberme.watch")!
            .setValue(token, forKey: "cyber-token")
          callback()
        },
        errorHandler: { err in
          print("send require token to iPhone error \(err.localizedDescription)")
        })
    } else {
      callback()
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
    print("active done \(String(describing: error?.localizedDescription))")
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

  }
  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any],
               replyHandler: @escaping ([String : Any]) -> Void) {
    guard let action = message["action"] as? String else {
      print("receiving no action, skip handle it")
      return
    }
    #if os(iOS)
    if action == "require-token" {
      let token = UserDefaults(suiteName: "group.mazhangjing.cyberme.share")!
          .string(forKey: "cyber-token") ?? ""
      if !token.isEmpty {
        print("sending token \(token) to watchOS")
        replyHandler(["token": token])
      } else {
        print("iOS have no token!")
        replyHandler(["msg": "no-token"])
      }
    } else {
      replyHandler(["msg": "no-action"])
    }
    #endif
  }
  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {

  }
  
  func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
  }
  
  func session(_ session: WCSession, didReceiveMessageData messageData: Data,
               replyHandler: @escaping (Data) -> Void) {
  }
}
