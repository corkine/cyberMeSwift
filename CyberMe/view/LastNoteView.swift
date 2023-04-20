//
//  ShortLinkView.swift
//  CyberMe
//
//  Created by Corkine on 2023/4/19.
//

import SwiftUI

struct LastNoteSheetModifier: ViewModifier {
    @State var text: String = ""
    @Binding var showSheet: Bool
    @State var showResult = false
    @State var addResult = false
    @EnvironmentObject var service: CyberService
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showSheet) {
                GeometryReader { proxy in
                    Form {
                        ZStack(alignment:.leading) {
                            RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                                .fill(Color.white.opacity(0.00001))
                            Text("📒 笔记")
                                .font(.system(size: 30))
                                .padding(.vertical, 10)
                        }
                        .onTapGesture {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                        TextEditor(text: $text)
                            .frame(height: proxy.size.height / 1.4)
                        HStack {
                            Spacer()
                            Button("添加到笔记") {
                                service.addNote(content: text) { res in
                                    showResult = true
                                    addResult = res
                                }
                            }
                            .disabled(text.isEmpty)
                            .foregroundColor(.blue)
                            Spacer()
                        }
                    }
                }
                .onAppear {
                    text = service.noteContent.fromBase64() ?? ""
                }
                .onDisappear {
                    service.noteContent = ""
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
                              UIPasteboard.general.string = "https://cyber.mazhangjing.com/cyber/note/last"
                    })) :
                    Alert(title: Text(""),
                          message: Text("添加失败"),
                          dismissButton: .default(Text("确定"), action: {
                              showResult = false
                              showSheet = false
                          }))
                }
            }
    }
}

struct LastNoteSheetModifier_Previews: PreviewProvider {
    static var service = CyberService()
    static var previews: some View {
        Text("HELLO")
            .modifier(LastNoteSheetModifier(showSheet: .constant(true)))
            .environment(\.colorScheme, .dark)
            .environmentObject(service)
    }
}
