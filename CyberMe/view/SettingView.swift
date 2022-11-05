//
//  SettingView.swift
//  helloSwift
//
//  Created by Corkine on 2022/11/5.
//

import SwiftUI
import WidgetKit
import HealthKit

struct ProfileView: View {
    @EnvironmentObject var service:CyberService
    @State private var widgetBG: WidgetBackground = .mountain
    @State private var autoUpldateHealthInfo = false
    @State private var slowApi = false
    @State var showBodyMassSheet = false
    
    init() {
        _widgetBG = State(initialValue: WidgetBackground(rawValue: CyberService.widgetBG)!)
        _autoUpldateHealthInfo = State(initialValue: CyberService.autoUpdateHealthInfo)
        _slowApi = State(initialValue: CyberService.slowApi)
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 15) {
                Text("小应用")
                Button("BullsEye Game") {
                    withAnimation {
                        service.gaming = true
                    }
                }
                Button("Landmarks") {
                    withAnimation {
                        service.landing = true
                    }
                }
                Button("ReadMe") {
                    withAnimation {
                        service.readme = true
                    }
                }
                Button("体重管理") {
                    showBodyMassSheet = true
                }
                Divider()
                HStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        Text("Widget 背景")
                        Picker("Widget 背景", selection: $widgetBG) {
                            Text("蓝色").tag(WidgetBackground.blue)
                            Text("桂林阳朔的群山").tag(WidgetBackground.mountain)
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: widgetBG) { newValue in
                            CyberService.widgetBG = newValue.rawValue
                            Dashboard.updateWidget(inSeconds: 0)
                        }
                    }
                    Spacer()
                }
                Group {
                    Toggle("自动更新健身记录", isOn: $autoUpldateHealthInfo)
                    Toggle("请求 API 节流", isOn: $slowApi)
                }
                .onChange(of: autoUpldateHealthInfo) { newValue in
                    CyberService.autoUpdateHealthInfo = newValue
                }
                .onChange(of: slowApi) { newValue in
                    CyberService.slowApi = newValue
                }
                Group {
                    Button("清空凭证") {
                        service.clearLoginToken()
                    }
                    Button("清空设置") {
                        service.clearSettings()
                    }
                }
                .foregroundColor(.red)
                Spacer()
            }
            .padding(25)
            .navigationTitle("设置")
            .sheet(isPresented: $showBodyMassSheet) {
                BodyMassView()
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var service = CyberService()
    static var previews: some View {
        ProfileView()
            .environmentObject(service)
    }
}
