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
                .transition(.scale)
        } else if service.landing {
            ContentView()
                .environmentObject(ModelData())
                .transition(.scale)
        } else if service.readme {
            ReadMe()
                .environmentObject(Library())
                .transition(.scale)
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
            }
            .accentColor(.blue)
            .transition(.moveAndFade)
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var service:CyberService
    var body: some View {
        VStack(spacing: 15) {
            Button("BullsEye Game") {
                withAnimation {
                    service.gaming = true
                }
            }
            Button("Landmarks") {
                withAnimation {
                    service.landing = true
                }
            }
            Button("ReadMe") {
                withAnimation {
                    service.readme = true
                }
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
        }
        .onAppear(perform: service.fetchSummary)
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
