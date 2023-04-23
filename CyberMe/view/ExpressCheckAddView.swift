//
//  ExpressCheckAddView.swift
//  CyberMe
//
//  Created by Corkine on 2023/4/22.
//

import SwiftUI

struct ExpressCheckAddSheetModifier: ViewModifier {
    @State var id: String = ""
    @State var name: String = ""
    @Binding var showSheet: Bool
    @State var isSF = false
    @State var sfSuffix = ""
    @State var overwrite = false
    @State var showResult = false
    @State var addResult = false
    @State var respMessage = ""
    @EnvironmentObject var service: CyberService
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showSheet) {
                GeometryReader { proxy in
                    Form {
                        ZStack(alignment:.leading) {
                            RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                                .fill(Color.white.opacity(0.00001))
                            Text("📦 快递追踪")
                                .font(.system(size: 30))
                                .padding(.vertical, 10)
                        }
                        .onTapGesture {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                        TextEditor(text: $id)
                            .frame(height: proxy.size.height / 3)
                        Toggle(isOn: $isSF) {
                            Text("顺丰快递")
                        }
                        if isSF {
                            TextField("联系人手机号后四位", text: $sfSuffix)
                        }
                        Toggle(isOn: $overwrite) {
                            Text("覆盖现有追踪")
                        }
                        TextField("快递备注", text: $name)
                        HStack {
                            Spacer()
                            Button("开始追踪") {
                                service.addTrackExpress(no: isSF ? "\(id):\(sfSuffix)" : id,
                                                        overwrite: overwrite,
                                                        name: name.isEmpty ? nil : name) {
                                    res in
                                    showResult = true
                                    addResult = res?.status ?? -1 > 0
                                    respMessage = res?.message ?? "没有错误消息"
                                }
                            }
                            .disabled(id.isEmpty || (isSF && sfSuffix.count != 4))
                            Spacer()
                        }
                    }
                }
                .onAppear {
                    id = UIPasteboard.general.string ?? ""
                    name = ""
                    isSF = id.lowercased().starts(with: "sf")
                }
                .onDisappear {
                    print("dismissed track")
                    id = ""
                    name = ""
                    isSF = false
                    sfSuffix = ""
                    UIPasteboard.general.string = ""
                    showSheet = false
                }
                .alert(isPresented: $showResult) {
                    addResult ?
                    Alert(title: Text("添加追踪成功"),
                          message: Text(respMessage),
                          dismissButton: .default(Text("确定"), action: {
                              showResult = false
                              showSheet = false
                    })) :
                    Alert(title: Text("添加追踪失败"),
                          message: Text(respMessage),
                          primaryButton: .default(Text("确定"), action: {
                              showResult = false
                              showSheet = false
                          }),
                          secondaryButton: .destructive(Text(overwrite ? "重试" : "覆盖并重试"), action: {
                              showResult = false
                              overwrite = true
                          }))
                }
            }
    }
}

struct ExpressCheckAddSheetModifier_Previews: PreviewProvider {
    static var service = CyberService()
    static var previews: some View {
        Text("HELLO")
            .modifier(ExpressCheckAddSheetModifier(showSheet: .constant(true)))
            .environment(\.colorScheme, .dark)
            .environmentObject(service)
    }
}
