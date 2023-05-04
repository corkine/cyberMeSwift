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
                    if let paste = UIPasteboard.general.string {
                        if let genData = (parseText(paste) ?? parseTextByMailFormat(paste)) {
                            start = genData.start
                            end = genData.end
                            trainNo = genData.trainNo
                            siteNo = genData.siteNo
                            let calendar = Calendar.current
                            var dateComponents = DateComponents()
                            dateComponents.year = genData.year
                            dateComponents.month = genData.month
                            dateComponents.day = genData.day
                            dateComponents.hour = genData.hour
                            dateComponents.minute = genData.minute
                            if let date = calendar.date(from: dateComponents) {
                                self.date = date
                            }
                        }
                    }
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
    
    fileprivate struct ParsedData {
        var start: String
        var end: String
        var year: Int
        var month: Int
        var day: Int
        var hour: Int
        var minute: Int
        var trainNo: String
        var siteNo: String
    }
    
    fileprivate func parseText(_ text: String) -> ParsedData? {
        let regex = try! NSRegularExpression(pattern: "(\\d{4})年(\\d{2})月(\\d{2})日(\\d{2}):(\\d{2})开，(.*?)-(.*?)，(.*?)次列车,(.*?)，", options: [])
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
        guard let match = matches.first else {
            return nil
        }
        guard let year = Int((text as NSString).substring(with: match.range(at: 1))),
        let month = Int((text as NSString).substring(with: match.range(at: 2))),
        let day = Int((text as NSString).substring(with: match.range(at: 3))),
        let hour = Int((text as NSString).substring(with: match.range(at: 4))),
        let minute = Int((text as NSString).substring(with: match.range(at: 5)))
        else { return nil }
        var parsedData = ParsedData(start: "", end: "", year: year, month: month, day: day, hour: hour, minute: minute, trainNo: "", siteNo: "")
        parsedData.start = (text as NSString).substring(with: match.range(at: 6))
        parsedData.end = (text as NSString).substring(with: match.range(at: 7))
        parsedData.trainNo = (text as NSString).substring(with: match.range(at: 8))
        parsedData.siteNo = (text as NSString).substring(with: match.range(at: 9))
        return parsedData
    }
    
    fileprivate func parseTextByMailFormat(_ text: String) -> ParsedData? {
        let regex = try! NSRegularExpression(pattern: "(\\d{4})年(\\d{2})月(\\d{2})日(\\d{2}):(\\d{2})开，(.*?)-(.*?)，(.*?)次列车，(.*?)，", options: [])
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
        guard let match = matches.first else {
            return nil
        }
        guard let year = Int((text as NSString).substring(with: match.range(at: 1))),
        let month = Int((text as NSString).substring(with: match.range(at: 2))),
        let day = Int((text as NSString).substring(with: match.range(at: 3))),
        let hour = Int((text as NSString).substring(with: match.range(at: 4))),
        let minute = Int((text as NSString).substring(with: match.range(at: 5)))
        else { return nil }
        var parsedData = ParsedData(start: "", end: "", year: year, month: month, day: day, hour: hour, minute: minute, trainNo: "", siteNo: "")
        parsedData.start = (text as NSString).substring(with: match.range(at: 6))
        parsedData.end = (text as NSString).substring(with: match.range(at: 7))
        parsedData.trainNo = (text as NSString).substring(with: match.range(at: 8))
        parsedData.siteNo = (text as NSString).substring(with: match.range(at: 9))
        return parsedData
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
