//
//  OnboardingView.swift
//  cc85
//
//  Session ID: 2204
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var mainViewModel: MainViewModel
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color(hex: "FFFFFF")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                TabView(selection: $currentPage) {
                    OnboardingPageView(
                        icon: "paintpalette.fill",
                        title: "Welcome to GamePlus",
                        description: "Combine the excitement of gaming with powerful productivity tools to achieve your goals while having fun."
                    )
                    .tag(0)
                    
                    OnboardingPageView(
                        icon: "flame.fill",
                        title: "Color Match Game",
                        description: "Play our exciting color-matching game with increasing difficulty. Build combos, unlock productivity tips, and beat your high score!"
                    )
                    .tag(1)
                    
                    OnboardingPageView(
                        icon: "checkmark.circle.fill",
                        title: "Organize Your Tasks",
                        description: "Create and manage tasks with categories. Use the Pomodoro technique to stay focused and productive."
                    )
                    .tag(2)
                    
                    OnboardingPageView(
                        icon: "chart.bar.fill",
                        title: "Track Your Progress",
                        description: "Build daily streaks, earn points, and watch your productivity soar. Every completed task and focus session counts!"
                    )
                    .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .frame(height: 450)
                
                Spacer()
                
                PrimaryActionButton(title: currentPage < 3 ? "Next" : "Get Started") {
                    if currentPage < 3 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        mainViewModel.completeOnboarding()
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPageView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "FF3C00"))
                .frame(width: 120, height: 120)
                .background(
                    Circle()
                        .fill(Color(hex: "FFFFFF"))
                        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                )
            
            VStack(spacing: 15) {
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.system(size: 17))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(mainViewModel: MainViewModel())
    }
}

