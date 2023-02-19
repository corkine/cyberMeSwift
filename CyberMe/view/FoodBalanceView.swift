//
//  FoodBalance.swift
//  helloSwift
//
//  Created by Corkine on 2022/10/28.
//

import SwiftUI
import CoreData

enum FoodCategory: String, CaseIterable, Identifiable {
    case all = "所有类型"
    case energy = "碳水"
    case suger = "甜点"
    case drink = "饮品"
    case fat = "油炸"
    case reflect = "反馈"
    case other = "其它"
    case placeholder = "占位符"
    var id: FoodCategory { self }
    var description: String {
        switch self {
        case .all: return "all"
        case .energy: return "energy"
        case .suger: return "suger"
        case .drink: return "drink"
        case .fat: return "fat"
        case .other: return "other"
        case .reflect: return "reflect"
        case .placeholder: return "placeholder"
        }
    }
    static func descToCategory(desc:String?) -> Self {
        if desc == nil { return .other }
        switch desc! {
        case "all": return .all
        case "energy": return .energy
        case "suger": return .suger
        case "drink": return .drink
        case "fat": return .fat
        case "other": return .other
        case "reflect": return .reflect
        case "placeholder": return .placeholder
        default: return .other
        }
    }
}

struct FoodBalanceView: View {
    @State var filter: FoodCategory = .all
    @State var showAdd = false
    @State var showBodyMass = false
    
    @EnvironmentObject var service: CyberService
    
    @AppStorage("blance.showCompleted")
    var foodShowCompleted = true
    
    struct FetchView: View {

        @Binding var showCompleted: Bool
        
        @Environment(\.managedObjectContext) var context
        
        @EnvironmentObject var service: CyberService
        
        @FetchRequest
        var newItems: FetchedResults<FoodAccountDAO>
        
