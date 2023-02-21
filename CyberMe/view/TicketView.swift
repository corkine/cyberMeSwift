//
//  TicketView.swift
//  helloSwift
//
//  Created by Corkine on 2023/1/25.
//

import SwiftUI

struct TicketView: View {
    @Binding var info: [CyberService.TicketInfo]
    var uncommingInfo: [CyberService.TicketInfo] {
        info.filter { t in t.isUncomming }
    }
    var finishedInfo: [CyberService.TicketInfo] {
        info.filter { t in !t.isUncomming }
    }
    var body: some View {
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
                        .padding(.vertical, 5)
                    }
                } else {
                    Text("没有未出行的车票信息")
                }
            }, header: {
                Text("未出行")
            })
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
                        .padding(.vertical, 5)
                    }
                } else {
                    Text("没有最近已出行的信息")
                }
            }, header: {
                Text("已出行")
            })
        }
    }
}

struct TicketView_Previews: PreviewProvider {
    static var previews: some View {
        TicketView(info: .constant([CyberService.TicketInfo(
            id: "abc",
            start: "武汉东",
            end: "武汉",
            date: "2023-01-26T13:23:00",
            trainNo: "G1234",
            siteNo: "A13B",
            originData: "ABCD")]))
    }
}
