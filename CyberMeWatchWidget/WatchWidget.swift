//
//  CyberMeWatchWidget.swift
//  CyberMeWatchWidget
//
//  Created by Corkine on 2024/9/7.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: TimelineProvider {
  typealias Entry = SimpleEntry
  //typealias Intent = ConfigurationIntent
  
  func placeholder(in context: Context) -> SimpleEntry {
    //let intent = ConfigurationIntent()
    //intent.tab = "todo"
    return SimpleEntry(date: Date(), dashboard: Dashboard.demo
                       //, intent: intent
    )
  }

  func getSnapshot(//for configuration: Intent,
                   in context: Context, completion: @escaping (SimpleEntry) -> ()) {
    let entry = SimpleEntry(date: Date(), dashboard: Dashboard.demo
                            //, intent: configuration
    )
    completion(entry)
  }

  func getTimeline(//for configuration: Intent,
                   in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    Task.detached {
        let (dashboard, error) = await CyberService.fetchDashboard(location: nil)
        if let dashboard = dashboard {
            let currentDate = Date()
            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
            
            let entry = SimpleEntry(date: currentDate, dashboard: dashboard
                                    //, intent: configuration
            )

            let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            completion(timeline)
        } else {
            let currentDate = Date()
            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
            
            let entry = SimpleEntry(date: currentDate, dashboard: Dashboard.failed(error: error)
                                    //, intent: configuration
            )

            let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }
  }
  
//  func recommendations() -> [IntentRecommendation<Intent>] {
//    return [("car", "车辆信息"), ("todo", "待办和工作信息")]
//      .map { key in
//        let intent = ConfigurationIntent()
//        intent.tab = key.0
//        return IntentRecommendation(intent: intent, description: key.1)
//      }
//  }
}

struct SimpleEntry: TimelineEntry {
  let date: Date
  let dashboard: Dashboard
  //let intent: ConfigurationIntent
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
    let rangeText = carFuelRange != 0.0 ? Text("\(carFuelRange, format: .number)") : Text("N/A")
    ProgressView(value: carFuelPercent, total: 100) {
      VStack(spacing: 0) {
        rangeText
          .font(.system(size: 16))
          .offset(x: 0, y: 3)
        Text("km")
          .font(.system(size: 10))
          .offset(x: 0, y: -1)
      }
    }
    .tint(carFuelPercent < 0.1 ? .yellow : .green)
    .progressViewStyle(CircularProgressViewStyle())
  }
}

struct WorkStatusRangeView: View {
  var dash: Dashboard
  var body: some View {
    let all = dash.todo.count
    let finished = dash.todo.filter({ t in
      t.isFinished
    }).count
    let progress = all == 0 ? 0.0 : (Double(finished) / Double(all)) * 1.0
    let offWork = dash.offWork
    let needCard = dash.workStatus == "🔴"
    let color = colorOfStatus(dash: dash)
    ProgressView(value: progress, total: 1) {
      Image(systemName: offWork ? "moon.haze.fill" :
              needCard ? "exclamationmark.triangle.fill" :"wallet.pass.fill")
        .font(.system(size: 19))
        .foregroundColor(color)
    }
    .tint(color)
    .progressViewStyle(CircularProgressViewStyle())
  }
}

struct TodoCornerView: View {
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
    let todoTop = dash.todo.prefix(4)
    return HStack(alignment: .top) {
      Rectangle()
        .foregroundColor(colorOfStatus(dash: dash))
        .frame(width: 5)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.trailing, 3)
        .padding(.leading, 2)
        .padding(.vertical, 1)
      VStack(alignment: .leading) {
        if todoTop.isEmpty {
          Text("无待办事项")
            .padding(.bottom, 0)
          Text("Have a nice day!")
        } else {
          ForEach(todoTop, id: \.id) { todo in
            if todo.isFinished {
              Text(todo.title)
                .foregroundColor(.gray)
                .strikethrough(true, color: .white)
            } else {
              Text(todo.title)
            }
          }
          .lineLimit(1)
          .truncationMode(.tail)
          .font(.system(size: 14))
        }
      }
      Spacer()
    }
  }
}

