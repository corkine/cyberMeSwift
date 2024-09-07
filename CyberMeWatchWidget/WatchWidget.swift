//
//  CyberMeWatchWidget.swift
//  CyberMeWatchWidget
//
//  Created by Corkine on 2024/9/7.
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

  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    Task.detached {
        let (dashboard, error) = await CyberService.fetchDashboard(location: nil)
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

func colorOfStatus(dash: Dashboard) -> Color {
  switch dash.workStatus {
  case "🟢": return .green
  case "🟡": return .yellow
  case "🔴": return .red
  case "⚪️": return .white
  case "⚫️": return .gray
  case "🔵": return .blue
  default: return .white
  }
}

struct CarRangeView: View {
  var dash: Dashboard
  var body: some View {
    let carFuelPercent = dash.car?.status.fuelLevel ?? 100
    let carFuelRange = dash.car?.status.range ?? 0.0
    ProgressView(value: carFuelPercent, total: 100) {
      VStack(spacing: 0) {
        Text("\(carFuelRange, format: .number)")
          .offset(x: 0, y: 3)
        Text("km")
          .font(.system(size: 10))
          .offset(x: 0, y: -1)
      }
    }
    .tint(.green)
    .progressViewStyle(CircularProgressViewStyle())
  }
}

struct CornerView: View {
  var dash: Dashboard
  var body: some View {
    let all = dash.todo.count
    let finished = dash.todo.filter({ t in
      t.isFinished
    }).count
    let progress = all == 0 ? 0.0 : (Double(finished) / Double(all)) * 1.0
    let color = colorOfStatus(dash: dash)
    return Image(systemName: "list.bullet.circle.fill")
      .font(.system(size: 35))
      .foregroundColor(color)
      .widgetLabel {
        ProgressView(value: progress) {
          Text("\(finished)/\(all) ")
        }
        .tint(color)
      }
  }
}

struct CarInlineView: View {
  var dash: Dashboard
  var body: some View {
    let fuel = String(format:"%.0f", dash.car?.tripStatus.fuel ?? 0)
    let mile = String(format:"%.0f", dash.car?.tripStatus.mileage ?? 0)
    let cost = String(format:"%.1f", dash.car?.tripStatus.averageFuel ?? 0)
    return ViewThatFits {
      Text("\(fuel)L · \(mile)km · \(cost)L/100km")
      Text("\(fuel)L · \(mile)km")
      Text("\(fuel)L")
    }
  }
}

struct TodoView: View {
  var dash: Dashboard
  var body: some View {
    return HStack(alignment: .top) {
      Rectangle()
        .foregroundColor(colorOfStatus(dash: dash))
        .frame(width: 5)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.trailing, 3)
        .padding(.vertical, 1)
      VStack(alignment: .leading) {
        ForEach(dash.todo, id: \.id) { todo in
          if todo.isFinished {
            Text(todo.title)
              .strikethrough()
          } else {
            Text(todo.title)
          }
        }
        .lineLimit(1)
        .truncationMode(.tail)
        .font(.system(size: 15))
      }
      Spacer()
    }
  }
}

struct CyberMeWatchWidgetEntryView : View {
  @Environment(\.widgetFamily) var family
  var entry: Provider.Entry

  var body: some View {
    switch family {
    case .accessoryCircular:
      CarRangeView(dash: entry.dashboard)
    case .accessoryCorner:
      CornerView(dash: entry.dashboard)
    case .accessoryInline:
      CarInlineView(dash: entry.dashboard)
    case .accessoryRectangular:
      TodoView(dash: entry.dashboard)
    @unknown default:
      Text("Unsupport widget")
    }
  }
}

@main
struct CyberMeWatchWidget: Widget {
  let kind: String = "CyberMeWatchWidget"
  
  let backgroundData = BackgroundManager()

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
        CyberMeWatchWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("WatchMe")
    .description("工作状态, 待办事项, 车辆状态")
    .onBackgroundURLSessionEvents { (sessionIdentifier, completion) in
        if sessionIdentifier == self.kind {
            self.backgroundData.update()
            self.backgroundData.completionHandler = completion
            print("background update")
        }
    }
  }
}

struct CyberMeWatchWidget_Previews: PreviewProvider {
  static var previews: some View {
    CyberMeWatchWidgetEntryView(entry: SimpleEntry(date: Date(), dashboard: Dashboard.demo))
      .previewContext(WidgetPreviewContext(family: .accessoryCircular))
  }
}
