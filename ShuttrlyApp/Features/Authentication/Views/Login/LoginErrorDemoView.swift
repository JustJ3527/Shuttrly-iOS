//
//  LoginErrorDemoView.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - Login Error Demo View
// Demonstrates different types of authentication errors and their display

struct LoginErrorDemoView: View {
    
    // MARK: - Properties
    
    @State private var selectedErrorType: AuthErrorConstants.ErrorType = .login
    @State private var showError: Bool = false
    @State private var currentError: AuthError?
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Title
                Text("Authentication Error Demo")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Error type selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select Error Type:")
                        .font(.headline)
                    
                    Picker("Error Type", selection: $selectedErrorType) {
                        Text("Login").tag(AuthErrorConstants.ErrorType.login)
                        Text("Registration").tag(AuthErrorConstants.ErrorType.registration)
                        Text("2FA").tag(AuthErrorConstants.ErrorType.twoFA)
                        Text("Validation").tag(AuthErrorConstants.ErrorType.validation)
                        Text("Network").tag(AuthErrorConstants.ErrorType.network)
                        Text("Server").tag(AuthErrorConstants.ErrorType.server)
                        Text("Session").tag(AuthErrorConstants.ErrorType.session)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // Generate error button
                Button("Generate Error") {
                    generateError()
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal)
                
                // Error display
                if let error = currentError, showError {
                    AuthErrorView(
                        error: error,
                        onDismiss: {
                            showError = false
                            currentError = nil
                        },
                        onRetry: {
                            showError = false
                            currentError = nil
                            // Simulate retry
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                generateError()
                            }
                        }
                    )
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .scale))
                }
                
                Spacer()
            }
            .navigationTitle("Error Demo")
            .navigationBarTitleDisplayMode(.inline)
        }
        .animation(.easeInOut(duration: 0.3), value: showError)
    }
    
    // MARK: - Private Methods
    
    private func generateError() {
        currentError = createError(for: selectedErrorType)
        showError = true
    }
    
    private func createError(for type: AuthErrorConstants.ErrorType) -> AuthError {
        switch type {
        case .login:
            // Randomly select a login error
            let loginErrors = [
                AuthError.invalidCredentials(),
                AuthError.userNotFound(identifier: "test@example.com"),
                AuthError.accountLocked(),
                AuthError.emailNotVerified(email: "test@example.com"),
                AuthError.tooManyAttempts(attemptsRemaining: 2)
            ]
            return loginErrors.randomElement() ?? AuthError.invalidCredentials()
            
        case .registration:
            // Randomly select a registration error
            let registrationErrors = [
                AuthError.emailAlreadyExists(email: "test@example.com"),
                AuthError.usernameAlreadyTaken(username: "testuser"),
                AuthError.invalidUsernameFormat(username: "t", validationErrors: ["Username too short"]),
                AuthError.invalidPasswordFormat(validationErrors: ["Password too weak"]),
                AuthError.passwordsDontMatch(),
                AuthError.ageRestriction(minimumAge: 16),
                AuthError.verificationCodeExpired(),
                AuthError.invalidVerificationCode()
            ]
            return registrationErrors.randomElement() ?? AuthError.emailAlreadyExists(email: "test@example.com")
            
        case .twoFA:
            // Randomly select a 2FA error
            let twoFAErrors = [
                AuthError.twofaRequired(),
                AuthError.invalid2FACode(),
                AuthError.twofaCodeExpired(),
                AuthError.twofaMethodNotAvailable(method: "sms")
            ]
            return twoFAErrors.randomElement() ?? AuthError.invalid2FACode()
            
        case .validation:
            return AuthError.validationError(validationErrors: [
                "email": ["Invalid email format"],
                "username": ["Username must be 3-30 characters"]
            ])
            
        case .network:
            return AuthError.networkError()
            
        case .server:
            return AuthError.serverError(details: [
                "error": AnyCodable("Database connection failed"),
                "timestamp": AnyCodable("2025-08-28T10:30:00Z")
            ])
            
        case .session:
            return AuthError.sessionExpired()
        }
    }
}

// MARK: - Button Style

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    LoginErrorDemoView()
}
