//
//  CS+Story.swift
//  CyberMe
//
//  Created by Corkine on 2023/4/25.
//

import Foundation

extension CyberService {
    struct StoryBook: Codable {
        var name:String
        var stories: [String]
    }
    func getStoryBook(callback: @escaping ([StoryBook]) -> Void) {
        let url = "cyber/story/all-book-and-story-name"
        loadJSON(from: url, for: CyberResult<[StoryBook]>.self) { resp, error in
            guard let data = resp else {
                print("can't parse \(url) ",
                      "error: \(String(describing: error?.localizedDescription))")
                return
            }
            callback(data.data ?? [])
        }
    }
    struct StoryDetail: Codable {
        var book:String
        var name:String
        var content:String
        var info:StoryInfo
        struct StoryInfo: Codable {
            var url:String?
        }
    }
    func getStory(book:String,storyName:String,
                  callback: @escaping (StoryDetail?) -> Void) {
        guard let url = "cyber/story/read-story/\(book)/\(storyName)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                print("can't encodeing get story \(book) \(storyName)")
            return
        }
        loadJSON(from: url, for: CyberResult<StoryDetail>.self) { resp, error in
            guard let data = resp else {
                print("can't parse \(url) ",
                      "error: \(String(describing: error?.localizedDescription))")
                return
            }
            callback(data.data)
        }
    }
}
