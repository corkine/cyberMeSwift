//
//  ContentView.swift
//  WatchMe Watch App
//
//  Created by Corkine on 2024/7/18.
//

import SwiftUI

struct ContentView: View {
    @State var number: Double = 10.0
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "trophy.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.accentColor)
                Text("CyberMe")
                    .font(.title)
            }
            Spacer()
            Text("Connect to Server")
                .font(.footnote)
            Text("Sync Progress: \(number, specifier: "%.0f")%")
              .focusable()
              .digitalCrownRotation($number,
                                    from: 0.0, through: 100.0)
            Spacer()
            HStack {
                Spacer()
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
