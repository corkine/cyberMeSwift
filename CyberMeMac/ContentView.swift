//
//  ContentView.swift
//  MacLandmarks
//
//  Created by corkine on 2022/9/15.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model:ModelData
    var body: some View {
        LandmarkList(selectedLandmark:$model.selectedLandmark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ModelData())
    }
}
