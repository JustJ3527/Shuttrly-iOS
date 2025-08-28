//
//  TwoFACoordinatorView.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - 2FA Coordinator View
// Manages navigation between 2FA steps independently

struct TwoFACoordinatorView: View {
    
    // MARK: - Properties
    
    @StateObject private var twoFAService = TwoFAService()
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            switch twoFAService.currentStep {
            case .credentials:
                CredentialsView(twoFAService: twoFAService)
                
            case .choose2FA:
                TwoFAChoiceView(twoFAService: twoFAService)
                
            case .email2FA:
                Email2FAView(twoFAService: twoFAService)
                
            case .totp2FA:
                TOTP2FAView(twoFAService: twoFAService)
                
            case .complete:
                LoginCompleteView(twoFAService: twoFAService, onDismiss: { dismiss() })
            }
        }
        .onReceive(twoFAService.$currentStep) { step in
            // Handle step changes if needed
            print("🔄 2FA Step changed to: \(step)")
        }
    }
}

// MARK: - Credentials View

struct CredentialsView: View {
    
    @ObservedObject var twoFAService: TwoFAService
    
    @State private var identifier = ""
    @State private var password = ""
    @State private var rememberDevice = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Welcome Back")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Sign in to your account")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                // Form
                VStack(spacing: 20) {
                    // Identifier field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email or Username")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter your email or username", text: $identifier)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.username)
                            .autocapitalization(.none)
                    }
                    
                    // Password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.password)
                    }
                    
                    // Remember device
                    Toggle("Remember this device", isOn: $rememberDevice)
                        .font(.subheadline)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Login Button
                Button("Sign In") {
                    twoFAService.verifyCredentials(username: identifier, password: password)
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .padding(.horizontal, 20)
                .disabled(identifier.isEmpty || password.isEmpty || twoFAService.isLoading)
                
                // Error Message
                if let errorMessage = twoFAService.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Loading Indicator
                if twoFAService.isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                        .padding()
                }
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
    

}

// MARK: - Login Complete View

struct LoginCompleteView: View {
    
    @ObservedObject var twoFAService: TwoFAService
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                
                // Success Icon
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                // Success Message
                VStack(spacing: 16) {
                    Text("Welcome Back!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let user = twoFAService.userInfo {
                        Text("Hello, \(user.firstName ?? user.username)!")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("You have successfully signed in to your account.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // Continue Button
                Button("Continue") {
                    onDismiss()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .padding(.horizontal, 20)
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Preview

#Preview {
    TwoFACoordinatorView()
}
