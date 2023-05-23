//
//  Dashboard.swift
//  helloSwift
//
//  Created by Corkine on 2022/11/11.
//

import SwiftUI
import SwiftUIFlowLayout

struct DashboardView: View {
    @EnvironmentObject var service:CyberService
    @Environment(\.colorScheme) var currentMode
    var summary: ISummary
    
    @ViewBuilder var myDayContextMenu: some View {
        // MARK: TODO 同步
        Button("同步 Microsoft TODO") {
            service.syncTodo = true
            service.syncTodo {
                service.syncTodo = false
                service.fetchSummary()
                Dashboard.updateWidget(inSeconds: 0)
            }
        }
        // MARK: HCM 登录
        Button("尝试 HCM 登录") {
            service.syncTodo = true
            service.syncTodo(isLogin: true) {
                service.syncTodo = false
            }
        }
        // MARK: 车票信息
        Button("最近车票信息") {
            service.showTicketView = true
        }
        // MARK: 今天日记
        Button("今天日记") {
            service.showLastDiary = true
        }
        // MARK: GPT
        Button("GPT 问答") {
            service.showGptQuestionView = true
        }
        // MARK: 工作和休假标记
        Button("标记今天不工作") {
            service.forceWork(work: false) {
                Dashboard.updateWidget(inSeconds: 0)
            }
        }
        Button("标记今天工作") {
            service.forceWork(work: true) {
                Dashboard.updateWidget(inSeconds: 0)
            }
        }
        Button("取消今天标记") {
            service.forceWork(clean:true) {
                Dashboard.updateWidget(inSeconds: 0)
            }
        }
    }
    
    @ViewBuilder var healthContextMenu: some View {
        Button("同步 Apple Health") {
            service.refreshAndUploadHealthInfo()
        }
    }
    
    @ViewBuilder var buildTodoPart: some View {
        HStack(alignment:.center) {
            Text("我的一天")
            .font(.title2)
            .foregroundColor(Color.blue)
            .contextMenu { myDayContextMenu }
            
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
        .fullScreenCover(isPresented: $service.syncTodo) {
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(.circular)
                Text("正在同步，请稍后")
            }
        }
        
        ToDoView(todo: summary.todo,
                 weekPlan: summary.weekPlan)
    }
    
    @ViewBuilder func buildHealthPart(proxy:GeometryProxy) -> some View {
        // MARK: 健身卡片
        Text("形体之山")
        .font(.title2)
        .foregroundColor(Color.blue)
        .padding(.top, 10)
        .padding(.bottom, 5)
        .contextMenu { healthContextMenu }
        
        FitnessView(data:
                        (Int(summary.fitness.active),
                         Int(summary.fitness.exercise ?? 0),
                         Int(summary.fitness.mindful ?? 0)),
                    geo: proxy,
                    height: 150)
        
        // MARK: 30 天体重趋势
        if service.bodyMass.count >= 2 {
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
                service.showBodyMassView(withFetch: false)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .frame(height: 150)
            .zIndex(10)
        }
    }
    
