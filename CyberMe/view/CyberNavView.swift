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

    private var badgePosition: CGFloat = 2
    private var tabsCount: CGFloat = 3
    
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
            GeometryReader { geometry in
                ZStack(alignment: .bottomLeading) {
                    // TabView
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
                    
                    // Badge View
                    ZStack {
                        Circle()
                            .foregroundColor(.red)
                        
                        Text("\(service.foodCount)")
                            .foregroundColor(.white)
                            .font(Font.system(size: 12))
                    }
                    .frame(width: 20, height: 20)
                    .offset(x: ( ( 2 * self.badgePosition) - 1 ) * ( geometry.size.width / ( 2 * self.tabsCount ) ) + 7, y: -25)
                    .opacity(service.foodCount == 0 ? 0 : 1)
                }
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}

struct CyberNav_Previews: PreviewProvider {
    static var service = CyberService()
    static var previews: some View {
        CyberNav()
        .environmentObject(service)
    }
}
