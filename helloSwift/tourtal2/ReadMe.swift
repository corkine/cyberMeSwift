//
//  ReadMe.swift
//  helloSwift
//
//  Created by corkine on 2022/9/19.
//

import SwiftUI

struct ReadMe: View {
    var body: some View {
        VStack {
            Book.Image()
            Text("Title").font(.title2)
        }
    }
}

struct ReadMe_Previews: PreviewProvider {
    static var previews: some View {
        ReadMe()
    }
}
