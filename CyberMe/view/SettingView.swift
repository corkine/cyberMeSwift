//
//  SettingView.swift
//  helloSwift
//
//  Created by Corkine on 2022/11/5.
//

import SwiftUI
import WidgetKit
import HealthKit
import SwiftUIFlowLayout

struct SmallAppView: View {
    @ObservedObject var service: CyberService
    @State var showBodyMassSheet: Bool = false
    var body: some View {
        FlowLayout(mode: .scrollable,
                   items: [("BullsEye Game", { service.gaming = true }),
                           ("Landmarks", { service.landing = true }),
                           ("ReadMe", { service.readme = true }),
                           ("体重管理", { showBodyMassSheet = true })],
                   itemSpacing: 10) { (name, call) in
            Button(name) { withAnimation { call() } }
                .padding(.vertical, -5) }
       .padding(.leading, -9)
       .sheet(isPresented: $showBodyMassSheet) {
           BodyMassView()
       }
    }
}

struct ProfileView: View {
    @EnvironmentObject var service:CyberService
    @State private var widgetBG: WidgetBackground = .mountain
    @State private var autoUpldateHealthInfo = false
    @State private var slowApi = false
    @State private var gpsPeriod = 3
    @State private var showGpsHelp = false
    @State private var showLogin = false
    @State private var username = ""
    @State private var password = ""
    @State private var hcmShortcutName = "checkCardHCM"
    
    init() {
        //aviod onChange trigger multi-times
        _widgetBG = State(initialValue: WidgetBackground(rawValue: CyberService.widgetBG)!)
        _autoUpldateHealthInfo = State(initialValue: CyberService.autoUpdateHealthInfo)
        _slowApi = State(initialValue: CyberService.slowApi)
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 15) {
                // MARK: - 小应用
                HStack(alignment: .center) {
                    Text("小应用").font(.title2)
                    Rectangle()
                        .fill(.gray.opacity(0.1))
                        .frame(height: 1)
                }.padding(.top, 0)
                SmallAppView(service: service)
                // MARK: - 设置项
                HStack(alignment: .center) {
                    Text("设置项").font(.title2)
                    Rectangle()
                        .fill(.gray.opacity(0.1))
                        .frame(height: 1)
                }.padding(.top, 10)
                // MARK: -- 组件背景
                HStack(alignment: .center, spacing: 20) {
                    Text("桌面组件背景")
                    Picker("桌面组件背景", selection: $widgetBG) {
                        Text("蓝色").tag(WidgetBackground.blue)
                        Text("桂林阳朔的群山").tag(WidgetBackground.mountain)
                    }
                    .pickerStyle(.segmented)
                }
                // MARK: -- 组件 GPS 定位周期
                Stepper(value: $gpsPeriod, in: 0...30) {
                    Text(gpsPeriod <= 0 ?
                         "未开启组件定期 GPS 定位" :
                         "GPS 定位周期：\(gpsPeriod) 分钟")
                    .onLongPressGesture(perform: {
                        showGpsHelp = true
                    })
                }
                .alert(isPresented: $showGpsHelp) {
                    Alert(title: Text(""),
                          message: Text("""
                                        将在桌面组件自动定时刷新或由主程序进入后台触发刷新时，在 \(gpsPeriod)\
                                        分钟内执行一次 GPS 定位。一般情况下 3 分钟间隔将导致 1 小时定位 5 次左右
                                        """), dismissButton: .default(Text("确定"), action: {
                        showGpsHelp = false
                    }))
                }
                // MARK: -- API 节流
                Group {
                    Toggle("自动更新健身记录", isOn: $autoUpldateHealthInfo)
                    Toggle("请求 API 节流", isOn: $slowApi)
                }
                // MARK: -- 更新凭证和设置
                Button("更新凭证") {
                    showLogin = true
                }
                .padding(.top, 10)
                .sheet(isPresented: $showLogin) {
                    Form {
                        TextField("用户名", text: $username)
                            .autocorrectionDisabled(true)
                            .autocapitalization(.none)
                        SecureField("密码", text: $password)
                            .textContentType(.password)
                            .autocapitalization(.none)
                        HStack {
                            Text("HCM 快捷指令名称")
                                .fixedSize()
                            Divider()
                            TextField("", text: $hcmShortcutName)
                                .autocorrectionDisabled(true)
                                .autocapitalization(.none)
                        }
                    }
                    .onAppear {
                        username = "corkine"
                        password = ""
                        hcmShortcutName = service.settings["hcmShortcutName"] ?? hcmShortcutName
                    }
                    .onDisappear {
                        var needReloadTimeline = false
                        if !password.isEmpty && !username.isEmpty {
                            service.setLoginToken(user: username, pass: password)
                            service.fetchSummary()
                            needReloadTimeline = true
                        }
                        if !hcmShortcutName.isEmpty {
                            if let hs = service.settings["hcmShortcutName"],
                               hs == hcmShortcutName {
                               return
                            }
                            service.settings.updateValue(hcmShortcutName,
                                                         forKey: "hcmShortcutName")
                            needReloadTimeline = true
                        }
                        if needReloadTimeline {
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                    }
                }
                Spacer()
            }
            .padding(25)
            .navigationTitle("设置")
        }
        .onChange(of: widgetBG) {
            CyberService.widgetBG = $0.rawValue
            Dashboard.updateWidget(inSeconds: 1)
        }
        .onChange(of: gpsPeriod) { CyberService.gpsPeriod = $0 }
        .onChange(of: slowApi) { CyberService.slowApi = $0 }
        .onChange(of: autoUpldateHealthInfo) {
            CyberService.autoUpdateHealthInfo = $0
        }
        .onAppear {
            widgetBG = WidgetBackground(rawValue: CyberService.widgetBG)!
            autoUpldateHealthInfo = CyberService.autoUpdateHealthInfo
            slowApi = CyberService.slowApi
            gpsPeriod = CyberService.gpsPeriod
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var service = CyberService()
    static var previews: some View {
        ProfileView().environmentObject(service)
        //SmallAppView(service: service)
    }
}
