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
    }
}