let carUrl = URL(string: "cyberme-watch://car")

let todoUrl = URL(string: "cyberme-watch://todo")

struct CyberMeWatchWidgetEntryView : View {
  @Environment(\.isLuminanceReduced) var isLuminanceReduced
  @Environment(\.widgetFamily) var family
  var entry: Provider.Entry

  var body: some View {
    if isLuminanceReduced {
      switch family {
      case .accessoryCircular:
        WorkStatusRangeView(dash: entry.dashboard)
      case .accessoryCorner:
        TodoCornerView(dash: entry.dashboard)
      case .accessoryRectangular:
        TodoView(dash: entry.dashboard)
      case .accessoryInline:
        Text("Unsupport widget")
      default:
        Text("Unsupport widget")
      }
    } else {
      switch family {
      case .accessoryCircular:
        WorkStatusRangeView(dash: entry.dashboard)
          .widgetURL(todoUrl)
      case .accessoryCorner:
        TodoCornerView(dash: entry.dashboard)
          .widgetURL(todoUrl)
      case .accessoryRectangular:
        TodoView(dash: entry.dashboard)
          .widgetURL(todoUrl)
      case .accessoryInline:
        Text("Unsupport widget")
      default:
        Text("Unsupport widget")
      }
    }
  }
}

struct CyberMeWatchWidgetCarEntryView : View {
  @Environment(\.widgetFamily) var family
  var entry: Provider.Entry

  var body: some View {
    switch family {
    case .accessoryCircular:
      CarRangeView(dash: entry.dashboard)
    case .accessoryInline:
      CarInlineView(dash: entry.dashboard)
    case .accessoryCorner:
      Text("Unsupport widget")
    case .accessoryRectangular:
      Text("Unsupport widget")
    @unknown default:
      Text("Unsupport widget")
    }
  }
}

struct CyberMeWatchWidget: Widget {
  let kind: String = "CyberMeWatchWidget"
  
  let backgroundData = BackgroundManager()

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind,
                        //intent: ConfigurationIntent.self,
                        provider: Provider()) { entry in
      CyberMeWatchWidgetEntryView(entry: entry)
    }
    .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryRectangular])
    .configurationDisplayName("工作与待办")
    .description("工作状态与待办事项")
    .onBackgroundURLSessionEvents { (sessionIdentifier, completion) in
        if sessionIdentifier == self.kind {
            self.backgroundData.update()
            self.backgroundData.completionHandler = completion
            print("background update")
        }
    }
  }
}

struct CyberMeWatchCarWidget: Widget {
  let kind: String = "CyberMeWatchWidgetCar"
  
  let backgroundData = BackgroundManager()

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind,
                        //intent: ConfigurationIntent.self,
                        provider: Provider()) { entry in
      CyberMeWatchWidgetCarEntryView(entry: entry)
    }
    .supportedFamilies([.accessoryCircular, .accessoryInline])
    .configurationDisplayName("车辆信息")
    .description("大众车联网信息")
    .onBackgroundURLSessionEvents { (sessionIdentifier, completion) in
        if sessionIdentifier == self.kind {
            self.backgroundData.update()
            self.backgroundData.completionHandler = completion
            print("background update for car")
        }
    }
  }
}

@main
struct CyberMeWatchWidgets: WidgetBundle {
  @WidgetBundleBuilder
  var body: some Widget {
      CyberMeWatchWidget()
      CyberMeWatchCarWidget()
  }
}

struct CyberMeWatchWidget_Previews: PreviewProvider {
  static var previews: some View {
    CyberMeWatchWidgetEntryView(entry: SimpleEntry(date: Date(), dashboard: Dashboard.demo
                                                   //,intent: ConfigurationIntent()
                                                  ))
      .previewContext(WidgetPreviewContext(family: .accessoryCircular))
  }
}
