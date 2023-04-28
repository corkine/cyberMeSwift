//
//  TicketAddView.swift
//  CyberMe
//
//  Created by Corkine on 2023/4/28.
//

import SwiftUI

struct TicketAddSheetModifier: ViewModifier {
    @State var start: String = ""
    @State var end: String = ""
    @State var trainNo: String = ""
    @State var siteNo: String = ""
    @State var date: Date = Date.today
    @Binding var showSheet: Bool
    var exitCall: (()->Void)?
    @State var showResult = false
    @State var addResult = false
    @State var message = ""
    @EnvironmentObject var service: CyberService
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showSheet) {
                Form {
                    Text("🚝 12306 车票")
                        .font(.system(size: 30))
                        .padding(.top, 10)
                    HStack {
                        Text("起点")
                        TextField("", text: $start)
                            .autocorrectionDisabled()
                        Divider()
                        Text("终点")
                        TextField("", text: $end)
                            .autocorrectionDisabled()
                    }
                    HStack {
                        Text("车次")
                        TextField("", text: $trainNo)
                            .autocorrectionDisabled()
                        Divider()
                        Text("座位")
                        TextField("", text: $siteNo)
                            .autocorrectionDisabled()
                    }
                    DatePicker("发车时间", selection: $date,
                               displayedComponents: [.date, .hourAndMinute])
                    Button("确定") {
                        service.addTicket(start: start, end: end, date: date, trainNo: trainNo, siteNo: siteNo, originData: nil) { res in
                            guard let res = res else { return }
                            addResult = res.status > 0
                            message = res.message
                            showResult = true
                        }
                    }
                    .disabled(start.isEmpty || end.isEmpty || trainNo.isEmpty || siteNo.isEmpty)
                }
                .onAppear {
                    start = ""
                    end = ""
                    date = Date()
                    trainNo = ""
                    siteNo = ""
                    //TODO 后期增加剪贴板解析
                }
                .onDisappear {
                    if let exitCall = exitCall {
                        exitCall()
                    }
                    showSheet = false
                }
                .alert(isPresented: $showResult) {
                    addResult ?
                    Alert(title: Text("添加成功"),
                          message: Text(message),
                          dismissButton: .default(Text("确定"), action: {
                              showResult = false
                              showSheet = false
                          })) :
                    Alert(title: Text("添加失败"),
                          message: Text(message),
                          primaryButton: .destructive(Text("取消"), action: {
                              showResult = false
                              showSheet = false
                          }),
                          secondaryButton: .default(Text("重试"), action: {
                              showResult = false
                    }))
                }
            }
    }
}

struct TicketAddView_Previews: PreviewProvider {
    static var service = CyberService()
    static var previews: some View {
        Text("HELLO")
            .modifier(TicketAddSheetModifier(showSheet: .constant(true)))
            .environmentObject(service)
    }
}
