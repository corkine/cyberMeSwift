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
                                    UIApplication.shared.open(URL(string: Default.UrlScheme.todoApp)!)
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
                                .padding(.bottom, 5)
                            
                            // MARK: - 健身卡片
                            Button("形体之山") {
                                service.refreshAndUploadHealthInfo()
                            }
                            .font(.title2)
                            .foregroundColor(Color.blue)
                            .padding(.top, 10)
                            .padding(.bottom, 5)
                            
                            FitnessView(data:
                                            (Int(summary.fitness.active),
                                             Int(summary.fitness.exercise ?? 0),
                                             Int(summary.fitness.mindful ?? 0)),
                                        geo: proxy,
                                        height: 150)
                            
                            if !service.bodyMass.isEmpty {
                                ZStack {
                                    Color("backgroundGray")
                                    VStack(alignment: .leading,
                                    spacing: 10) {
                                        Text("30 天体重趋势")
                                        BodyMassChartView(
                                            data: service.bodyMass,
                                            color: .red)
                                    }
                                    .padding(.top, 18)
                                    .padding([.leading, .trailing], 25)
                                    .padding(.bottom, 15)
                                }
                                .onTapGesture {
                                    service.showBodyMassSheetFetch = (true, false)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .frame(height: 150)
                                .zIndex(10)
                            }
                            
                            // MARK: - 周计划
                            if !summary.weekPlan.isEmpty {
                                Text("本周计划")
                                    .font(.title2)
                                    .foregroundColor(Color.blue)
                                    .padding(.top, 15)
                                
                                ForEach(summary.weekPlan, id: \.id) { plan in
                                    DashboardPlanView(weekPlan: plan, proxy: proxy)
                                }
                                .padding(.bottom, 0)
                                .zIndex(10)
                            }
            
                            Spacer()
                            
                            // MARK: - 背景
                            if currentMode == .light {
                                Image("background_image")
                                    .resizable()
                                    .scaledToFill()
                                    .padding(.leading, -20)
                                    .padding(.trailing, -10)
                                    .padding(.top, -200)
                                    .zIndex(0)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.leading, 20)
                        .padding(.trailing, 5)
                        .opacity(summary.isDemo ? 0 : 1)
                        Spacer()
                    }
                }
                .navigationTitle("\(TimeUtil.getWeedayFromeDate(date: Date(), withMonth: true))")
                //.padding(.top, 0.2)
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        var defaultSummary = ISummary.default
        defaultSummary.isDemo = false
        defaultSummary.weekPlan[0].logs![0].name = "Very Long Very Long Very Long Very Long Very Long Very Long"
        return DashboardView(summary: defaultSummary)
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
                            if summary.work.WorkHour ?? 0.0 != 0.0 && summary.work.SignIn.count == 0 {
                                RoundBG(Text(""))
                                    .font(.system(size: 12))
                                    .padding(.trailing, 2)
                                    .opacity(0.0)
                            } else {
                                ForEach(summary.work.signInSort, id:\.self) { time in
                                    RoundBG(Text("\(time)"), fill:
                                                currentMode == .light ? .white : Color("grayBackground"))
                                        .font(.system(size: 12))
                                        .padding(.trailing, 2)
                                }
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
    @State var editLog: ISummary.WeekPlanItem.WeekPlanLog?
    @State var editPlan: ISummary.WeekPlanItem?
    @State var updateLogRemoveDate: Bool = false
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
                        .contextMenu {
                            Button("修改") {
                                editPlan = weekPlan
                            }
                        }
                    Spacer()
                    RoundBG(Text("\(String(format: "%.0f", weekPlan.progress ?? 0.0))%"),
                            fill: currentMode == .light ? .white : Color("grayBackground"))
                }
                .padding(.bottom, -5)
                // MARK: 内容
                HStack(alignment: .bottom) {
                    // MARK: 圆点和日志
                    HStack(alignment:.center, spacing: 0.0) {
                        // MARK: 圆点
                        ZStack {
                            Rectangle()
                                .fill(currentMode == .light ? Color("lightGray") : .gray)
                                .frame(width: 1)
                                .padding(.vertical, 5)
                                .opacity((weekPlan.logs ?? []).isEmpty ? 0 : 1)
                            VStack(alignment: .leading,spacing: 13) {
                                ForEach(weekPlan.logs ?? [], id:\.id) { log in
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
                                ForEach(weekPlan.logs ?? [], id:\.self) { log in
                                    Text(log.name)
                                        .contextMenu {
                                            Button("修改") {
                                                updateLogRemoveDate = false
                                                editLog = log
                                            }
                                            Button("移到最前") {
                                                moveItem(log: log, type: .toStart)
                                            }
                                            Button("移到最后") {
                                                moveItem(log: log, type: .toEnd)
                                            }
                                            Divider()
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
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            .sheet(item: $editLog) { item in
                SimpleInfoView(saveAction: { name, desc in
                    service.editLog(itemId: weekPlan.id, id: item.id, name: name,
                                    desc: desc, delta: 10,
                                    update: updateLogRemoveDate ? nil : item.update) { err in
                        editLog = nil
                        service.fetchSummary()
                    }
                }, title: "修改日志",
                   name: item.name,
                   desc: item.description ?? "")
            }
            .sheet(item: $editPlan) { item in
                SimpleInfoView(saveAction: { name, desc in
                    service.editItem(id: item.id, name: name, desc: desc) { err in
                        editPlan = nil
                        service.fetchSummary()
                    }
                }, title: "修改计划",
                   name: item.name,
                   desc: item.description ?? "")
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
    func moveItem(log: ISummary.WeekPlanItem.WeekPlanLog,
                  type: CyberService.EditLogActionType) {
        service.editLog(itemId: weekPlan.id, id: log.id, name: log.name,
                        desc: log.description ?? "", delta: log.progressDelta,
                        update: log.update, type: type) {err in
            service.fetchSummary()
        }
    }
}
