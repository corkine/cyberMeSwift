//
//  SimpleInfoView.swift
//  helloSwift
//
//  Created by Corkine on 2022/11/16.
//

import SwiftUI

struct SimpleInfoViewHolder: View {
    var body: some View {
        Text("INFO")
            .sheet(isPresented: .constant(true)) {
                SimpleInfoView(
                deleteAction: {},
                saveAction: {t,n in print("\(t), \(n)")},
                title: "修改日志",
                name: "名称",
                desc: "状态")
            }
    }
}

struct SimpleInfoView: View {
    var deleteAction: ()->Void = {}
    var saveAction: (String,String)->Void = {_,_ in }
    var title: String = "修改日志"
    @State var name: String = ""
    @State var desc: String = ""
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 0) {
                Button("删除") {
                    deleteAction()
                }
                .foregroundColor(.red)
                Spacer()
                Text(title)
                Spacer()
                Button("保存") {
                    saveAction(name,desc)
                }
            }
            .padding(.all, 25)
            Spacer()
            Form {
                SwiftUI.Section {
                    TextField("标题", text: $name)
                } header: {
                    Text("标题")
                }
                SwiftUI.Section {
                    TextEditor(text: $desc)
                        .frame(height: 120)
                } header: {
                    Text("描述")
                }
            }.padding(.top, -15)
        }
    }
}

struct SimpleInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleInfoViewHolder()
    }
}
