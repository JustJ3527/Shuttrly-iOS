//
//  BackgroundModifier.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - Modifier
struct AppBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            // Background fixe avec cercles flous
            Color("backgroundDefaultColor")
                .ignoresSafeArea()
            
            Circle()
                .fill(Color("primaryDefaultColor").opacity(0.3))
                .frame(width: 350, height: 350)
                .blur(radius: 120)
                .offset(x: -120, y: 250)
            
            Circle()
                .fill(Color("accentDefaultColor").opacity(0.2))
                .frame(width: 300, height: 300)
                .blur(radius: 100)
                .offset(x: 150, y: -200)
            
            Circle()
                .fill(Color("secondaryDefaultColor").opacity(0.2))
                .frame(width: 250, height: 250)
                .blur(radius: 100)
                .offset(x: -50, y: 0)
            
            // Ton contenu au-dessus
            content
        }
    }
}

// MARK: - Extension
extension View {
    func appBackground() -> some View {
        self.modifier(AppBackgroundModifier())
    }
}