    var updateMovie: [ISummary.MovieItem] {
        summary.movie.filter { $0.lastData != nil }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                ScrollView(.vertical,showsIndicators:false) {
                    HStack(alignment:.top) {
                        VStack(alignment:.leading,spacing: 10) {
                            // MARK: - 我的一天
                            buildTodoPart
                            
                            // MARK: - 工作状态
                            DashboardInfoView(summary: summary)
                                .padding(.top, 30)
                                .padding(.bottom, 5)
                            
                            // MARK: - 形体之山
                            buildHealthPart(proxy: proxy)
                            
                            // MARK: - 快递更新
                            if !summary.express.isEmpty {
                                Text("快递更新")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                    .padding(.top, 15)
                                    .zIndex(10)
                                ExpressUpdateView(items: summary.express)
                                    .zIndex(10)
                            }
                            
                            // MARK: - 影视更新
                            if !updateMovie.isEmpty {
                                Text("影视更新")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                    .padding(.top, 15)
                                    .zIndex(10)
                                MovieUpdateView(items: updateMovie)
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
                            
                            // MARK: - 背景 -
                            if currentMode == .light {
                                Image("background_image")
                                    .resizable()
                                    .scaledToFill()
                                    .padding(.leading, -20)
                                    .padding(.trailing, -10)
                                    .padding(.top,
                                             summary.weekPlan.isEmpty ?
                                                service.bodyMass.count < 2 ? -100 : -200 :
                                                service.bodyMass.count < 2 ? -200 : -100)
                                    .zIndex(0)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.leading, 15)
                        .padding(.trailing, 5)
                        .opacity(summary.isDemo ? 0 : 1)
                        Spacer()
                    }
                }
                .navigationTitle("\(TimeUtil.getWeedayFromeDate(date: Date(), withMonth: true))")
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var service = CyberService()
    static var previews: some View {
        var defaultSummary = ISummary.default
        defaultSummary.isDemo = false
        defaultSummary.movie = [
            ISummary.MovieItem(name: "曼达洛人", url: "https://123.com", data: ["S03E02"], last_update: "20220301"),
            ISummary.MovieItem(name: "曼达洛人", url: "https://123.com", data: ["S03E02"], last_update: "20220301"),
            ISummary.MovieItem(name: "曼达洛人", url: "https://123.com", data: ["S03E02"], last_update: "20220301")
        ]
        defaultSummary.weekPlan[0].logs![0].name = "Very Long Very Long Very Long Very Long Very Long Very Long"
        return DashboardView(summary: defaultSummary)
            .environmentObject(service)
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
    
    @ViewBuilder
    func logContextMenu(_ log:ISummary.WeekPlanItem.WeekPlanLog) -> some View {
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
                                    Text(log.name).contextMenu { logContextMenu(log) }
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

struct MovieUpdateView: View {
    @EnvironmentObject var service: CyberService
    @State var showAlert = false
    @State var response: SimpleResult?
    var items: [ISummary.MovieItem]
    var body: some View {
        FlowLayout(mode: .scrollable,
                   items: self.items,
                   itemSpacing: 5) { movie in
            HStack(spacing: 0) {
                Text(movie.name)
                Text("|")
                    .padding(.horizontal, 5)
                    .opacity(0.1)
                Text(movie.lastData ?? "NEW")
                    .opacity(0.5)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(Color("backgroundGray"))
            .cornerRadius(10)
            .onTapGesture {
                if let url = URL(string: movie.url) {
                    UIApplication.shared.open(url)
                }
            }
            .onLongPressGesture {
                service.markMovieWatched(name: movie.name, watched: movie.lastData ?? "") {
                    response in
                    self.response = response
                    showAlert = true
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("结果"),
                      message: Text(response?.message ?? "内部错误"),
                      dismissButton: .default(Text("确定")){
                          showAlert = false
                          response = nil
                          service.fetchSummary()
                      })
            }
        }
        .padding(.leading, -5)
    }
}

struct ExpressUpdateView: View {
    @EnvironmentObject var service: CyberService
    @State var showSheet = false
    @State var deleteItem: ISummary.ExpressItem?
    var items: [ISummary.ExpressItem]
    var body: some View {
        VStack(spacing: 10) {
            ForEach(items, id: \.id) { item in
                VStack(alignment:.leading) {
                    HStack {
                        Circle()
                            .fill(item.status == 1 ? Color.green : Color.orange)
                            .frame(width: 15,height: 15)
                        Text(item.name ?? "📦")
                        Spacer()
                    }
                    Text(item.info ?? "")
                        .lineLimit(1)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(Color("backgroundGray"))
                .cornerRadius(10)
                .onTapGesture { deleteItem = item; showSheet = true }
            }
        }
        .alert(isPresented: $showSheet) {
            Alert(title: Text("\(deleteItem!.name ?? "📦快递")"),
                  message: Text("\(deleteItem?.info ?? "没有信息")"),
                  primaryButton: .destructive(Text("删除")) {
                guard let id = deleteItem?.id else { showSheet = false; return }
                service.deleteTrackExpress(no: id) { _ in
                    showSheet = false
                    Command.expressDelete(id: id).dispatch(afterSeconds: 5)
                }
            }, secondaryButton: .default(Text("确定")) {
                showSheet = false
            })
        }
    }
}
