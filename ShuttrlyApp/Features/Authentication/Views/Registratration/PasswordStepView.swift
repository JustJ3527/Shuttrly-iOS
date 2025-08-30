//
//  PasswordStepView.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - Password Step View
// Step 5: Password creation with confirmation

struct PasswordStepView: View {
    
    // MARK: - Properties
    @Binding var password1: String
    @Binding var password2: String
    let onSubmit: () -> Void
    let onBack: () -> Void
    
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
                    Text("Create Your Password")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(Color("textDefaultColor"))
                        .multilineTextAlignment(.center)
                    
                    Text("Choose a strong password to secure your account")
                        .font(.system(size: 16))
                        .foregroundColor(Color("textDefaultColor").opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
            .padding(.top, 60)
            
            // Form content
            VStack(spacing: 24) {
                // Password Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("textDefaultColor"))
                    
                    SecureField("Enter your password", text: $password1)
                        .textFieldStyle(CustomTextFieldStyle())
                        .textContentType(.newPassword)
                }
                
                // Password Confirmation Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Confirm Password")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("textDefaultColor"))
                    
                    SecureField("Confirm your password", text: $password2)
                        .textFieldStyle(CustomTextFieldStyle())
                        .textContentType(.newPassword)
                }
                
                // Password Requirements
                VStack(alignment: .leading, spacing: 12) {
                    Text("Password Requirements:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("textDefaultColor"))
                    
                    VStack(alignment: .leading, spacing: 6) {
                        PasswordRequirementRow(
                            text: "At least 8 characters long",
                            isMet: password1.count >= 8
                        )
                        PasswordRequirementRow(
                            text: "Contains at least one letter",
                            isMet: password1.rangeOfCharacter(from: .letters) != nil
                        )
                        PasswordRequirementRow(
                            text: "Contains at least one number",
                            isMet: password1.rangeOfCharacter(from: .decimalDigits) != nil
                        )
                        PasswordRequirementRow(
                            text: "Passwords match",
                            isMet: !password1.isEmpty && password1 == password2
                        )
                    }
                }
                .padding(.top, 8)
                
                // Submit Button
                CustomButton.primary(
                    title: "Continue",
                    action: onSubmit,
                    isEnabled: isFormValid
                )
                .padding(.top, 16)
                
                // Help text
                VStack(spacing: 8) {
                    Text("Your password is encrypted and never stored in plain text")
                        .font(.system(size: 14))
                        .foregroundColor(Color("textDefaultColor").opacity(0.6))
                        .multilineTextAlignment(.center)
                    
                    Text("Make sure to remember your password")
                        .font(.system(size: 12))
                        .foregroundColor(Color("textDefaultColor").opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 16)
                
                Spacer(minLength: 0) // Push content to fill available space
            }
            .padding(.horizontal, 32)
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
    }
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
        return password1.count >= 8 && 
               password1.rangeOfCharacter(from: .letters) != nil &&
               password1.rangeOfCharacter(from: .decimalDigits) != nil &&
               password1 == password2
    }
}

// MARK: - Password Requirement Row
struct PasswordRequirementRow: View {
    let text: String
    let isMet: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isMet ? .green : Color("textDefaultColor").opacity(0.4))
                .font(.system(size: 14))
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(isMet ? Color("textDefaultColor") : Color("textDefaultColor").opacity(0.6))
        }
    }
}

// MARK: - Custom Text Field Style
struct PasswordTextFieldStyle: TextFieldStyle {
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
    PasswordStepView(
        password1: .constant("password123"),
        password2: .constant("password123"),
        onSubmit: {},
        onBack: {}
    )
    .background(Color("backgroundDefaultColor"))
}
