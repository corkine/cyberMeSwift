//
//  Dashboard.swift
//  helloSwift
//
//  Created by Corkine on 2022/11/11.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var service:CyberService
    @Environment(\.colorScheme) var currentMode
    var summary: ISummary
    var body: some View {
        NavigationView {
            ZStack(alignment:.bottom) {
                if currentMode == .light {
                    Image("background_image")
                        .resizable()
                        .scaledToFit()
                }
                GeometryReader { proxy in
                    ScrollView(.vertical,showsIndicators:false) {
                        HStack(alignment:.top) {
                            VStack(alignment:.leading,spacing: 10) {
                                HStack(alignment:.center) {
                                    Button("我的一天") {
                                        service.syncTodo {
                                            service.fetchSummary()
                                            Dashboard.updateWidget(inSeconds: 0)
                                        }
                                    }
                                    .font(.title2)
                                    .foregroundColor(Color.blue)
                                    
                                    Spacer()
                
                                    Button {
                                        UIApplication.shared.open(URL(string: Default.UrlScheme.shortcutUrl("TODO"))!)
                                    } label: {
                                        Label("", systemImage: "plus")
                                            .labelStyle(.iconOnly)
                                    }
                                    .scaleEffect(1.2)
                                    .padding(.trailing, 8)

                                }
                                .padding(.bottom, 10)
                                
                                
                                ToDoView(todo: summary.todo,
                                         weekPlan: summary.weekPlan)
                                
                                DashboardInfoView(summary: summary)
                                    .padding(.top, 30)
                                    .padding(.bottom, 20)
                                
                                Text("本周计划")
                                    .font(.title2)
                                    .foregroundColor(Color.blue)
                                
                                ForEach(summary.weekPlan, id: \.id) { plan in
                                    DashboardPlanView(weekPlan: plan, proxy: proxy)
                                }
                                .padding(.bottom, 10)
                                
                                Spacer()
                            }
                            .padding(.top, 20)
                            .padding(.leading, 20)
                            .padding(.trailing, 5)
                            .navigationTitle("\(TimeUtil.getWeedayFromeDate(date: Date(), withMonth: true))")
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(summary: .default)
            .previewDevice(.init(rawValue: "iPhone XR"))
        //DashboardInfoView()
        //DashboardPlanView()
    }
}

struct DashboardInfoView: View {
    var summary: ISummary
    var scale = 1.8
    @State var offset = -25.0
    @Environment(\.colorScheme) var currentMode
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                    .foregroundColor(Color("backgroundGray"))
                HStack(alignment:.center) {
                    Image("jiangluosan")
                        .resizable()
                        .scaledToFit()
                        .clipped()
                        .frame(width: proxy.size.width / 4,
                               height: proxy.size.height)
                        .padding(.all, 0)
                        .scaleEffect(CGSize(width: scale, height: scale),
                                     anchor: UnitPoint(x: 0.5, y: 0.7))
                        .offset(x: offset)
                        .animation(.spring(), value: offset)
                    Spacer()
                    VStack(alignment:.leading) {
                        HStack {
                            if summary.work.NeedWeekLearn ?? false {
                                Text("✕ 每周一学")
                                    .foregroundColor(.red.opacity(0.7))
                            } else {
                                Text("✓ 每周一学")
                            }
                            if summary.work.NeedDiaryReport ?? false {
                                Text("✕ 每日日报")
                                    .foregroundColor(.red.opacity(0.7))
                            } else {
                                Text("✓ 每日日报")
                            }
                        }
                        HStack(spacing: 0) {
                            if summary.work.WorkHour ?? 0.0 != 0.0 {
                                Text("已工作")
                                    .scaledToFit()
                                Text(String(format: "%.1f", summary.work.WorkHour ?? 0.0))
                                    .padding(.horizontal, 8)
                                    .scaleEffect(x: 1.3, y: 1.3,
                                                 anchor: UnitPoint(x: 0.5, y: 0.7))
                                Text("小时")
                                    .padding(.trailing, 10)
                                    .scaledToFit()
                            }
                            ForEach(summary.work.SignIn.map { s in s.timeSimple }, id:\.self) { time in
                                RoundBG(Text("\(time)"), fill:
                                            currentMode == .light ? .white : Color("grayBackground"))
                                    .font(.system(size: 12))
                                    .padding(.trailing, 2)
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
        .frame(height: 120)
        .onAppear {
            self.offset = 10
        }
    }
}

struct RoundBG<T: View>: View {
    var of: T
    var fill: Color
    init(_ of: T, fill: Color = Color.gray.opacity(0.1)) {
        self.of = of
        self.fill = fill
    }
    var body: some View {
        ZStack(alignment:.center) {
            fill
            of
                .padding(.vertical, 1.0)
                .padding(.horizontal, 10.0)
        }.clipShape(RoundedRectangle(cornerRadius: 15))
            .fixedSize(horizontal: true, vertical: true)
    }
}

struct DashboardPlanView: View {
    @EnvironmentObject var service:CyberService
    @Environment(\.colorScheme) var currentMode
    let proxy: GeometryProxy
    var weekPlan: ISummary.WeekPlanItem
    init(weekPlan: ISummary.WeekPlanItem, proxy: GeometryProxy) {
        self.proxy = proxy
        self.weekPlan = weekPlan
    }
    var body: some View {
        ZStack {
            // MARK: 背景
            RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                .foregroundColor(Color("backgroundGray"))
            // MARK: 图像
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Image("plant")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: proxy.size.width / 6, minHeight: 50)
                        .opacity(0.9)
                }
            }
            .padding(.trailing, 15)
            VStack(alignment:.leading, spacing: 20) {
                // MARK: 标题
                HStack {
                    Text(weekPlan.name)
                        .font(.title3)
                        .foregroundColor(.gray)
                        .padding(.bottom, -5)
                    Spacer()
                    RoundBG(Text("\(String(format: "%.0f", weekPlan.progress ?? 0.0))%"),
                            fill: currentMode == .light ? .white : Color("grayBackground"))
                }
                // MARK: 内容
                HStack(alignment: .bottom) {
                    // MARK: 圆点和日志
                    HStack(alignment:.top, spacing: 0.0) {
                        // MARK: 圆点
                        ZStack {
                            Rectangle()
                                .fill(currentMode == .light ? Color("lightGray") : .gray)
                                .frame(width: 1)
                                .padding(.vertical, 3)
                            VStack(alignment: .leading) {
                                ForEach(weekPlan.logs, id:\.id) { _ in
                                    Circle()
                                        .foregroundColor(
                                            currentMode == .light ? Color("lightGray") : .gray)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                        .padding(.trailing, 10)
                        .fixedSize(horizontal: true, vertical: false)
                        
                        // MARK: 日志
                        HStack(alignment:.bottom, spacing: 0.0) {
                            VStack(alignment:.leading, spacing: 4) {
                                ForEach(weekPlan.logs, id:\.self) { log in
                                    Text(log.name)
                                        .contextMenu {
                                            Button("删除") {
                                                removeLogAndRefresh(log.id)
                                            }
                                            .accentColor(Color.red)
                                        }
                                }
                                .lineLimit(1)
                            }
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                        }
                    }
                    .fixedSize(horizontal: true, vertical: true)
                }
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 15)
        }
    }
    func removeLogAndRefresh(_ logId: String) {
        service.removeLog(weekPlan.id, logId) {
           service.fetchSummary()
        }
    }
}
