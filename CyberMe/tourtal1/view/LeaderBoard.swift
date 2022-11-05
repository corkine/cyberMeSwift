//
//  LeaderBoard.swift
//  helloSwift
//
//  Created by corkine on 2022/9/17.
//

import SwiftUI

struct LeaderBoard: View {
    var logs: [Log]
    init(logs: [Log]) {
        self.logs = logs
        self.logs.sort { l1, l2 in l1.points > l2.points }
    }
    var count: Int {
        logs.count >= 5 ? 5 : logs.count
    }
    var body: some View {
        ZStack {
            Color("dialogBackground").ignoresSafeArea()
            VStack {
                Text("LeaderBoard".uppercased())
                    .fontWeight(.heavy)
                    .font(.title2)
                    .kerning(5.0)
                    .padding(.bottom, 20)
                if logs.isEmpty {
                    Text("Try play some round and go back here")
                } else {
                    GeometryReader { s in
                        HStack {
                            Text(String(""))
                                .bold()
                            .frame(width: 30, height:30)
                            Spacer()
                            Text("Player".uppercased())
                                .font(.system(size: 9))
                                .frame(width: s.size.width / 4, alignment: .center)
                            Spacer()
                            Text("Score".uppercased())
                                .font(.system(size: 9))
                                .frame(width: s.size.width / 7, alignment: .center)
                            Spacer()
                            Text("Rounded".uppercased())
                                .font(.system(size: 9))
                                .frame(width: s.size.width / 6, alignment: .center)
                            Spacer()
                        }
                    }.frame(height: 30)
                        .padding(.bottom, -10)
                    ForEach(0..<count) { index in
                        RowView(log: logs[index], rank: index + 1)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct RowView: View {
    var log:Log
    var rank:Int
    var body: some View {
        GeometryReader { s in
            ZStack {
                RoundedRectangle(cornerRadius: 40.0)
                    .stroke()
                    .frame(height:30)
                HStack {
                    ZStack {
                        Circle()
                            .stroke()
                        Text(String(rank))
                            .bold()
                    }
                    .frame(width: 30, height:30)
                    Spacer()
                    Text(log.playerName.uppercased())
                        .bold()
                        .frame(width: s.size.width / 4, alignment: .center)
                    Spacer()
                    Text("\(log.points)")
                        .bold()
                        .frame(width: s.size.width / 7, alignment: .center)
                    Spacer()
                    Text("\(log.rounds)")
                        .bold()
                        .frame(width: s.size.width / 6, alignment: .center)
                    Spacer()
                }
            }
        }.frame(height: 30)
    }
}

struct LeaderBoard_Previews: PreviewProvider {
    static var previews: some View {
//        VStack{
//            RowView(log:Log(index:1,playerName: "Corkine", score: 20, rounds: 3))
//            RowView(log:Log(index:2,playerName: "Corkine", score: 20, rounds: 3))
//            RowView(log:Log(index:3,playerName: "Corkine", score: 20, rounds: 3))
//        }
        LeaderBoard(logs: [
            Log(playerName: "Corkine", points: 20, rounds: 3),
            Log(playerName: "Corkine", points: 20, rounds: 3),
            Log(playerName: "Corkine", points: 20, rounds: 3)
        ]).preferredColorScheme(.dark)
            //.previewLayout(.fixed(width: 500, height: 400))
    }
}
