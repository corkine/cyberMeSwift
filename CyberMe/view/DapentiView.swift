//
//  DapentiView.swift
//  CyberMe
//
//  Created by Corkine on 2023/5/10.
//

import SwiftUI
import WebKit

struct DapentiSheetModifier: ViewModifier {
    @Binding var showSheet: Bool
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $showSheet) {
                ZStack(alignment:.topTrailing) {
                    WebView(url: URL(string: "https://go.mazhangjing.com/news")!)
                    Image(systemName: "x.circle")
                        .font(.system(size: 30))
                        .padding(.top, 10)
                        .padding(.trailing, 8)
                        .foregroundColor(.black.opacity(0.4))
                        .onTapGesture {
                            showSheet = false
                        }
                }
            }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

struct DapentiView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
            .modifier(DapentiSheetModifier(showSheet: .constant(true)))
    }
}
