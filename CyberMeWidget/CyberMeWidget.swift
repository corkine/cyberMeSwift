//
//  CyberMeWidget.swift
//  CyberMeWidget
//
//  Created by corkine on 2022/9/20.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), dashboard: Dashboard.demo)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), dashboard: Dashboard.demo)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        CyberService.fetchDashboard { dashboard, error in
            if let dashboard = dashboard {
                WidgetLocation.fetchIfTime(handler: { (loc, err) in
                    if let err = err {
                        CyberService.sendNotice(msg: "Error when fetch location: \(err.localizedDescription)")
                    } else {
                        CyberService.trackUrl(location: loc!, by: "corkine@CMIXR")
                    }
                })
                let currentDate = Date()
                let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
                
                let entry = SimpleEntry(date: currentDate, dashboard: dashboard)

                let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                completion(timeline)
            } else {
                let currentDate = Date()
                let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
                
                let entry = SimpleEntry(date: currentDate, dashboard: Dashboard.failed(error: error))

                let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                completion(timeline)
            }
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let dashboard: Dashboard
}

struct CyberMeWidgetEntryView : View {
    
    @Environment(\.widgetFamily) var family
    
    var entry: Provider.Entry
    let basic: CGFloat = 11.5
    
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
        let calendar = Calendar.current
        let today = Date()
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: today)
        return "\(dayOfYear! + 52000)"
    }
    
    var largeView: some View {
        var data = entry.dashboard
        let needFitness = needWarnFitness(data)
        let bg = WidgetBackground(rawValue: UserDefaults(suiteName: Default.groupName)!
            .string(forKey: "widgetBG") ?? "mountain")
        let alertOn = UserDefaults(suiteName: Default.groupName)!
            .bool(forKey: "alert")
        let fakeTodo = data.tickets.filter(\.isUncomming).map { ticket in
            Dashboard.Todo(title: ticket.description, isFinished: false)
        }
        data.todo = fakeTodo + data.todo
        
        let bodyMassNum = data.fitnessInfo?.bodyMassDay30 ?? 0.0
        var bodyMass = String(format: "%.1f", abs(bodyMassNum))
        bodyMass = bodyMass == "0.0" ? "0" : bodyMass
        let bodyMassStr = bodyMass == "0.0" ? "" :
        "\(bodyMassNum >= 0 ? "▼" : "▲")\(bodyMass)kg"
        
        let mind = data.fitnessInfo?.mindful ?? 0.0
        let mindStr = mind != 0.0 ? "🫧" : "⚠︎M"
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
                if let (temp, isYesterday) = data.tempSmartInfo,
                   let temp = temp {
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
                    Text("UP \(updateStr) \(magicNumber)")
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
    
    var todoView: some View {
        var data = entry.dashboard
        let fakeTodo = data.tickets.filter(\.isUncomming).map { ticket in
            Dashboard.Todo(title: ticket.description, isFinished: false)
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
        let finishWork = !data.needDiaryReport && data.offWork
        return ZStack {
            if #available(iOSApplicationExtension 16.0, *) {
                AccessoryWidgetBackground()
            } else {
                Color.white.opacity(0.2)
            }
            VStack(spacing: 2) {
                if finishWork {
                    Image(systemName: "moon.fill")
                       .padding(.bottom, 3)
                }
                HStack(spacing: 2) {
                     if data.needDiaryReport {
                         Text("日报")
                     }
                     if !data.offWork {
                         Text("打卡")
                     }
               }
               .font(.system(size: finishWork ? 17 : 14))
               .padding(.bottom, 3)
               Text(magicNumber)
                    .font(.system(size: finishWork ? 14 : 10))
            }
        }
    }
    
    var weatherView: some View {
        let data = entry.dashboard
        let (temp, isYesterday) = data.tempSmartInfo
        var weatherInfo = data.weatherInfo == nil || ((data.weatherInfo?.isEmpty) != nil) ? "没有天气信息" : data.weatherInfo!
        let tempHighDetail = temp != nil && temp!.diffHigh != nil && Int(temp!.diffHigh!) != 0
        let tempLowDetail = temp != nil && temp!.diffLow != nil && Int(temp!.diffLow!) != 0
        
        let useWeather = UserDefaults(suiteName: Default.groupName)!.bool(forKey: "showWeather")
        if !useWeather {
            let bodyMassNum = data.fitnessInfo?.bodyMassDay30 ?? 0.0
            var bodyMass = String(format: "%.1f", bodyMassNum)
            bodyMass = bodyMass == "0.0" ? "0" : bodyMass
            let bodyMassStr = bodyMass == "0.0" ? "" :
            "\(bodyMassNum <= 0 ? "▼" : "▲")\(bodyMass)kg"
            
            let mind = data.fitnessInfo?.mindful ?? 0.0
            let mindStr = mind != 0.0 ? "🫧" : "⚠︎Balance"
            weatherInfo = "\(bodyMassStr)  \(mindStr)"
        } 
        
        if let temp = temp {
            let highTemp = "↑\(Int(temp.high))\(tempHighDetail ? String(format: "%+.0f", temp.diffHigh!) : "")"
            let lowTemp = "↓\(Int(temp.low))\(tempLowDetail ? String(format: "%+.0f", temp.diffLow!) : "")"
            return Text("\(isYesterday ? "*" : "")\(highTemp)\(lowTemp) \(weatherInfo)")
        } else {
            return Text("\(weatherInfo)")
        }
    }

    var body: some View {
        switch family {
        case .systemMedium:
            largeView
        case .accessoryInline:
            weatherView
        case .accessoryRectangular:
            todoView
        case .accessoryCircular:
            workView
        default:
            Text("Not Support")
        }
    }
}

@main
struct CyberMeWidget: Widget {
    let kind: String = "CyberMeWidget"
    
    let backgroundData = BackgroundManager()
    
    var supportFamilies: [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            return [WidgetFamily.systemMedium,
                    WidgetFamily.accessoryInline,
                    WidgetFamily.accessoryCircular,
                    WidgetFamily.accessoryRectangular]
        } else {
            return [WidgetFamily.systemMedium]
        }
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CyberMeWidgetEntryView(entry: entry)
        }
        .supportedFamilies(supportFamilies)
        .configurationDisplayName("CyberMe")
        .description("Cloud Life Easy")
        .onBackgroundURLSessionEvents { (sessionIdentifier, completion) in
            if sessionIdentifier == self.kind {
                self.backgroundData.update()
                self.backgroundData.completionHandler = completion
                print("background update")
            }
        }
    }
}

//@main
//struct CyberMeWidgets: WidgetBundle {
//    @WidgetBundleBuilder
//    var body: some Widget {
//        CyberMeWidget()
//    }
//}

struct CyberMeWidget_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOSApplicationExtension 16.0, *) {
            CyberMeWidgetEntryView(entry: SimpleEntry(date: Date(),
                                                      dashboard: Dashboard.demo))
            .preferredColorScheme(.dark)
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
            .previewDisplayName("Todo")
            CyberMeWidgetEntryView(entry: SimpleEntry(date: Date(),
                                                      dashboard: Dashboard.demo))
            .previewContext(WidgetPreviewContext(family: .accessoryInline))
            .previewDisplayName("Weather")
            CyberMeWidgetEntryView(entry: SimpleEntry(date: Date(),
                                                      dashboard: Dashboard.demo))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
            .previewDisplayName("Work")
            CyberMeWidgetEntryView(entry: SimpleEntry(date: Date(),
                                                      dashboard: Dashboard.demo))
            .preferredColorScheme(.dark)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        } else {
            CyberMeWidgetEntryView(entry: SimpleEntry(date: Date(),
                                                      dashboard: Dashboard.demo))
            .preferredColorScheme(.dark)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
