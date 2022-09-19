//
//  Detail.swift
//  helloSwift
//
//  Created by corkine on 2022/9/19.
//

import SwiftUI
import PhotosUI

struct DetailView: View {
    @EnvironmentObject var library: Library
    @ObservedObject var book: Book
    @State var pickingImage = false
    @State var deletePhoto = false
    @Binding var image: Image?
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            HStack(alignment: .top) {
                VStack(alignment:.leading) {
                    HStack(alignment:.top, spacing: 10) {
                        Button {
                            book.readMe.toggle()
                        } label: {
                            Image(systemName:
                                    book.readMe ? "bookmark" : "bookmark.fill")
                                .font(.system(size: 40))
                        }
                        VStack(alignment:.leading) {
                            Text(book.title)
                                .font(.title2)
                            Text(book.author)
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                    }
                    Divider()
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
                .padding(.all, 20)
                Spacer()
            }
            //.padding(.top, -60)
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
            .onDisappear {
                withAnimation {
                    library.sortBooks()
                }
            }
            
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(book: Library().sortedBooks[.readMe]![0],
                   image: .constant(nil))
            .environmentObject(Library())
            //.allColorSchemes
    }
}
