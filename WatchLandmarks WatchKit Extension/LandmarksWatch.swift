//
//  LandmarksWatch.swift
//  WatchLandmarks WatchKit Extension
//
//  Created by corkine on 2022/9/14.
//

import SwiftUI

struct LandmarkDetailWatch: View {
    @EnvironmentObject var modelData: ModelData
    var land: Landmark
    var landmarkIndex: Int {
        modelData.landmarks.firstIndex(where: { $0.id == land.id })!
    }
    var body: some View {
        ScrollView {
            VStack {
                CircleImage(image: land.image.resizable())
                    .scaledToFit()
                Text(land.name)
                    .font(.headline)
                    .lineLimit(0)
                Toggle(isOn: $modelData.landmarks[landmarkIndex].isFavorite) {
                    Text("Favorite")
                }
                Divider()
                Text(land.park)
                    .font(.caption)
                    .bold()
                    .lineLimit(0)
                Text(land.state)
                    .font(.caption)
                Divider()
                MapView(coord: land.local)
                    .scaledToFit()
            }
            .padding(16)
        }
        .navigationTitle("Landmarks")
    }
}
