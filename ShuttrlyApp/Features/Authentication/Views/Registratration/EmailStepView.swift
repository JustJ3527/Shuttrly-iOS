//
//  EmailStepView.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - Email Step View
// Step 1: Email input for registration

struct EmailStepView: View {
    
    // MARK: - Properties
    @Binding var email: String
    let onSubmit: () -> Void
    let isLoading: Bool
    let errorMessage: String?
    let onSwitchToLogin: () -> Void
    
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
                    Text("Create Your Account")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(Color("textDefaultColor"))
                        .multilineTextAlignment(.center)
                    
                    Text("Enter your email to get started")
                        .font(.system(size: 16))
                        .foregroundColor(Color("textDefaultColor").opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
            .padding(.top, 60)
            
            // Form content
            VStack(spacing: 32) {
                // Email Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email Address")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("textDefaultColor"))
                    
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(CustomTextFieldStyle())
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
                
                // Submit Button
                CustomButton.primary(
                    title: isLoading ? "Sending Code..." : "Send Verification Code",
                    action: onSubmit,
                    isEnabled: isEmailValid,
                    isLoading: isLoading
                )
                
                // Help text
                VStack(spacing: 8) {
                    Text("We'll send a 6-digit verification code to your email")
                        .font(.system(size: 14))
                        .foregroundColor(Color("textDefaultColor").opacity(0.6))
                        .multilineTextAlignment(.center)
                    
                    Text("This helps us verify your email address")
                        .font(.system(size: 12))
                        .foregroundColor(Color("textDefaultColor").opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 16)
                
                // Sign in link
                Button("Already have an account? Sign in") {
                    onSwitchToLogin()
                }
                .font(.system(size: 14))
                .foregroundColor(Color("accentDefaultColor"))
                .padding(.top, 16)
                
                Spacer(minLength: 0) // Push content to fill available space
            }
            .padding(.horizontal, 32)
            
            // Error Message
            if let errorMessage = errorMessage {
                SimpleErrorView(
                    message: errorMessage,
                    errorType: .registration,
                    onDismiss: { /* Clear error */ }
                )
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .appBackground()
        .navigationBarHidden(true)
    }
    
    // MARK: - Computed Properties
    private var isEmailValid: Bool {
        return !email.isEmpty && email.contains("@") && email.contains(".")
    }
}

// MARK: - Custom Text Field Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color("backgroundDefaultColor"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("primaryDefaultColor").opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Preview
#Preview {
    EmailStepView(
        email: .constant("test@example.com"),
        onSubmit: {},
        isLoading: false,
        errorMessage: nil,
        onSwitchToLogin: {}
    )
    .background(Color("backgroundDefaultColor"))
}
