//
//  ShortLinkView.swift
//  CyberMe
//
//  Created by Corkine on 2023/4/19.
//

import SwiftUI

struct ShortLinkSheetModifier: ViewModifier {
    @State var keyword: String = ""
    @State var originUrl: String = ""
    @State var override: Bool = false
    @Binding var showSheet: Bool
    @State var showResult = false
    @State var addResult = false
    @EnvironmentObject var service: CyberService
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showSheet) {
                Form {
                    HStack {
                        Text("https://mazhangjing.com/")
                            .accentColor(.primary.opacity(1))
                            .layoutPriority(1)
                        TextField("关键词", text: $keyword)
                            .autocorrectionDisabled()
                    }
                    HStack {
                        Text("跳转到")
                        TextField("https://", text: $originUrl)
                            .autocorrectionDisabled()
                            .keyboardType(.URL)
                    }
                    Toggle(isOn: $override) {
                        Text("允许覆盖")
                    }
                    Button("确定") {
                        service.addShortLink(keyword: keyword, originUrl: originUrl, focus: override) { res in
                            addResult = res
                            showResult = true
                        }
                    }
                    .disabled(keyword.isEmpty || originUrl.isEmpty || !originUrl.lowercased().starts(with: "http"))
                }
                .onAppear {
                    keyword = ""
                    originUrl = service.originUrl
                }
                .onDisappear {
                    service.originUrl = ""
                    showSheet = false
                }
                .alert(isPresented: $showResult) {
                    addResult ?
                    Alert(title: Text(""),
                          message: Text("添加成功"),
                          primaryButton: .default(Text("确定"), action: {
                              showResult = false
                              showSheet = false
                          }),
                          secondaryButton: .default(Text("拷贝到剪贴板"), action: {
                              showResult = false
                              showSheet = false
                              UIPasteboard.general.string = "https://go.mazhangjing.com/\(keyword)"
                    })) :
                    Alert(title: Text(""),
                          message: Text("添加失败，存在重复项"),
                          primaryButton: .default(Text("取消"), action: {
                              showResult = false
                              showSheet = false
                          }),
                          secondaryButton: .default(Text("取消"), action: {
                              showResult = false
                    }))
                }
            }
    }
}

struct ShortLinkView_Previews: PreviewProvider {
    static var service = CyberService()
    static var previews: some View {
        Text("HELLO")
            .modifier(ShortLinkSheetModifier(showSheet: .constant(true)))
            .environmentObject(service)
    }
}
