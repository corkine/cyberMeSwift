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
    @State var hcmShortcutName = Setting.hcmShortcutName
    
    var body: some View {
        DashboardView(summary: service.summaryData)
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
            .onAppear { service.setDashboardDataIfNeed() }
    }
}

struct CyberHomeScene_Previews: PreviewProvider {
    static var service = CyberService()
    static var previews: some View {
        //CyberHome()
        CyberHome()
            .environmentObject(service)
        //        ProfileView()
        //            .environmentObject(service)
        //            .onAppear {
        ////                Task {
        ////                    //await service.fetchSummary()
        ////                }
        //            }
//        HStack {
//            Text("Hello World")
//            Spacer()
//            ZStack(alignment:.center) {
//                Color.gray.opacity(0.1)
//                Text("List 1").padding([.leading, .trailing], 8)
//                    .padding([.top, .bottom], 5)
//            }.clipShape(RoundedRectangle(cornerRadius: 15))
//                .fixedSize(horizontal: true, vertical: true)
//            .padding(.trailing, 4)
//        }.padding()
    }
}
