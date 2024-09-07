//
//  WatchMeApp.swift
//  WatchMe Watch App
//
//  Created by Corkine on 2024/7/18.
//

import SwiftUI
import WidgetKit

@main
struct WatchMe_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
  @Environment(\.scenePhase) private var scenePhase
  #if DEBUG
  private static let refreshSeconds = 5
  #else
  private static let refreshSeconds = 180
  #endif
  @State var dashboard = Dashboard.demo
  @State var lastUpdate = Date.yesterday
  @State var loading = true
  @State var errMsg = ""
  
  func timeToUpdate() -> Bool {
    let now = Date()
    let needUpdate = now.timeIntervalSince(lastUpdate) >= Double(Self.refreshSeconds)
    if needUpdate {
      lastUpdate = now
      DispatchQueue.main.async {
        loading = true
        errMsg = ""
      }
      return true
    }
    return false
  }
  
  @State var showMenu = false
  
  func updateData() {
    Connectivity.shared.ensureHaveToken {
      Task {
        let (dash, err) = await CyberService.fetchDashboard(location: nil)
        DispatchQueue.main.async {
          if let dash = dash {
            self.dashboard = dash
            loading = false
          } else {
            errMsg = err!.localizedDescription
          }
        }
        WidgetCenter.shared.reloadAllTimelines()
      }
    }
  }
  
  var body: some View {
    ZStack {
      TabContentView(dashboard: $dashboard,
                     callUpdate: .constant(updateData))
        .opacity(loading ? 0.3 : 1)
      if loading {
        if !errMsg.isEmpty {
          VStack {
            Text(errMsg)
            Text("请打开 iPhone 并等待应用同步")
          }
        } else {
          ProgressView {
            Text("正在同步...")
          }
          .frame(width: 100, height: 20)
        }
      }
    }
    .onChange(of: scenePhase) { scene in
      if scene == ScenePhase.active {
        if timeToUpdate() { updateData() }
      }
    }
  }
}
