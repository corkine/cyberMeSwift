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
    var entry: Provider.Entry
    let basic: CGFloat = 11.5
    
    var dateStr: String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "MM月dd日 E"
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

    var body: some View {
        let data = entry.dashboard
        
        return VStack(alignment:.leading) {
            HStack {
                Text(data.workStatus)
                    .padding(.trailing, -5)
                VStack(alignment:.leading) {
                    Text("我的一天")
                        .kerning(0.6)
                        .bold()
                        .font(.system(size: basic))
                    Text(dateStr)
                        .font(.system(size: basic - 3))
                }
                Spacer()
                VStack {
                    Text("今日日报")
                        .foregroundColor(data.needDiaryReport ? .white : Color("BackgroundColor-Heavy"))
                        .font(.system(size: basic - 3))
                    Text("每日浇水")
                        .foregroundColor(data.needPlantWater ? .white : Color("BackgroundColor-Heavy"))
                        .font(.system(size: basic - 3))
                }
                if !data.cardCheck.isEmpty {
                    ZStack {
                        Color.white.opacity(0.22)
                        if data.cardCheck.count == 1 {
                            HStack(spacing:1) {
                                Text(data.cardCheck[0])
                            }
                            .font(.system(size: basic))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                        } else if data.cardCheck.count >= 2 {
                            HStack(spacing:1) {
                                Text(data.cardCheck[0])
                                Text("|").opacity(0.2)
                                Text(data.cardCheck[data.cardCheck.count - 1])
                            }
                            .font(.system(size: basic))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                        }
                    }.fixedSize(horizontal: true, vertical: true)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                   
            }
            Spacer()
            Spacer()
            VStack(alignment:.leading) {
                if let weather = data.weatherInfo,
                   !weather.isEmpty {
                    Text(weather)
                        .font(.system(size: basic))
                    Divider()
                        .background(Color.white)
                        .opacity(0.4)
                        .padding(.top, -5)
                        .padding(.bottom, -15)
                }
                if !data.todo.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(data.todo.prefix(3), id: \.self) { item in
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
                    .padding(.top, -10)
                    .padding(.bottom, 1)
                }
                
                HStack(spacing: 1) {
                    if data.todo.count - 3 > 0 {
                        Text("其它 \(data.todo.count - 3) 个")
                            .padding(.trailing, 3)
                    }
                    Text("UPDATE \(updateStr)")
                        .kerning(0.1)
                        .bold()
                        .padding(.trailing, 3)
                    if TimeUtil.needCheckCard {
                        Text("HCM")
                            .kerning(-1)
                            .bold()
                            .opacity(1)
                            .padding(.trailing, 3)
                    } else {
                        Text("GRAPH")
                            .kerning(-1)
                            .bold()
                    }
                }
                .font(.system(size: basic - 2))
                .opacity(0.5)
            }
        }
        .padding(.all, 14)
        .background(Color("BackgroundColor"))
        .foregroundColor(.white)
        .widgetURL(URL(string: "cyberme://checkCardIfNeed"))
    }
}

@main
struct CyberMeWidget: Widget {
    let kind: String = "CyberMeWidget"
    
    let backgroundData = BackgroundManager()

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CyberMeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("CyberMe")
        .description("智能的提供你最关注的信息")
        .onBackgroundURLSessionEvents { (sessionIdentifier, completion) in
            if sessionIdentifier == self.kind {
                self.backgroundData.update()
                self.backgroundData.completionHandler = completion
                print("background update")
            }
        }
    }
}

struct CyberMeWidget_Previews: PreviewProvider {
    static var previews: some View {
        CyberMeWidgetEntryView(entry: SimpleEntry(date: Date(),
                                                  dashboard: Dashboard.demo))
            .preferredColorScheme(.dark)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
