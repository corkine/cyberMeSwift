//
//  Helper.swift
//  helloSwift
//
//  Created by corkine on 2022/9/14.
//

import SwiftUI
import MapKit

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
    @AppStorage("MapView.zoom")
    private var zoom: Zoom = .medium

    enum Zoom: String, CaseIterable, Identifiable {
        case near = "Near"
        case medium = "Medium"
        case far = "Far"

        var id: Zoom {
            return self
        }
    }
    var delta: CLLocationDegrees {
        switch zoom {
        case .near: return 0.02
        case .medium: return 0.2
        case .far: return 2
        }
    }
    var body: some View {
        Map(coordinateRegion: $region)
            .onAppear {
                region = MKCoordinateRegion(
                    center: coord, span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta))
            }
    }
}
