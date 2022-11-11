//
//  Todo.swift
//  helloSwift
//
//  Created by corkine on 2022/9/19.
//

import Foundation
import SwiftUI

struct MyToDo: View {
    @Binding var todo: [String:[ISummary.TodoItem]]
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
        if today.isEmpty {
            //Text("没有数据")
        } else {
            ForEach(today) { item in
                HStack(alignment:.firstTextBaseline) {
                    if item.status == "completed" {
                        Text(item.title)
                            .strikethrough()
                            .fixedSize(horizontal: false, vertical: false)
                    } else {
                        Text(item.title)
                    }
                    Spacer()
                    RoundBG(Text(item.list).font(.system(size: 14)).padding(.vertical, 5),
                            fill: .gray.opacity(0.1))
                    .padding(.trailing, 2)
                }.padding(.vertical, -3)
            }
            .padding(.leading, 2.0)
        }
    }
}

struct MyToDo_Previews: PreviewProvider {
    typealias Todo = ISummary.TodoItem
    static var previews: some View {
        VStack {
            MyToDo(todo: .constant(
                [TimeUtil.getDate():[
                Todo(time: "2022", title: "Todo Item 1", list: "学习", status: "completed", create_at: "2022", importance: "high"),
                Todo(time: "2022", title: "Todo Item 1", list: "学习", status: "completed", create_at: "2022", importance: "high"),
                Todo(time: "2022", title: "Todo Item 1", list: "学习", status: "completed", create_at: "2022", importance: "high"),
                Todo(time: "2022", title: "Todo Item 1", list: "学习", status: "completed", create_at: "2022", importance: "high")
                ]]
            ))
        }
    }
}
