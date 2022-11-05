//
//  Todo.swift
//  helloSwift
//
//  Created by corkine on 2022/9/19.
//

import Foundation
import SwiftUI

struct MyToDo: View {
    @Binding var todo: [String:[Summary.TodoItem]]
    var today: [Summary.TodoItem] {
        var data = todo[getDate()] ?? []
        if data.isEmpty && Calendar.current.component(.hour, from: Date()) < 7 {
            data = todo[getDate(off:-1)] ?? []
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
            Text("没有数据")
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
                    ZStack(alignment:.center) {
                        Color.gray.opacity(0.1)
                        Text(item.list)
                            .padding(.vertical, 1.0)
                            .padding(.horizontal, 10.0)
                    }.clipShape(RoundedRectangle(cornerRadius: 15))
                        .fixedSize(horizontal: true, vertical: true)
                    .padding(.trailing, 2)
                }.padding(.vertical, -3)
            }
            .padding(.leading, 2.0)
        }
    }
}

struct MyToDo_Previews: PreviewProvider {
    typealias Todo = Summary.TodoItem
    static var previews: some View {
        VStack {
            MyToDo(todo: .constant(
                [getDate():[
                Todo(time: "2022", title: "Todo Item 1", list: "学习", status: "completed", create_at: "2022", importance: "high"),
                Todo(time: "2022", title: "Todo Item 1", list: "学习", status: "completed", create_at: "2022", importance: "high"),
                Todo(time: "2022", title: "Todo Item 1", list: "学习", status: "completed", create_at: "2022", importance: "high"),
                Todo(time: "2022", title: "Todo Item 1", list: "学习", status: "completed", create_at: "2022", importance: "high")
                ]]
            ))
        }
    }
}
