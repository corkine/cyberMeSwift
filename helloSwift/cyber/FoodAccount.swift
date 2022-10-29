//
//  FoodAccount.swift
//  helloSwift
//
//  Created by Corkine on 2022/10/28.
//

import SwiftUI
import CoreData

enum FoodCategory: String, CaseIterable, Identifiable {
    case all = "所有类型"
    case suger = "甜点"
    case drink = "饮品"
    case fat = "油炸"
    case other = "其它"
    case placeholder = "占位符"
    var id: FoodCategory { self }
    var description: String {
        switch self {
        case .all: return "all"
        case .suger: return "suger"
        case .drink: return "drink"
        case .fat: return "fat"
        case .other: return "other"
        case .placeholder: return "placeholder"
        }
    }
    static func descToCategory(desc:String?) -> Self {
        if desc == nil { return .other }
        switch desc! {
        case "all": return .all
        case "suger": return .suger
        case "drink": return .drink
        case "fat": return .fat
        case "other": return .other
        case "placeholder": return .placeholder
        default: return .other
        }
    }
}

struct DynamicFetchRequestView<T: NSManagedObject, Content: View>: View {

    // That will store our fetch request, so that we can loop over it inside the body.
    // However, we don’t create the fetch request here, because we still don’t know what we’re searching for.
    // Instead, we’re going to create custom initializer(s) that accepts filtering information to set the fetchRequest property.
    @FetchRequest var fetchRequest: FetchedResults<T>

    // this is our content closure; we'll call this once the fetch results is available
    let content: (FetchedResults<T>) -> Content

    var body: some View {
        self.content(fetchRequest)
    }

    // This is a generic initializer that allow to provide all filtering information
    init( withPredicate predicate: NSPredicate,
          andSortDescriptor sortDescriptors: [NSSortDescriptor] = [],
          @ViewBuilder content: @escaping (FetchedResults<T>) -> Content) {
        _fetchRequest = FetchRequest<T>(sortDescriptors: sortDescriptors, predicate: predicate)
        self.content = content
    }

    // This initializer allows to provide a complete custom NSFetchRequest
    init( withFetchRequest request:NSFetchRequest<T>,
          @ViewBuilder content: @escaping (FetchedResults<T>) -> Content) {
        _fetchRequest = FetchRequest<T>(fetchRequest: request)
        self.content = content
    }
}

struct FoodAccountView: View {
    @State var filter: FoodCategory = .all
    @State var showAdd = false
    
    @AppStorage("food.showCompleted")
    var foodShowCompleted = true
    
    struct FetchView: View {
        @Binding var foodShowCompleted: Bool
        
        @Environment(\.managedObjectContext) var context
        
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
            _foodShowCompleted = foodShowCompleted
        }
        
        var body: some View {
            List {
                SwiftUI.Section {
                    ForEach(newItems) { item in
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
                        .contextMenu {
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
                                Label("标记已抵账", systemImage: "arrow.3.trianglepath")
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
                        Image(systemName: "list.dash")
                        Text("已入账")
                    }
                }
                if foodShowCompleted {
                    SwiftUI.Section {
                        ForEach(solvedItems) { item in
                            HStack {
                                VStack {
                                    Text(item.name ?? "无名称")
                                        .strikethrough()
                                    Text(FoodCategory.descToCategory(desc: item.category).rawValue)
                                }
                                Spacer()
                                Text(String(format: "%.0f cal", item.calories))
                                    .padding(.trailing, 10)
                            }
                            .contextMenu {
                                Button {
                                    withAnimation {
                                        item.solved = false
                                        try! context.save()
                                    }
                                } label: {
                                    Label("标记未抵账", systemImage: "list.dash")
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
                            Text("已抵账")
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            FetchView(forCategory: filter, foodShowCompleted: $foodShowCompleted)
            .toolbar {
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
                            Label("显示已抵账的条目", systemImage: "arrow.3.trianglepath")
                        }
                    } label: {
                        Text("过滤")
                    }
                }
            }
            .onChange(of: filter, perform: { newValue in
                
            })
            .sheet(isPresented: $showAdd, content: {
                FoodAccountAddView(showAdd: $showAdd)
            })
            .navigationTitle("饮食账单")
        }
    }
}

struct FoodAccountAddView: View {
    @Binding var showAdd: Bool
    @State var name = ""
    @State var category = FoodCategory.suger
    @State var calories = ""
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
                        ForEach([FoodCategory.suger,
                                 FoodCategory.drink,
                                 FoodCategory.fat,
                                 FoodCategory.other,
                                 FoodCategory.placeholder]) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
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

struct FoodAccountView_Previews: PreviewProvider {
    static var previews: some View {
        FoodAccountView()
        //        Text("Hello")
        //            .sheet(isPresented: .constant(true)) {
        //                FoodAccountAddView(showAdd: .constant(true))
        //            }
    }
}
