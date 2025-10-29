//
//  SettingsView.swift
//  cc85
//
//  Session ID: 2204
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "FFFFFF")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Daily Streak
                        StreakSection(streak: viewModel.dailyStreak)
                        
                        // Pomodoro Settings
                        PomodoroSettingsSection(viewModel: viewModel)
                        
                        // Reset Button
                        ResetSection(viewModel: viewModel)
                        
                        // App Version
                        Text("GamePlus v1.0.0 • Session 2204")
                            .font(.system(size: 12))
                            .foregroundColor(.gray.opacity(0.6))
                            .padding(.top, 20)
                        
                        Spacer(minLength: 30)
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .alert(isPresented: $viewModel.showResetConfirmation) {
                Alert(
                    title: Text("Reset All Data"),
                    message: Text("This will permanently delete all your tasks, game progress, and settings. This action cannot be undone."),
                    primaryButton: .destructive(Text("Reset")) {
                        viewModel.resetAllData()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct AppInfoSection: View {
    var body: some View {
        NeumorphicCard {
            VStack(spacing: 15) {
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "FF3C00"))
                
                Text("GamePlus")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                
                Text("Version 1.0.0")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Text("Session ID: 2204")
                    .font(.system(size: 12))
                    .foregroundColor(.gray.opacity(0.7))
            }
            .padding(.vertical, 10)
        }
    }
}

struct StreakSection: View {
    let streak: Int
    
    var body: some View {
        NeumorphicCard {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 30))
                    .foregroundColor(Color(hex: "FF3C00"))
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Daily Streak")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("\(streak) day\(streak != 1 ? "s" : "")")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("\(streak)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(hex: "FF3C00"))
            }
        }
    }
}

struct PreferencesSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preferences")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 5)
            
            NeumorphicCard {
                VStack(spacing: 15) {
                    SettingToggleRow(
                        icon: "bell.fill",
                        title: "Notifications",
                        isOn: Binding(
                            get: { viewModel.notificationsEnabled },
                            set: { _ in viewModel.toggleNotifications() }
                        )
                    )
                    
                    Divider()
                    
                    SettingToggleRow(
                        icon: "speaker.wave.2.fill",
                        title: "Sound Effects",
                        isOn: Binding(
                            get: { viewModel.soundEnabled },
                            set: { _ in viewModel.toggleSound() }
                        )
                    )
                    
                    Divider()
                    
                    SettingToggleRow(
                        icon: "hand.tap.fill",
                        title: "Haptic Feedback",
                        isOn: Binding(
                            get: { viewModel.hapticsEnabled },
                            set: { _ in viewModel.toggleHaptics() }
                        )
                    )
                }
            }
        }
    }
}

struct SettingToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "FF3C00"))
                .frame(width: 30)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.black)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color(hex: "FF3C00"))
        }
    }
}

struct PomodoroSettingsSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var workMinutes: Int = 25
    @State private var breakMinutes: Int = 5
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pomodoro Settings")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 5)
            
            NeumorphicCard {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundColor(Color(hex: "FF3C00"))
                            Text("Work Duration")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            Spacer()
                            Text("\(workMinutes) min")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        
                        Stepper("", value: $workMinutes, in: 5...60, step: 5)
                            .labelsHidden()
                            .onChange(of: workMinutes) { newValue in
                                viewModel.updatePomodoroDuration(work: newValue, breakTime: breakMinutes)
                            }
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "cup.and.saucer.fill")
                                .foregroundColor(Color(hex: "FF3C00"))
                            Text("Break Duration")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            Spacer()
                            Text("\(breakMinutes) min")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        
                        Stepper("", value: $breakMinutes, in: 1...30, step: 1)
                            .labelsHidden()
                            .onChange(of: breakMinutes) { newValue in
                                viewModel.updatePomodoroDuration(work: workMinutes, breakTime: newValue)
                            }
                    }
                }
            }
        }
        .onAppear {
            workMinutes = Int(viewModel.pomodoroWorkDuration / 60)
            breakMinutes = Int(viewModel.pomodoroBreakDuration / 60)
        }
    }
}

struct AboutSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 5)
            
            NeumorphicCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("GamePlus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("GamePlus combines the excitement of gaming with powerful productivity tools. Play engaging games, unlock productivity tips, manage tasks, and use the Pomodoro technique to achieve your goals.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        InfoRow(label: "Developer", value: "GamePlus Team")
                        InfoRow(label: "Category", value: "Productivity & Games")
                        InfoRow(label: "Requires", value: "iOS 15.6 or later")
                    }
                }
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
        }
    }
}

struct ResetSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Data Management")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 5)
            
            Button(action: {
                viewModel.confirmReset()
            }) {
                HStack {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.red)
                    
                    Text("Reset All Application Data")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.red)
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(hex: "FFFFFF"))
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 4, y: 4)
                        .shadow(color: Color.white.opacity(0.7), radius: 8, x: -4, y: -4)
                )
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: SettingsViewModel(mainViewModel: MainViewModel(), gameService: GameService(), productivityService: ProductivityService()))
    }
}

