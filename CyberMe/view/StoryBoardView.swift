//
//  StoryBoardView.swift
//  CyberMe
//
//  Created by Corkine on 2023/4/25.
//

import SwiftUI
import Introspect

struct StoryBoardModifier: ViewModifier {
    @Binding var showSheet: Bool
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showSheet) {
                StoryBoardView()
            }
    }
}

struct StoryBoardView: View {
    typealias Book = CyberService.StoryBook
    @State private var stories: [Book] = []
    @EnvironmentObject var service: CyberService
    var body: some View {
        NavigationView {
            List {
                ForEach(stories, id: \.name) { story in
                    NavigationLink {
                        StoryBookView(book: story)
                    } label: {
                        Text(story.name)
                    }

                }
            }
            .navigationTitle("🎈故事社")
        }
        .onAppear {
            service.getStoryBook { stories = $0 }
        }
    }
}

struct StoryBoardView_Previews: PreviewProvider {
    static var service = CyberService()
    static var previews: some View {
        StoryBoardView()
            .environmentObject(service)
    }
}

struct StoryBookView: View {
    typealias Book = CyberService.StoryBook
    var book: Book
    var body: some View {
        List {
            ForEach(book.stories.indices) { idx in
                NavigationLink {
                    StoryView(bookName: book.name, storyName: book.stories[idx])
                } label: {
                    Text(book.stories[idx])
                }

            }
        }
        .navigationTitle("\(book.name)")
    }
}

//struct StoryBook_Previews: PreviewProvider {
//    static var previews: some View {
//        StoryBookView(book: CyberService.StoryBook(name: "伊索寓言",
//            stories: ["故事1","故事2","故事3","故事4"]))
//    }
//}

struct StoryView: View {
    typealias Story = CyberService.StoryDetail
    @EnvironmentObject var service: CyberService
    @Environment(\.presentationMode) var presentationMode
    var bookName: String
    var storyName: String
    @State private var story: Story?
    @State private var showAlert: Bool = false
    @State private var nowContent: String = ""
    @State private var showRemember: Bool = false
    @State private var markRemember: Bool = false
    var buildContent: some View {
        let content = (story?.content)!
        let pages = content.split(separator: "\n")
            .map { raw in
                raw.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        var font: Font = .system(size: 17)
        if let fzSongFont = UIFont(name: "Songti SC", size: 17) {
            font = Font.custom(fzSongFont.fontName, size: fzSongFont.pointSize)
        }
        return VStack {
            Image("field")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .padding(.top, 90)
                .frame(height: 300)
                .clipped()
            LazyVStack(alignment:.leading) {
                Text("")
                    .onDisappear {
                        print("start recording progress...")
                        showRemember = true
                    }
                ForEach(pages.indices) { idx in
                    Text(pages[idx])
                        .lineSpacing(5)
                        .font(font)
                        .padding(.bottom, 10)
                        .padding(.leading, 5)
                        .onDisappear {
                            nowContent = pages[idx]
                        }
                        .id(pages[idx].hash)
                }
                .padding(.horizontal, 10)
            }
        }
    }
    var body: some View {
        ScrollViewReader { scroll in
            ScrollView(showsIndicators: false) {
                if story?.content == nil {
                    ProgressView("正在加载...")
                        .padding(.top, 400)
                } else {
                    buildContent
                        //.background(GeometryReader { proxy -> Color in
                        //    DispatchQueue.main.async {
                        //        offset = -proxy.frame(in: .named("scroll")).origin.y
                        //    }
                        //    return Color.clear
                        //})
                }
            }
            //.introspectScrollView { scrollView in
            //    //let width = scrollView.contentSize.width - scrollView.frame.width
            //    //scrollView.contentOffset.x = offset * width
            //    print("setting \(scrollView)")
            //    let height = scrollView.contentSize.height - scrollView.frame.height
            //    scrollView.contentOffset.y = offset * height
            //}
            //.coordinateSpace(name: "scroll")
            .ignoresSafeArea()
            .onAppear {
                service.getStory(book: bookName, storyName: storyName) { story in
                    guard let story = story else {
                        showAlert = true
                        return
                    }
                    self.story = story
                    let off = UserDefaults.standard.integer(forKey: "\(bookName):\(storyName)")
                    print("reading offset for \(bookName):\(storyName) off \(off)")
                    if off != 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            scroll.scrollTo(off, anchor: UnitPoint.top)
                        }
                    }
                }
            }
            .onDisappear {
                story = nil
                showAlert = false
                if !markRemember {
                    print("clear offset for \(bookName):\(storyName)")
                    UserDefaults.standard.removeObject(forKey: "\(bookName):\(storyName)")
                } else {
                    let nowHash = nowContent.hash
                    print("setting offset for \(bookName):\(storyName) off \(nowHash)")
                    UserDefaults.standard.set(nowHash, forKey: "\(bookName):\(storyName)")
                }
                markRemember = false
            }
            .navigationTitle(storyName)
            .navigationBarTitleDisplayMode(.automatic)
            .navigationBarItems(trailing: Button( showRemember ? "下次再读" : "") {
                markRemember = true
                self.presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showAlert, content: {
                Alert(title: Text("错误"), message: Text("无法解析获取数据"))
            })
        }
    }
    
}

struct StoryView_Previews: PreviewProvider {
    static var previews: some View {
        StoryView(bookName: "王尔德童话", storyName: "夜莺与玫瑰")
            .navigationTitle("夜莺与玫瑰")
            .environmentObject(CyberService())
    }
}
