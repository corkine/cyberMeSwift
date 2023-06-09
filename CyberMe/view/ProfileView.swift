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
import Flutter

struct SmallAppView: View {
    @EnvironmentObject var service: CyberService
    var body: some View {
        FlowLayout(mode: .scrollable,
                   items: [("BullsEye Game", { service.app = .gaming }),
                           ("Landmarks", { service.app = .landing }),
                           ("ReadMe", { service.app = .readme }),
                           ("体重管理", { service.showBodyMassView = true }),
                           ("Flutter Demo", { openFlutterApp() }),
                           ("12306 最近车票", { service.showTicketView = true }),
                           ("GPT 问答", { service.showGptQuestionView = true }),
                           ("GPT 翻译", { service.showGptTranslateView = true }),
                           ("今天日记", { service.showLastDiary = true }),
                           ("短链接跳转", { service.showGoView = true }),
                           ("跨平台笔记", { service.showAddNoteView = true }),
                           ("快递追踪", { service.showExpressTrack = true }),
                           ("故事社", { service.showStoryBook = true }),
                           ("喷嚏图卦", { service.showDapenti = true })],
                   itemSpacing: 10) { (name, call) in
            Button(name) { withAnimation { call() } }
                .padding(.vertical, -5) }
       .padding(.leading, -9)
    }
    
    func openFlutterApp() {
        // Get the RootViewController.
        guard
          let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive && $0 is UIWindowScene }) as? UIWindowScene,
          let window = windowScene.windows.first(where: \.isKeyWindow),
          let rootViewController = window.rootViewController
        else { return }

        // Create the FlutterViewController.
        let flutterViewController = FlutterViewController(
          // Access the Flutter Engine via AppDelegate.
          engine: AppDelegate.flutterEngine,
          nibName: nil,
          bundle: nil)
        flutterViewController.modalPresentationStyle = .overCurrentContext
        flutterViewController.isViewOpaque = false

        rootViewController.present(flutterViewController, animated: true)
      }
}

struct SettingView: View {
    
    init(service: CyberService) {
        setting = CyberService.Setting(service: service)
    }
    
    @ObservedObject var setting: CyberService.Setting
    @State private var showGpsHelp = false
    @State private var password = ""
    @State private var showLogin = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("偏好设置", systemImage: "gear")
                .foregroundColor(.primary)
                .font(.title2)
                .padding(.top, 10)
                .padding(.bottom, 10)
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
                Toggle("锁屏单行组件显示天气", isOn: $setting.lockLineWithWeather)
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
            // MARK: -- Wireguard Base Port
            HStack {
                Text("Wireguard 基础端口")
                    .fixedSize()
                Spacer()
                TextField("", text: $setting.basePort)
                    .multilineTextAlignment(.trailing)
                    .autocorrectionDisabled(true)
                    .keyboardType(.numberPad)
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
                    HStack {
                        Text("服务端点")
                        TextField("endpoint", text: $setting.endpoint)
                            .autocorrectionDisabled(true)
                            .autocapitalization(.none)
                            .foregroundColor(setting.endpoint.starts(with: "https://")
                                             ? .primary : .red)
                            .multilineTextAlignment(.trailing)
                    }
                }.onAppear { setting.password = "" }
            }
            Spacer()
        }
        .onDisappear(perform: setting.saveToCyber)
        .padding(25)
    }
}

struct ProfileView: View {
    
    @EnvironmentObject var service: CyberService
    @State private var showSetting = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 15) {
                // MARK: - 小应用
                Label("小应用", systemImage: "plus.viewfinder")
                    .font(.title2)
                    .padding(.top, 0)
                SmallAppView()
                Button(action: { self.showSetting = true }) {
                    Label("偏好设置", systemImage: "gear")
                        .foregroundColor(.primary)
                        .font(.title2)
                }
                Spacer()
            }
            .sheet(isPresented: $showSetting) {
                SettingView(service: service)
            }
            .padding(25)
            .navigationTitle("个人中心")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var service = CyberService()
    static var previews: some View {
        ProfileView()
            .environmentObject(service)
        //SmallAppView(service: service)
    }
}
