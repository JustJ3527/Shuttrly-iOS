//
//  CredentialsStepView.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - Credentials Step View
// Native iOS navigation view for login credentials

struct CredentialsStepView: View {
    
    // MARK: - Properties
    @Binding var identifier: String
    @Binding var password: String
    @Binding var rememberDevice: Bool
    let onSubmit: () -> Void
    let isLoading: Bool
    let errorMessage: String?
    let onSwitchToRegistration: () -> Void
    
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
                    Text("Sign in to your account")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(Color("textDefaultColor"))
                        .multilineTextAlignment(.center)
                    
                    Text("Enter your credentials to continue")
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
                // Form fields
                VStack(spacing: 24) {
                    // Email/Username field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email or Username")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color("textDefaultColor"))
                        
                        TextField("Enter your email or username", text: $identifier)
                            .textFieldStyle(ShuttrlyTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                    }
                    
                    // Password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color("textDefaultColor"))
                        
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(ShuttrlyTextFieldStyle())
                    }
                    
                    // Remember device toggle
                    ToggleField.checkboxWithIcon(
                        title: "Remember this device",
                        icon: "lock.shield",
                        isOn: $rememberDevice
                    )
                }
                
                // Login button
                CustomButton.primary(
                    title: "Sign In",
                    action: onSubmit,
                    isEnabled: !identifier.isEmpty && !password.isEmpty,
                    isLoading: isLoading
                )
                
                // Error message
                if let errorMessage = errorMessage {
                    SimpleErrorView(
                        message: errorMessage,
                        onDismiss: { /* Clear error */ }
                    )
                    .padding(.horizontal, 24)
                }
                
                // Forgot password link
                Button("Forgot password?") {
                    // TODO: Navigate to forgot password
                }
                .font(.system(size: 14))
                .foregroundColor(Color("primaryDefaultColor"))
                .padding(.top, 16)
                
                // Create account link
                Button("Don't have an account? Create one") {
                    onSwitchToRegistration()
                }
                .font(.system(size: 14))
                .foregroundColor(Color("accentDefaultColor"))
                .padding(.top, 8)
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 32)
        }
        .appBackground()
        .navigationBarHidden(true)
    }
}

// MARK: - Custom Text Field Style
struct ShuttrlyTextFieldStyle: TextFieldStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color("backgroundDefaultColor"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("textDefaultColor").opacity(0.2), lineWidth: 1)
            )
            .foregroundColor(Color("textDefaultColor"))
    }
}

// MARK: - Preview
#Preview {
    CredentialsStepView(
        identifier: .constant(""),
        password: .constant(""),
        rememberDevice: .constant(false),
        onSubmit: {},
        isLoading: false,
        errorMessage: nil,
        onSwitchToRegistration: {}
    )
}
