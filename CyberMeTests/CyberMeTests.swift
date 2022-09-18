//
//  CyberMeTests.swift
//  CyberMeTests
//
//  Created by corkine on 2022/9/16.
//

import XCTest
@testable import CyberMe

class CyberMeTests: XCTestCase {
    
    var game: Game!
    
    override func setUpWithError() throws {
        game = Game()
    }
    
    override func tearDownWithError() throws {
        game = nil
    }
    
    
    func testBigger() {
        let guess = game.target + 5
        XCTAssertEqual(game.points(Double(guess)), 95)
    }
    
    func testSmaller() {
        let guess = game.target - 5
        XCTAssertEqual(game.points(Double(guess)), 95)
    }
    
    func testStartNewRound() {
        game.startNewRound(points: 100)
        XCTAssertEqual(game.score, 100)
        XCTAssertEqual(game.round, 2)
    }
    
    func testScoreExact() {
        XCTAssertEqual(game.points(Double(game.target)), 200)
    }
    
    func testScoreClose() {
        XCTAssertEqual(game.points(Double(game.target + 2)), 98 + 50)
    }
    
    func testRoundReset() {
        game.reset()
        XCTAssertEqual(game.score, 0)
        XCTAssertEqual(game.round, 1)
        game.startNewRound(points: 100)
        XCTAssertEqual(game.score, 100)
        XCTAssertEqual(game.round, 2)
        game.reset()
        XCTAssertEqual(game.score, 0)
        XCTAssertEqual(game.round, 1)
    }
    
    func testLeaderboard() {
        game.startNewRound(points: 100)
        XCTAssertEqual(game.logs.count, 1)
        XCTAssertEqual(game.logs[0].points, 100)
        game.startNewRound(points: 200)
        XCTAssertEqual(game.logs.count, 2)
        XCTAssertEqual(game.logs[0].points, 100)
        XCTAssertEqual(game.logs[1].points, 200)
    }
    
    func testPerformanceExample() throws {
        measure {
            (1...1000).forEach { i in
                print(i)
            }
        }
    }
    
}
