//
//  TwoFAChoiceView.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - 2FA Method Choice View
// Independent view for choosing 2FA method when multiple are available

struct TwoFAChoiceView: View {
    
    // MARK: - Properties
    
    @ObservedObject var twoFAService: TwoFAService
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Choose 2FA Method")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Select how you'd like to verify your identity")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // 2FA Method Options
                VStack(spacing: 16) {
                    ForEach(twoFAService.availableMethods, id: \.self) { method in
                        TwoFAMethodButton(
                            method: method,
                            isSelected: twoFAService.chosenMethod == method,
                            action: {
                                selectMethod(method)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
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
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        twoFAService.goBack()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func selectMethod(_ method: String) {
        twoFAService.choose2FAMethod(method)
    }
}

// MARK: - 2FA Method Button

struct TwoFAMethodButton: View {
    let method: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: method == "email" ? "envelope.fill" : "key.fill")
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)
                    .frame(width: 24)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(method == "email" ? "Email Code" : "Authenticator App")
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(method == "email" ? "Receive a 6-digit code via email" : "Use your authenticator app")
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title3)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    TwoFAChoiceView(twoFAService: TwoFAService())
}