        @FetchRequest(
            sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)],
            predicate: NSPredicate(format: "solved == true"))
        var solvedItems: FetchedResults<FoodAccountDAO>
        
        init(forCategory filter: FoodCategory?, foodShowCompleted: Binding<Bool>) {
            let req = FoodAccountDAO.fetchRequest()
            req.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            let sol = NSPredicate(format: "solved == false")
            if filter != nil && filter != .all {
                let cate = NSPredicate(format: "category == %@", filter!.description)
                req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [sol, cate])
            } else {
                req.predicate = sol
            }
            _newItems = FetchRequest(fetchRequest: req)
            _showCompleted = foodShowCompleted
        }
        
        @State var op = 0.0
        
        var body: some View {
            List {
                SwiftUI.Section {
                    ForEach(newItems) { item in
                        NavigationLink(destination: {
                            FoodBalanceEditView(item: item)
                        }, label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.name ?? "无名称")
                                    Text(FoodCategory.descToCategory(desc: item.category).rawValue)
                                }
                                Spacer()
                                Text(String(format: "%.0f cal", item.calories))
                                    .foregroundColor(item.calories < 0 ? .green : .red)
                                    .padding(.trailing, 10)
                            }
                        })
                        .contextMenu {
                            if FoodCategory.descToCategory(desc: item.category) != .placeholder {
                                Button {
                                    withAnimation {
                                        
                                    }
                                } label: {
                                    Label("从此项复制", systemImage: "doc.on.doc")
                                }
                                Button {
                                    withAnimation {
                                        item.solved = true
                                        try! context.save()
                                    }
                                } label: {
                                    Label("标记已结束", systemImage: "arrow.3.trianglepath")
                                }
                                Divider()
                            }
                            Button {
                                withAnimation {
                                    context.delete(item)
                                }
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                    }
                } header: {
                    HStack {
                        Image(systemName: "list.dash")
                        Text("正进行")
                    }
                }
                if showCompleted {
                    SwiftUI.Section {
                        ForEach(solvedItems) { item in
                            NavigationLink(destination: {
                                FoodBalanceEditView(item: item)
                            }, label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(item.name ?? "无名称")
                                            .strikethrough()
                                        Text(FoodCategory.descToCategory(desc: item.category).rawValue)
                                    }
                                    Spacer()
                                    Text(String(format: "%.0f cal", item.calories))
                                        .padding(.trailing, 10)
                                }
                            })
                            .contextMenu {
                                Button {
                                    withAnimation {
                                        item.solved = false
                                        try! context.save()
                                    }
                                } label: {
                                    Label("标记未结束", systemImage: "list.dash")
                                }
                                Divider()
                                Button {
                                    withAnimation {
                                        context.delete(item)
                                    }
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                        }
                    } header: {
                        HStack {
                            Image(systemName: "arrow.3.trianglepath")
                            Text("已完成")
                        }
                    }
                }
            }
            .opacity(op)
            .onAppear {
                withAnimation(.spring()) {
                    op = 1.0
                }
            }
            .onChange(of: newItems.count) { count in
                service.setBlanceCount(count)
                service.balanceCount = count
            }
        }
    }
    
    var body: some View {
        NavigationView {
            FetchView(forCategory: filter, foodShowCompleted: $foodShowCompleted)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            showBodyMass = true
                        } label: {
                            Text("体重管理")
                        }
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button {
                            showAdd = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        Menu {
                            Picker("食物类别", selection: $filter) {
                                ForEach(FoodCategory.allCases) { category in
                                    Text(category.rawValue).tag(category)
                                }
                            }
                            .pickerStyle(.inline)
                            
                            Toggle(isOn: $foodShowCompleted) {
                                Label("显示已完成的条目", systemImage: "arrow.3.trianglepath")
                            }
                        } label: {
                            Label("过滤", systemImage: "gearshape.fill")
                        }
                    }
                }
                .sheet(isPresented: $showAdd, content: {
                    FoodBalanceAddView(showAdd: $showAdd)
                })
                .sheet(isPresented: $showBodyMass, content: {
                    BodyMassView()
                        .environmentObject(service)
                })
                .onReceive(service.$goToView, perform: { v in
                    if let v = v, v == .foodBalanceAdd {
                        showAdd = true
                    }
                })
                .navigationTitle("饮食平衡")
        }
    }
}

fileprivate extension Optional<String> {
    var forBind: FoodCategory {
        get { FoodCategory.descToCategory(desc: self) }
        set { self = newValue.description }
    }
}

extension Double {
    var text: String {
        get { String(self) }
        set { self = Double(newValue) ?? 0.0 }
    }
}

extension Optional<Date> {
    var orNull: Date {
        get { self ?? Date() }
        set { self = newValue }
    }
}

extension Binding where Value == Optional<String> {
    func onNone(_ fallback: String) -> Binding<String> {
        return Binding<String>(get: {
            return self.wrappedValue ?? fallback
        }) { value in
            self.wrappedValue = value
        }
    }
}

