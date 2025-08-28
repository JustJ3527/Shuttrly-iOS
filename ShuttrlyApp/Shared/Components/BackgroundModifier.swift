//
//  BackgroundModifier.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - Background Modifier
// Custom ViewModifier for the blurred circles background used across the app

struct BlurredCirclesBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            // MARK: - Background with blurred circles
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            ZStack {
                Circle()
                    .fill(Color("PrimaryColor").opacity(0.3))
                    .frame(width: 350, height: 350)
                    .blur(radius: 120)
                    .offset(x: -120, y: 250)
                
                Circle()
                    .fill(Color("AccentColor").opacity(0.2))
                    .frame(width: 300, height: 300)
                    .blur(radius: 100)
                    .offset(x: 150, y: -200)
                
                Circle()
                    .fill(Color("SecondaryColor").opacity(0.2))
                    .frame(width: 250, height: 250)
                    .blur(radius: 100)
                    .offset(x: -50, y: 0)
            }
            
            // Content goes on top
            content
        }
    }
}

// MARK: - View Extension
// Convenience extension to apply the background easily

extension View {
    /// Apply the standard blurred circles background used across the app
    func blurredCirclesBackground() -> some View {
        self.modifier(BlurredCirclesBackground())
    }
}

// MARK: - Preview
// Preview to see how the background looks

#Preview {
    VStack(spacing: 20) {
        Text("Hello World!")
            .font(.title)
            .foregroundColor(.primary)
        
        Text("This is a preview of the background")
            .foregroundColor(.secondary)
        
        Button("Sample Button") {
            // Action
        }
        .buttonStyle(.borderedProminent)
    }
    .blurredCirclesBackground()
}
