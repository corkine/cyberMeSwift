//
//  WidgetProvider.swift
//  CyberMeWidgetExtension
//
//  Created by Corkine on 2024/9/4.
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
        Task.detached {
            let (location, err) = await WidgetLocation.fetchIfTime()
            if let err = err {
                CyberService.sendNotice(msg: "Error when fetch location: \(err.localizedDescription)")
            } else {
                CyberService.trackUrl(location: location!, by: "corkine@CMIXR")
            }
        }
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

struct QuickProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuickEntry {
      QuickEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (QuickEntry) -> ()) {
        completion(QuickEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickEntry>) -> ()) {
      let entry = QuickEntry(date: Date())
      let timeline = Timeline(entries: [entry], policy: .never)
      completion(timeline)
    }
}

struct QuickEntry: TimelineEntry {
    let date: Date
}
