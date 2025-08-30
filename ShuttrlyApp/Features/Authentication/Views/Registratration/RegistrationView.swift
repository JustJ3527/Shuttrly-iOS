//
//  RegistrationView.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - Registration View
// Native iOS navigation with horizontal transitions between registration steps

struct RegistrationView: View {
    
    // MARK: - Properties
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var registrationService: RegistrationService
    let onSwitchToLogin: () -> Void
    
    // Navigation path for programmatic navigation
    @State private var navigationPath = NavigationPath()
    
    // MARK: - Body
    var body: some View {
        NavigationStack(path: $navigationPath) {
            EmailStepView(
                email: $registrationService.registrationData.email,
                onSubmit: handleEmailSubmit,
                isLoading: registrationService.isLoading,
                errorMessage: registrationService.errorMessage,
                onSwitchToLogin: onSwitchToLogin
            )
            .navigationDestination(for: RegistrationStep.self) { step in
                switch step {
                case .verification:
                    VerificationStepView(
                        email: registrationService.registrationData.email,
                        code: $registrationService.registrationData.verificationCode,
                        onSubmit: handleVerificationSubmit,
                        onResend: handleResendCode,
                        isLoading: registrationService.isLoading,
                        errorMessage: registrationService.errorMessage,
                        onBack: handleBackNavigation
                    )
                    .navigationBarBackButtonHidden()
                    
                case .personalInfo:
                    PersonalInfoStepView(
                        firstName: $registrationService.registrationData.firstName,
                        lastName: $registrationService.registrationData.lastName,
                        dateOfBirth: $registrationService.registrationData.dateOfBirth,
                        onSubmit: handlePersonalInfoSubmit,
                        onBack: handleBackNavigation
                    )
                    .navigationBarBackButtonHidden()
                    
                case .username:
                    UsernameStepView(
                        username: $registrationService.registrationData.username,
                        isChecking: $registrationService.registrationData.isUsernameChecking,
                        isAvailable: $registrationService.registrationData.isUsernameAvailable,
                        validationMessage: $registrationService.registrationData.usernameValidationMessage,
                        onSubmit: handleUsernameSubmit,
                        onContinue: handleUsernameContinue,
                        onBack: handleBackNavigation
                    )
                    .navigationBarBackButtonHidden()
                    
                case .password:
                    PasswordStepView(
                        password1: $registrationService.registrationData.password1,
                        password2: $registrationService.registrationData.password2,
                        onSubmit: handlePasswordSubmit,
                        onBack: handleBackNavigation
                    )
                    .navigationBarBackButtonHidden()
                    
                case .accountSummary:
                    AccountSummaryStepView(
                        email: registrationService.registrationData.email,
                        firstName: registrationService.registrationData.firstName,
                        lastName: registrationService.registrationData.lastName,
                        dateOfBirth: registrationService.registrationData.dateOfBirth,
                        username: registrationService.registrationData.username,
                        onSubmit: handleAccountSummarySubmit,
                        onBack: handleBackNavigation
                    )
                    .navigationBarBackButtonHidden()
                    
                case .complete:
                    RegistrationCompleteStepView(
                        onContinue: handleRegistrationComplete
                    )
                    .navigationBarBackButtonHidden()
                    
                default:
                    EmptyView()
                }
            }
        }
        .appBackground()
        .onReceive(registrationService.$currentStep) { step in
            print("🔍 RegistrationView: currentStep changed to: \(step)")
            // Navigate to the new step using NavigationPath
            if step != .email {
                print("🚀 Navigating to registration step: \(step)")
                navigationPath.append(step)
            }
        }
    }
    
    // MARK: - Actions
    private func handleEmailSubmit() {
        registrationService.registerStep1(email: registrationService.registrationData.email)
    }
    
    private func handleVerificationSubmit() {
        registrationService.registerStep2(
            email: registrationService.registrationData.email,
            verificationCode: registrationService.registrationData.verificationCode
        )
    }
    
    private func handlePersonalInfoSubmit() {
        registrationService.registerStep3(
            firstName: registrationService.registrationData.firstName,
            lastName: registrationService.registrationData.lastName,
            dateOfBirth: registrationService.registrationData.dateOfBirth
        )
    }
    
    private func handleUsernameSubmit() {
        registrationService.checkUsernameAvailability(registrationService.registrationData.username)
    }
    
    private func handleUsernameContinue() {
        registrationService.continueFromUsername()
    }
    
    private func handlePasswordSubmit() {
        // Move to account summary step instead of creating account directly
        registrationService.currentStep = .accountSummary
    }
    
    private func handleAccountSummarySubmit() {
        // Create the account using the complete registration data
        registrationService.registerComplete()
    }
    
    private func handleResendCode() {
        registrationService.resendVerificationCode(email: registrationService.registrationData.email)
    }
    
    private func handleBackNavigation() {
        print("🔙 Back button pressed in registration, navigating back")
        // Remove the last item from navigation path to go back
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
        // Move to previous step
        registrationService.previousStep()
    }
    
    private func handleRegistrationComplete() {
        // Reset registration process
        registrationService.resetRegistration()
        // Clear navigation path to go back to email step
        navigationPath = NavigationPath()
    }
}

// MARK: - Preview
#Preview {
    RegistrationView(onSwitchToLogin: {})
        .environmentObject(RegistrationService())
}
