//
//  RegistrationCompleteStepView.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - Registration Complete Step View
// Final step: Registration success

struct RegistrationCompleteStepView: View {
    
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
                    Text("Welcome to Shuttrly!")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(Color("textDefaultColor"))
                        .multilineTextAlignment(.center)
                    
                    Text("Your account has been created successfully")
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
                
                // Success Message
                VStack(spacing: 16) {
                    Text("Account Created!")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color("textDefaultColor"))
                    
                    Text("You can now sign in to your account and start using Shuttrly")
                        .font(.system(size: 16))
                        .foregroundColor(Color("textDefaultColor").opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                Spacer(minLength: 0) // Push content to fill available space
                
                // Continue Button
                CustomButton.primary(
                    title: "Sign In to Your Account",
                    action: onContinue
                )
                .padding(.horizontal, 32)
                
                // Additional Info
                VStack(spacing: 8) {
                    Text("What's next?")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("textDefaultColor"))
                    
                    Text("• Complete your profile\n• Upload your first photos\n• Explore the community")
                        .font(.system(size: 12))
                        .foregroundColor(Color("textDefaultColor").opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 16)
            }
            
            Spacer(minLength: 0) // Bottom spacing
        }
        .appBackground()
        .navigationBarHidden(true)
    }
}

// MARK: - Preview
#Preview {
    RegistrationCompleteStepView(
        onContinue: {}
    )
    .background(Color("backgroundDefaultColor"))
}
