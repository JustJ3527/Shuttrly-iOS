//
//  TwoFAValidationButton.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - TwoFA Validation Button
// Reusable component for 2FA code validation buttons

struct TwoFAValidationButton: View {
    
    // MARK: - Properties
    let code: String
    let isLoading: Bool
    let onTap: () -> Void
    
    // MARK: - Computed Properties
    private var isEnabled: Bool {
        return code.count == 6 && !isLoading
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: onTap) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text("Verify Code")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(isEnabled ? Color("primaryDefaultColor") : Color("primaryDefaultColor").opacity(0.5))
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(!isEnabled)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        // Enabled button
        TwoFAValidationButton(
            code: "123456",
            isLoading: false,
            onTap: {}
        )
        
        // Disabled button (incomplete code)
        TwoFAValidationButton(
            code: "123",
            isLoading: false,
            onTap: {}
        )
        
        // Loading button
        TwoFAValidationButton(
            code: "123456",
            isLoading: true,
            onTap: {}
        )
    }
    .padding()
    .background(Color("backgroundDefaultColor"))
}
