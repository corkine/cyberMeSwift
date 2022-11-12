//
//  Todo.swift
//  helloSwift
//
//  Created by corkine on 2022/9/19.
//

import Foundation
import SwiftUI

struct ToDoView: View {
    @EnvironmentObject var service:CyberService
    var todo: [String:[ISummary.TodoItem]]
    var weekPlan: [ISummary.WeekPlanItem]
    var today: [ISummary.TodoItem] {
        var data = todo[TimeUtil.getDate()] ?? []
        if data.isEmpty && Calendar.current.component(.hour, from: Date()) < 7 {
            data = todo[TimeUtil.getDate(off:-1)] ?? []
        }
        return data.sorted(by: {a,b in
            if a.list == b.list {
                return a.create_at < b.create_at
            } else {
                return a.list < b.list
            }
        })
    }
    var body: some View {
        ForEach(today) { item in
            HStack(alignment:.firstTextBaseline) {
                if item.status == "completed" {
                    Text(item.title)
                        .strikethrough()
                        .fixedSize(horizontal: false, vertical: false)
                        .contextMenu {
                            ForEach(weekPlan, id: \.id) { plan in
                                Button("添加到\(plan.name)") {
                                    addLogAndRefresh(item, plan)
                                }
                            }
                        }
                } else {
                    Text(item.title)
                        .contextMenu {
                            ForEach(weekPlan, id: \.id) { plan in
                                Button("添加到\(plan.name)") {
                                    addLogAndRefresh(item, plan)
                                }
                            }
                        }
                }
                Spacer()
                RoundBG(Text(item.list).font(.system(size: 14)).padding(.vertical, 3),
                        fill: .gray.opacity(0.1))
                .padding(.trailing, 2)
            }
            .padding(.vertical, -4)
        }
        .padding(.leading, 2.0)
    }
    func addLogAndRefresh(_ item: ISummary.TodoItem, _ plan: ISummary.WeekPlanItem) {
        service.addLog(
            WeekPlanAddLog(planId: plan.id,
                           name: "\(TimeUtil.getWeedayFromeDate(date: Date()))：\(item.title)",
                           progressDelta: 10.0,
                           description: "由待办事项在 CyberMe iOS 添加")) {
               service.fetchSummary()
           }
    }
}

struct MyToDo_Previews: PreviewProvider {
    typealias Todo = ISummary.TodoItem
    static var service = CyberService()
    static var previews: some View {
        VStack {
            ToDoView(todo: [TimeUtil.getDate():[
                Todo(time: "2022", title: "Todo Item 11111111111111111111111111122222323232323232323232", list: "学习", status: "completed", create_at: "2022", importance: "high"),
                Todo(time: "2022", title: "Todo Item 1", list: "学习", status: "completed", create_at: "2022", importance: "high"),
                Todo(time: "2022", title: "Todo Item 1", list: "学习", status: "completed", create_at: "2022", importance: "high"),
                Todo(time: "2022", title: "Todo Item 1", list: "学习", status: "completed", create_at: "2022", importance: "high")
                ]], weekPlan: [ISummary.WeekPlanItem.default])
        }
        .environmentObject(service)
    }
}
