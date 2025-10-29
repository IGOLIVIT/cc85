//
//  GameViewModel.swift
//  cc85
//
//  Session ID: 2204
//

import Foundation
import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var gameService: GameService
    @Published var tiles: [GameTile] = []
    @Published var targetColor: Color = .blue
    @Published var targetColorName: String = "Blue"
    
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    private let gameColors: [(Color, String)] = [
        (Color(hex: "FF3C00"), "Orange"),
        (.blue, "Blue"),
        (.green, "Green"),
        (.purple, "Purple"),
        (.red, "Red"),
        (.pink, "Pink"),
        (.yellow, "Yellow"),
        (.cyan, "Cyan")
    ]
    
    var isGameActive: Bool {
        gameService.gameState.isActive
    }
    
    var currentScore: Int {
        gameService.gameState.score
    }
    
    var currentLevel: Int {
        gameService.gameState.level
    }
    
    var currentMatches: Int {
        gameService.gameState.currentMatches
    }
    
    var targetMatches: Int {
        gameService.gameState.targetMatches
    }
    
    var timeRemaining: Double {
        gameService.gameState.timeRemaining
    }
    
    var combo: Int {
        gameService.gameState.combo
    }
    
    var progress: Double {
        return Double(currentMatches) / Double(targetMatches)
    }
    
    var highScore: Int {
        gameService.gameState.highScore
    }
    
    var bestCombo: Int {
        gameService.gameState.bestCombo
    }
    
    init(gameService: GameService) {
        self.gameService = gameService
        
        // If game is already active (from saved state), generate tiles
        if gameService.gameState.isActive {
            generateTiles()
        }
    }
    
    func startGame() {
        gameService.startGame()
        generateTiles()
        startTimer()
        objectWillChange.send()
    }
    
    func generateTiles() {
        // Select random target color
        let randomTarget = gameColors.randomElement()!
        targetColor = randomTarget.0
        targetColorName = randomTarget.1
        
        // Fixed grid: 12 tiles (4x3 or 3x4)
        let tileCount = 12
        let correctTileCount = 4 // Always 4 correct tiles
        
        var newTiles: [GameTile] = []
        
        // Add correct tiles
        for _ in 0..<correctTileCount {
            newTiles.append(GameTile(color: targetColor, colorName: targetColorName))
        }
        
        // Add incorrect tiles
        let remainingCount = tileCount - correctTileCount
        for _ in 0..<remainingCount {
            let randomColor = gameColors.filter { $0.1 != targetColorName }.randomElement()!
            newTiles.append(GameTile(color: randomColor.0, colorName: randomColor.1))
        }
        
        // Shuffle tiles
        tiles = newTiles.shuffled()
        print("✅ Generated \(tiles.count) tiles, target: \(targetColorName)")
    }
    
    func handleTileTap(_ tile: GameTile) {
        guard isGameActive else { return }
        
        let isCorrect = tile.colorName == targetColorName
        gameService.registerMatch(isCorrect: isCorrect)
        
        // Provide haptic feedback
        if isCorrect {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Check if level is complete
            if currentMatches >= targetMatches {
                // Level complete - regenerate new round
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.generateTiles()
                }
            } else {
                // Remove this tile and regenerate board
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.generateTiles()
                }
            }
        } else {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
    
    func endGame() {
        stopTimer()
        gameService.endGame()
        tiles = []
    }
    
    func resetGame() {
        stopTimer()
        gameService.resetGame()
        tiles = []
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.gameService.gameState.timeRemaining > 0 && self.gameService.gameState.isActive {
                self.gameService.gameState.timeRemaining -= 0.1
                self.objectWillChange.send()
            } else if self.gameService.gameState.timeRemaining <= 0 {
                self.endGame()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func getUnlockedTips() -> [ProductivityTip] {
        return gameService.getUnlockedTips()
    }
}
