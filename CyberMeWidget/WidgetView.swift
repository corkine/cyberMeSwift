//
//  WidgetView.swift
//  CyberMe
//
//  Created by Corkine on 2024/9/4.
//

import WidgetKit
import SwiftUI

struct CyberMeWidgetEntryView : View {
    
    @Environment(\.widgetFamily) var family
    
    var entry: Provider.Entry
    let basic: CGFloat = 11.5
    
    var store = UserDefaults(suiteName: Default.groupName)
    
    var dateStr: String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 E"//"MM月dd日 E"
        return formatter.string(from: now)
    }
    
    var updateStr1: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        let updateAt = Date(timeIntervalSince1970: TimeInterval(entry.dashboard.updateAt))
        let now = Date()
        let timeinterval = now.distance(to: updateAt)
        return formatter.string(from: timeinterval) ?? "? MINUTES"
    }
    
    var updateStr: String {
        let updateAt = Date(timeIntervalSince1970: TimeInterval(entry.dashboard.updateAt))
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: updateAt)
    }
    
    func needWarnFitness(_ dash: Dashboard) -> Bool {
        guard let fit = dash.fitnessInfo else { return false }
        if fit.active > 550 { return false }
        return true
    }
    
    func alert(_ text: String) -> some View {
        ZStack {
            Color.white.opacity(0.22)
            HStack(spacing:1) {
                Text(text)
            }
            .font(.system(size: basic))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
        }
        .fixedSize(horizontal: true, vertical: true)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    /// 如果工作日没有打卡或者是周六 8:00 - 20:00，则显示
    func needHCMCard(_ data: Dashboard) -> Bool {
        let now = Date()
        if now.weekday >= 6 {
            let hour = now.hour
            return hour >= 8 && hour <= 20
        }
        if !data.offWork { return true }
        return false
    }
    
    var magicNumber: String {
        let base = (store!.dictionary(forKey: "settings") as? [String:String] ?? [:])["wireguardBasePort"]
        let baseInt = Int(base ?? "21000") ?? 21000
        let calendar = Calendar.current
        let today = Date()
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: today)
        return "\(dayOfYear! + baseInt)"
    }
    
    /// Home 长条 Widget
    var largeView: some View {
        var data = entry.dashboard
        data.todo = data.todo.sorted { a, b in
            if (a.isFinished && b.isFinished) ||
                (!a.isFinished && !b.isFinished) {
                return a.create_at > b.create_at
            } else if a.isFinished {
                return false;
            } else if b.isFinished {
                return true;
            } else {
                return false;
            }
        }
        let needFitness = needWarnFitness(data)
        let bg = WidgetBackground(rawValue: store!.string(forKey: "widgetBG") ?? "mountain")
        let alertOn = store!.bool(forKey: "alert")
        let fakeTodo = data.tickets.filter(\.isUncomming).map { ticket in
            Todo(title: ticket.description, isFinished: false, create_at: "0", list: "Work")
        }
        data.todo = fakeTodo + data.todo
        
        let bodyMassNum = data.fitnessInfo?.bodyMassDay30 ?? 0.0
        var bodyMass = String(format: "%.1f", abs(bodyMassNum))
        bodyMass = bodyMass == "0.0" ? "0" : bodyMass
        let bodyMassStr = bodyMass == "0.0" ? "" :
        "\(bodyMassNum >= 0 ? "▼" : "▲")\(bodyMass)kg"
        
        //let mind = data.fitnessInfo?.mindful ?? 0.0
        let mindStr = "" //mind != 0.0 ? "🫧" : "⚠︎M"
        let fitInfo = "\(bodyMassStr) \(mindStr)"
        
        return VStack(alignment:.leading) {
            HStack {
                // MARK: 顶部左侧
                Link(data.workStatus,
                     destination: URL(string: "cyberme://checkCardForce")!)
                    .padding(.trailing, -5)
                Link(destination: URL(string: CyberUrl.showCal)!) {
                    Text(dateStr)
                        .kerning(0.6)
                        .font(.system(size: basic + 3))
                }
                Text(fitInfo)
                    .font(.system(size: basic + 2))
                Spacer()
                // MARK: 顶部提醒日报、健身信息
                if data.needDiaryReport && needFitness {
                    VStack {
                        Text("今日日报")
                            .foregroundColor(data.needDiaryReport ? .white : Color("BackgroundColor-Heavy"))
                            .font(.system(size: basic - 3))
                        Text("形体之山")
                            .foregroundColor(needFitness ? .white : Color("BackgroundColor-Heavy"))
                            .font(.system(size: basic - 3))
                    }
                } else if data.needDiaryReport {
                    alert("今日日报")
                } else if needFitness {
                    Link(destination: URL(string: CyberUrl.showBodyMass)!) {
                        alert("形体之山")
                    }
                }
                // MARK: 顶部打卡事件信息
                if !data.cardCheck.isEmpty {
                    ZStack {
                        Color.white.opacity(0.22)
                        HStack(spacing:1) {
                            Text(data.cardCheck.last ?? "Nil")
                        }
                        .font(.system(size: basic))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        //if data.cardCheck.count == 1 {
                        //    HStack(spacing:1) {
                        //        Text(data.cardCheck[0])
                        //    }
                        //    .font(.system(size: basic))
                        //    .padding(.horizontal, 6)
                        //    .padding(.vertical, 3)
                        //} else if data.cardCheck.count >= 2 {
                        //    HStack(spacing:1) {
                        //        Text(data.cardCheck[0])
                        //        Text("|").opacity(0.2)
                        //        Text(data.cardCheck[data.cardCheck.count - 1])
                        //    }
                        //    .font(.system(size: basic))
                        //    .padding(.horizontal, 6)
                        //    .padding(.vertical, 3)
                        //}
                    }
                    .fixedSize(horizontal: true, vertical: true)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.leading, -2)
                }
                   
            }
            Spacer()
            Spacer()
            // MARK: 天气信息
            VStack(alignment:.leading) {
                // 先显示气温，后显示天气，其中当时间大于等于晚上七点则显示第二天气温
                let (temp, isYesterday) = data.tempSmartInfo
                if let temp = temp {
                    Link(destination: URL(string: CyberUrl.showWeather)!) {
                        HStack(alignment: isYesterday ? .bottom : .top, spacing: 0) {
                            Text("↑\(Int(temp.high))")
                                .font(.system(size: basic))
                            if temp.diffHigh != nil && Int(temp.diffHigh!) != 0 {
                                Text(String(format: "%+.0f", temp.diffHigh!))
                                    .font(.system(size: basic - 2))
                                    .opacity(0.5)
                            }
                            Text("↓\(Int(temp.low))")
                                .font(.system(size: basic))
                                .padding(.leading, 1)
                            if temp.diffLow != nil && Int(temp.diffLow!) != 0 {
                                Text(String(format: "%+.0f", temp.diffLow!))
                                    .font(.system(size: basic - 2))
                                    .opacity(0.5)
                            }
                            Text(" " + (data.weatherInfo ?? ""))
                                .lineLimit(1)
                                .font(.system(size: basic))
                        }
                    }
                } else {
                    Link(destination: URL(string: CyberUrl.showWeather)!) {
                        Text(data.weatherInfo ?? "")
                            .lineLimit(1)
                            .font(.system(size: basic))
                    }
                }
                Divider()
                    .background(Color.white)
                    .opacity(0)
                    .padding(.top, -5)
                    .padding(.bottom, -15)
                // MARK: 待办事项
                if !data.todo.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(data.todo.prefix(3), id: \.self) { item in
                            if !fakeTodo.isEmpty && fakeTodo.contains(where: { t in t.title == item.title }) {
                                Link(destination: URL(string: CyberUrl.show12306)!) {
                                    Text(item.title)
                                        .font(.system(size: basic + 4))
                                        .lineLimit(1)
                                }
                            } else {
                                if item.isFinished {
                                    Text(item.title)
                                        .strikethrough()
                                        .font(.system(size: basic + 4))
                                        .lineLimit(1)
                                } else {
                                    Text(item.title)
                                        .font(.system(size: basic + 4))
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                    .padding(.top, -10)
                    .padding(.bottom, 1)
                }
                // MARK: 底部信息
                HStack(spacing: 1) {
                    if data.todo.count - 3 > 0 {
                        Text("其它 \(data.todo.count - 3) 个")
                            .padding(.trailing, 3)
                    }
                    if alertOn {
                        Link(destination: URL(string: CyberUrl.showMiHome)!) {
                            Image(systemName: "video")
                                .padding(.trailing, 3)
                                .padding(.bottom, 1)
                        }
                    }
                    Text("UP \(updateStr)")
                        .kerning(0.1)
                        .bold()
                        .padding(.trailing, 3)
                    if needHCMCard(data) || true {
                        Link(destination: URL(string: CyberUrl.checkCardHCM)!) {
                            Text("HCM")
                                .kerning(0.3)
                                .bold()
                                .opacity(1)
                                //.padding(.leading, 3)
                        }
                    }
                }
                .font(.system(size: basic - 2))
                .opacity(0.5)
            }
        }
        .padding(.all, 14)
        .background(bg == .mountain ? Image("mountain")
            .resizable()
            .offset(y:-50)
            .scaledToFill() : nil)
        .background(bg == .mountain ? Color.clear : Color("BackgroundColor"))
        .foregroundColor(.white)
        .widgetURL(URL(string: CyberUrl.syncWidget))
    }
  
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
    
    var smallView: some View {
      let data = entry.dashboard
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
        ZStack {
          Color.black
          
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
              Spacer()
              VStack(alignment: .trailing) {
                Text(formatDate(update))
                Text(data.car?.loc.place ?? "--")
                  .truncationMode(.head)
              }
              .font(.system(size: 9))
              .lineLimit(1)
              .foregroundColor(.gray)
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
                .font(.system(size: 13))
                .offset(x: -7)
            }
            .foregroundColor(.white)
            
            ProgressView(value: fuelLevel, total: 100)
                .accentColor(.white)
                .frame(width: 80, height: 10)
                .offset(y: -7)
              
            Spacer()
            
            HStack {
              Spacer()
              Text("\(fuel)L · \(mile)km · \(cost)L/100km")
                .font(.system(size: 8))
                .foregroundColor(.gray)
                .lineLimit(1)
                .offset(y: 8)
              Spacer()
            }
          }
          .padding()
          
          Image("car")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: geometry.size.width - 20)
            .offset(x: geometry.size.width / 8, y: geometry.size.height / 3.9)
        }
        .widgetURL(URL(string: CyberUrl.svwUrl))
      }
    }
    
    var todoView: some View {
        var data = entry.dashboard
        let fakeTodo = data.tickets.filter(\.isUncomming).map { ticket in
          Todo(title: ticket.description, isFinished: false, create_at: "0", list: "车票")
        }
        data.todo = Array((fakeTodo + data.todo).prefix(3))
        
        return VStack(alignment: .leading, spacing: 2) {
            ForEach(data.todo.prefix(3), id: \.self) { item in
                if !fakeTodo.isEmpty && fakeTodo.contains(where: { t in t.title == item.title }) {
                    Link(destination: URL(string: CyberUrl.show12306)!) {
                        Text(item.title)
                            .font(.system(size: basic + 4))
                            .lineLimit(1)
                    }
                } else {
                    if item.isFinished {
                        Text(item.title)
                            .strikethrough()
                            .font(.system(size: basic + 4))
                            .lineLimit(1)
                    } else {
                        Text(item.title)
                            .font(.system(size: basic + 4))
                            .lineLimit(1)
                    }
                }
            }
        }
    }
    
    var workView: some View {
        let data = entry.dashboard
        let finishWork = data.offWork
        
        let (temp, isYesterday) = data.tempSmartInfo
        let tempHighDetail = temp != nil && temp!.diffHigh != nil && Int(temp!.diffHigh!) != 0
        let tempLowDetail = temp != nil && temp!.diffLow != nil && Int(temp!.diffLow!) != 0
        var tempSum = "-"
        if let temp = temp {
            let highTemp = "\(Int(temp.high))\(tempHighDetail ? String(format: "%+.0f", temp.diffHigh!) : "")"
            let lowTemp = "\(Int(temp.low))\(tempLowDetail ? String(format: "%+.0f", temp.diffLow!) : "")"
            tempSum = "\(isYesterday ? "*" : "")\(highTemp)/\(lowTemp)"
        }
        
        return ZStack {
            if #available(iOSApplicationExtension 16.0, *) {
                AccessoryWidgetBackground()
            } else {
                Color.white.opacity(0.2)
            }
            VStack(spacing: 2) {
                Image(systemName: finishWork ? "moon.haze.fill" : "flag.fill")
                   .padding(.bottom, 3)
               Text(tempSum)
                    .font(.system(size: finishWork ? 11 : 9))
            }
        }
    }
    
    var weatherView: some View {
        let data = entry.dashboard
        let (temp, isYesterday) = data.tempSmartInfo
        var weatherInfo = (data.weatherInfo == nil || data.weatherInfo!.isEmpty) ? "没有天气信息" : data.weatherInfo!
        let tempHighDetail = temp != nil && temp!.diffHigh != nil && Int(temp!.diffHigh!) != 0
        let tempLowDetail = temp != nil && temp!.diffLow != nil && Int(temp!.diffLow!) != 0
        
        let useWeather = UserDefaults(suiteName: Default.groupName)!.bool(forKey: "useWeather")
        if !useWeather {
            let bodyMassNum = data.fitnessInfo?.bodyMassDay30 ?? 0.0
            var bodyMass = String(format: "%.1f", bodyMassNum)
            bodyMass = bodyMass == "0.0" ? "0" : bodyMass
            let bodyMassStr = bodyMass == "0.0" ? "" :
            "\(bodyMassNum <= 0 ? "▼" : "▲")\(bodyMass)"
            
            let mind = data.fitnessInfo?.mindful ?? 0.0
            let mindStr = mind != 0.0 ? "🫧" : "⚠︎Balance"
            weatherInfo = "\(bodyMassStr) \(mindStr)"
            
            if let temp = temp {
                let highTemp = "↑\(Int(temp.high))\(tempHighDetail ? String(format: "%+.0f", temp.diffHigh!) : "")"
                let lowTemp = "↓\(Int(temp.low))\(tempLowDetail ? String(format: "%+.0f", temp.diffLow!) : "")"
                return Text("\(isYesterday ? "*" : "")\(highTemp)\(lowTemp) \(weatherInfo)")
            }
        }
        
        return Text("\(weatherInfo)")
    }

    var body: some View {
        switch family {
        case .systemMedium:
            largeView
        case .systemSmall:
            smallView
        case .accessoryInline:
            weatherView
        case .accessoryRectangular:
            todoView
        default:
            Text("Not Support")
        }
    }
}

