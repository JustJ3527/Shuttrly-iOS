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
    @Published var errorMessage: String?
    
    // 2FA state properties
    @Published var requires2FA: Bool = false
    @Published var current2FAStep: LoginStep = .credentials
    @Published var available2FAMethods: [String] = []
    @Published var chosen2FAMethod: String?
    
    // Network manager instance
    private let networkManager = NetworkManager.shared
    
    // Cancellables for Combine subscriptions
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initialization
    
    init() {
        // Check if user is already authentificated on app launch
        checkAuthenticationStatus()
    }
    
    // MARK: - Authentification Methods
    
    /// Step 1: Login with credentials (email/username + password)
    func loginStep1(identifier: String, password: String, rememberDevice: Bool = false) {
        isLoading = true
        errorMessage = nil
        
        let loginRequest = LoginStep1Request(
            step: "credentials",
            identifier: identifier,
            password: password,
            rememberDevice: rememberDevice
        )
        
        networkManager.performRequest(
            endpoint: AppConstants.API.Endpoints.login,
            method: .POST,
            requestBody: loginRequest,
            responseType: DjangoLoginResponse.self
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("🔴 Login error: \(error)")
                    self?.errorMessage = error.localizedDescription
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
        errorMessage = nil
        
        let choiceRequest = LoginStep2ChoiceRequest(
            step: "choose_2fa",
            twofaMethod: method
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
                    self?.errorMessage = error.localizedDescription
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
        errorMessage = nil
        
        let email2FARequest = LoginStep3Email2FARequest(
            step: "email_2fa",
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
                    self?.errorMessage = error.localizedDescription
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
        errorMessage = nil
        
        let totp2FARequest = LoginStep3TOTP2FARequest(
            step: "totp_2fa",
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
                    self?.errorMessage = error.localizedDescription
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
    
    private func handleDjangoLoginResponse(_ response: DjangoLoginResponse) {
        print("🔄 Processing Django login response...")
        
        // Check if login was successful
        guard response.success else {
            print("❌ Login failed: \(response.message)")
            errorMessage = response.message
            return
        }
        
        // Check if 2FA is required
        if response.requires2FA {
            print("🔐 2FA required")
            requires2FA = true
            // TODO: Handle 2FA flow
        } else {
            // No 2FA required, complete login
            print("✅ Login successful, no 2FA required")
            handleSuccessfulDjangoLogin(response)
        }
    }
    
    private func handleFlexibleLoginResponse(_ response: FlexibleLoginResponse) {
        print("🔄 Processing flexible login response...")
        
        // Check if login was successful
        guard response.isSuccessful else {
            let errorMsg = response.errorMessage ?? "Unknown error occurred"
            print("❌ Login failed: \(errorMsg)")
            errorMessage = errorMsg
            return
        }
        
        // Check if 2FA is required
        if response.actualRequires2FA {
            print("🔐 2FA required")
            requires2FA = true
            
            if let methods = response.actualAvailableMethods, methods.count > 1 {
                current2FAStep = .choose2FA
                available2FAMethods = methods
            } else if let methods = response.actualAvailableMethods, methods.count == 1 {
                let method = methods[0]
                if method == "email" {
                    current2FAStep = .email2FA
                } else if method == "totp" {
                    current2FAStep = .totp2FA
                }
                available2FAMethods = methods
            }
        } else {
            // No 2FA required, complete login
            print("✅ Login successful, no 2FA required")
            handleSuccessfulLogin(response)
        }
    }
    
    private func handleLoginStep1Response(_ response: LoginStep1Response) {
        if response.requires2FA {
            // 2FA required
            requires2FA = true
            
            if let methods = response.availableMethods, methods.count > 1 {
                current2FAStep = .choose2FA
                available2FAMethods = methods
            } else if let methods = response.availableMethods, methods.count == 1 {
                let method = methods[0]
                if method == "email" {
                    current2FAStep = .email2FA
                } else if method == "totp" {
                    current2FAStep = .totp2FA
                }
                available2FAMethods = methods
            }
        } else {
            // No 2FA required, complete login
            handleSuccessfulLogin(response)
        }
    }
    
    private func handleLoginStep2ChoiceResponse(_ response: LoginStep2ChoiceResponse) {
        if response.nextStep == "email_2fa" {
            current2FAStep = .email2FA
            chosen2FAMethod = "email"
        } else if response.nextStep == "totp_2fa" {
            current2FAStep = .totp2FA
            chosen2FAMethod = "totp"
        }
    }
    
    private func handleLoginStep3Email2FAResponse(_ response: LoginStep3Email2FAResponse) {
        if response.success {
            handleSuccessfulLogin(response)
        } else {
            errorMessage = response.message
        }
    }
    
    private func handleLoginStep3TOTP2FAResponse(_ response: LoginStep3TOTP2FAResponse) {
        if response.success {
            handleSuccessfulLogin(response)
        } else {
            errorMessage = response.message
        }
    }
    
    private func handleSuccessfulDjangoLogin(_ response: DjangoLoginResponse) {
        // Extract user and tokens from Django response
        let user = response.user
        let accessToken = response.tokens.access
        let refreshToken = response.tokens.refresh
        
        // Store tokens
        storeTokens(access: accessToken, refresh: refreshToken)
        
        // Update user state
        currentUser = user
        isAuthenticated = true
        requires2FA = false
        current2FAStep = .credentials
        errorMessage = nil
        
        // Log successful login
        print("✅ User logged in successfully: \(user.username)")
        print("🔑 Access token stored: \(String(accessToken.prefix(20)))...")
    }
    
    private func handleSuccessfulLogin<T>(_ response: T) {
        // Extract user and tokens based on response type
        var user: User?
        var accessToken: String?
        var refreshToken: String?
        
        if let djangoResponse = response as? DjangoLoginResponse {
            user = djangoResponse.user
            accessToken = djangoResponse.tokens.access
            refreshToken = djangoResponse.tokens.refresh
        } else if let flexibleResponse = response as? FlexibleLoginResponse {
            user = flexibleResponse.user
            accessToken = flexibleResponse.access
            refreshToken = flexibleResponse.refresh
        } else if let step1Response = response as? LoginStep1Response {
            user = step1Response.user
            accessToken = step1Response.access
            refreshToken = step1Response.refresh
        } else if let emailResponse = response as? LoginStep3Email2FAResponse {
            user = emailResponse.user
            accessToken = emailResponse.access
            refreshToken = emailResponse.refresh
        } else if let totpResponse = response as? LoginStep3TOTP2FAResponse {
            user = totpResponse.user
            accessToken = totpResponse.access
            refreshToken = totpResponse.refresh
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
            errorMessage = nil
            
            // Log successful login
            print("✅ User logged in successfully: \(user.username)")
        }
    }
    
    private func handleLogout() {
        // Clear stored data
        networkManager.clearStoredTokens()
        
        // Update state
        currentUser = nil
        isAuthenticated = false
        requires2FA = false
        current2FAStep = .credentials
        errorMessage = nil
        
        // Log logout
        print("👋 User logged out")
    }
    
    func checkAuthenticationStatus() {
        // Check if we have a valid access token
        if let _ = getStoredAccessToken() {
            // TODO: Validate token with backend or check expiration
            // For now, assume token is valid
            isAuthenticated = true
        }
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


// MARK: - Supporting Types

enum LoginStep: Hashable {
    case credentials
    case choose2FA
    case email2FA
    case totp2FA
    case complete
}

struct EmptyRequest: Codable {}

struct LogoutResponse: Codable {
    let success: Bool
    let message: String
}

// MARK: - 2FA Login Request Models

// Login response model that exactly matches the Django API structure
struct DjangoLoginResponse: Codable {
    let success: Bool
    let message: String
    let user: User
    let tokens: TokenResponse
    let requires2FA: Bool
    let loginComplete: Bool
    
    enum CodingKeys: String, CodingKey {
        case success, message, user, tokens
        case requires2FA = "requires_2fa"
        case loginComplete = "login_complete"
    }
}

struct TokenResponse: Codable {
    let refresh: String
    let access: String
}

// Flexible login response that can handle API variations
struct FlexibleLoginResponse: Codable {
    let success: Bool?
    let message: String?
    let requires2FA: Bool?
    let nextStep: String?
    let availableMethods: [String]?
    let access: String?
    let refresh: String?
    let user: User?
    
    // Additional fields that might be present
    let error: String?
    let detail: String?
    let status: String?
    
    enum CodingKeys: String, CodingKey {
        case success, message, error, detail, status
        case requires2FA = "requires_2fa"
        case nextStep = "next_step"
        case availableMethods = "available_methods"
        case access, refresh, user
    }
    
    // Computed properties for easier access
    var isSuccessful: Bool {
        return success == true || status == "success"
    }
    
    var errorMessage: String? {
        return error ?? detail ?? message
    }
    
    // Get the actual 2FA requirement status
    var actualRequires2FA: Bool {
        return requires2FA ?? false
    }
    
    // Get the actual next step
    var actualNextStep: String? {
        return nextStep
    }
    
    // Get the actual available methods
    var actualAvailableMethods: [String]? {
        return availableMethods
    }
}

struct LoginStep1Request: Codable {
    let step: String
    let identifier: String
    let password: String
    let rememberDevice: Bool
    
    enum CodingKeys: String, CodingKey {
        case step, identifier, password
        case rememberDevice = "remember_device"
    }
}

struct LoginStep1Response: Codable {
    let success: Bool
    let message: String
    let requires2FA: Bool
    let nextStep: String?
    let availableMethods: [String]?
    let access: String?
    let refresh: String?
    let user: User?
    
    enum CodingKeys: String, CodingKey {
        case success, message
        case requires2FA = "requires_2fa"
        case nextStep = "next_step"
        case availableMethods = "available_methods"
        case access, refresh, user
    }
}

struct LoginStep2ChoiceRequest: Codable {
    let step: String
    let twofaMethod: String
    
    enum CodingKeys: String, CodingKey {
        case step
        case twofaMethod = "twofa_method"
    }
}

struct LoginStep2ChoiceResponse: Codable {
    let success: Bool
    let message: String
    let nextStep: String?
    
    enum CodingKeys: String, CodingKey {
        case success, message
        case nextStep = "next_step"
    }
}

struct LoginStep3Email2FARequest: Codable {
    let step: String
    let verificationCode: String
    
    enum CodingKeys: String, CodingKey {
        case step
        case verificationCode = "verification_code"
    }
}

struct LoginStep3Email2FAResponse: Codable {
    let success: Bool
    let message: String
    let access: String?
    let refresh: String?
    let user: User?
}

struct LoginStep3TOTP2FARequest: Codable {
    let step: String
    let totpCode: String
    
    enum CodingKeys: String, CodingKey {
        case step
        case totpCode = "totp_code"
    }
}

struct LoginStep3TOTP2FAResponse: Codable {
    let success: Bool
    let message: String
    let access: String?
    let refresh: String?
    let user: User?
}
