//
//  CyberNavView.swift
//  helloSwift
//
//  Created by Corkine on 2022/11/5.
//

import SwiftUI
import WidgetKit
import HealthKit

struct CyberNav: View {
    @State var selection: Tab = .today
    @EnvironmentObject var service:CyberService
    enum Tab { case today, eat, setting }
    var body: some View {
        if service.gaming {
            Bullseye().accentColor(.red)
                .transition(.scale)
        } else if service.landing {
            ContentView()
                .environmentObject(ModelData())
                .transition(.scale)
        } else if service.readme {
            ReadMe()
                .environmentObject(Library())
                .transition(.scale)
        } else {
            TabView(selection: $selection) {
                CyberHome()
                    .tabItem {
                        Label("Today", systemImage: "house")
                    }
                    .tag(Tab.today)
                FoodAccountView()
                    .tabItem {
                        Label("Eat & Drink", systemImage: "flame")
                    }
                    .tag(Tab.eat)
                ProfileView()
                    .tabItem {
                        Label("Settings", systemImage: "slider.horizontal.3")
                    }
                    .tag(Tab.setting)
            }
            .accentColor(.blue)
            .transition(.moveAndFade)
        }
    }
}
