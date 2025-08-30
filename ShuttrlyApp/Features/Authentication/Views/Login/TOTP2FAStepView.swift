//
//  TOTP2FAStepView.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - TOTP 2FA Step View
// Native iOS navigation view for TOTP 2FA code verification

struct TOTP2FAStepView: View {
    // MARK: - Properties
    @Binding var code: String
    let onSubmit: () -> Void
    let isLoading: Bool
    let errorMessage: String?
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
                    Text("TOTP Verification")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(Color("textDefaultColor"))
                        .multilineTextAlignment(.center)
                    
                    Text("Enter the 6-digit code from your authenticator app")
                        .font(.system(size: 16))
                        .foregroundColor(Color("textDefaultColor").opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
            .padding(.top, 60)
            
            // Code Input
            VStack(spacing: 16) {
                DigitField(numberOfFields: 6, code: $code)
                TwoFAValidationButton(
                    code: code,
                    isLoading: isLoading,
                    onTap: onSubmit
                )
            }
            .padding(.horizontal, 20)
            
            Spacer(minLength: 0) // Push content to fill available space
            
            // Help text
            VStack(spacing: 8) {
                Text("Make sure your authenticator app is in sync")
                    .font(.system(size: 14))
                    .foregroundColor(Color("textDefaultColor").opacity(0.6))
                    .multilineTextAlignment(.center)
                
                Text("The code refreshes every 30 seconds")
                    .font(.system(size: 12))
                    .foregroundColor(Color("textDefaultColor").opacity(0.5))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            
            // Error Message
            if let errorMessage = errorMessage {
                SimpleErrorView(
                    message: errorMessage,
                    errorType: .twoFA,
                    onDismiss: { /* Clear error */ }
                )
                .padding(.horizontal, 32)
                .padding(.top, 16)
            }
            
            Spacer(minLength: 0) // Bottom spacing
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
        TOTP2FAStepView(
            code: .constant(""),
            onSubmit: {},
            isLoading: false,
            errorMessage: nil,
            onBack: {}
        )
    }
    .environmentObject(AuthService())
}
