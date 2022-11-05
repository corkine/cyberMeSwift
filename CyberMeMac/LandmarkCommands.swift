//
//  LandmarkCommands.swift
//  helloSwift
//
//  Created by corkine on 2022/9/15.
//

import SwiftUI

struct LandmarkCommands: Commands {
    //@FocusedBinding(\.selectedLandmark) var selectedLandmark
    var model:ModelData
    var body: some Commands {
        SidebarCommands()
        
        CommandMenu("Landmark") {
            Button("\(model.selectedLandmark?.isFavorite == true ? "Remove" : "Mark") as Favorite") {
                model.selectedLandmark?.isFavorite.toggle()
                model.landmarks = model.landmarks.map { land in
                    var land = land
                    if land.id == model.selectedLandmark?.id {
                        land.isFavorite.toggle()
                    }
                    return land
                }
                
            }
            .keyboardShortcut("f", modifiers: [.shift, .option])
            .disabled(model.selectedLandmark == nil)
        }
    }
}

private struct SelectedLandmarkKey: FocusedValueKey {
    typealias Value = Binding<Landmark>
}

extension FocusedValues {
    var selectedLandmark: Binding<Landmark>? {
        get { self[SelectedLandmarkKey.self] }
        set {
            //print("newValue is \(String(describing: newValue))")
            self[SelectedLandmarkKey.self] = newValue
        }
    }
}

