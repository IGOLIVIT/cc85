//
//  GameService.swift
//  cc85
//
//  Session ID: 2204
//

import Foundation
import Combine

class GameService: ObservableObject {
    @Published var gameState: GameModel
    @Published var productivityTips: [ProductivityTip]
    
    private let gameStateKey = "GamePlus_GameState"
    private let tipsKey = "GamePlus_UnlockedTips"
    
    init() {
        // Load saved game state
        if let data = UserDefaults.standard.data(forKey: gameStateKey),
           let savedState = try? JSONDecoder().decode(GameModel.self, from: data) {
            self.gameState = savedState
        } else {
            self.gameState = GameModel()
        }
        
        // Initialize productivity tips
        self.productivityTips = GameService.createProductivityTips()
    }
    
    static func createProductivityTips() -> [ProductivityTip] {
        return [
            ProductivityTip(title: "Start Small", content: "Break large tasks into smaller, manageable chunks. This reduces overwhelm and increases momentum.", unlockLevel: 1),
            ProductivityTip(title: "Time Blocking", content: "Dedicate specific time blocks to different types of tasks. This helps maintain focus and prevents context switching.", unlockLevel: 2),
            ProductivityTip(title: "Two-Minute Rule", content: "If a task takes less than two minutes, do it immediately. This prevents small tasks from piling up.", unlockLevel: 3),
            ProductivityTip(title: "Energy Management", content: "Schedule your most important tasks during your peak energy hours. Know when you work best.", unlockLevel: 4),
            ProductivityTip(title: "Single-Tasking", content: "Focus on one task at a time. Multitasking reduces efficiency and increases errors.", unlockLevel: 5),
            ProductivityTip(title: "Regular Breaks", content: "Take short breaks between focused work sessions. This maintains mental clarity and prevents burnout.", unlockLevel: 6),
            ProductivityTip(title: "Environment Design", content: "Create a workspace that minimizes distractions and supports your productivity goals.", unlockLevel: 7),
            ProductivityTip(title: "Weekly Review", content: "Set aside time each week to review accomplishments and plan ahead. This provides clarity and direction.", unlockLevel: 8),
            ProductivityTip(title: "Learn to Say No", content: "Protect your time by declining commitments that don't align with your priorities.", unlockLevel: 9),
            ProductivityTip(title: "Celebrate Wins", content: "Acknowledge your accomplishments, no matter how small. This reinforces positive habits.", unlockLevel: 10)
        ]
    }
    
    func startGame() {
        gameState.isActive = true
        gameState.timeRemaining = max(20.0, 30.0 - Double(gameState.level - 1) * 1.0)
        gameState.score = 0
        gameState.currentMatches = 0
        gameState.combo = 0
        saveGameState()
    }
    
    func registerMatch(isCorrect: Bool) {
        guard gameState.isActive else { return }
        
        if isCorrect {
            gameState.addMatch()
            gameState.incrementCombo()
            
            // Points based on combo
            let points = 10 + (gameState.combo * 2)
            gameState.addScore(points: points)
            
            // Check if level is complete
            if gameState.currentMatches >= gameState.targetMatches {
                completeLevel()
            }
        } else {
            // Wrong tile tapped - reset combo
            gameState.resetCombo()
        }
        
        saveGameState()
    }
    
    func completeLevel() {
        gameState.levelUp()
        unlockTipForLevel(gameState.level)
        saveGameState()
    }
    
    func endGame() {
        gameState.isActive = false
        gameState.totalGamesPlayed += 1
        saveGameState()
    }
    
    func resetGame() {
        gameState.reset()
        saveGameState()
    }
    
    func unlockTipForLevel(_ level: Int) {
        if let tip = productivityTips.first(where: { $0.unlockLevel == level }) {
            if !gameState.unlockedTips.contains(tip.id.uuidString) {
                gameState.unlockedTips.append(tip.id.uuidString)
            }
        }
    }
    
    func getUnlockedTips() -> [ProductivityTip] {
        return productivityTips.filter { tip in
            gameState.unlockedTips.contains(tip.id.uuidString)
        }
    }
    
    func saveGameState() {
        if let encoded = try? JSONEncoder().encode(gameState) {
            UserDefaults.standard.set(encoded, forKey: gameStateKey)
        }
    }
    
    func resetAllData() {
        UserDefaults.standard.removeObject(forKey: gameStateKey)
        UserDefaults.standard.removeObject(forKey: tipsKey)
        gameState = GameModel()
    }
}

