//
//  FitnessView.swift
//  helloSwift
//
//  Created by Corkine on 2022/11/22.
//

import SwiftUI

struct FitnessItemView: View {
    
    var color:Color
    var imageName:String
    var text:[String]
    
    let smallSize = 17.0
    let standSize = 20.0
    let mediumSize = 25.0
    let biggerSize = 30.0
    
    var body: some View {
        ZStack(alignment:.leading) {
            Color("backgroundGray")
            VStack(alignment:.leading) {
                ZStack {
                    color
                    Image(systemName: imageName)
                        .foregroundColor(.white)
                        .padding(.all, 10)
                }
                .clipShape(Circle())
                .fixedSize(horizontal: true, vertical: true)
                .padding(.bottom, 5)
                Text(text.first!)
                HStack(alignment: .firstTextBaseline,spacing: 5) {
                    Text(text[1])
                        .font(.system(size: biggerSize))
                    Text(text.last!)
                        .font(.system(size: smallSize))
                }
            }
            .foregroundColor(color)
            .font(.system(size: standSize))
            .padding(.leading, 20)
            .padding(.vertical, 15)
        }
        .clipShape(RoundedRectangle(cornerSize:
                .init(width: 15, height: 15)))
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct FitnessView: View {
    var data = (0,0,0)
    var geo: GeometryProxy
    var body: some View {
        HStack {
            FitnessItemView(color: Color("orange"),
                            imageName: "flame",
                            text: ["燃脂",data.0.description,"卡"])
            .frame(width: geo.size.width / 3.4)
            Spacer()
            FitnessItemView(color: Color("green"),
                            imageName: "figure.walk",
                            text: ["运动",data.1.description,"分钟"])
            .frame(width: geo.size.width / 3.4)
            Spacer()
            FitnessItemView(color: Color("cyan"),
                            imageName: "heart",
                            text: ["正念",data.2.description,"分钟"])
            .frame(width: geo.size.width / 3.4)
        }
        //.padding(.horizontal, 10)
    }
}

struct FitnessView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { proxy in
            FitnessView(data: (135,12,10), geo: proxy)
        }
    }
}
