//
//  Game.swift
//  helloSwift
//
//  Created by corkine on 2022/9/16.
//

import Foundation

struct Log: Hashable {
    var playerName:String
    var points:Int
    var rounds:Int
}

struct Game: Hashable {
    var target:Int = Int.random(in: 1...100)
    var score: Int = 0
    var round: Int = 1
    var logs: [Log] = []
    func points(_ sliderValue:Double) -> Int {
        let diff = abs(Int(sliderValue) - target)
        let points = 100 - diff
        if diff == 0 {
            return points + 100
        } else if diff <= 2 {
            return points + 50
        } else {
            return points
        }
    }
    mutating func startNewRound(points:Int) {
        logs.append(Log(playerName: "Corkine", points: points, rounds: self.round))
        round += 1
        score += points
        target = Int.random(in: 1...100)
    }
    mutating func reset() {
        logs.removeAll()
        round = 1
        score = 0
        target = Int.random(in: 1...100)
    }
}
