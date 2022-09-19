//
//  Model.swift
//  helloSwift
//
//  Created by corkine on 2022/9/19.
//

import Foundation
import SwiftUI
import Combine

class Book: ObservableObject {
    var title:String
    var author:String
    @Published var microReview: String
    @Published var readMe:Bool
    init(title:String = "Title", author:String = "Author",
         microReview:String = "", readMe:Bool = true) {
        self.title = title; self.author = author;
        self.microReview = microReview; self.readMe = true;
    }
}

extension Book: Equatable, Hashable, Identifiable {
    static func == (lhs: Book, rhs: Book) -> Bool {
        lhs === rhs
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Book {
    struct Image:View {
        let image: SwiftUI.Image?
        let title: String
        var size: CGFloat?
        let cornerRadius: CGFloat
        var body: some View {
            if let image = image {
                image.resizable().scaledToFill().frame(width: size, height: size)
                    .cornerRadius(cornerRadius)
            } else {
                let symbol =
                SwiftUI.Image(title: title) ?? SwiftUI.Image(systemName: "book")
                symbol
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .font(Font.title.weight(.light))
                    .foregroundColor(.secondary.opacity(0.5))
            }
        }
    }
}

extension Book.Image {
    init(title:String) {
        self.init(image: nil, title: title, cornerRadius: .init())
    }
}

extension Image {
    init?(title:String) {
        guard let character = title.first,
              case let symbolName = "\(character.lowercased()).square",
              UIImage(systemName: symbolName) != nil else {
            return nil
        }
        self.init(systemName: symbolName)
    }
}

enum Section: CaseIterable {
    case readMe
    case finished
}

class Library: ObservableObject {
    var sortedBooks: [Section:[Book]] {
        let gb =  Dictionary(grouping: booksCache, by: \.readMe)
        return Dictionary(uniqueKeysWithValues:gb.map {
            (($0.key ? Section.readMe : Section.finished), $0.value)
        })
    }
    func addBook(_ book:Book) {
        booksCache.append(book)
    }
    func sortBooks() {
        booksCache = sortedBooks.flatMap{$0.value}
        objectWillChange.send()
    }
    func markAsRead(book:Book) {
        book.readMe.toggle()
        objectWillChange.send()
    }
    func markAsUnRead(book:Book) {
        book.readMe.toggle()
        objectWillChange.send()
    }
    func deleteBook(book:Book) {
        booksCache = booksCache.filter { $0 != book }
        objectWillChange.send()
    }
    @Published var images: [Book:Image] = [:]
    @Published private var booksCache: [Book] = [
        .init(title: "Ein Neues Land", author: "Shaun Tan"),
        .init(title: "Bosch", author: "Laurinda Dixon"),
        .init(title: "Dare to Lead", author: "Brene Brown", readMe: false),
        .init(title: "Drinking with the Saints", author: "Michael P. Foley"),
        .init(title: "A Guide to Tea", author: "Adagio Teas", readMe: false),
        .init(title: "The Life and Complete Work of Francisco Goya", author: "P. Gassier & J Wilson"),
        .init(title: "Lady Cottington's Pressed Fairy Book", author: "Lady Cottington"),
        .init(title: "How to Draw Cats", author: "Janet Rancan", readMe: false),
        .init(title: "Drawing People", author: "Barbara Bradley"),
        .init(title: "What to Say When You Talk to yourself", author: "Shad Helmstetter")
    ]
}
