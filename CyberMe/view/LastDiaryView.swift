//
//  ShortLinkView.swift
//  CyberMe
//
//  Created by Corkine on 2023/4/19.
//

import SwiftUI

struct LastDiarySheetModifier: ViewModifier {
    typealias Diary = ISummary.DiaryItem
    @State var title: String = ""
    @State var text: String = ""
    @State var copyDone: Bool = false
    @Binding var showSheet: Bool
    @EnvironmentObject var service: CyberService
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showSheet) {
                GeometryReader { proxy in
                    VStack {
                        ZStack(alignment:.leading) {
                            RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                                .fill(Color.white.opacity(0.00001))
                            Text("📜 " + title)
                                .font(.system(size: 30))
                                .padding(.vertical, 10)
                        }
                        .onTapGesture {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                        TextEditor(text: $text)
                            .layoutPriority(100)
                        Divider()
                        HStack {
                            Spacer()
                            Button(copyDone ? "已复制到剪贴板" : "复制到剪贴板") {
                                UIPasteboard.general.string = text
                                copyDone = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                                    showSheet = false
                                }
                            }
                            .foregroundColor(.blue)
                            Spacer()
                        }
                        .padding(.bottom, 10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                }
                .onChange(of: service.summaryData, perform: { data in
                    guard let diary = data.diary?.today?.first else { return }
                    title = diary.title
                    text = diary.content
                })
                .onAppear {
                    guard let diary = service.summaryData.diary?.today?.first else {
                        title = "没有日记"
                        text = "没有找到今天的日记"
                        return
                    }
                    title = diary.title
                    text = diary.content
                }
                .onDisappear {
                    title = ""
                    text = ""
                    copyDone = false
                    showSheet = false
                }
            }
    }
}

struct LastDiaryModifier_Previews: PreviewProvider {
    static var service = CyberService()
    static var previews: some View {
        Text("HELLO")
            .modifier(LastDiarySheetModifier(showSheet: .constant(true)))
            .environmentObject(service)
    }
}
