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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: dateOfBirth)
        
        let request = RegisterStep3Request(
            firstName: firstName,
            lastName: lastName,
            dateOfBirth: dateString
        )
        
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
        isLoading = true
        errorMessage = nil
        
        let request = UsernameAvailabilityRequest(username: username)
        
        networkManager.performRequest(
            endpoint: AppConstants.API.Endpoints.checkUsername,
            method: .POST,
            requestBody: request,
            responseType: UsernameAvailabilityResponse.self
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
                self?.handleUsernameAvailabilityResponse(response, username: username)
            }
        )
        .store(in: &cancellables)
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
        case .complete:
            currentStep = .password
        }
    }
    
    /// Reset registration process
    func resetRegistration() {
        currentStep = .email
        registrationData = RegistrationData()
        errorMessage = nil
        successMessage = nil
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
        if response.available {
            // Username is available
            registrationData.username = username
            registrationData.isUsernameAvailable = true
            registrationData.usernameValidationMessage = response.message
            
            // Move to next step
            currentStep = .password
        } else {
            // Username is not available
            registrationData.isUsernameAvailable = false
            registrationData.usernameValidationMessage = response.message
            errorMessage = response.message
        }
    }
    
    private func handleRegistrationComplete(_ response: RegisterCompleteResponse) {
        if response.success {
            // Registration successful
            currentStep = .complete
            successMessage = response.message
            
            // TODO: Automatically log in the user or redirect to login
            print("✅ Registration successful for user: \(response.user.username)")
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
        case .complete:
            return true
        }
    }
    
    /// Get progress percentage (0.0 to 1.0)
    var progress: Double {
        return currentStep.progress
    }
}
