//
//  LoginHeaderView.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - Login Header View
// Navigation header with back button and transparent background

struct LoginHeaderView<Content: View>: View {
    
    // MARK: - Properties
    let title: String
    let subtitle: String?
    let showBackButton: Bool
    let onBack: (() -> Void)?
    let content: Content
    
    // MARK: - Initializer
    init(
        title: String,
        subtitle: String? = nil,
        showBackButton: Bool = false,
        onBack: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.showBackButton = showBackButton
        self.onBack = onBack
        self.content = content()
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar with Back Button
            if showBackButton {
                HStack {
                    Button(action: onBack ?? {}) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                            Text("Back")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(Color("primaryDefaultColor"))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    
                    Spacer()
                }
                .padding(.top, 60) // Status bar + safe area
                .padding(.bottom, 16)
                .background(Color.clear)
            }
            
            // Logo and Title Section
            VStack(spacing: 24) {
                // Logo
                Image("logoShuttrlyFit")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                
                // Title and subtitle
                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(Color("textDefaultColor"))
                        .multilineTextAlignment(.center)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 16))
                            .foregroundColor(Color("textDefaultColor").opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
            
            // Content
            content
        }
        .background(Color.clear)
    }
}

// MARK: - Preview
#Preview {
    LoginHeaderView(
        title: "Two-Factor Authentication",
        subtitle: "Choose your preferred method",
        showBackButton: true,
        onBack: {}
    ) {
        VStack(spacing: 20) {
            Text("Content goes here")
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
            
            Spacer()
        }
        .padding()
    }
    .background(Color("backgroundDefaultColor"))
}
