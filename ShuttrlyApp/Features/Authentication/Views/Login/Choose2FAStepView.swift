//
//  Choose2FAStepView.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - Choose 2FA Step View
// Native iOS navigation view for selecting 2FA method

struct Choose2FAStepView: View {
    // MARK: - Properties
    let availableMethods: [String]
    let onMethodSelected: (String) -> Void
    let onBack: () -> Void
    
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
                    Text("Two-Factor Authentication")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(Color("textDefaultColor"))
                        .multilineTextAlignment(.center)
                    
                    Text("Choose your preferred 2FA method")
                        .font(.system(size: 16))
                        .foregroundColor(Color("textDefaultColor").opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
            .padding(.top, 60)
            
            // 2FA Method options
            VStack(spacing: 24) {
                // Email 2FA Option
                if availableMethods.contains("email") {
                    Button(action: {
                        onMethodSelected("email")
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color("primaryDefaultColor"))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Email")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color("textDefaultColor"))
                                
                                Text("Receive a code via email")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color("textDefaultColor").opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color("textDefaultColor").opacity(0.5))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color("backgroundDefaultColor"))
                        .cornerRadius(12)
                    }
                }
                
                // TOTP 2FA Option
                if availableMethods.contains("totp") {
                    Button(action: {
                        onMethodSelected("totp")
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: "key.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color("primaryDefaultColor"))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Authenticator App")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color("textDefaultColor"))
                                
                                Text("Use TOTP from your app")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color("textDefaultColor").opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color("textDefaultColor").opacity(0.5))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color("backgroundDefaultColor"))
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 32)
            
            // Help text
            VStack(spacing: 8) {
                Text("Need help?")
                    .font(.system(size: 14))
                    .foregroundColor(Color("textDefaultColor").opacity(0.6))
                
                Text("Contact support if you're having trouble")
                    .font(.system(size: 12))
                    .foregroundColor(Color("textDefaultColor").opacity(0.5))
            }
            .padding(.top, 16)
            .padding(.horizontal, 32)
            
            Spacer(minLength: 0) // Push content to fill available space
        }
        .appBackground()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    onBack()
                }
                .foregroundColor(Color("primaryDefaultColor"))
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        Choose2FAStepView(
            availableMethods: ["email", "totp"],
            onMethodSelected: { _ in },
            onBack: { }
        )
    }
    .environmentObject(AuthService())
}
