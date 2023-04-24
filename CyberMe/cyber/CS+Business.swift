//
//  CS+Business.swift
//  CyberMe
//
//  Created by Corkine on 2023/4/24.
//

import Foundation

extension CyberService {
    fileprivate struct UploadAddShort: Codable {
        var keyword: String
        var redirectURL: String
        var note: String = "由 CyberMe iOS 添加"
        var override: Bool = false
    }
    /// 短链接添加
    func addShortLink(keyword:String, originUrl:String, focus: Bool,
                      callback: @escaping (Bool) -> Void = { _ in }) {
        let data = UploadAddShort(keyword: keyword, redirectURL: originUrl, override: focus)
        uploadJSON(api: CyberService.goAddUrl, data: data) {
            response, error in
            print("upload create shortlink action: data: \(data)," +
                  "response: \(response.debugDescription)," +
                  "error: \(error?.localizedDescription ?? "nil")")
            callback(response?.status ?? -1 > 0)
        }
    }
    
    fileprivate struct UploadNote: Codable {
        var content: String
        var from: String = "由 CyberMe iOS 添加"
        var liveSeconds: Int
        var id: Int?
    }
    /// 笔记添加
    func addNote(content:String,
                 id: Int? = nil,
                 liveSeconds: Int = 60 * 60,
                 callback: @escaping (Bool) -> Void = { _ in }) {
        let data = UploadNote(content: content, liveSeconds: liveSeconds, id: id)
        uploadJSON(api: CyberService.noteAddUrl, data: data) {
            response, error in
            print("upload create note action: data: \(data)," +
                  "response: \(response.debugDescription)," +
                  "error: \(error?.localizedDescription ?? "nil")")
            callback(response?.status ?? -1 > 0)
        }
    }
    
    /// 快递追踪
    func addTrackExpress(no:String,
                         overwrite:Bool,
                         name:String?,
                         callback: @escaping (SimpleResult?) -> Void = { _ in }) {
        let url = CyberService.addTrackExpress(no: no, name: name, rewriteIfExist: overwrite)
        loadJSON(from: url, for: SimpleResult.self) { response, error in
            print("upload add track express action: \(url)," +
                  "response: \(response.debugDescription)," +
                  "error: \(error?.localizedDescription ?? "nil")")
            callback(response)
        }
    }
    
    fileprivate struct MarkMovieWatched: Codable {
        var name:String
        var watched:String
    }
    /// 美剧标记已看
    func markMovieWatched(name:String, watched:String,
                          callback: @escaping (SimpleResult?) -> Void = { _ in }) {
        let data = MarkMovieWatched(name: name, watched: watched)
        uploadJSON(api: (CyberService.markMovieWatched +
                   "?watched=\(watched)&name=\(name)").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                   data: data) { response, error in
            print("upload markMovieWatched action: data: \(data)," +
                  "response: \(response?.message ?? "nil")," +
                  "error: \(error?.localizedDescription ?? "nil")")
            callback(response)
        }
    }
    
    /// GPT 问答
    func gptSimpleQuestion(question:String,
                           callback: @escaping (CyberResult<String>?) -> Void = { _ in }) {
        loadJSON(from: (CyberService.gptSimpleQuestion + "?question=\(question)")
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                 for: CyberResult<String>.self) { response, error in
            print("gpt simple question action: data: \(question)," +
                  "response: \(response?.message ?? "nil")," +
                  "error: \(error?.localizedDescription ?? "nil")")
            callback(response)
        }
    }
}
