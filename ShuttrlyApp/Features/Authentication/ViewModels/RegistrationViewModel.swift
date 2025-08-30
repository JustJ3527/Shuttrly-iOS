//
//  RegistrationViewModel.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import Foundation
import Combine

// MARK: - Registration ViewModel
// Manages registration state and UI logic for SwiftUI

class RegistrationViewModel: ObservableObject {
    
    // MARK: - Properties
    
    // Registration state
    @Published var currentStep: RegistrationStep = .email
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    // Form data
    @Published var email = ""
    @Published var verificationCode = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var dateOfBirth = Date()
    @Published var username = ""
    @Published var password1 = ""
    @Published var password2 = ""
    
    // Username validation state
    @Published var isUsernameChecking = false
    @Published var isUsernameAvailable = false
    @Published var usernameValidationMessage = ""
    
    // Service
    private let registrationService = RegistrationService()
    
    // Cancellables
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Bind RegistrationService state to ViewModel
        registrationService.$currentStep
            .assign(to: \.currentStep, on: self)
            .store(in: &cancellables)
        
        registrationService.$isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
        
        registrationService.$errorMessage
            .assign(to: \.errorMessage, on: self)
            .store(in: &cancellables)
        
        registrationService.$successMessage
            .assign(to: \.successMessage, on: self)
            .store(in: &cancellables)
        
        registrationService.$registrationData
            .sink { [weak self] data in
                self?.updateFormFromRegistrationData(data)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /// Step 1: Submit email for verification
    func submitEmail() {
        clearMessages()
        
        guard !email.isEmpty else {
            errorMessage = "Please enter your email address"
            return
        }
        
        guard email.contains("@") else {
            errorMessage = "Please enter a valid email address"
            return
        }
        
        registrationService.registerStep1(email: email)
    }
    
    /// Step 2: Submit verification code
    func submitVerificationCode() {
        clearMessages()
        
        guard !verificationCode.isEmpty else {
            errorMessage = "Please enter the verification code"
            return
        }
        
        guard verificationCode.count == 6 else {
            errorMessage = "Verification code must be 6 digits"
            return
        }
        
        registrationService.registerStep2(email: email, verificationCode: verificationCode)
    }
    
    /// Step 3: Submit personal information
    func submitPersonalInfo() {
        clearMessages()
        
        guard !firstName.isEmpty else {
            errorMessage = "Please enter your first name"
            return
        }
        
        guard !lastName.isEmpty else {
            errorMessage = "Please enter your last name"
            return
        }
        
        // Check age requirement (16+)
        let calendar = Calendar.current
        let sixteenYearsAgo = calendar.date(byAdding: .year, value: -16, to: Date()) ?? Date()
        
        guard dateOfBirth <= sixteenYearsAgo else {
            errorMessage = "You must be at least 16 years old"
            return
        }
        
        registrationService.registerStep3(
            firstName: firstName,
            lastName: lastName,
            dateOfBirth: dateOfBirth
        )
    }
    
    /// Step 4: Check username availability
    func checkUsername() {
        clearMessages()
        
        guard !username.isEmpty else {
            errorMessage = "Please enter a username"
            return
        }
        
        guard username.count >= 3 else {
            errorMessage = "Username must be at least 3 characters"
            return
        }
        
        guard username.count <= 30 else {
            errorMessage = "Username must be 30 characters or less"
            return
        }
        
        isUsernameChecking = true
        registrationService.checkUsernameAvailability(username)
    }
    
    /// Step 5: Submit password and complete registration
    func submitPassword() {
        clearMessages()
        
        guard !password1.isEmpty else {
            errorMessage = "Please enter a password"
            return
        }
        
        guard password1.count >= 8 else {
            errorMessage = "Password must be at least 8 characters"
            return
        }
        
        guard password1 == password2 else {
            errorMessage = "Passwords do not match"
            return
        }
        
        registrationService.registerStep5(password1: password1, password2: password2)
    }
    
    /// Resend verification code
    func resendCode() {
        clearMessages()
        registrationService.resendVerificationCode(email: email)
    }
    
    /// Navigate to next step
    func nextStep() {
        registrationService.nextStep()
    }
    
    /// Navigate to previous step
    func previousStep() {
        registrationService.previousStep()
    }
    
    /// Reset registration process
    func resetRegistration() {
        registrationService.resetRegistration()
        clearForm()
    }
    
    /// Clear error message
    func clearError() {
        errorMessage = nil
    }
    
    /// Clear success message
    func clearSuccess() {
        successMessage = nil
    }
    
    // MARK: - Private Methods
    
    private func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
    
    private func clearForm() {
        email = ""
        verificationCode = ""
        firstName = ""
        lastName = ""
        dateOfBirth = Date()
        username = ""
        password1 = ""
        password2 = ""
        isUsernameChecking = false
        isUsernameAvailable = false
        usernameValidationMessage = ""
    }
    
    private func updateFormFromRegistrationData(_ data: RegistrationData) {
        email = data.email
        firstName = data.firstName
        lastName = data.lastName
        dateOfBirth = data.dateOfBirth
        username = data.username
        password1 = data.password1
        password2 = data.password2
        isUsernameChecking = data.isUsernameChecking
        isUsernameAvailable = data.isUsernameAvailable
        usernameValidationMessage = data.usernameValidationMessage
    }
    
    // MARK: - Computed Properties
    
    /// Check if current step form is valid
    var isCurrentStepValid: Bool {
        switch currentStep {
        case .email:
            return !email.isEmpty && email.contains("@")
        case .verification:
            return !verificationCode.isEmpty && verificationCode.count == 6
        case .personalInfo:
            return !firstName.isEmpty && !lastName.isEmpty && isAgeValid
        case .username:
            return !username.isEmpty && username.count >= 3 && username.count <= 30
        case .password:
            return !password1.isEmpty && password1.count >= 8 && password1 == password2
        case .accountSummary:
            return true // Account summary is always valid (read-only)
        case .complete:
            return true
        }
    }
    
    /// Check if user is old enough
    private var isAgeValid: Bool {
        let calendar = Calendar.current
        let sixteenYearsAgo = calendar.date(byAdding: .year, value: -16, to: Date()) ?? Date()
        return dateOfBirth <= sixteenYearsAgo
    }
    
    /// Get progress percentage (0.0 to 1.0)
    var progress: Double {
        return currentStep.progress
    }
    
    /// Get current step title
    var currentStepTitle: String {
        return currentStep.title
    }
    
    /// Get current step description
    var currentStepDescription: String {
        return currentStep.description
    }
}
