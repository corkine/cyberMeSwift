//
//  ContentView.swift
//  helloSwift
//
//  Created by corkine on 2022/8/31.
//

import SwiftUI
import MapKit
import CoreLocation
import Foundation
import Combine

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

class ModelData: ObservableObject {
    @Published var landmarks: [Landmark] = load("landmarkData.json")
}

struct ContentView: View {
    @EnvironmentObject var model:ModelData
    @State var showFavor = false
    var lanmarks:[Landmark] {
        model.landmarks.filter { !showFavor || $0.isFavorite }
    }
    var body: some View {
        NavigationView {
            List {
                Toggle(isOn: $showFavor) {
                    Text("Favorites only")
                }
                ForEach(lanmarks) { land in
                    NavigationLink {
                        LandmarkDetail(land:land)
                    } label: {
                        LandmarkRow(land: land)
                    }
                }
            }.navigationTitle("Landmarks")
        }
    }
}

struct LandmarkRow: View {
    var land: Landmark
    var body: some View {
        HStack {
            land.image.resizable()
                .frame(width:50,height: 50)
            Text(land.name)
            Spacer()
            if land.isFavorite {
                Image(systemName: "star.fill")
                    .imageScale(.medium)
                    .foregroundColor(.yellow)
            }
        }
    }
}

struct FavoriteButton: View {
    @Binding var isSet: Bool
    var body: some View {
        Button {
            isSet.toggle()
        } label: {
            Label("Toggle Favoriate",
                  systemImage: isSet ? "star.fill" : "star")
                .labelStyle(.iconOnly)
                .foregroundColor(isSet ? .yellow : .gray)
        }
    }
}

struct LandmarkDetail: View {
    @EnvironmentObject var model:ModelData
    var land: Landmark
    var index: Int {
        model.landmarks.firstIndex(where: {
            $0.id == land.id
        })!
    }
    var body: some View {
        ScrollView(showsIndicators:false) {
            MapView(coord: land.local)
                .ignoresSafeArea()
                .frame(height:300)
            CircleImage(image:land.image)
                .offset(y:-140)
                .padding(.bottom, -140)
            VStack(alignment: .leading) {
                HStack {
                    Text(land.name)
                        .font(.title)
                    FavoriteButton(isSet: $model.landmarks[index].isFavorite)
                }
                HStack{
                    Text(land.park)
                    Spacer()
                    Text(land.city)
                }
                Divider()
                Text("About \(land.name)")
                    .font(.title2)
                    .padding(.bottom, 1)
                Text(land.description)
            }.padding()
        }.ignoresSafeArea()
    }
}

struct CircleImage: View {
    let image:Image
    var body: some View {
        image
            .frame(width:250)
            .clipShape(Circle())
            .shadow(radius: 7)
    }
}

struct MapView: View {
    var coord: CLLocationCoordinate2D
    @State private var region = MKCoordinateRegion()
    var body: some View {
        Map(coordinateRegion: $region)
            .onAppear {
                region = MKCoordinateRegion(
                    center: coord, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var model = ModelData()
    static var previews: some View {
        FavoriteButton(isSet: .constant(true))
            .previewLayout(.fixed(width: 300, height: 70))
        LandmarkDetail(land: (model.landmarks)[3])
            .environmentObject(model)
        ContentView()
            .preferredColorScheme(.dark)
            .environmentObject(model)
//            .previewDevice("iPhone 11")
//        Group {
//            LandmarkRow(land: landmarks[0])
//            LandmarkRow(land: landmarks[1])
//        }.previewLayout(.fixed(width: 300, height: 70))
    }
}
