//
//  ContentView.swift
//  WatchLandmarks WatchKit Extension
//
//  Created by corkine on 2022/9/14.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        LandmarkList()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LandmarkList()
            .environmentObject(ModelData())
    }
}
