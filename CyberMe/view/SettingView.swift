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
    @EnvironmentObject var service: CyberService
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
    
    init(service: CyberService) {
        setting = CyberService.Setting(service: service)
    }
    
    @ObservedObject var setting: CyberService.Setting
    @State private var showGpsHelp = false
    @State private var showSaveDone = false
    @State private var showLogin = false
    @State private var password = ""
    
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
                SmallAppView()
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
                    Picker("桌面组件背景", selection: $setting.widgetBG) {
                        Text("蓝色").tag(WidgetBackground.blue)
                        Text("桂林阳朔的群山").tag(WidgetBackground.mountain)
                    }
                    .pickerStyle(.segmented)
                }
                // MARK: -- 组件 GPS 定位周期
                Stepper(value: $setting.gpsPeriod, in: 0...30) {
                    Text(setting.gpsPeriod <= 0 ?
                         "未开启组件定期 GPS 定位" :
                            "GPS 定位周期：\(setting.gpsPeriod) 分钟")
                    .onLongPressGesture(perform: {
                        showGpsHelp = true
                    })
                }
                .alert(isPresented: $showGpsHelp) {
                    Alert(title: Text(""),
                          message: Text("""
                                        将在桌面组件自动定时刷新或由主程序进入后台触发刷新时，在 \(setting.gpsPeriod)\
                                        分钟内执行一次 GPS 定位。一般情况下 3 分钟间隔将导致 1 小时定位 5 次左右
                                        """), dismissButton: .default(Text("确定"), action: {
                        showGpsHelp = false
                    }))
                }
                // MARK: -- API 节流
                Group {
                    Toggle("自动更新健身记录", isOn: $setting.autoUpdateHealthInfo)
                    Toggle("请求 API 节流", isOn: $setting.slowApi)
                }
                // MARK: -- HCM 打卡快捷指令名称
                HStack {
                    Text("HCM 快捷指令名称")
                        .fixedSize()
                    Spacer()
                    TextField("", text: $setting.hcmShortcutName)
                        .multilineTextAlignment(.trailing)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                        .frame(width: 140)
                }
                // MARK: -- 更新凭证和设置
                Button("更新用户凭证") {
                    showLogin = true
                }
                .padding(.top, 6)
                .sheet(isPresented: $showLogin) {
                    Form {
                        TextField("用户名", text: $setting.username)
                            .autocorrectionDisabled(true)
                            .autocapitalization(.none)
                        SecureField("密码", text: $setting.password)
                            .textContentType(.password)
                            .autocapitalization(.none)
                    }.onAppear { setting.password = "" }
                }
                // MARL -- 更新设置项
                Button("保存设置") {
                    setting.saveToCyber()
                    showSaveDone = true
                }
                .padding(.top, 5)
                .alert(isPresented: $showSaveDone) {
                    Alert(title: Text(""),
                          message: Text("""
                                        设置项已更新
                                        """), dismissButton: .default(Text("好"), action: {
                        showSaveDone = false
                    }))
                }
                Spacer()
            }
            .padding(25)
            .navigationTitle("设置")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var service = CyberService()
    static var previews: some View {
        ProfileView(service: service)
            .environmentObject(service)
        //SmallAppView(service: service)
    }
}
