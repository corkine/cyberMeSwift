//
//  ContentView.swift
//  WatchMe Watch App
//
//  Created by Corkine on 2024/7/18.
//

import SwiftUI

func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd HH:mm"
    return formatter.string(from: date)
}

enum TabTag {
  case car
  case todo
}

struct TabContentView: View {
  @State var selectedTab = TabTag.car
  @Binding var dashboard: Dashboard
  @Binding var callUpdate: () -> Void
  
  var carView: some View {
    let data = dashboard
    let fuel = String(format:"%.0f", data.car?.tripStatus.fuel ?? 0)
    let mile = String(format:"%.0f", data.car?.tripStatus.mileage ?? 0)
    let cost = String(format:"%.1f", data.car?.tripStatus.averageFuel ?? 0)
    let update = Date(timeIntervalSince1970: Double(data.car?.reportTime ?? 0) / 1000)
    let range = String(format: "%.0f", data.car?.status.range ?? 0)
    let fuelLevel = data.car?.status.fuelLevel
    var warning = false
    if let car = data.car {
      let status = car.status
      if  status.parkingBrake == "active" &&
          (
            status.tyre != "checked" ||
            status.lock != "locked" ||
            status.doors != "closed" ||
            status.windows != "closed"
          ) {
        warning = true
      }
    }
    
    return GeometryReader { geometry in
      ScrollView {
        VStack(alignment: .leading, spacing: 5) {
          HStack {
            if warning {
              Image("vw")
                  .resizable()
                  .colorMultiply(Color(red: 0.7, green: 0.2, blue: 0.2, opacity: 0.9))
                  .frame(width: 20, height: 20)
            } else {
              Image("vw")
                  .resizable()
                  .frame(width: 20, height: 20)
            }
            Text("Volkswagen")
              .font(.system(size: 15))
          }
            
          HStack(alignment: .firstTextBaseline) {
            if #available(iOSApplicationExtension 16.1, *) {
              Text(range)
                .font(.system(size: 32))
                .fontWeight(.bold)
                .fontDesign(.monospaced)
            } else {
              Text(range)
                .font(.system(size: 32))
            }
              
            Text("km")
              .font(.system(size: 15))
              .offset(x: -2)
          }
          .foregroundColor(.white)
          
          ProgressView(value: fuelLevel, total: 100)
              .accentColor(.white)
              .frame(width: 86, height: 5)
              .clipShape(RoundedRectangle(cornerRadius: 5))
              .padding(.bottom, 10)
          
          Group {
            Text("\(fuel)L · \(mile)km · \(cost)L/100km")
              .lineLimit(1)
            Text(data.car?.loc.place ?? "--")
              .truncationMode(.head)
            Text(formatDate(update))
          }
          .font(.system(size: 12))
          .lineLimit(1)
          .foregroundColor(.gray)
          
          Image("car")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: geometry.size.width)
            .offset(x: 50, y: -50)
        }
        .padding(.horizontal, 10)
      }
    }
  }
  
  var todoView: some View {
    return HStack {
      ScrollView {
        VStack(alignment: .leading) {
          HStack {
            Text("\(dashboard.workStatus)")
            Text("今日待办")
          }
          .padding(.bottom, 5)
          ForEach(dashboard.todo, id: \.id) { todo in
            VStack(alignment: .leading) {
              Text(todo.list)
                .font(.system(size: 12))
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(.tertiary)
                .cornerRadius(18)
              if todo.isFinished {
                Text(todo.title)
                  .strikethrough()
              } else {
                Text(todo.title)
              }
            }
            .padding(.bottom, 3)
          }
          
          Button("更新数据") {
            callUpdate()
          }
          .padding(.top, 5)
          
          Spacer()
        }.padding(.horizontal, 7)
      }
      Spacer()
    }
  }
  
  var body: some View {
    TabView(selection: $selectedTab) {
      todoView.tag(TabTag.todo)
      carView.tag(TabTag.car)
    }
    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .automatic))
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    TabContentView(dashboard: .constant(Dashboard.demo),
                   callUpdate: .constant {
      
    })
  }
}
