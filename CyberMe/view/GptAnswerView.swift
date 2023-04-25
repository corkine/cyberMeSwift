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
                VStack {
                    ZStack(alignment:.leading) {
                        RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                            .fill(Color.white.opacity(0.00001))
                        Text("🔮 GPT Q&A")
                            .font(.system(size: 30))
                            .padding(.vertical, 10)
                    }
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    HStack {
                        TextField("在这里输入你的问题",text: $question)
                            .padding(.horizontal, 5)
                        Image(systemName: "xmark")
                            .foregroundColor(.gray.opacity(0.3))
                            .onTapGesture {
                                question = ""
                            }
                    }
                    .padding(.vertical, 10)
                    TextEditor(text: $answer)
                        .layoutPriority(100)
                    Divider()
                        .padding(.bottom, 5)
                    HStack {
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
                        Divider()
                        Spacer()
                        Button(thinking ? "正在思考..." : "询问 GPT") {
                            callGpt()
                        }
                        .disabled(question.isEmpty || thinking)
                        Spacer()
                    }
                    .padding(.bottom, 10)
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
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
                    service.questionContent = ""
                    question = ""
                    answer = ""
                    copyDone = false
                    thinking = false
                    showSheet = false
                }
            }
    }
    func callGpt() {
        answer = ""
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
