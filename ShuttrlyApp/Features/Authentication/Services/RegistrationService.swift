//
//  RegistrationService.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import Foundation
import Combine

// MARK: - Registration Service
// Handles multi-step user registration with Django API

class RegistrationService: ObservableObject {
    
    // MARK: - Properties
    
    // Published properties for SwiftUI binding
    @Published var currentStep: RegistrationStep = .email
    @Published var registrationData = RegistrationData()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var shouldRedirectToProfile: Bool = false
    
    // Network manager instance
    private let networkManager = NetworkManager.shared
    
    // Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Registration Methods
    
    /// Step 1: Send email verification code
    func registerStep1(email: String) {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        let request = RegisterStep1Request(email: email)
        
        networkManager.performRequest(
            endpoint: AppConstants.API.Endpoints.registerStep1,
            method: .POST,
            requestBody: request,
            responseType: RegisterStep1Response.self
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            },
            receiveValue: { [weak self] response in
                self?.handleStep1Response(response)
            }
        )
        .store(in: &cancellables)
    }
    
    /// Step 2: Verify email code
    func registerStep2(email: String, verificationCode: String) {
        isLoading = true
        errorMessage = nil
        
        let request = RegisterStep2Request(
            email: email,
            verificationCode: verificationCode
        )
        
        networkManager.performRequest(
            endpoint: AppConstants.API.Endpoints.registerStep2,
            method: .POST,
            requestBody: request,
            responseType: RegisterStep2Response.self
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            },
            receiveValue: { [weak self] response in
                self?.handleStep2Response(response)
            }
        )
        .store(in: &cancellables)
    }
    
    /// Step 3: Submit personal information
    func registerStep3(firstName: String, lastName: String, dateOfBirth: Date) {
        isLoading = true
        errorMessage = nil
        
        // Store data locally (no API call for this step)
        registrationData.firstName = firstName
        registrationData.lastName = lastName
        registrationData.dateOfBirth = dateOfBirth
        
        // Move to next step
        currentStep = .username
        isLoading = false
    }
    
    /// Step 4: Check username availability
    func checkUsernameAvailability(_ username: String) {
        print("🚀 Starting username availability check for: \(username)")
        
        // Set checking state to true
        registrationData.isUsernameChecking = true
        errorMessage = nil
        
        print("🔍 Set isUsernameChecking to true")
        
        let request = UsernameAvailabilityRequest(username: username)
        
        networkManager.performRequest(
            endpoint: AppConstants.API.Endpoints.registerStep4,
            method: .POST,
            requestBody: request,
            responseType: UsernameAvailabilityResponse.self
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                print("🔍 Username check completion: \(completion)")
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    print("❌ Username check failed: \(error)")
                    
                    // Handle HTTP 400 errors (username already taken)
                    if case .httpError(let statusCode) = error, statusCode == 400 {
                        self?.registrationData.isUsernameAvailable = false
                        self?.registrationData.usernameValidationMessage = "Username is already taken"
                        print("🔍 Set username as unavailable due to 400 error")
                    } else {
                        // Network or other errors - show generic message
                        self?.registrationData.isUsernameAvailable = false
                        self?.registrationData.usernameValidationMessage = "Unable to check username availability"
                        print("🔍 Set username as unavailable due to network error")
                    }
                }
                
                // Always set checking to false after completion (success or failure)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.registrationData.isUsernameChecking = false
                }
            },
            receiveValue: { [weak self] response in
                print("🔍 Username check response received: \(response)")
                self?.handleUsernameAvailabilityResponse(response, username: username)
            }
        )
        .store(in: &cancellables)
    }
    
    /// Step 4: Continue to next step after username validation
    func continueFromUsername() {
        if registrationData.isUsernameAvailable {
            currentStep = .password
        }
    }
    
    /// Step 5: Submit password and complete registration
    func registerStep5(password1: String, password2: String) {
        isLoading = true
        errorMessage = nil
        
        // Validate passwords match
        guard password1 == password2 else {
            errorMessage = "Passwords do not match"
            isLoading = false
            return
        }
        
        // Validate password length
        guard password1.count >= 8 else {
            errorMessage = "Password must be at least 8 characters long"
            isLoading = false
            return
        }
        
        // Store passwords
        registrationData.password1 = password1
        registrationData.password2 = password2
        
        // Create complete registration request
        let request = registrationData.createCompleteRequest()
        
        networkManager.performRequest(
            endpoint: AppConstants.API.Endpoints.registerComplete,
            method: .POST,
            requestBody: request,
            responseType: RegisterCompleteResponse.self
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            },
            receiveValue: { [weak self] response in
                self?.handleRegistrationComplete(response)
            }
        )
        .store(in: &cancellables)
    }
    
    /// Complete registration (called from account summary step)
    func registerComplete() {
        // Use the stored password data to complete registration
        registerStep5(
            password1: registrationData.password1,
            password2: registrationData.password2
        )
    }
    
    /// Resend verification code
    func resendVerificationCode(email: String) {
        isLoading = true
        errorMessage = nil
        
        let request = ResendCodeRequest(email: email)
        
        networkManager.performRequest(
            endpoint: AppConstants.API.Endpoints.resendCode,
            method: .POST,
            requestBody: request,
            responseType: ResendCodeResponse.self
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            },
            receiveValue: { [weak self] response in
                self?.handleResendCodeResponse(response)
            }
        )
        .store(in: &cancellables)
    }
    
    // MARK: - Navigation Methods
    
    /// Move to next step
    func nextStep() {
        switch currentStep {
        case .email:
            currentStep = .verification
        case .verification:
            currentStep = .personalInfo
        case .personalInfo:
            currentStep = .username
        case .username:
            currentStep = .password
        case .password:
            currentStep = .accountSummary
        case .accountSummary:
            currentStep = .complete
        case .complete:
            break // Already at final step
        }
    }
    
    /// Move to previous step
    func previousStep() {
        switch currentStep {
        case .email:
            break // Already at first step
        case .verification:
            currentStep = .email
        case .personalInfo:
            currentStep = .verification
        case .username:
            currentStep = .personalInfo
        case .password:
            currentStep = .username
        case .accountSummary:
            currentStep = .password
        case .complete:
            currentStep = .accountSummary
        }
    }
    
    /// Reset registration process
    func resetRegistration() {
        currentStep = .email
        registrationData = RegistrationData()
        errorMessage = nil
        successMessage = nil
        shouldRedirectToProfile = false
    }
    
    // MARK: - Private Methods
    
    private func handleStep1Response(_ response: RegisterStep1Response) {
        if response.success {
            // Store email and temp user ID
            registrationData.email = response.email
            registrationData.tempUserId = response.tempUserId
            
            // Move to next step
            currentStep = .verification
            successMessage = response.message
        } else {
            errorMessage = response.message
        }
    }
    
    private func handleStep2Response(_ response: RegisterStep2Response) {
        if response.success && response.emailVerified {
            // Email verified successfully
            currentStep = .personalInfo
            successMessage = response.message
        } else {
            errorMessage = response.message
        }
    }
    
    private func handleUsernameAvailabilityResponse(_ response: UsernameAvailabilityResponse, username: String) {
        print("🔍 UsernameAvailabilityResponse received: \(response)")
        
        // Note: isUsernameChecking is set to false in the completion handler
        // with a delay to ensure the animation is visible
        
        if response.available {
            // Username is available
            registrationData.username = username
            registrationData.isUsernameAvailable = true
            registrationData.usernameValidationMessage = response.message
            
            print("✅ Username available: \(username), message: \(response.message)")
            print("🔍 Updated registrationData: isAvailable=\(registrationData.isUsernameAvailable), message='\(registrationData.usernameValidationMessage)'")
            
            // Don't move to next step automatically for real-time validation
            // User will click "Continue" when ready
        } else {
            // Username is not available
            registrationData.isUsernameAvailable = false
            registrationData.usernameValidationMessage = response.message
            errorMessage = response.message
            
            print("❌ Username not available: \(username), message: \(response.message)")
            print("🔍 Updated registrationData: isAvailable=\(registrationData.isUsernameAvailable), message='\(registrationData.usernameValidationMessage)'")
        }
    }
    
    private func handleRegistrationComplete(_ response: RegisterCompleteResponse) {
        if response.success {
            // Registration successful
            currentStep = .complete
            successMessage = response.message
            
            // Set flag to redirect to profile view
            shouldRedirectToProfile = true
            
            print("✅ Registration successful for user: \(response.user.username)")
            print("🔄 Redirecting to ProfileView...")
        } else {
            errorMessage = response.message
        }
    }
    
    private func handleResendCodeResponse(_ response: ResendCodeResponse) {
        if response.success {
            successMessage = response.message
        } else {
            errorMessage = response.message
        }
    }
    
    // MARK: - Validation Methods
    
    /// Check if current step is valid
    var isCurrentStepValid: Bool {
        switch currentStep {
        case .email:
            return registrationData.isStep1Valid
        case .verification:
            return registrationData.isStep2Valid
        case .personalInfo:
            return registrationData.isStep3Valid
        case .username:
            return registrationData.isStep4Valid
        case .password:
            return registrationData.isStep5Valid
        case .accountSummary:
            return true // Account summary is always valid (read-only)
        case .complete:
            return true
        }
    }
    
    /// Get progress percentage (0.0 to 1.0)
    var progress: Double {
        return currentStep.progress
    }
}
