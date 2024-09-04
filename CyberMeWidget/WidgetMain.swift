//
//  CyberMeWidget.swift
//  CyberMeWidget
//
//  Created by corkine on 2022/9/20.
//

import WidgetKit
import SwiftUI

@available(iOSApplicationExtension 16.0, *)
struct CyberMeWidget: Widget {
    let kind: String = "CyberMeWidget"
    
    let backgroundData = BackgroundManager()
    
    var supportFamilies: [WidgetFamily] {
        return [WidgetFamily.systemMedium,
                WidgetFamily.systemSmall,
                WidgetFamily.accessoryInline,
                WidgetFamily.accessoryRectangular]
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CyberMeWidgetEntryView(entry: entry)
        }
        .supportedFamilies(supportFamilies)
        .configurationDisplayName("CyberMe")
        .description("待办事项, 车辆状态, 打卡、天气、健身与运动")
        .onBackgroundURLSessionEvents { (sessionIdentifier, completion) in
            if sessionIdentifier == self.kind {
                self.backgroundData.update()
                self.backgroundData.completionHandler = completion
                print("background update")
            }
        }
    }
}

@available(iOSApplicationExtension 16.0, *)
struct QuickWidget: Widget {
    let kind: String = "CyberMeQuickWidget"
    
    var supportFamilies: [WidgetFamily] {
        return [WidgetFamily.accessoryCircular]
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuickProvider()) { entry in
           QuickWidgetEntryView(entry: entry)
        }
        .supportedFamilies(supportFamilies)
        .configurationDisplayName("CyberMeQuick")
        .description("快速操作")
    }
}

@available(iOSApplicationExtension 16.0, *)
@main
struct CyberMeWidgets: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        CyberMeWidget()
        QuickWidget()
    }
}

struct CyberMeWidget_Previews: PreviewProvider {
    static var previews: some View {
      CyberMeWidgetEntryView(entry: SimpleEntry(date: Date(),
                                                dashboard: Dashboard.demo))
      .preferredColorScheme(.dark)
      .previewContext(WidgetPreviewContext(family: .systemSmall))
      .previewDisplayName("Car")
//        if #available(iOSApplicationExtension 16.0, *) {
//            CyberMeWidgetEntryView(entry: SimpleEntry(date: Date(),
//                                                      dashboard: Dashboard.demo))
//            .preferredColorScheme(.dark)
//            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
//            .previewDisplayName("Todo")
//            CyberMeWidgetEntryView(entry: SimpleEntry(date: Date(),
//                                                      dashboard: Dashboard.demo))
//            .previewContext(WidgetPreviewContext(family: .accessoryInline))
//            .previewDisplayName("Weather")
//            CyberMeWidgetEntryView(entry: SimpleEntry(date: Date(),
//                                                      dashboard: Dashboard.demo))
//            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
//            .previewDisplayName("Shortcut")
//            CyberMeWidgetEntryView(entry: SimpleEntry(date: Date(),
//                                                      dashboard: Dashboard.demo))
//            .preferredColorScheme(.dark)
//            .previewContext(WidgetPreviewContext(family: .systemMedium))
//        } else {
//            CyberMeWidgetEntryView(entry: SimpleEntry(date: Date(),
//                                                      dashboard: Dashboard.demo))
//            .preferredColorScheme(.dark)
//            .previewContext(WidgetPreviewContext(family: .systemMedium))
//        }
    }
}
