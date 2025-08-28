//
//  TwoFAModels.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import Foundation

// MARK: - Token Response
struct TokenResponse: Codable {
    let refresh: String
    let access: String
}

// MARK: - 2FA Request Models
// These models define the request structure for each 2FA step

// MARK: - Step 1: Credentials Request
struct LoginStep1Request: Codable {
    let identifier: String
    let password: String
    let rememberDevice: Bool
    
    enum CodingKeys: String, CodingKey {
        case identifier, password
        case rememberDevice = "remember_device"
    }
}

// MARK: - Step 2: 2FA Method Choice Request
struct LoginStep2ChoiceRequest: Codable {
    let chosenMethod: String
    
    enum CodingKeys: String, CodingKey {
        case chosenMethod = "chosen_method"
    }
}

// MARK: - Step 3: Email 2FA Request
struct LoginStep3Email2FARequest: Codable {
    let verificationCode: String
    
    enum CodingKeys: String, CodingKey {
        case verificationCode = "verification_code"
    }
}

// MARK: - Step 3: TOTP 2FA Request
struct LoginStep3TOTP2FARequest: Codable {
    let totpCode: String
    
    enum CodingKeys: String, CodingKey {
        case totpCode = "totp_code"
    }
}

// MARK: - Resend 2FA Code Request
struct Resend2FACodeRequest: Codable {
    let method: String
}

// MARK: - Resend 2FA Code Response
struct Resend2FACodeResponse: Codable {
    let success: Bool
    let message: String
}

// MARK: - 2FA Response Models
// These models exactly match the Django API responses for 2FA

// MARK: - Step 1: Credentials Response
struct LoginStep1Response: Codable {
    let success: Bool
    let message: String
    let requires2FA: Bool
    let nextStep: String?
    let availableMethods: [String]?
    let user: User?
    let tokens: TokenResponse?
    
    enum CodingKeys: String, CodingKey {
        case success, message, user, tokens
        case requires2FA = "requires_2fa"
        case nextStep = "next_step"
        case availableMethods = "available_methods"
    }
}

// MARK: - Step 2: 2FA Method Choice Response
struct LoginStep2ChoiceResponse: Codable {
    let success: Bool
    let message: String
    let nextStep: String?
    let method: String?
    
    enum CodingKeys: String, CodingKey {
        case success, message, method
        case nextStep = "next_step"
    }
}

// MARK: - Step 3: Email 2FA Response
struct LoginStep3Email2FAResponse: Codable {
    let success: Bool
    let message: String
    let method: String?
    let user: User?
    let tokens: TokenResponse?
}

// MARK: - Step 3: TOTP 2FA Response
struct LoginStep3TOTP2FAResponse: Codable {
    let success: Bool
    let message: String
    let method: String?
    let user: User?
    let tokens: TokenResponse?
}

// MARK: - Login Success Response (Final)
struct LoginSuccessResponse: Codable {
    let success: Bool
    let message: String
    let user: User
    let access: String
    let refresh: String
    let requires2FA: Bool
    let loginComplete: Bool
    let trustedDevice: TrustedDeviceInfo?
    
    enum CodingKeys: String, CodingKey {
        case success, message, user, access, refresh
        case requires2FA = "requires_2fa"
        case loginComplete = "login_complete"
        case trustedDevice = "trusted_device"
    }
}



// MARK: - Trusted Device Info
struct TrustedDeviceInfo: Codable {
    let token: String
    let cookieName: String
    let maxAge: Int
    let expiresInDays: Int
    
    enum CodingKeys: String, CodingKey {
        case token
        case cookieName = "cookie_name"
        case maxAge = "max_age"
        case expiresInDays = "expires_in_days"
    }
}

// MARK: - 2FA State Management
enum TwoFAStep: String, CaseIterable {
    case credentials = "credentials"
    case choose2FA = "choose_2fa"
    case email2FA = "email_2fa"
    case totp2FA = "totp_2fa"
    case complete = "complete"
    
    var title: String {
        switch self {
        case .credentials: return "Login"
        case .choose2FA: return "Choose 2FA Method"
        case .email2FA: return "Email Verification"
        case .totp2FA: return "TOTP Verification"
        case .complete: return "Welcome!"
        }
    }
    
    var description: String {
        switch self {
        case .credentials: return "Enter your credentials"
        case .choose2FA: return "Select your preferred 2FA method"
        case .email2FA: return "Enter the code sent to your email"
        case .totp2FA: return "Enter your TOTP code"
        case .complete: return "Login successful!"
        }
    }
    
    var progress: Double {
        guard let index = TwoFAStep.allCases.firstIndex(of: self) else { return 0.0 }
        return Double(index + 1) / Double(TwoFAStep.allCases.count)
    }
}


