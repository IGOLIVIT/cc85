//
//  AppPreferencesModel.swift
//  cc85
//
//  Session ID: 2204
//

import Foundation
import SwiftUI

struct AppPreferencesModel: Codable {
    var hasCompletedOnboarding: Bool
    var notificationsEnabled: Bool
    var soundEnabled: Bool
    var hapticsEnabled: Bool
    var pomodoroWorkDuration: TimeInterval
    var pomodoroBreakDuration: TimeInterval
    var dailyStreak: Int
    var lastOpenDate: Date?
    
    init(hasCompletedOnboarding: Bool = false, notificationsEnabled: Bool = true, soundEnabled: Bool = true, hapticsEnabled: Bool = true, pomodoroWorkDuration: TimeInterval = 1500, pomodoroBreakDuration: TimeInterval = 300, dailyStreak: Int = 0, lastOpenDate: Date? = nil) {
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.notificationsEnabled = notificationsEnabled
        self.soundEnabled = soundEnabled
        self.hapticsEnabled = hapticsEnabled
        self.pomodoroWorkDuration = pomodoroWorkDuration
        self.pomodoroBreakDuration = pomodoroBreakDuration
        self.dailyStreak = dailyStreak
        self.lastOpenDate = lastOpenDate
    }
    
    mutating func updateStreak() {
        guard let lastDate = lastOpenDate else {
            dailyStreak = 1
            lastOpenDate = Date()
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastDay = calendar.startOfDay(for: lastDate)
        let daysDifference = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
        
        if daysDifference == 0 {
            // Same day, no change
            return
        } else if daysDifference == 1 {
            // Consecutive day
            dailyStreak += 1
        } else {
            // Streak broken
            dailyStreak = 1
        }
        
        lastOpenDate = Date()
    }
}

struct UserStats: Codable {
    var totalTasksCompleted: Int
    var totalPomodorosCompleted: Int
    var totalGamesPlayed: Int
    var totalPoints: Int
    
    init(totalTasksCompleted: Int = 0, totalPomodorosCompleted: Int = 0, totalGamesPlayed: Int = 0, totalPoints: Int = 0) {
        self.totalTasksCompleted = totalTasksCompleted
        self.totalPomodorosCompleted = totalPomodorosCompleted
        self.totalGamesPlayed = totalGamesPlayed
        self.totalPoints = totalPoints
    }
}

