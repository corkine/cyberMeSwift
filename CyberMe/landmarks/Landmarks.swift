//
//  Landmarks.swift
//  helloSwift
//
//  Created by corkine on 2022/9/14.
//

import SwiftUI

struct LandmarkList: View {
    @EnvironmentObject var model:ModelData
    @State private var showFavor = false
    @State private var filter = FilterCategory.all
    @Binding var selectedLandmark: Landmark?
    enum FilterCategory: String, CaseIterable, Identifiable {
        case all = "All"
        case lakes = "Lakes"
        case rivers = "Rivers"
        case mountains = "Mountains"
        var id: FilterCategory { self }
    }
    var filteredLandmarks: [Landmark] {
        model.landmarks.filter { landmark in
            (!showFavor || landmark.isFavorite)
                && (filter == .all || filter.rawValue == landmark.category)
        }
    }
    var title: String {
        let title = filter == .all ? "Landmarks" : filter.rawValue
        return showFavor ? "Favorite \(title)" : title
    }
    var index: Int? {
        model.landmarks.firstIndex(where: { $0.id == selectedLandmark?.id })
    }
    var body: some View {
        NavigationView {
            #if !os(watchOS)
            List(selection: $selectedLandmark) {
                ForEach(filteredLandmarks) { landmark in
                    NavigationLink {
                        #if os(macOS)
                        LandmarkDetailMac(land: landmark)
                        #endif
                        #if !os(macOS)
                        LandmarkDetail(land: landmark)
                        #endif
                    } label: {
                        LandmarkRow(land: landmark)
                    }
                    .tag(landmark)
                }
            }
            .navigationTitle(title)
            .frame(minWidth: 300)
            .toolbar {
                ToolbarItem {
                    Menu {
                        Picker("Category", selection: $filter) {
                            ForEach(FilterCategory.allCases) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .pickerStyle(.inline)
                        
                        Toggle(isOn: $showFavor) {
                            Label("Favorites only", systemImage: "star.fill")
                        }
                    } label: {
                        Label("Filter", systemImage: "slider.horizontal.3")
                    }
                }
            }
            Text("Select a Landmark")
            #endif
        }
        //.focusedValue(\.selectedLandmark, $model.landmarks[index ?? 0])
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

struct Previews_Landmarks_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ModelData())
    }
}