struct QuickWidgetEntryView : View {
    
    @Environment(\.widgetFamily) var family
    
    var entry: QuickProvider.Entry
    let basic: CGFloat = 11.5
    
    var store = UserDefaults(suiteName: Default.groupName)
    
    var dateStr: String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 E"//"MM月dd日 E"
        return formatter.string(from: now)
    }
    
    func alert(_ text: String) -> some View {
        ZStack {
            Color.white.opacity(0.22)
            HStack(spacing:1) {
                Text(text)
            }
            .font(.system(size: basic))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
        }
        .fixedSize(horizontal: true, vertical: true)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    /// 如果工作日没有打卡或者是周六 8:00 - 20:00，则显示
    func needHCMCard(_ data: Dashboard) -> Bool {
        let now = Date()
        if now.weekday >= 6 {
            let hour = now.hour
            return hour >= 8 && hour <= 20
        }
        if !data.offWork { return true }
        return false
    }
    
    var magicNumber: String {
        let base = (store!.dictionary(forKey: "settings") as? [String:String] ?? [:])["wireguardBasePort"]
        let baseInt = Int(base ?? "21000") ?? 21000
        let calendar = Calendar.current
        let today = Date()
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: today)
        return "\(dayOfYear! + baseInt)"
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/dd HH:mm"
        return formatter.string(from: date)
    }
    
    var shortcutView: some View {
        return ZStack {
            if #available(iOSApplicationExtension 16.0, *) {
                AccessoryWidgetBackground()
            } else {
                Color.white.opacity(0.2)
            }
            Image(systemName: "car.side")
                .font(.system(size: 24))
        }
        .widgetURL(URL(string: CyberUrl.showShortcut))
    }
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            shortcutView
        default:
            Text("Not Support")
        }
    }
}
