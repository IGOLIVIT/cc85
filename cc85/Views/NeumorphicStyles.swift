//
//  NeumorphicStyles.swift
//  cc85
//
//  Session ID: 2204
//

import SwiftUI

// MARK: - Neumorphic Button Style

struct NeumorphicButtonStyle: ButtonStyle {
    var backgroundColor: Color = Color(hex: "FFFFFF")
    var isPressed: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(backgroundColor)
                        .shadow(color: Color.black.opacity(configuration.isPressed ? 0.1 : 0.2), radius: configuration.isPressed ? 5 : 10, x: configuration.isPressed ? 5 : 10, y: configuration.isPressed ? 5 : 10)
                        .shadow(color: Color.white.opacity(configuration.isPressed ? 0.5 : 0.7), radius: configuration.isPressed ? 5 : 10, x: configuration.isPressed ? -5 : -10, y: configuration.isPressed ? -5 : -10)
                }
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Neumorphic Card

struct NeumorphicCard<Content: View>: View {
    var backgroundColor: Color = Color(hex: "FFFFFF")
    let content: Content
    
    init(backgroundColor: Color = Color(hex: "FFFFFF"), @ViewBuilder content: () -> Content) {
        self.backgroundColor = backgroundColor
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(backgroundColor)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                    .shadow(color: Color.white.opacity(0.7), radius: 10, x: -10, y: -10)
            )
    }
}

// MARK: - Primary Action Button

struct PrimaryActionButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isEnabled ? Color(hex: "FF3C00") : Color.gray)
                )
                .shadow(color: Color(hex: "FF3C00").opacity(isEnabled ? 0.3 : 0), radius: 10, x: 0, y: 5)
        }
        .disabled(!isEnabled)
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

