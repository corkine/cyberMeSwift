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
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct CyberMeWidgetEntryView : View {
    var entry: Provider.Entry
    let basic: CGFloat = 11.5

    var body: some View {
        VStack(alignment:.leading) {
            HStack {
                Text("🟡")
                    .padding(.trailing, -5)
                VStack(alignment:.leading) {
                    Text("我的一天")
                        .kerning(0.6)
                        .bold()
                        .font(.system(size: basic))
                    Text("9月20日 周二")
                        .font(.system(size: basic - 3))
                }
                Spacer()
                VStack {
                    Text("每周一学")
                        .foregroundColor(Color("BackgroundColor-Heavy"))
                        .font(.system(size: basic - 3))
                    Text("每日浇水")
                        .font(.system(size: basic - 3))
                }
                ZStack {
                    Color.white.opacity(0.22)
                    HStack(spacing:1) {
                        Text("7:30")
                        Text("|").opacity(0.2)
                        Text("18:20")
                    }
                    .font(.system(size: basic))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                }.fixedSize(horizontal: true, vertical: true)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                   
            }
            Spacer()
            Spacer()
            VStack(alignment:.leading) {
                Text("降雨带：西南 34 公里之外 +44m")
                    .font(.system(size: basic))
                Divider()
                    .background(Color.white)
                    .opacity(0.4)
                    .padding(.top, -5)
                    .padding(.bottom, -15)
                VStack(alignment: .leading, spacing: 2) {
                    Text("五元组：北向 API 提供查询接口 1")
                        .font(.system(size: basic + 4))
                    Text("五元组：北向 API 提供查询接口 2")
                        .font(.system(size: basic + 4))
                    Text("五元组：北向 API 提供查询接口 3")
                        .font(.system(size: basic + 4))
                }
                .padding(.top, -10)
                .padding(.bottom, 1)
                HStack(spacing: 1) {
                    Text("其它 6 个")
                        .padding(.trailing, 3)
                    Text("8 MINUTES AGO")
                        .kerning(0.1)
                        .bold()
                        .padding(.trailing, 3)
                    Text("HCM")
                        .kerning(-1)
                        .bold()
                        .opacity(1)
                        .padding(.trailing, 3)
                    Text("GRAPH")
                        .kerning(-1)
                }
                .font(.system(size: basic - 2))
                .opacity(0.5)
            }
        }
        .padding(.all, 14)
        .background(Color("BackgroundColor"))
        .foregroundColor(.white)
    }
}

@main
struct CyberMeWidget: Widget {
    let kind: String = "CyberMeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CyberMeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("CyberMe")
        .description("智能的提供你最关注的信息")
    }
}

struct CyberMeWidget_Previews: PreviewProvider {
    static var previews: some View {
        CyberMeWidgetEntryView(entry: SimpleEntry(date: Date()))
            .preferredColorScheme(.dark)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
