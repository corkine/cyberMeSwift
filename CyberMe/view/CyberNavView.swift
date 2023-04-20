//
//  CyberNavView.swift
//  helloSwift
//
//  Created by Corkine on 2022/11/5.
//

import SwiftUI
import WidgetKit
import HealthKit

struct MainApp: View {
    
    enum Tab { case dashboard, balance, profile }
    
    @EnvironmentObject var service: CyberService
    @State var selection: Tab = .dashboard
    
    private var badgePosition: CGFloat = 2
    private var tabsCount: CGFloat = 3

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                // TabView
                TabView(selection: $selection) {
                    CyberHome()
                        .modifier(ShortLinkSheetModifier(showSheet: $service.showGoView))
                        .modifier(LastNoteSheetModifier(showSheet: $service.showAddNoteView))
                        .tabItem {
                            Label("Today", systemImage: "house")
                        }
                        .tag(Tab.dashboard)
                    FoodBalanceView()
                        .tabItem {
                            Label("Balance", systemImage: "repeat")
                        }
                        .tag(Tab.balance)
                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person")
                        }
                        .tag(Tab.profile)
                }
                .onReceive(service.$goToView, perform: { v in
                    if let v = v, v == .foodBalanceAdd {
                        selection = .balance
                    }
                })
                .accentColor(.blue)
                .transition(.moveAndFade)
                
                // Badge View
                ZStack {
                    Circle()
                        .foregroundColor(.red)
                    
                    Text("\(service.balanceCount)")
                        .foregroundColor(.white)
                        .font(Font.system(size: 12))
                }
                .frame(width: 20, height: 20)
                .offset(x: ( ( 2 * self.badgePosition) - 1 ) * ( geometry.size.width / ( 2 * self.tabsCount ) ) + 7, y: -25)
                .opacity(service.balanceCount == 0 ? 0 : 1)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct CyberNav: View {
    
    @EnvironmentObject var service: CyberService
    
    var body: some View {
        switch service.app {
        case .gaming:
            Bullseye().accentColor(.red)
                .transition(.scale)
        case .landing:
            ContentView()
                .environmentObject(ModelData())
                .transition(.scale)
        case .readme:
            ReadMe()
                .environmentObject(Library())
                .transition(.scale)
        default:
            MainApp()
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
