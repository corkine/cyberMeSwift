//
//  LandmarksMac.swift
//  MacLandmarks
//
//  Created by corkine on 2022/9/15.
//

import SwiftUI
import MapKit

struct LandmarkDetailMac: View {
    @EnvironmentObject var modelData: ModelData
    var land: Landmark

    var landmarkIndex: Int {
        modelData.landmarks.firstIndex(where: { $0.id == land.id })!
    }

    var body: some View {
        ScrollView {
            ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
                MapView(coord: land.local)
                    .ignoresSafeArea(edges: .top)
                    .frame(height: 300)

                Button("Open in Maps") {
                    let destination = MKMapItem(placemark: MKPlacemark(coordinate: land.local))
                    destination.name = land.name
                    destination.openInMaps()
                }
                .padding()
            }

            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 24) {
                    CircleImage(image: land.image.resizable())
                        .frame(width: 160, height: 160)

                    VStack(alignment: .leading) {
                        HStack {
                            Text(land.name)
                                .font(.title)
                            FavoriteButton(isSet: $modelData.landmarks[landmarkIndex].isFavorite)
                                .buttonStyle(.plain)
                        }

                        VStack(alignment: .leading) {
                            Text(land.park)
                            Text(land.state)
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                }

                Divider()

                Text("About \(land.name)")
                    .font(.title2)
                Text(land.description)
            }
            .padding()
            .frame(maxWidth: 700)
            .offset(y: -50)
        }
        .navigationTitle(land.name)
    }
}
