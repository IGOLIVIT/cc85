//
//  SettingsViewModel.swift
//  cc85
//
//  Session ID: 2204
//

import Foundation
import SwiftUI
import Combine

class SettingsViewModel: ObservableObject {
    @Published var mainViewModel: MainViewModel
    @Published var gameService: GameService
    @Published var productivityService: ProductivityService
    @Published var showResetConfirmation: Bool = false
    
    var notificationsEnabled: Bool {
        mainViewModel.preferences.notificationsEnabled
    }
    
    var soundEnabled: Bool {
        mainViewModel.preferences.soundEnabled
    }
    
    var hapticsEnabled: Bool {
        mainViewModel.preferences.hapticsEnabled
    }
    
    var dailyStreak: Int {
        mainViewModel.preferences.dailyStreak
    }
    
    var pomodoroWorkDuration: TimeInterval {
        mainViewModel.preferences.pomodoroWorkDuration
    }
    
    var pomodoroBreakDuration: TimeInterval {
        mainViewModel.preferences.pomodoroBreakDuration
    }
    
    init(mainViewModel: MainViewModel, gameService: GameService, productivityService: ProductivityService) {
        self.mainViewModel = mainViewModel
        self.gameService = gameService
        self.productivityService = productivityService
    }
    
    func toggleNotifications() {
        mainViewModel.toggleNotifications()
        
        if mainViewModel.preferences.notificationsEnabled {
            NotificationService.shared.requestAuthorization()
        }
    }
    
    func toggleSound() {
        mainViewModel.toggleSound()
    }
    
    func toggleHaptics() {
        mainViewModel.toggleHaptics()
    }
    
    func updatePomodoroDuration(work: Int, breakTime: Int) {
        mainViewModel.updatePomodoroDuration(work: TimeInterval(work * 60), breakDuration: TimeInterval(breakTime * 60))
    }
    
    func resetAllData() {
        mainViewModel.resetAllData()
        gameService.resetAllData()
        productivityService.resetAllData()
        
        // Provide haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    func confirmReset() {
        showResetConfirmation = true
    }
}

