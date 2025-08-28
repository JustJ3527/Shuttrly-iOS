//
//  TwoFAService.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import Foundation
import Combine

// MARK: - 2FA Service
// Handles 2FA authentication steps independently with clear API communication

class TwoFAService: ObservableObject {
    
    // MARK: - Properties
    
    // Current step state
    @Published var currentStep: TwoFAStep = .credentials
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Step-specific data
    @Published var availableMethods: [String] = []
    @Published var chosenMethod: String?
    @Published var userInfo: User?
    
    // Network manager
    private let networkManager = NetworkManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        print("🚀 TwoFAService initialized")
    }
    
    // MARK: - Step 1: Credentials Verification
    
    /// Step 1: Verify user credentials
    func verifyCredentials(username: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        let request = LoginStep1Request(
            identifier: username,
            password: password,
            rememberDevice: false
        )
        
        networkManager.performRequest(
            endpoint: AppConstants.API.Endpoints.login,
            method: .POST,
            requestBody: request,
            responseType: LoginStep1Response.self
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
                self?.handleCredentialsResponse(response)
            }
        )
        .store(in: &cancellables)
    }
    
    private func handleCredentialsResponse(_ response: LoginStep1Response) {
        guard response.success else {
            errorMessage = response.message
            return
        }
        
        if response.requires2FA {
            // 2FA required - determine next step
            if let methods = response.availableMethods {
                availableMethods = methods
                if methods.count > 1 {
                    currentStep = .choose2FA
                } else if methods.count == 1 {
                    chosenMethod = methods[0]
                    currentStep = methods[0] == "email" ? .email2FA : .totp2FA
                }
            }
        } else {
            // No 2FA required - login complete
            if let user = response.user, let tokens = response.tokens {
                // Store tokens and complete login
                storeTokens(access: tokens.access, refresh: tokens.refresh)
                userInfo = user
                currentStep = .complete
            }
        }
    }
    
    // MARK: - Step 2: 2FA Method Choice
    
    /// Step 2: Choose 2FA method when multiple are available
    func choose2FAMethod(_ method: String) {
        isLoading = true
        errorMessage = nil
        
        let request = LoginStep2ChoiceRequest(
            chosenMethod: method
        )
        
        networkManager.performRequest(
            endpoint: AppConstants.API.Endpoints.login,
            method: .POST,
            requestBody: request,
            responseType: LoginStep2ChoiceResponse.self
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
                self?.handleMethodChoiceResponse(response, chosenMethod: method)
            }
        )
        .store(in: &cancellables)
    }
    
    private func handleMethodChoiceResponse(_ response: LoginStep2ChoiceResponse, chosenMethod: String) {
        guard response.success else {
            errorMessage = response.message
            return
        }
        
        self.chosenMethod = chosenMethod
        if let nextStep = response.nextStep {
            switch nextStep {
            case "email_2fa":
                currentStep = .email2FA
            case "totp_2fa":
                currentStep = .totp2FA
            default:
                errorMessage = "Invalid next step: \(nextStep)"
            }
        }
    }
    
    // MARK: - Step 3: Email 2FA Verification
    
    /// Step 3: Verify email 2FA code
    func verifyEmail2FA(code: String) {
        isLoading = true
        errorMessage = nil
        
        let request = LoginStep3Email2FARequest(
            verificationCode: code
        )
        
        networkManager.performRequest(
            endpoint: AppConstants.API.Endpoints.login,
            method: .POST,
            requestBody: request,
            responseType: LoginStep3Email2FAResponse.self
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
                self?.handleEmail2FAResponse(response)
            }
        )
        .store(in: &cancellables)
    }
    
    private func handleEmail2FAResponse(_ response: LoginStep3Email2FAResponse) {
        guard response.success else {
            errorMessage = response.message
            return
        }
        
        // Email 2FA completed successfully
        if let user = response.user, let tokens = response.tokens {
            storeTokens(access: tokens.access, refresh: tokens.refresh)
            userInfo = user
            currentStep = .complete
        } else {
            errorMessage = "Invalid response: missing user or tokens"
        }
    }
    
    // MARK: - Step 4: TOTP 2FA Verification
    
    /// Step 4: Verify TOTP 2FA code
    func verifyTOTP2FA(code: String) {
        isLoading = true
        errorMessage = nil
        
        let request = LoginStep3TOTP2FARequest(
            totpCode: code
        )
        
        networkManager.performRequest(
            endpoint: AppConstants.API.Endpoints.login,
            method: .POST,
            requestBody: request,
            responseType: LoginStep3TOTP2FAResponse.self
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
                self?.handleTOTP2FAResponse(response)
            }
        )
        .store(in: &cancellables)
    }
    
    private func handleTOTP2FAResponse(_ response: LoginStep3TOTP2FAResponse) {
        guard response.success else {
            errorMessage = response.message
            return
        }
        
        // TOTP 2FA completed successfully
        if let user = response.user, let tokens = response.tokens {
            storeTokens(access: tokens.access, refresh: tokens.refresh)
            userInfo = user
            currentStep = .complete
        } else {
            errorMessage = "Invalid response: missing user or tokens"
        }
    }
    
    // MARK: - Resend 2FA Code
    
    /// Resend 2FA code for email method
    func resend2FACode() {
        isLoading = true
        errorMessage = nil
        
        let request = Resend2FACodeRequest(
            method: chosenMethod ?? "email"
        )
        
        networkManager.performRequest(
            endpoint: AppConstants.API.Endpoints.resend2FACode,
            method: .POST,
            requestBody: request,
            responseType: Resend2FACodeResponse.self
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
                if response.success {
                    self?.errorMessage = "2FA code resent successfully"
                } else {
                    self?.errorMessage = response.message
                }
            }
        )
        .store(in: &cancellables)
    }
    
    // MARK: - Navigation
    
    /// Go back to previous step
    func goBack() {
        switch currentStep {
        case .credentials:
            // Already at first step
            break
        case .choose2FA:
            currentStep = .credentials
        case .email2FA, .totp2FA:
            if availableMethods.count > 1 {
                currentStep = .choose2FA
            } else {
                currentStep = .credentials
            }
        case .complete:
            // Login complete, can't go back
            break
        }
    }
    
    /// Reset to initial state
    func reset() {
        currentStep = .credentials
        isLoading = false
        errorMessage = nil
        availableMethods = []
        chosenMethod = nil
        userInfo = nil
    }
    
    // MARK: - Private Methods
    
    private func storeTokens(access: String, refresh: String) {
        UserDefaults.standard.set(access, forKey: AppConstants.StorageKeys.accessToken)
        UserDefaults.standard.set(refresh, forKey: AppConstants.StorageKeys.refreshToken)
    }
}
