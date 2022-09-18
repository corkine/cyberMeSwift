//
//  Model.swift
//  helloSwift
//
//  Created by corkine on 2022/9/19.
//

import Foundation
import SwiftUI

struct Book {
    var title:String
    var author:String
    init(title:String = "Title", author:String = "Author") {
        self.title = title; self.author = author;
    }
}

extension Book {
    struct Image:View {
        var body: some View {
            SwiftUI.Image(systemName: "book")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .font(Font.title.weight(.light))
                .foregroundColor(.secondary.opacity(0.5))
        }
    }
}
