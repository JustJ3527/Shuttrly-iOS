//
//  AuthErrorView.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - Authentication Error View
// Displays authentication errors with proper styling, icons, and user guidance

struct AuthErrorView: View {
    
    // MARK: - Properties
    
    let error: AuthError
    let onDismiss: (() -> Void)?
    let onRetry: (() -> Void)?
    
    // MARK: - Initialization
    
    init(error: AuthError, onDismiss: (() -> Void)? = nil, onRetry: (() -> Void)? = nil) {
        self.error = error
        self.onDismiss = onDismiss
        self.onRetry = onRetry
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            // Error icon and title
            HStack(spacing: 12) {
                Image(systemName: error.iconName)
                    .font(.title2)
                    .foregroundColor(Color(error.colorName))
                
                Text(errorTitle)
                    .font(.headline)
                    .foregroundColor(Color(error.colorName))
                
                Spacer()
                
                // Dismiss button if provided
                if let onDismiss = onDismiss {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Error message
            Text(error.localizedMessage)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Action buttons
            if shouldShowActionButtons {
                HStack(spacing: 12) {
                    if let onRetry = onRetry {
                        Button("Try Again") {
                            onRetry()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    
                    if error.requiresUserAction {
                        Button("Get Help") {
                            // TODO: Implement help system
                            print("Help requested for error: \(error.id)")
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                }
            }
            
            // Additional guidance for specific error types
            if let guidance = errorGuidance {
                VStack(alignment: .leading, spacing: 8) {
                    Text("💡 Tip")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text(guidance)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.top, 8)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
                .fill(Color(error.colorName).opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
                .stroke(Color(error.colorName).opacity(0.3), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.3), value: error.id)
    }
    
    // MARK: - Computed Properties
    
    /// Error title based on error type
    private var errorTitle: String {
        switch error.errorType {
        case .login:
            return "Login Error"
        case .registration:
            return "Registration Error"
        case .twoFA:
            return "2FA Error"
        case .validation:
            return "Validation Error"
        case .network:
            return "Network Error"
        case .server:
            return "Server Error"
        case .session:
            return "Session Error"
        }
    }
    
    /// Whether to show action buttons
    private var shouldShowActionButtons: Bool {
        return onRetry != nil || error.requiresUserAction
    }
    
    /// Contextual guidance for the user
    private var errorGuidance: String? {
        switch error.errorType {
        case .login:
            if error.id == AuthErrorConstants.ErrorCodes.userNotFound {
                return "If you don't have an account, you can create one by tapping 'Create Account' below."
            } else if error.id == AuthErrorConstants.ErrorCodes.emailNotVerified {
                return "Check your email inbox and spam folder for the verification link."
            } else if error.id == AuthErrorConstants.ErrorCodes.accountLocked {
                return "This is a temporary security measure. Try again in a few minutes."
            }
        case .registration:
            if error.id == AuthErrorConstants.ErrorCodes.emailAlreadyExists {
                return "Try logging in instead, or use a different email address."
            } else if error.id == AuthErrorConstants.ErrorCodes.usernameAlreadyTaken {
                return "Try adding numbers or special characters to make it unique."
            } else if error.id == AuthErrorConstants.ErrorCodes.invalidPasswordFormat {
                return "Use at least 8 characters with a mix of letters, numbers, and symbols."
            }
        case .twoFA:
            if error.id == AuthErrorConstants.ErrorCodes.invalid2FACode {
                return "Make sure you're using the most recent code from your authenticator app or email."
            } else if error.id == AuthErrorConstants.ErrorCodes.twofaCodeExpired {
                return "Request a new code - they expire quickly for security reasons."
            }
        case .validation:
            return "Please check your input and try again. All fields are required."
        case .network:
            return "Check your internet connection and try again."
        case .server:
            return "We're experiencing technical difficulties. Please try again later."
        case .session:
            return "Your session has expired. Please log in again to continue."
        }
        
        return nil
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color("primaryDefaultColor"))
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(Color("primaryDefaultColor"))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color("primaryDefaultColor").opacity(0.1))
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        // Login error
        AuthErrorView(
            error: AuthError.invalidCredentials(),
            onDismiss: { print("Dismissed") },
            onRetry: { print("Retry") }
        )
        
        // Registration error
        AuthErrorView(
            error: AuthError.usernameAlreadyTaken(username: "testuser"),
            onDismiss: { print("Dismissed") }
        )
        
        // 2FA error
        AuthErrorView(
            error: AuthError.invalid2FACode(),
            onRetry: { print("Retry") }
        )
        
        // Network error
        AuthErrorView(
            error: AuthError.networkError()
        )
    }
    .padding()
    .background(Color("BackgroundColor"))
}
