//
//  ReadMe.swift
//  helloSwift
//
//  Created by corkine on 2022/9/19.
//

import SwiftUI
import PhotosUI

struct NewBook: View {
    @Binding var book: Book
    @Binding var image: Image?
    @State var pickingImage = false
    @State var deletePhoto = false
    //@Environment(\.dismiss) var dismiss
    var body: some View {
        ScrollView(showsIndicators:false) {
            VStack {
                TextField("Title", text: $book.title)
                TextField("Author", text: $book.author)
                TextField("Review", text: $book.microReview)
                    .padding(.leading, 3)
                Divider().padding(.bottom, 2)
                Book.Image(image: image, title: book.title,
                           size: 300, cornerRadius: 12)
                HStack {
                    Button("Update Image...") {
                        pickingImage = true
                    }
                    Spacer()
                    if image != nil {
                        Button("Delete Photo") {
                            deletePhoto = true
                        }
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 10)
                Spacer()
            }
            .padding()
            .actionSheet(isPresented: $deletePhoto) {
                ActionSheet(
                    title: Text(""),
                    message: Text("Delete Image?"),
                    buttons: [
                        .destructive(Text("Delete"),
                                     action: {
                                         image = nil
                                     }),
                        .cancel()
                    ])
            }
            .sheet(isPresented: $pickingImage) {
                PHPickerViewController.View(image: $image, showing: $pickingImage)
            }
        }
    }
}

struct ReadMe: View {
    @EnvironmentObject var service: CyberService
    @EnvironmentObject var library: Library
    @State var addBook = false
    @State var newBookImage: Image?
    @State var tempBook: Book =
    Book(title: "", author: "", microReview: "", readMe: false)
    var body: some View {
        NavigationView {
            List {
                HStack {
                    Spacer()
                    Button {
                        addBook = true
                    } label: {
                        VStack(alignment:.center, spacing:1) {
                            Spacer()
                            Image(systemName: "book.circle")
                                .font(.system(size: 40))
                            Text("Add New Book")
                                .font(.system(size: 15))
                            Spacer()
                        }
                    }
                    Spacer()
                }
                SwiftUI.Section {
                    ForEach(library.sortedBooks[.readMe] ?? []) { book in
                        if #available(iOS 16.0, *) {
                            BookRow(book: book, image: $library.images[book])
                                .swipeActions(edge: .leading) {
                                    Button {
                                        library.markAsRead(book: book)
                                    } label: {
                                        Label("Mark As Read", systemImage: "bookmark.fill")
                                    }.tint(.accentColor)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        library.deleteBook(book: book)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        } else {
                            BookRow(book: book, image: $library.images[book])
                                .contextMenu {
                                    Button {
                                        withAnimation {
                                            library.markAsRead(book: book)
                                        }
                                    } label: {
                                        Label("Mark As Read", systemImage: "bookmark.fill")
                                    }
                                    Button {
                                        withAnimation {
                                            library.deleteBook(book: book)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }.padding(.vertical, -10)
                } header: {
                    HStack {
                        Image(systemName: "book")
                        Text("New In Libarry")
                    }
                }
                SwiftUI.Section {
                    ForEach(library.sortedBooks[.finished] ?? []) { book in
                        if #available(iOS 15.0, *) {
                            BookRow(book: book, image: $library.images[book])
                                .swipeActions(edge: .leading) {
                                    Button {
                                        library.markAsUnRead(book: book)
                                    } label: {
                                        Label("Mark As UnRead", systemImage: "bookmark.fill")
                                    }.tint(.gray)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        library.deleteBook(book: book)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        } else {
                            BookRow(book: book, image: $library.images[book])
                                .contextMenu {
                                    Button {
                                        withAnimation {
                                            library.markAsUnRead(book: book)
                                        }
                                    } label: {
                                        Label("Mark As UnRead", systemImage: "bookmark.slash")
                                    }
                                    Button {
                                        withAnimation {
                                            library.deleteBook(book: book)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                        }
                    }.padding(.vertical, -10)
                } header:{
                    HStack {
                        Image(systemName: "books.vertical.fill")
                        Text("Finished")
                    }
                }
            }
            .navigationTitle("My Library")
            .sheet(isPresented: $addBook, onDismiss: {
                library.images[tempBook] = newBookImage
                library.addBook(tempBook)
                tempBook = Book(title: "", author: "", microReview: "", readMe: false)
            }) {
                NewBook(book: $tempBook, image: $newBookImage)
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        withAnimation {
                            service.app = .mainApp
                        }
                    } label: {
                        Label("EXIT", systemImage: "pip.exit")
                    }
                }
            }
        }
        .accentColor(.blue)
    }
}

extension View {
    var allColorSchemes: some View {
        ForEach(
            ColorScheme.allCases, id: \.self,
            content: preferredColorScheme
        )
    }
}

struct ReadMe_Previews: PreviewProvider {
    static var previews: some View {
        ReadMe()
            .environmentObject(Library())//.allColorSchemes
//        NewBook(book: .constant(Book(title: "", author: "", microReview: "", readMe: false)), image: .constant(nil))
    }
}

struct BookRow: View {
    @ObservedObject var book: Book
    @Binding var image: Image?
    var body: some View {
        NavigationLink(destination: DetailView(book: book,
                                              image: $image)) {
            HStack {
                Book.Image(image: image, title: book.title,
                           size: 60, cornerRadius: 10)
                VStack(alignment: .leading) {
                    Text(book.title)
                        .font(.title2)
                    Text(book.author)
                        .font(.title3)
                        .foregroundColor(.secondary)
                    if !(book.microReview == "") {
                        Text(book.microReview)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                .lineLimit(1)
            }
            .padding(.vertical)
        }
    }
}
