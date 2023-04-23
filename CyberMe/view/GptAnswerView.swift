//
//  GptAnswerView.swift
//  CyberMe
//
//  Created by Corkine on 2023/4/24.
//

import SwiftUI

struct GptAnswerSheetModifier: ViewModifier {
    @State var question: String = ""
    @State var answer: String = ""
    @State var copyDone: Bool = false
    @State var thinking: Bool = false
    @Binding var showSheet: Bool
    @EnvironmentObject var service: CyberService
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showSheet) {
                GeometryReader { proxy in
                    Form {
                        ZStack(alignment:.leading) {
                            RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                                .fill(Color.white.opacity(0.00001))
                            Text("🔮 Q&A")
                                .font(.system(size: 30))
                                .padding(.vertical, 10)
                        }
                        .onTapGesture {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                        TextField("请输入问题", text: $question)
                            .padding(.horizontal, 5)
                        TextEditor(text: $answer)
                            .frame(height: proxy.size.height / 1.5)
                        HStack {
                            Text("")
                            Spacer()
                            Button(copyDone ? "已复制到剪贴板" : "复制到剪贴板") {
                                UIPasteboard.general.string = answer
                                copyDone = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                                    copyDone = false
                                }
                            }
                            .foregroundColor(.blue)
                            Spacer()
                        }
                        HStack {
                            Spacer()
                            Button(thinking ? "正在思考..." : "询问 ChatGPT") {
                                callGpt()
                            }
                            .disabled(question.isEmpty || thinking)
                            Spacer()
                        }
                    }
                }
                .onAppear {
                    question = service.questionContent
                    if question.hasPrefix("AUTO") {
                        question = String(question.dropFirst(4))
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                            callGpt()
                        }
                    }
                }
                .onDisappear {
                    question = ""
                    answer = ""
                    copyDone = false
                    thinking = false
                    showSheet = false
                }
            }
    }
    func callGpt() {
        thinking = true
        service.gptSimpleQuestion(question: question) {
            response in
            thinking = false
            guard let resp = response else { return }
            answer = resp.data ?? resp.message
        }
    }
}

struct GptAnswerModifier_Previews: PreviewProvider {
    static var service = CyberService()
    static var previews: some View {
        Text("HELLO")
            .modifier(GptAnswerSheetModifier(showSheet: .constant(true)))
            .environmentObject(service)
    }
}
