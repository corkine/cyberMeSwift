//
//  TicketView.swift
//  helloSwift
//
//  Created by Corkine on 2023/1/25.
//

import SwiftUI

struct TicketSheetModifier: ViewModifier {
    @EnvironmentObject var service: CyberService
    @Binding var showSheet: Bool
    @State private var tickets: [CyberService.TicketInfo] = []
    @State private var showAddSheet = false
    
    var uncommingInfo: [CyberService.TicketInfo] {
        tickets.filter { t in t.isUncomming }
    }
    var finishedInfo: [CyberService.TicketInfo] {
        tickets.filter { t in !t.isUncomming }
    }
    
    @ViewBuilder func buildMenu(info:CyberService.TicketInfo) -> some View {
        Button {
            guard let date = info.dateParsed else { return }
            service.deleteTicketByDate(date: date) { result in reqTicket()}
        } label: { Text("删除") }
    }
    
    @ViewBuilder var buildDoneTickets: some View {
        SwiftUI.Section(content: {
            if !finishedInfo.isEmpty {
                ForEach(finishedInfo, id: \.id) { info in
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text(info.startFull ?? "未知起始站")
                                Text("➢")
                                Text(info.endFull ?? "未知终点站")
                            }
                            HStack(alignment: .bottom) {
                                Text(info.trainNo ?? "")
                                Text(info.siteNoFull ?? "")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                            }
                        }
                        Spacer()
                        Text((info.dateFormat) + "")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    .contextMenu { buildMenu(info: info) }
                    .padding(.vertical, 5)
                }
            } else {
                Text("没有最近已出行的信息")
            }
        }, header: {
            Text("已出行")
        })
    }
    
    @ViewBuilder var buildTicketView: some View {
        List {
            SwiftUI.Section(content: {
                if !uncommingInfo.isEmpty {
                    ForEach(uncommingInfo, id: \.id) { info in
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text(info.startFull ?? "未知起始站")
                                    Text("➢")
                                    Text(info.endFull ?? "未知终点站")
                                }
                                HStack(alignment: .bottom) {
                                    Text(info.trainNo ?? "")
                                    Text(info.siteNoFull ?? "")
                                        .font(.system(size: 15))
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                            Text(info.dateFormat + " 出发")
                                .font(.system(size: 15))
                                .foregroundColor(.green)
                        }
                        .contextMenu { buildMenu(info: info) }
                        .padding(.vertical, 5)
                    }
                } else {
                    Text("没有未出行的车票信息")
                }
                HStack {
                    Spacer()
                    Button {
                        showAddSheet = true
                    } label: {
                        Text("添加新车票")
                    }
                    Spacer()
                }
            }, header: {
                Text("未出行")
            })
            buildDoneTickets
        }
        
    }
    
    func reqTicket() {
        service.recentTicket { tickets = $0 }
    }
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showSheet) {
                buildTicketView
                    .modifier(TicketAddSheetModifier(showSheet: $showAddSheet,
                                                     exitCall: reqTicket))
                    .onAppear(perform: reqTicket)
                    .onDisappear { tickets = []; showSheet = false }
            }
    }
}

struct TicketViewPreview: PreviewProvider {
    static var service = CyberService()
    static var previews: some View {
        Text("HELLO")
            .modifier(TicketSheetModifier(showSheet: .constant(true)))
            .environmentObject(service)
    }
}
