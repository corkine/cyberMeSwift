//
//  CyberHomeScene.swift
//  helloSwift
//
//  Created by corkine on 2022/9/15.
//

import SwiftUI
import WidgetKit
import HealthKit

struct CyberHome: View {
    @EnvironmentObject var service:CyberService
    @State var username:String = "corkine"
    @State var password:String = ""
    @State var showLogin = false
    @State var showAlert = false
    @State var healthURL = Setting.healthUrlScheme
    @State var hcmShortcutName = Setting.hcmShortcutName
    @State var syncHealthShortcutName = Setting.syncHealthShortcutName
    
    var healthManager: HealthManager?
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthManager = HealthManager()
        }
    }
    
    var body: some View {
        ScrollView(.vertical,showsIndicators:false) {
            HStack(alignment:.top) {
                VStack(alignment:.leading,spacing: 10) {
                    Label("我的一天", systemImage: "calendar")
                        .font(.title2)
                        .foregroundColor(Color.blue)
                    MyToDo(todo:$service.summaryData.data.todo)
                        .padding(.bottom, 9)
                        .padding(.top, 3)
                    Label("我的日记", systemImage: "book.closed")
                        .font(.title2)
                        .foregroundColor(Color.blue)
                    
                    Label("本周计划", systemImage: "books.vertical")
                        .font(.title2)
                        .foregroundColor(Color.blue)
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.leading, 15)
                //.navigationTitle("我的一天")
                .navigationTitle("\(getWeedayFromeDate(date:Date()))")
                Spacer()
            }
            .onReceive(service.$alertInfomation, perform: { info in
                if info != nil { showAlert = true }
            })
            .alert(isPresented: $showAlert) {
                Alert(title: Text(""),
                      message: Text(service.alertInfomation ?? "无结果"),
                      dismissButton: .default(Text("确定"), action: {
                    service.alertInfomation = nil
                }))
            }
            .fullScreenCover(isPresented: $service.syncTodoNow) {
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(.circular)
                    Text("正在同步，请稍后")
                }
            }
            .sheet(isPresented: $service.showLogin) {
                Form {
                    TextField("用户名", text: $username)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                    SecureField("密码", text: $password)
                        .textContentType(.password)
                        .autocapitalization(.none)
                    Button("确定") {
                        service.setLoginToken(user: username, pass: password)
                    }
                }
            }
            .sheet(isPresented: $service.showSettings) {
                Form {
                    TextField("健康码 URLScheme", text: $healthURL)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                    TextField("HCM 打卡快捷指令名称", text: $hcmShortcutName)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                    TextField("锻炼信息同步快捷指令名称", text: $syncHealthShortcutName)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                    Button("确定") {
                        service.setSettings(["healthURL":healthURL,
                                             "hcmShortcutName":hcmShortcutName,
                                             "syncHealthShortcutName":syncHealthShortcutName])
                    }
                }
            }
            .sheet(isPresented: $service.showBodyMassSheet) {
                BodyMassView()
            }
        }
        .onAppear {
            if service.updateCacheAndNeedAction || !CyberService.slowApi {
                service.fetchSummary()
                if CyberService.autoUpdateHealthInfo {
                    healthManager?.withPermission {
                        healthManager?.fetchWorkoutData(completed: { sumType in
                            service.uploadHealth(data:
                                                    [HMUploadDateData(time: Date.dateFormatter.string(from: .today),
                                                                      activeEnergy: sumType.0,
                                                                      basalEnergy: sumType.1,
                                                                      standTime: sumType.2,
                                                                      exerciseTime: sumType.3)])
                        })
                    }
                }
            }
        }
        
    }
}

//struct CyberHomeScene_Previews: PreviewProvider {
//    static var service = CyberService()
//    static var previews: some View {
//        //CyberHome()
//        //CyberHome()
//        ProfileView()
//            .environmentObject(service)
//            .onAppear {
////                Task {
////                    //await service.fetchSummary()
////                }
//            }
////        HStack {
////            Text("Hello World")
////            Spacer()
////            ZStack(alignment:.center) {
////                Color.gray.opacity(0.1)
////                Text("List 1").padding([.leading, .trailing], 8)
////                    .padding([.top, .bottom], 5)
////            }.clipShape(RoundedRectangle(cornerRadius: 15))
////                .fixedSize(horizontal: true, vertical: true)
////            .padding(.trailing, 4)
////        }.padding()
//    }
//}

func getDate(off:Int = 0) -> String {
    var dayComponent = DateComponents()
    dayComponent.day = off
    let calendar = Calendar.current
    let day = calendar.date(byAdding: dayComponent, to: Date())!
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let currentTime: String = formatter.string(from: day)
    return currentTime
}

func getWeedayFromeDate(date: Date) -> String {
    let calendar = Calendar.current
    let dateComponets = calendar.dateComponents([Calendar.Component.year,Calendar.Component.month,Calendar.Component.weekday,Calendar.Component.day], from: date)
    //获取到今天是周几 1(星期天) 2(星期一) 3(星期二) 4(星期三) 5(星期四) 6(星期五) 7(星期六)
    let weekDay = dateComponets.weekday
    switch weekDay {
    case 1:
        return "周日"
    case 2:
        return "周一"
    case 3:
        return "周二"
    case 4:
        return "周三"
    case 5:
        return "周四"
    case 6:
        return "周五"
    case 7:
        return "周六"
    default:
        return ""
    }
}
