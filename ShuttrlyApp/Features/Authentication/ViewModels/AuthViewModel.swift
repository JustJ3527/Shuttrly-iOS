//
//  AuthViewModel.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import Foundation
import Combine

// MARK: - Authentication ViewModel
// Manages authentication state and UI logic for SwiftUI

class AuthViewModel: ObservableObject {
    
    // MARK: - Properties
    
    // Authentication state
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    // Login form state
    @Published var loginIdentifier = "" // Email or username
    @Published var loginPassword = ""
    @Published var rememberDevice = false
    
    // 2FA state
    @Published var requires2FA = false
    @Published var current2FAStep: LoginStep = .credentials
    @Published var available2FAMethods: [String] = []
    @Published var chosen2FAMethod: String?
    
    // 2FA form state
    @Published var email2FACode = ""
    @Published var totp2FACode = ""
    
    // Service
    private let authService = AuthService()
    
    // Cancellables
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Bind AuthService state to ViewModel
        authService.$isAuthenticated
            .assign(to: \.isAuthenticated, on: self)
            .store(in: &cancellables)
        
        authService.$currentUser
            .assign(to: \.currentUser, on: self)
            .store(in: &cancellables)
        
        authService.$isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
        
        authService.$errorMessage
            .assign(to: \.errorMessage, on: self)
            .store(in: &cancellables)
        
        authService.$requires2FA
            .assign(to: \.requires2FA, on: self)
            .store(in: &cancellables)
        
        authService.$current2FAStep
            .assign(to: \.current2FAStep, on: self)
            .store(in: &cancellables)
        
        authService.$available2FAMethods
            .assign(to: \.available2FAMethods, on: self)
            .store(in: &cancellables)
        
        authService.$chosen2FAMethod
            .assign(to: \.chosen2FAMethod, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /// Attempt to login with current credentials
    func login() {
        // Clear previous messages
        errorMessage = nil
        successMessage = nil
        
        // Validate input
        guard !loginIdentifier.isEmpty else {
            errorMessage = "Please enter your email or username"
            return
        }
        
        guard !loginPassword.isEmpty else {
            errorMessage = "Please enter your password"
            return
        }
        
        // Call AuthService
        authService.loginStep1(
            identifier: loginIdentifier,
            password: loginPassword,
            rememberDevice: rememberDevice
        )
    }
    
    /// Choose 2FA method
    func choose2FAMethod(_ method: String) {
        chosen2FAMethod = method
        authService.loginStep2Choose2FA(method: method)
    }
    
    /// Submit email 2FA code
    func submitEmail2FACode() {
        guard !email2FACode.isEmpty else {
            errorMessage = "Please enter the verification code"
            return
        }
        
        authService.loginStep3Email2FA(code: email2FACode)
    }
    
    /// Submit TOTP 2FA code
    func submitTOTP2FACode() {
        guard !totp2FACode.isEmpty else {
            errorMessage = "Please enter the TOTP code"
            return
        }
        
        authService.loginStep3TOTP2FA(code: totp2FACode)
    }
    
    /// Logout current user
    func logout() {
        authService.logout()
        clearLoginForm()
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
    
    private func clearLoginForm() {
        loginIdentifier = ""
        loginPassword = ""
        rememberDevice = false
        email2FACode = ""
        totp2FACode = ""
        requires2FA = false
        current2FAStep = .credentials
        chosen2FAMethod = nil
    }
    
    // MARK: - Computed Properties
    
    /// Check if login form is valid
    var isLoginFormValid: Bool {
        return !loginIdentifier.isEmpty && !loginPassword.isEmpty
    }
    
    /// Check if email 2FA form is valid
    var isEmail2FAFormValid: Bool {
        return !email2FACode.isEmpty
    }
    
    /// Check if TOTP 2FA form is valid
    var isTOTP2FAFormValid: Bool {
        return !totp2FACode.isEmpty
    }
    
    /// Get current 2FA step title
    var current2FAStepTitle: String {
        switch current2FAStep {
        case .credentials:
            return "Login"
        case .choose2FA:
            return "Choose 2FA Method"
        case .email2FA:
            return "Email Verification"
        case .totp2FA:
            return "TOTP Verification"
        case .complete:
            return "Welcome!"
        }
    }
    
    /// Get current 2FA step description
    var current2FAStepDescription: String {
        switch current2FAStep {
        case .credentials:
            return "Enter your credentials to continue"
        case .choose2FA:
            return "Choose your preferred 2FA method"
        case .email2FA:
            return "Enter the 6-digit code sent to your email"
        case .totp2FA:
            return "Enter the 6-digit code from your authenticator app"
        case .complete:
            return "Authentication successful"
        }
    }
}
