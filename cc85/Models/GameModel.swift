//
//  GameModel.swift
//  cc85
//
//  Session ID: 2204
//

import Foundation
import SwiftUI

struct GameTile: Identifiable, Equatable {
    let id: UUID
    let color: Color
    let colorName: String
    var isMatched: Bool
    
    init(id: UUID = UUID(), color: Color, colorName: String, isMatched: Bool = false) {
        self.id = id
        self.color = color
        self.colorName = colorName
        self.isMatched = isMatched
    }
    
    static func == (lhs: GameTile, rhs: GameTile) -> Bool {
        lhs.id == rhs.id
    }
}

struct GameModel: Codable, Identifiable {
    let id: UUID
    var score: Int
    var level: Int
    var targetMatches: Int
    var currentMatches: Int
    var timeRemaining: Double
    var isActive: Bool
    var unlockedTips: [String]
    var totalGamesPlayed: Int
    var highScore: Int
    var combo: Int
    var bestCombo: Int
    
    init(id: UUID = UUID(), score: Int = 0, level: Int = 1, targetMatches: Int = 10, currentMatches: Int = 0, timeRemaining: Double = 30.0, isActive: Bool = false, unlockedTips: [String] = [], totalGamesPlayed: Int = 0, highScore: Int = 0, combo: Int = 0, bestCombo: Int = 0) {
        self.id = id
        self.score = score
        self.level = level
        self.targetMatches = targetMatches
        self.currentMatches = currentMatches
        self.timeRemaining = timeRemaining
        self.isActive = isActive
        self.unlockedTips = unlockedTips
        self.totalGamesPlayed = totalGamesPlayed
        self.highScore = highScore
        self.combo = combo
        self.bestCombo = bestCombo
    }
    
    mutating func addScore(points: Int) {
        score += points
        if score > highScore {
            highScore = score
        }
    }
    
    mutating func incrementCombo() {
        combo += 1
        if combo > bestCombo {
            bestCombo = combo
        }
    }
    
    mutating func resetCombo() {
        combo = 0
    }
    
    mutating func addMatch() {
        currentMatches += 1
    }
    
    mutating func levelUp() {
        level += 1
        targetMatches = 10 + (level * 3)
        currentMatches = 0
        timeRemaining = max(20.0, 30.0 - Double(level) * 1.0)
    }
    
    mutating func reset() {
        score = 0
        level = 1
        targetMatches = 10
        currentMatches = 0
        timeRemaining = 30.0
        isActive = false
        combo = 0
    }
}

struct ProductivityTip: Codable, Identifiable {
    let id: UUID
    let title: String
    let content: String
    let unlockLevel: Int
    
    init(id: UUID = UUID(), title: String, content: String, unlockLevel: Int) {
        self.id = id
        self.title = title
        self.content = content
        self.unlockLevel = unlockLevel
    }
}

