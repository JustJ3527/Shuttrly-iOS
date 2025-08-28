//
//  TOTP2FAView.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - TOTP 2FA Verification View
// Independent view for TOTP 2FA code verification

struct TOTP2FAView: View {
    
    // MARK: - Properties
    
    @ObservedObject var twoFAService: TwoFAService
    @Environment(\.dismiss) private var dismiss
    
    @State private var totpCode = ""
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Authenticator App")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Enter the 6-digit code from your authenticator app")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Code Input
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        ForEach(0..<6, id: \.self) { index in
                            CodeDigitField(
                                index: index,
                                code: totpCode,
                                onCodeChange: { newCode in
                                    totpCode = newCode
                                }
                            )
                        }
                    }
                    
                    // Auto-submit when 6 digits are entered
                    if totpCode.count == 6 {
                        Button("Verify Code") {
                            verifyCode()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(twoFAService.isLoading)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Help Text
                VStack(spacing: 8) {
                    Text("Don't have an authenticator app?")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Popular options: Google Authenticator, Authy, Microsoft Authenticator")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                
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
    
    private func verifyCode() {
        guard totpCode.count == 6 else { return }
        twoFAService.verifyTOTP2FA(code: totpCode)
    }
}

// MARK: - Code Digit Field (Reused from Email2FAView)

struct TOTPCodeDigitField: View {
    let index: Int
    let code: String
    let onCodeChange: (String) -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        TextField("", text: Binding(
            get: {
                if index < code.count {
                    return String(code[code.index(code.startIndex, offsetBy: index)])
                }
                return ""
            },
            set: { newValue in
                var newCode = code
                if newValue.count == 1 {
                    if index < newCode.count {
                        newCode.remove(at: newCode.index(newCode.startIndex, offsetBy: index))
                        newCode.insert(newValue.first!, at: newCode.index(newCode.startIndex, offsetBy: index))
                    } else {
                        newCode.append(newValue)
                    }
                    onCodeChange(newCode)
                    
                    // Auto-focus next field
                    if index < 5 && newValue.count == 1 {
                        // Focus next field logic would go here
                    }
                }
            }
        ))
        .keyboardType(.numberPad)
        .multilineTextAlignment(.center)
        .font(.title2)
        .fontWeight(.bold)
        .frame(width: 50, height: 60)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .focused($isFocused)
        .onTapGesture {
            isFocused = true
        }
    }
}

// MARK: - Preview

#Preview {
    TOTP2FAView(twoFAService: TwoFAService())
}
