//
//  AuthService.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import Foundation
import Combine

// MARK: - Authentification Service
// Handles user authentification (login, logout, token management)

class AuthService: ObservableObject {
    
    // MARK: - Properties
    
    // Published properties for SwiftUI binding
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var isLoading: Bool = false
    @Published var authError: AuthError?
    
    // 2FA state properties
    @Published var requires2FA: Bool = false
    @Published var current2FAStep: TwoFAStep = .credentials
    @Published var available2FAMethods: [String] = []
    @Published var chosen2FAMethod: String?
    
    // Network manager instance
    private let networkManager = NetworkManager.shared
    
    // Cancellables for Combine subscriptions
    private var cancellables: Set<AnyCancellable> = []
    
    // Session refresh timer
    private var sessionRefreshTimer: Timer?
    
    // MARK: - Initialization
    
    init() {
        // Check if user is already authentificated on app launch
        checkAuthenticationStatus()
    }
    
    // MARK: - Authentification Methods
    
    /// Step 1: Login with credentials (email/username + password)
    func loginStep1(identifier: String, password: String, rememberDevice: Bool = false) {
        // Reset state to start fresh
        current2FAStep = .credentials
        requires2FA = false
        available2FAMethods = []
        chosen2FAMethod = nil
        authError = nil
        isLoading = true
        
        let loginRequest = LoginStep1Request(
            identifier: identifier,
            password: password,
            rememberDevice: false
        )
        
        networkManager.performRequest(
            endpoint: AppConstants.API.Endpoints.login,
            method: .POST,
            requestBody: loginRequest,
            responseType: LoginStep1Response.self
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("🔴 Login error: \(error)")
                    if let networkError = error as? NetworkError {
                        switch networkError {
                        case .apiError(let errorData):
                            // Parse structured API error
                            print("🔍 Parsing API error data: \(errorData)")
                            self?.authError = self?.createAuthError(from: errorData) ?? AuthError.serverError()
                        default:
                            self?.authError = AuthError.networkError()
                        }
                    } else {
                        self?.authError = AuthError.networkError()
                    }
                }
            },
            receiveValue: { [weak self] response in
                print("🟢 Login response received: \(response)")
                self?.handleDjangoLoginResponse(response)
            }
        )
        .store(in: &cancellables)
    }
    
    /// Step 2: Choose 2FA method (if multiple available)
    func loginStep2Choose2FA(method: String) {
        isLoading = true
        authError = nil
        
        let choiceRequest = LoginStep2ChoiceRequest(
            chosenMethod: method
        )
        
        networkManager.performRequest(
            endpoint: AppConstants.API.Endpoints.login,
            method: .POST,
            requestBody: choiceRequest,
            responseType: LoginStep2ChoiceResponse.self
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    if let networkError = error as? NetworkError {
                        switch networkError {
                        case .apiError(let errorData):
                            // Parse structured API error
                            self?.authError = self?.createAuthError(from: errorData) ?? AuthError.serverError()
                        default:
                            self?.authError = AuthError.networkError()
                        }
                    } else {
                        self?.authError = AuthError.networkError()
                    }
                }
            },
            receiveValue: { [weak self] response in
                self?.handleLoginStep2ChoiceResponse(response)
            }
        )
        .store(in: &cancellables)
    }
    
    /// Step 3: Email 2FA verification
    func loginStep3Email2FA(code: String) {
        isLoading = true
        authError = nil
        
        let email2FARequest = LoginStep3Email2FARequest(
            verificationCode: code
        )
        
        networkManager.performRequest(
            endpoint: AppConstants.API.Endpoints.login,
            method: .POST,
            requestBody: email2FARequest,
            responseType: LoginStep3Email2FAResponse.self
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    if let networkError = error as? NetworkError {
                        switch networkError {
                        case .apiError(let errorData):
                            // Parse structured API error
                            self?.authError = self?.createAuthError(from: errorData) ?? AuthError.serverError()
                        default:
                            self?.authError = AuthError.networkError()
                        }
                    } else {
                        self?.authError = AuthError.networkError()
                    }
                }
            },
            receiveValue: { [weak self] response in
                self?.handleLoginStep3Email2FAResponse(response)
            }
        )
        .store(in: &cancellables)
    }
    
    /// Step 3: TOTP 2FA verification
    func loginStep3TOTP2FA(code: String) {
        isLoading = true
        authError = nil
        
        let totp2FARequest = LoginStep3TOTP2FARequest(
            totpCode: code
        )
        
        networkManager.performRequest(
            endpoint: AppConstants.API.Endpoints.login,
            method: .POST,
            requestBody: totp2FARequest,
            responseType: LoginStep3TOTP2FAResponse.self
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    if let networkError = error as? NetworkError {
                        switch networkError {
                        case .apiError(let errorData):
                            // Parse structured API error
                            self?.authError = self?.createAuthError(from: errorData) ?? AuthError.serverError()
                        default:
                            self?.authError = AuthError.networkError()
                        }
                    } else {
                        self?.authError = AuthError.networkError()
                    }
                }
            },
            receiveValue: { [weak self] response in
                self?.handleLoginStep3TOTP2FAResponse(response)
            }
        )
        .store(in: &cancellables)
    }
    
    /// Logout current user
    func logout() {
        isLoading = true
        
        // Call logout API
        networkManager.performRequest(
            endpoint: AppConstants.API.Endpoints.logout,
            method: .POST,
            requestBody: EmptyRequest(),
            responseType: LogoutResponse.self
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                // Always logout locally, even if API call fails
                self?.handleLogout()
            },
            receiveValue: { [weak self] _ in
                self?.handleLogout()
            }
        )
        .store(in: &cancellables)
    }
    
    // MARK: - Private Methods
    
    /// Helper function to create AuthError from API response
    private func createAuthError(from response: Any) -> AuthError {
        print("🔍 createAuthError called with: \(response)")
        
        // Parse API error response to create appropriate AuthError
        if let responseDict = response as? [String: Any],
           let errorDict = responseDict["error"] as? [String: Any],
           let errorCode = errorDict["code"] as? String,
           let errorMessage = errorDict["message"] as? String {
            
            print("✅ Parsed structured error - Code: \(errorCode), Message: \(errorMessage)")
            // Create AuthError based on the error code from API
            let authError = AuthError.fromCode(errorCode, customMessage: errorMessage)
            print("✅ Created AuthError: \(authError.message)")
            return authError
        } else if let message = (response as? [String: Any])?["message"] as? String {
            print("⚠️ Using fallback parsing for message: \(message)")
            // Fallback: try to infer error type from message content
            let lowercasedMessage = message.lowercased()
            
            if lowercasedMessage.contains("credentials") || lowercasedMessage.contains("password") {
                return AuthError.invalidCredentials()
            } else if lowercasedMessage.contains("not found") || lowercasedMessage.contains("doesn't exist") {
                return AuthError.userNotFound(identifier: "unknown")
            } else if lowercasedMessage.contains("locked") || lowercasedMessage.contains("blocked") {
                return AuthError.accountLocked()
            } else if lowercasedMessage.contains("verified") || lowercasedMessage.contains("verification") {
                return AuthError.emailNotVerified(email: "unknown")
            } else if lowercasedMessage.contains("too many") || lowercasedMessage.contains("attempts") {
                return AuthError.tooManyAttempts()
            } else {
                return AuthError.serverError()
            }
        } else {
            print("❌ Could not parse error response, using server error fallback")
            return AuthError.serverError()
        }
    }
    
    private func handleDjangoLoginResponse(_ response: LoginStep1Response) {
        print("🔄 Processing Django login response...")
        
        // Check if login was successful
        guard response.success else {
            print("❌ Login failed: \(response.message)")
            // Create AuthError from response message
            authError = createAuthError(from: ["message": response.message])
            return
        }
        
        // Check if 2FA is required
        if response.requires2FA {
            print("🔐 2FA required")
            requires2FA = true
            
            // Handle 2FA flow based on available methods
            if let methods = response.availableMethods, methods.count > 1 {
                print("📋 Multiple 2FA methods available: \(methods)")
                current2FAStep = .choose2FA
                available2FAMethods = methods
                chosen2FAMethod = nil // Reset chosen method
            } else if let methods = response.availableMethods, methods.count == 1 {
                let method = methods[0]
                print("🔐 Single 2FA method: \(method)")
                chosen2FAMethod = method
                if method == "email" {
                    current2FAStep = .email2FA
                } else if method == "totp" {
                    current2FAStep = .totp2FA
                }
                available2FAMethods = methods
            }
            
            // Clear any previous error messages
            authError = nil
        } else {
            // No 2FA required, complete login
            print("✅ Login successful, no 2FA required")
            handleSuccessfulLogin(response)
        }
    }
    


    
    private func handleLoginStep2ChoiceResponse(_ response: LoginStep2ChoiceResponse) {
        print("🔄 Processing 2FA method choice response...")
        
        if response.success {
            if let nextStep = response.nextStep {
                if nextStep == "email_2fa" {
                    current2FAStep = .email2FA
                    chosen2FAMethod = "email"
                    print("📧 Email 2FA selected")
                } else if nextStep == "totp_2fa" {
                    current2FAStep = .totp2FA
                    chosen2FAMethod = "totp"
                    print("🔑 TOTP 2FA selected")
                }
            }
        } else {
            // Create AuthError from response message
            authError = createAuthError(from: ["message": response.message])
        }
    }
    
    private func handleLoginStep3Email2FAResponse(_ response: LoginStep3Email2FAResponse) {
        print("🔄 Processing email 2FA response...")
        
        if response.success {
            // Email 2FA step completed successfully
            // The API should have returned user data and tokens
            if let user = response.user, let tokens = response.tokens {
                // Store tokens
                storeTokens(access: tokens.access, refresh: tokens.refresh)
                
                // Update user state
                currentUser = user
                isAuthenticated = true
                requires2FA = false
                current2FAStep = .credentials
                authError = nil
                
                // Log successful login
                print("✅ User logged in successfully after email 2FA: \(user.username)")
                print("🔑 Access token stored: \(String(tokens.access.prefix(20)))...")
                
                // Start session refresh timer
                startSessionRefreshTimer()
            } else {
                // Fallback: if no user data in response, try to complete login
                print("⚠️ No user data in 2FA response, attempting to complete login...")
                complete2FALogin()
            }
        } else {
            // Create AuthError from response message
            authError = createAuthError(from: ["message": response.message])
        }
    }
    
    private func handleLoginStep3TOTP2FAResponse(_ response: LoginStep3TOTP2FAResponse) {
        print("🔄 Processing TOTP 2FA response...")
        
        if response.success {
            // TOTP 2FA step completed successfully
            // The API should have returned user data and tokens
            if let user = response.user, let tokens = response.tokens {
                // Store tokens
                storeTokens(access: tokens.access, refresh: tokens.refresh)
                
                // Update user state
                currentUser = user
                isAuthenticated = true
                requires2FA = false
                current2FAStep = .credentials
                authError = nil
                
                // Log successful login
                print("✅ User logged in successfully after TOTP 2FA: \(user.username)")
                print("🔑 Access token stored: \(String(tokens.access.prefix(20)))...")
                
                // Start session refresh timer
                startSessionRefreshTimer()
            } else {
                // Fallback: if no user data in response, try to complete login
                print("⚠️ No user data in 2FA response, attempting to complete login...")
                complete2FALogin()
            }
        } else {
            // Create AuthError from response message
            authError = createAuthError(from: ["message": response.message])
        }
    }
    

    
    private func handleSuccessfulLogin<T>(_ response: T) {
        // Extract user and tokens based on response type
        var user: User?
        var accessToken: String?
        var refreshToken: String?
        
        if let step1Response = response as? LoginStep1Response {
            user = step1Response.user
            if let tokens = step1Response.tokens {
                accessToken = tokens.access
                refreshToken = tokens.refresh
            }
        } else if let emailResponse = response as? LoginStep3Email2FAResponse {
            user = emailResponse.user
            if let tokens = emailResponse.tokens {
                accessToken = tokens.access
                refreshToken = tokens.refresh
            }
        } else if let totpResponse = response as? LoginStep3TOTP2FAResponse {
            user = totpResponse.user
            if let tokens = totpResponse.tokens {
                accessToken = tokens.access
                refreshToken = tokens.refresh
            }
        }
        
        // Store tokens if available
        if let access = accessToken, let refresh = refreshToken {
            storeTokens(access: access, refresh: refresh)
        }
        
        // Update user state
        if let user = user {
            currentUser = user
            isAuthenticated = true
            requires2FA = false
            current2FAStep = .credentials
            authError = nil
            
            // Log successful login
            print("✅ User logged in successfully: \(user.username)")
            
            // Start session refresh timer
            startSessionRefreshTimer()
        }
    }
    
    private func handleLogout() {
        // Stop session refresh timer
        stopSessionRefreshTimer()
        
        // Clear stored data
        networkManager.clearStoredTokens()
        
        // Update state
        currentUser = nil
        isAuthenticated = false
        requires2FA = false
        current2FAStep = .credentials
        authError = nil
        
        // Log logout
        print("👋 User logged out")
    }
    
    func checkAuthenticationStatus() {
        // Check if we have a valid access token
        if let _ = getStoredAccessToken() {
            // With the new configuration, tokens don't expire automatically
            // Only logout manually will invalidate the session
            isAuthenticated = true
            
            // Refresh session to keep it active
            refreshSession()
            
            // Start session refresh timer
            startSessionRefreshTimer()
        }
    }
    
    /// Refresh user session to keep it active
    private func refreshSession() {
        networkManager.performRequest(
            endpoint: AppConstants.API.Endpoints.refreshSession,
            method: .POST,
            requestBody: EmptyRequest(),
            responseType: SessionRefreshResponse.self
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("⚠️ Session refresh failed: \(error)")
                    // Don't logout user if refresh fails - session remains valid
                }
            },
            receiveValue: { response in
                print("✅ Session refreshed successfully")
            }
        )
        .store(in: &cancellables)
    }
    
    /// Start automatic session refresh timer
    private func startSessionRefreshTimer() {
        // Stop existing timer if any
        stopSessionRefreshTimer()
        
        // Start new timer that refreshes session every 30 minutes
        sessionRefreshTimer = Timer.scheduledTimer(withTimeInterval: 30 * 60, repeats: true) { [weak self] _ in
            self?.refreshSession()
        }
        
        print("⏰ Session refresh timer started (30 minute intervals)")
    }
    
    /// Stop automatic session refresh timer
    private func stopSessionRefreshTimer() {
        sessionRefreshTimer?.invalidate()
        sessionRefreshTimer = nil
        print("⏰ Session refresh timer stopped")
    }
    
    // MARK: - Token Storage
    
    private func storeTokens(access: String, refresh: String) {
        UserDefaults.standard.set(access, forKey: AppConstants.StorageKeys.accessToken)
        UserDefaults.standard.set(refresh, forKey: AppConstants.StorageKeys.refreshToken)
    }
    
    private func getStoredAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: AppConstants.StorageKeys.accessToken)
    }
        
    private func getStoredRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: AppConstants.StorageKeys.refreshToken)
    }
}