struct FoodBalanceEditView: View {
    @State var item: FoodAccountDAO
    @State var showAlert = false
    @State var errorMessage = ""
    @State var isSolved: Bool
    @Environment(\.managedObjectContext) var context
    init(item: FoodAccountDAO) {
        _item = State(wrappedValue: item)
        _isSolved = State(initialValue: item.solved)
    }
    func checkCanSubmit() -> Bool {
        if item.name == nil || item.name!.isEmpty {
            errorMessage = "名称不能为空"
            return false
        }
        return true
    }
    func doSave() {
        if checkCanSubmit() {
            do {
                item.solved = isSolved
                try context.save()
            } catch let e {
                showAlert = true
                errorMessage = e.localizedDescription
            }
        } else {
            showAlert = true
        }
    }
    var body: some View {
        ZStack(alignment: .top) {
            Color.white.opacity(0.0001)
            VStack(alignment: .leading) {
                Group {
                    Text("名称").padding(.top, 10)
                    TextField("食物名称",text: $item.name.onNone(""))
                }
                Group {
                    Text("类别").padding(.top, 10)
                    Picker("食物类别", selection: $item.category.forBind) {
                        ForEach([FoodCategory.energy,
                                 FoodCategory.suger,
                                 FoodCategory.drink,
                                 FoodCategory.fat,
                                 FoodCategory.reflect,
                                 //FoodCategory.other,
                                 FoodCategory.placeholder]) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Group {
                    Text("卡路里").padding(.top, 10)
                    TextField("食物消耗的卡路里",text: $item.calories.text)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }
                Group {
                    DatePicker("记录时间", selection: $item.date.orNull)
                        .padding(.top, 10)
                }
                Group {
                    Toggle("已抵账", isOn: $isSolved)
                }
                Group {
                    Text("备注").padding(.top, 10)
                    TextEditor(text: $item.note.onNone(""))
                }
                Spacer()
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .textFieldStyle(.roundedBorder)
        .padding(.horizontal, 20)
        .padding(.top ,5)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("请完成表单"),message: Text("\(errorMessage)"))
        }
        .onDisappear(perform: doSave)
        .navigationBarTitleDisplayMode(.inline)
        Spacer()
    }
}

struct FoodBalanceAddView: View {
    @Binding var showAdd: Bool
    @State var name = ""
    @State var category = FoodCategory.energy
    @State var calories = "100"
    @State var note = ""
    @State var date = Date()
    @State var showAlert = false
    @State var errorMessage = ""
    @Environment(\.managedObjectContext) var context
    func checkCanSubmit() -> Bool {
        if name.isEmpty {
            errorMessage = "名称不能为空"
            return false
        }
        guard let _ = Double(calories) else {
            errorMessage = "请输入卡路里消耗"
            return false
        }
        return true
    }
    var body: some View {
        VStack(alignment:.leading) {
            HStack {
                Button("关闭") {
                    showAdd = false
                }
                .accentColor(Color.red)
                Spacer()
                Button("保存") {
                    if checkCanSubmit() {
                        let dao = FoodAccountDAO(context: context)
                        dao.name = name
                        dao.id = UUID()
                        dao.category = category.description
                        dao.calories = Double(calories)!
                        if category == .placeholder {
                            dao.calories = -1 * dao.calories
                        }
                        if note != "" { dao.note = note }
                        dao.date = date
                        do {
                            try context.save()
                            showAdd = false
                        } catch let e {
                            showAlert = true
                            errorMessage = e.localizedDescription
                        }
                    } else {
                        showAlert = true
                    }
                }
            }
            .padding(20)
            VStack(alignment: .leading) {
                Group {
                    Text("名称").padding(.top, 10)
                    TextField("食物名称",text: $name)
                }
                Group {
                    Text("类别").padding(.top, 10)
                    Picker("食物类别", selection: $category) {
                        ForEach([FoodCategory.energy,
                                 FoodCategory.suger,
                                 FoodCategory.drink,
                                 FoodCategory.fat,
                                 FoodCategory.reflect,
                                 FoodCategory.other,
                                 FoodCategory.placeholder]) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .onChange(of: category) { newValue in
                    if newValue == .reflect {
                        name = "晚间健身圆环力量反馈"
                        calories = "30"
                    }
                }
                Group {
                    Text("卡路里").padding(.top, 10)
                    TextField("食物消耗的卡路里",text: $calories)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }
                Group {
                    DatePicker("记录时间", selection: $date)
                        .padding(.top, 10)
                }
                Group {
                    Text("备注").padding(.top, 10)
                    TextEditor(text: $note)
                }
                Spacer()
            }
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal, 20)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("请完成表单"),message: Text("\(errorMessage)"))
            }
            Spacer()
        }
        Spacer()
    }
}

struct FoodBalanceView_Previews: PreviewProvider {
    static var previews: some View {
        FoodBalanceView()
        //        Text("Hello")
        //            .sheet(isPresented: .constant(true)) {
        //                FoodAccountAddView(showAdd: .constant(true))
        //            }
    }
}
