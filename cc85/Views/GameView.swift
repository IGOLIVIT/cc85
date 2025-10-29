//
//  GameView.swift
//  cc85
//
//  Session ID: 2204
//

import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showTips = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "FFFFFF")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Stats Section
                        HStack(spacing: 15) {
                            StatCard(title: "Level", value: "\(viewModel.currentLevel)", icon: "star.fill")
                            StatCard(title: "High Score", value: "\(viewModel.highScore)", icon: "trophy.fill")
                            StatCard(title: "Best Combo", value: "\(viewModel.bestCombo)", icon: "flame.fill")
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        // Game Area
                        if viewModel.isGameActive {
                            ActiveColorMatchGame(viewModel: viewModel)
                        } else if viewModel.currentScore > 0 {
                            GameResultsCard(viewModel: viewModel)
                        } else {
                            InactiveGameCard(viewModel: viewModel)
                        }
                        
                        // Unlocked Tips Section
                        UnlockedTipsSection(viewModel: viewModel, showTips: $showTips)
                            .padding(.horizontal)
                        
                        Spacer(minLength: 30)
                    }
                }
            }
            .navigationTitle("GamePlus")
            .sheet(isPresented: $showTips) {
                TipsSheetView(tips: viewModel.getUnlockedTips())
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "FF3C00"))
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(hex: "FFFFFF"))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 5, y: 5)
                .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
        )
    }
}

struct ActiveColorMatchGame: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with target color and timer
            NeumorphicCard {
                VStack(spacing: 15) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("FIND THIS COLOR:")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 10) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(viewModel.targetColor)
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white, lineWidth: 4)
                                    )
                                    .shadow(color: viewModel.targetColor.opacity(0.5), radius: 10, x: 0, y: 5)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(viewModel.targetColorName)
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.black)
                                    
                                    Text("Tap all \(viewModel.targetColorName.lowercased()) tiles")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 5) {
                            Text("TIME")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                            
                            Text(String(format: "%.0f", viewModel.timeRemaining))
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(viewModel.timeRemaining < 10 ? .red : Color(hex: "FF3C00"))
                            
                            Text("seconds")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "FF3C00"))
                            Text("\(viewModel.currentMatches) / \(viewModel.targetMatches)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        if viewModel.combo > 1 {
                            HStack(spacing: 6) {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(Color(hex: "FF3C00"))
                                Text("COMBO x\(viewModel.combo)")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color(hex: "FF3C00"))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "FF3C00").opacity(0.15))
                            )
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            // Tiles Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                ForEach(viewModel.tiles) { tile in
                    ColorTileView(tile: tile) {
                        viewModel.handleTileTap(tile)
                    }
                }
            }
            .padding(.horizontal)
            .frame(minHeight: 400)
            .transition(.opacity)
            
            // End Game Button
            Button(action: {
                viewModel.endGame()
            }) {
                Text("End Game")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "FF3C00"))
                    .frame(width: 140, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "FF3C00"), lineWidth: 2)
                    )
            }
            .padding(.horizontal)
        }
    }
}

struct ColorTileView: View {
    let tile: GameTile
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                action()
                withAnimation {
                    isPressed = false
                }
            }
        }) {
            RoundedRectangle(cornerRadius: 20)
                .fill(tile.color)
                .frame(height: 110)
                .shadow(color: tile.color.opacity(0.5), radius: isPressed ? 8 : 15, x: 0, y: isPressed ? 4 : 8)
                .scaleEffect(isPressed ? 0.92 : 1.0)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.4), lineWidth: 3)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct GameResultsCard: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        NeumorphicCard {
            VStack(spacing: 25) {
                Image(systemName: viewModel.currentScore > 100 ? "star.fill" : "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(hex: "FF3C00"))
                
                Text(viewModel.currentScore > 100 ? "Great Job!" : "Game Over")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                
                // Results
                VStack(spacing: 15) {
                    ResultRow(label: "Score", value: "\(viewModel.currentScore)", highlight: true)
                    ResultRow(label: "Level Reached", value: "\(viewModel.currentLevel)")
                    ResultRow(label: "Best Combo", value: "x\(viewModel.combo)")
                    
                    if viewModel.currentScore >= viewModel.highScore {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                            Text("New High Score!")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: "FF3C00"))
                        }
                        .padding(.top, 10)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.05))
                )
                .padding(.horizontal, 10)
                
                PrimaryActionButton(title: "Play Again") {
                    viewModel.resetGame()
                    viewModel.startGame()
                }
                .padding(.horizontal, 30)
            }
            .padding(.vertical, 30)
        }
        .padding(.horizontal)
    }
}

struct ResultRow: View {
    let label: String
    let value: String
    var highlight: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.system(size: highlight ? 24 : 18, weight: .bold))
                .foregroundColor(highlight ? Color(hex: "FF3C00") : .black)
        }
    }
}

struct InactiveGameCard: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        NeumorphicCard {
            VStack(spacing: 25) {
                Image(systemName: "paintpalette.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(hex: "FF3C00"))
                
                Text("Color Match!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                
                // Instructions
                VStack(alignment: .leading, spacing: 15) {
                    Text("How to Play:")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    InstructionRow(number: "1", text: "Look at the target color at the top")
                    InstructionRow(number: "2", text: "Tap ALL tiles that match this color")
                    InstructionRow(number: "3", text: "Build combos for bonus points")
                    InstructionRow(number: "4", text: "Complete targets before time runs out!")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.05))
                )
                .padding(.horizontal, 10)
                
                VStack(spacing: 8) {
                    HStack(spacing: 15) {
                        FeatureBadge(icon: "flame.fill", text: "Combo System")
                        FeatureBadge(icon: "star.fill", text: "10 Levels")
                    }
                    HStack(spacing: 15) {
                        FeatureBadge(icon: "lightbulb.fill", text: "Unlock Tips")
                        FeatureBadge(icon: "timer", text: "30 Seconds")
                    }
                }
                
                PrimaryActionButton(title: "Start Playing") {
                    viewModel.startGame()
                }
                .padding(.horizontal, 30)
            }
            .padding(.vertical, 30)
        }
        .padding(.horizontal)
    }
}

struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Circle().fill(Color(hex: "FF3C00")))
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

struct FeatureBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(text)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundColor(Color(hex: "FF3C00"))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color(hex: "FF3C00").opacity(0.1))
        )
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "FF3C00"))
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding(.horizontal, 30)
    }
}

struct UnlockedTipsSection: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var showTips: Bool
    
    var body: some View {
        let unlockedTips = viewModel.getUnlockedTips()
        
        if !unlockedTips.isEmpty {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("Unlocked Tips")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text("\(unlockedTips.count)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(Color(hex: "FF3C00")))
                }
                
                Button(action: { showTips = true }) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(Color(hex: "FF3C00"))
                        
                        Text("View All Tips")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "FFFFFF"))
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 3, y: 3)
                            .shadow(color: Color.white.opacity(0.7), radius: 5, x: -3, y: -3)
                    )
                }
            }
        }
    }
}

struct TipsSheetView: View {
    let tips: [ProductivityTip]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "FFFFFF")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(tips) { tip in
                            TipCard(tip: tip)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Productivity Tips")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color(hex: "FF3C00"))
                }
            }
        }
    }
}

struct TipCard: View {
    let tip: ProductivityTip
    
    var body: some View {
        NeumorphicCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(tip.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text("Lvl \(tip.unlockLevel)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color(hex: "FF3C00")))
                }
                
                Text(tip.content)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(viewModel: GameViewModel(gameService: GameService()))
    }
}
