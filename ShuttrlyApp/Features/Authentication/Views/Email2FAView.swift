//
//  Email2FAView.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI
import Combine

// MARK: - Email 2FA Verification View
// Independent view for email 2FA code verification

struct Email2FAView: View {
    
    // MARK: - Properties
    
    @ObservedObject var twoFAService: TwoFAService
    @Environment(\.dismiss) private var dismiss
    
    @State private var verificationCode = ""
    @State private var timeRemaining = 60
    @State private var canResend = false
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Email Verification")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Enter the 6-digit code sent to your email")
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
                                code: verificationCode,
                                onCodeChange: { newCode in
                                    verificationCode = newCode
                                }
                            )
                        }
                    }
                    
                    // Auto-submit when 6 digits are entered
                    if verificationCode.count == 6 {
                        Button("Verify Code") {
                            verifyCode()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(twoFAService.isLoading)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Resend Code Section
                VStack(spacing: 16) {
                    if canResend {
                        Button("Resend Code") {
                            resendCode()
                        }
                        .buttonStyle(.bordered)
                        .disabled(twoFAService.isLoading)
                    } else {
                        Text("Resend code in \(timeRemaining) seconds")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
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
            .onReceive(timer) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    canResend = true
                }
            }
            .onAppear {
                startResendTimer()
            }
        }
    }
    
    // MARK: - Actions
    
    private func verifyCode() {
        guard verificationCode.count == 6 else { return }
        twoFAService.verifyEmail2FA(code: verificationCode)
    }
    
    private func resendCode() {
        twoFAService.resend2FACode()
        startResendTimer()
    }
    
    private func startResendTimer() {
        timeRemaining = 60
        canResend = false
    }
}

// MARK: - Code Digit Field

struct CodeDigitField: View {
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
    Email2FAView(twoFAService: TwoFAService())
}
