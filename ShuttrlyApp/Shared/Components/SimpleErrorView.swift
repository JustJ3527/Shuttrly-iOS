//
//  SimpleErrorView.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - Simple Error View
// Lightweight error display component for basic error messages

struct SimpleErrorView: View {
    
    // MARK: - Properties
    
    let message: String
    let errorType: AuthErrorConstants.ErrorType?
    let onDismiss: (() -> Void)?
    
    // MARK: - Initialization
    
    init(message: String, errorType: AuthErrorConstants.ErrorType? = nil, onDismiss: (() -> Void)? = nil) {
        self.message = message
        self.errorType = errorType
        self.onDismiss = onDismiss
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 12) {
            // Error icon
            Image(systemName: iconName)
                .font(.subheadline)
                .foregroundColor(Color(colorName))
            
            // Error message
            Text(message)
                .font(.subheadline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
            
            Spacer()
            
            // Dismiss button if provided
            if let onDismiss = onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(colorName).opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(colorName).opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Computed Properties
    
    /// Icon name based on error type
    private var iconName: String {
        guard let errorType = errorType else {
            return "exclamationmark.triangle"
        }
        
        switch errorType {
        case .login:
            return "exclamationmark.triangle"
        case .registration:
            return "person.badge.plus"
        case .twoFA:
            return "lock.shield"
        case .validation:
            return "checkmark.circle"
        case .network:
            return "wifi.slash"
        case .server:
            return "server.rack"
        case .session:
            return "clock.arrow.circlepath"
        }
    }
    
    /// Color name based on error type
    private var colorName: String {
        guard let errorType = errorType else {
            return "WarningColor"
        }
        
        let severity = AuthErrorConstants.ErrorSeverity(from: errorType)
        
        switch severity {
        case .low:
            return "primaryDefaultColor"
        case .medium:
            return "primaryDefaultColor"
        case .high:
            return "warningBackgroundColor"
        case .critical:
            return "warningBackgroundColor"
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        SimpleErrorView(
            message: "Invalid email or password",
            errorType: .login,
            onDismiss: { print("Dismissed") }
        )
        
        SimpleErrorView(
            message: "Username is already taken",
            errorType: .registration
        )
        
        SimpleErrorView(
            message: "Network connection error",
            errorType: .network
        )
        
        SimpleErrorView(
            message: "Generic error message"
        )
    }
    .padding()
    .background(Color("BackgroundColor"))
}
