//
//  LoginView.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - Login View
// Native iOS navigation with horizontal transitions between steps

struct LoginView: View {
    
    // MARK: - Properties
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authService: AuthService
    let onSwitchToRegistration: () -> Void
    
    // Form data
    @State private var identifier = ""
    @State private var password = ""
    @State private var rememberDevice = false
    @State private var twoFACode = ""
    
    // Navigation path for programmatic navigation
    @State private var navigationPath = NavigationPath()
    
    // MARK: - Body
    var body: some View {
        NavigationStack(path: $navigationPath) {
            CredentialsStepView(
                identifier: $identifier,
                password: $password,
                rememberDevice: $rememberDevice,
                onSubmit: handleCredentialsSubmit,
                isLoading: authService.isLoading,
                errorMessage: authService.authError?.localizedMessage,
                onSwitchToRegistration: onSwitchToRegistration
            )
            .navigationDestination(for: TwoFAStep.self) { step in
                switch step {
                case .choose2FA:
                    Choose2FAStepView(
                        availableMethods: authService.available2FAMethods,
                        onMethodSelected: select2FAMethod,
                        onBack: handleBackNavigation
                    )
                    .navigationBarBackButtonHidden()
                    
                case .email2FA:
                    Email2FAStepView(
                        code: $twoFACode,
                        onSubmit: { handle2FASubmit(.email) },
                        onResend: handleResendCode,
                        isLoading: authService.isLoading,
                        errorMessage: authService.authError?.localizedMessage,
                        onBack: handleBackNavigation
                    )
                    .navigationBarBackButtonHidden()
                    
                case .totp2FA:
                    TOTP2FAStepView(
                        code: $twoFACode,
                        onSubmit: { handle2FASubmit(.totp) },
                        isLoading: authService.isLoading,
                        errorMessage: authService.authError?.localizedMessage,
                        onBack: handleBackNavigation
                    )
                    .navigationBarBackButtonHidden()
                    
                case .complete:
                    LoginCompleteStepView(
                        onContinue: handleLoginComplete
                    )
                    .navigationBarBackButtonHidden()
                    
                default:
                    EmptyView()
                }
            }
        }
        .appBackground()
        .onReceive(authService.$current2FAStep) { step in
            print("🔍 LoginView: current2FAStep changed to: \(step)")
            // Navigate to the new step using NavigationPath
            if step != .credentials {
                print("🚀 Navigating to step: \(step)")
                navigationPath.append(step)
            }
        }
        .onReceive(authService.$isAuthenticated) { isAuthenticated in
            print("🔍 LoginView: isAuthenticated changed to: \(isAuthenticated)")
            if isAuthenticated {
                // Navigate to complete step
                print("🚀 Navigating to complete step")
                navigationPath.append(TwoFAStep.complete)
            }
        }
    }
    
    // MARK: - Actions
    private func handleCredentialsSubmit() {
        // Clear previous errors
        authService.authError = nil
        
        // Call login method
        authService.loginStep1(identifier: identifier, password: password, rememberDevice: rememberDevice)
    }
    
    private func select2FAMethod(_ method: String) {
        authService.loginStep2Choose2FA(method: method)
        
        // Navigation will be handled automatically by AuthService
        // No need to manually set currentStep
    }
    
    private func handle2FASubmit(_ method: TwoFAMethod) {
        // Clear previous errors
        authService.authError = nil
        
        if method == .email {
            authService.loginStep3Email2FA(code: twoFACode)
        } else if method == .totp {
            authService.loginStep3TOTP2FA(code: twoFACode)
        }
    }
    
    private func handleResendCode() {
        // Clear previous errors
        authService.authError = nil
        
        // Call the resend 2FA code method
        authService.resend2FACode()
    }
    
    private func handleBackNavigation() {
        print("🔙 Back button pressed, navigating back")
        // Remove the last item from navigation path to go back
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
        // Reset the current 2FA step to credentials
        authService.current2FAStep = .credentials
    }
    
    private func handleLoginComplete() {
        // Reset to credentials step for next login
        authService.current2FAStep = .credentials
        // Clear form data
        identifier = ""
        password = ""
        twoFACode = ""
        rememberDevice = false
        // Clear navigation path to go back to credentials
        navigationPath = NavigationPath()
    }
}

// MARK: - Supporting Types
enum TwoFAMethod: String, CaseIterable {
    case email = "email"
    case totp = "totp"
}

// MARK: - Preview
#Preview {
    LoginView(onSwitchToRegistration: {})
        .environmentObject(AuthService())
}
