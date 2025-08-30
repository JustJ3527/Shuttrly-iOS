//
//  VerificationStepView.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI
import Combine

// MARK: - Verification Step View
// Step 2: Email verification code input

struct VerificationStepView: View {
    
    // MARK: - Properties
    let email: String
    @Binding var code: String
    let onSubmit: () -> Void
    let onResend: () -> Void
    let isLoading: Bool
    let errorMessage: String?
    let onBack: () -> Void
    
    // MARK: - Timer for countdown
    @State private var timeRemaining = 60
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
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
                    Text("Verify Your Email")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(Color("textDefaultColor"))
                        .multilineTextAlignment(.center)
                    
                    Text("Enter the 6-digit code sent to \(email)")
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
                
                // Validation Button
                CustomButton.primary(
                    title: isLoading ? "Verifying..." : "Verify Code",
                    action: onSubmit,
                    isEnabled: isCodeValid,
                    isLoading: isLoading
                )
            }
            .padding(.horizontal, 20)
            
            Spacer(minLength: 0) // Push content to fill available space
            
            // Resend Code Section
            VStack(spacing: 16) {
                if timeRemaining > 0 {
                    Text("Resend code in \(timeRemaining) seconds")
                        .font(.system(size: 14))
                        .foregroundColor(Color("textDefaultColor").opacity(0.6))
                } else {
                    CustomButton.secondary(
                        title: "Resend Code",
                        action: {
                            onResend()
                            timeRemaining = 60
                        }
                    )
                }
            }
            .padding(.horizontal, 32)
            
            // Error Message
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
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
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
        .onAppear {
            timeRemaining = 60
        }
    }
    
    // MARK: - Computed Properties
    private var isCodeValid: Bool {
        return code.count == 6
    }
}

// MARK: - Preview
#Preview {
    VerificationStepView(
        email: "test@example.com",
        code: .constant("123456"),
        onSubmit: {},
        onResend: {},
        isLoading: false,
        errorMessage: nil,
        onBack: {}
    )
    .background(Color("backgroundDefaultColor"))
}
