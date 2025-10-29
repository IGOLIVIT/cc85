//
//  MainView.swift
//  cc85
//
//  Session ID: 2204
//

import SwiftUI

struct MainView: View {
    @StateObject private var mainViewModel = MainViewModel()
    @StateObject private var gameService = GameService()
    @StateObject private var productivityService = ProductivityService()
    
    var body: some View {
        TabView(selection: $mainViewModel.selectedTab) {
            GameView(viewModel: GameViewModel(gameService: gameService))
                .tabItem {
                    Label("Game", systemImage: "gamecontroller.fill")
                }
                .tag(0)
            
            ProductivityToolsView(viewModel: ProductivityToolsViewModel(productivityService: productivityService), preferences: mainViewModel.preferences)
                .tabItem {
                    Label("Tasks", systemImage: "checkmark.circle.fill")
                }
                .tag(1)
            
            SettingsView(viewModel: SettingsViewModel(mainViewModel: mainViewModel, gameService: gameService, productivityService: productivityService))
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .accentColor(Color(hex: "FF3C00"))
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

