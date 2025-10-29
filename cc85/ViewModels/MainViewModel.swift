//
//  MainViewModel.swift
//  cc85
//
//  Session ID: 2204
//

import Foundation
import SwiftUI
import Combine

class MainViewModel: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var preferences: AppPreferencesModel
    
    private let preferencesKey = "GamePlus_Preferences"
    
    init() {
        // Load saved preferences
        if let data = UserDefaults.standard.data(forKey: preferencesKey),
           let savedPreferences = try? JSONDecoder().decode(AppPreferencesModel.self, from: data) {
            self.preferences = savedPreferences
        } else {
            self.preferences = AppPreferencesModel()
        }
        
        // Update streak on app launch
        updateDailyStreak()
    }
    
    func updateDailyStreak() {
        preferences.updateStreak()
        savePreferences()
    }
    
    func completeOnboarding() {
        preferences.hasCompletedOnboarding = true
        savePreferences()
    }
    
    func toggleNotifications() {
        preferences.notificationsEnabled.toggle()
        savePreferences()
    }
    
    func toggleSound() {
        preferences.soundEnabled.toggle()
        savePreferences()
    }
    
    func toggleHaptics() {
        preferences.hapticsEnabled.toggle()
        savePreferences()
    }
    
    func updatePomodoroDuration(work: TimeInterval, breakDuration: TimeInterval) {
        preferences.pomodoroWorkDuration = work
        preferences.pomodoroBreakDuration = breakDuration
        savePreferences()
    }
    
    func savePreferences() {
        if let encoded = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: preferencesKey)
        }
    }
    
    func resetAllData() {
        UserDefaults.standard.removeObject(forKey: preferencesKey)
        preferences = AppPreferencesModel()
    }
}

