//
//  LoginCompleteStepView.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - Login Complete Step View
// Native iOS navigation view for login completion

struct LoginCompleteStepView: View {
    
    // MARK: - Properties
    let onContinue: () -> Void
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 24) {
                // Logo
                Image("logoShuttrlyFit")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                
                // Title and subtitle
                VStack(spacing: 8) {
                    Text("Welcome back!")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(Color("textDefaultColor"))
                        .multilineTextAlignment(.center)
                    
                    Text("You have successfully signed in to your account")
                        .font(.system(size: 16))
                        .foregroundColor(Color("textDefaultColor").opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
            .padding(.top, 60)
            
            // Success content
            VStack(spacing: 32) {
                // Success Icon
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                // Push content to fill available space
                Spacer(minLength: 0)
                
                // Continue Button
                CustomButton.primary(
                    title: "Continue to App",
                    action: onContinue
                )
                .padding(.horizontal, 32)
                
                // Bottom spacing
                Spacer(minLength: 0)
            }
        }
        .appBackground()
        .navigationBarHidden(true)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        LoginCompleteStepView(
            onContinue: {}
        )
    }
    .environmentObject(AuthService())
}