extension AuthService {
    /// Complete 2FA login by making a final request to get user data and tokens
    private func complete2FALogin() {
        isLoading = true
        authError = nil
        
        // Make a final request to complete the login and get user data
        let finalRequest = EmptyRequest()
        
        networkManager.performRequest(
            endpoint: AppConstants.API.Endpoints.login,
            method: .POST,
            requestBody: finalRequest,
            responseType: LoginStep1Response.self
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    if let networkError = error as? NetworkError {
                        switch networkError {
                        case .apiError(let errorData):
                            // Parse structured API error
                            self?.authError = self?.createAuthError(from: errorData) ?? AuthError.serverError()
                        default:
                            self?.authError = AuthError.networkError()
                        }
                    } else {
                        self?.authError = AuthError.networkError()
                    }
                }
            },
            receiveValue: { [weak self] response in
                self?.handleLoginSuccessResponse(response)
            }
        )
        .store(in: &cancellables)
    }
    
    /// Resend 2FA code
    func resend2FACode() {
        isLoading = true
        authError = nil
        
        let resendRequest = Resend2FACodeRequest(
            method: chosen2FAMethod ?? "email"
        )
        
        networkManager.performRequest(
            endpoint: AppConstants.API.Endpoints.resend2FACode,
            method: .POST,
            requestBody: resendRequest,
            responseType: LoginStep3Email2FAResponse.self
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    if let networkError = error as? NetworkError {
                        switch networkError {
                        case .apiError(let errorData):
                            // Parse structured API error
                            self?.authError = self?.createAuthError(from: errorData) ?? AuthError.serverError()
                        default:
                            self?.authError = AuthError.networkError()
                        }
                    } else {
                        self?.authError = AuthError.networkError()
                    }
                }
            },
            receiveValue: { [weak self] response in
                if response.success {
                    self?.authError = nil
                } else {
                    // Create AuthError from response message
                    self?.authError = self?.createAuthError(from: ["message": response.message]) ?? AuthError.serverError()
                }
            }
        )
        .store(in: &cancellables)
    }
    
    private func handleLoginSuccessResponse(_ response: LoginStep1Response) {
        if response.success {
            // Extract user and tokens
            if let user = response.user, let tokens = response.tokens {
                let accessToken = tokens.access
                let refreshToken = tokens.refresh
                
                // Store tokens
                storeTokens(access: accessToken, refresh: refreshToken)
                
                // Update user state
                currentUser = user
                isAuthenticated = true
                requires2FA = false
                current2FAStep = .credentials
                authError = nil
                
                // Log successful login
                print("✅ User logged in successfully: \(user.username)")
                print("🔑 Access token stored: \(String(accessToken.prefix(20)))...")
                
                // Start session refresh timer
                startSessionRefreshTimer()
            } else {
                authError = AuthError.serverError()
            }
        } else {
            // Create AuthError from response message
            authError = createAuthError(from: ["message": response.message])
        }
    }
}


// MARK: - Supporting Types

struct EmptyRequest: Codable {}

struct LogoutResponse: Codable {
    let success: Bool
    let message: String
}

struct SessionRefreshResponse: Codable {
    let success: Bool
    let message: String
    let user_id: Int
    let timestamp: String
}
