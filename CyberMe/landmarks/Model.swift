//
//  Model.swift
//  helloSwift
//
//  Created by corkine on 2022/9/14.
//

import CoreLocation
import Foundation
import Combine
import SwiftUI


func load<T:Decodable>(_ fileName:String)->T {
    let data: Data
    guard let file = Bundle.main.url(forResource: fileName, withExtension: nil)
    else {
        fatalError("can't find \(fileName)")
    }
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("can't load \(error)")
    }
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("can't parse \(error)")
    }
}

struct Landmark: Hashable, Codable, Identifiable {
    var id: Int
    var name:String
    var park:String
    var state:String
    var description:String
    var city:String
    var category:String
    var isFavorite:Bool
    var isFeatured:Bool
    var featureImage:Image? {
        isFeatured ? Image(imageName + "_feature") : nil
    }
    enum Category: String, CaseIterable, Codable {
            case lakes = "Lakes"
            case rivers = "Rivers"
            case mountains = "Mountains"
    }
    private var imageName:String
    var image:Image { Image(imageName) }
    private var coordinates:Coor
    var local: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
    }
    struct Coor: Hashable, Codable {
        var latitude, longitude: Double
    }
}

struct Hike: Codable, Hashable, Identifiable {
    var id: Int
    var name: String
    var distance: Double
    var difficulty: Int
    var observations: [Observation]
    static var formatter = LengthFormatter()
    var distanceText: String {
        Hike.formatter
            .string(fromValue: distance, unit: .kilometer)
    }
    struct Observation: Codable, Hashable {
        var distanceFromStart: Double
        var elevation: Range<Double>
        var pace: Range<Double>
        var heartRate: Range<Double>
    }
}

struct Profile {
    var username: String
    var prefersNotifications = true
    var seasonalPhoto = Season.winter
    var goalDate = Date()
    static let `default` = Profile(username: "g_kumar")
    enum Season: String, CaseIterable, Identifiable {
        case spring = "🌷"
        case summer = "🌞"
        case autumn = "🍂"
        case winter = "☃️"
        var id: String { rawValue }
    }
}

class ModelData: ObservableObject {
    @Published var landmarks: [Landmark] = load("landmarkData.json")
    @Published var profile:Profile = Profile.default
    @Published var selectedLandmark: Landmark?
    var features: [Landmark] {
        landmarks.filter {$0.isFeatured }
    }
    var categories:[String:[Landmark]] {
        Dictionary(
            grouping: landmarks, by: {$0.category}
        )
    }
    var hikes: [Hike] = load("hikeData.json")
}

