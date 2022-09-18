//
//  CyberHomeScene.swift
//  helloSwift
//
//  Created by corkine on 2022/9/15.
//

import SwiftUI

struct CyberNav: View {
    @State var selection: Tab = .today
    @EnvironmentObject var service:CyberService
    enum Tab { case today, game }
    var body: some View {
        if service.gaming {
            Bullseye().accentColor(.red)
        } else if service.landing {
            ContentView()
                .environmentObject(ModelData())
        } else {
            TabView(selection: $selection) {
                CyberHome()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(Tab.today)
                ProfileView()
                    .tabItem {
                        Label("Me", systemImage: "person.crop.circle")
                    }
                    .tag(Tab.game)
            }.accentColor(.blue)
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var service:CyberService
    var body: some View {
        VStack {
            Button("BullsEye Game") {
                service.gaming = true
            }
            Button("Landmarks") {
                service.landing = true
            }
        }
    }
}

struct CyberHome: View {
    @EnvironmentObject var service:CyberService
    var body: some View {
        ScrollView(.vertical,showsIndicators:false) {
            HStack(alignment:.top) {
                VStack(alignment:.leading,spacing: 10) {
                    Label("我的一天", systemImage: "calendar")
                        .font(.title2)
                        .foregroundColor(Color.blue)
                    MyToDo(todo:$service.summaryData.data.todo)
                        .padding(.bottom, 9)
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
        }
        .onAppear(perform: service.fetchSummary)
    }
}

struct MyToDo: View {
    typealias Todo = Summary.TodoItem
    @EnvironmentObject var service:CyberService
    @Binding var todo: [String:[Todo]]
    var today: [Todo] {
        var data = todo[getDate()] ?? []
        if data.isEmpty {
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
                HStack {
                    if item.status == "completed" {
                        Text(item.title)
                            .strikethrough()
                            .fixedSize(horizontal: false, vertical: false)
                    } else {
                        Text(item.title)
                            .strikethrough()
                    }
                    Spacer()
                    ZStack(alignment:.center) {
                        Color.gray.opacity(0.1)
                        Text(item.list)
                            .padding(.vertical, 4.0)
                            .padding(.horizontal, 6.0)
                    }.clipShape(RoundedRectangle(cornerRadius: 15))
                        .fixedSize(horizontal: true, vertical: true)
                    .padding(.trailing, 4)
                }
            }
            .padding(.leading, 2.0)
        }
    }
}

struct CyberHomeScene_Previews: PreviewProvider {
    static var service = CyberService()
    static var previews: some View {
        //CyberHome()
        //CyberHome()
        ProfileView()
            .environmentObject(service)
            .onAppear {
//                Task {
//                    //await service.fetchSummary()
//                }
            }
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
