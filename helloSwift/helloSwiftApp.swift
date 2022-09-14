//
//  helloSwiftApp.swift
//  helloSwift
//
//  Created by corkine on 2022/8/31.
//

import SwiftUI

@main
struct helloSwiftApp: App {
    @StateObject private var model:ModelData = ModelData()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
        #if os(macOS)
        .commands {
            LandmarkCommands(model: model)
        }
        #endif
        #if os(watchOS)
        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
        #endif
        #if os(macOS)
        Settings {
            LandmarkSettings()
        }
        #endif
    }
}
