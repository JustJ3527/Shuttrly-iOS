//
//  AuthErrorConstants.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import Foundation

// MARK: - Authentication Error Constants
// This file defines the error codes and messages that match the Django API

struct AuthErrorConstants {
    
    // MARK: - Error Codes
    // These codes match the Django API AuthErrorCode class
    
    struct ErrorCodes {
        // Login errors
        static let invalidCredentials = "AUTH_001"
        static let userNotFound = "AUTH_002"
        static let accountLocked = "AUTH_003"
        static let emailNotVerified = "AUTH_004"
        static let tooManyAttempts = "AUTH_005"
        
        // Registration errors
        static let emailAlreadyExists = "AUTH_101"
        static let usernameAlreadyTaken = "AUTH_102"
        static let invalidUsernameFormat = "AUTH_103"
        static let invalidPasswordFormat = "AUTH_104"
        static let passwordsDontMatch = "AUTH_105"
        static let ageRestriction = "AUTH_106"
        static let verificationCodeExpired = "AUTH_107"
        static let invalidVerificationCode = "AUTH_108"
        
        // 2FA errors
        static let twofaRequired = "AUTH_201"
        static let invalid2FACode = "AUTH_202"
        static let twofaCodeExpired = "AUTH_203"
        static let twofaMethodNotAvailable = "AUTH_204"
        
        // General errors
        static let validationError = "AUTH_301"
        static let serverError = "AUTH_302"
        static let networkError = "AUTH_303"
        static let sessionExpired = "AUTH_304"
    }
    
    // MARK: - Error Messages
    // These messages match the Django API AuthErrorMessage class
    
    struct ErrorMessages {
        // Login messages
        static let invalidCredentials = "Invalid email/username or password. Please check your credentials and try again."
        static let userNotFound = "No account found with this email/username. Please check your input or create a new account."
        static let accountLocked = "Your account has been temporarily locked due to too many failed login attempts. Please try again later."
        static let emailNotVerified = "Please verify your email address before logging in. Check your inbox for a verification link."
        static let tooManyAttempts = "Too many failed login attempts. Please wait a few minutes before trying again."
        
        // Registration messages
        static let emailAlreadyExists = "An account with this email address already exists. Please use a different email or try logging in."
        static let usernameAlreadyTaken = "This username is already taken. Please choose a different username."
        static let invalidUsernameFormat = "Username must be 3-30 characters long and can only contain letters, numbers, and underscores."
        static let invalidPasswordFormat = "Password must be at least 8 characters long and contain a mix of letters, numbers, and symbols."
        static let passwordsDontMatch = "Passwords do not match. Please make sure both passwords are identical."
        static let ageRestriction = "You must be at least 16 years old to create an account."
        static let verificationCodeExpired = "Verification code has expired. Please request a new code."
        static let invalidVerificationCode = "Invalid verification code. Please check your email and enter the correct code."
        
        // 2FA messages
        static let twofaRequired = "Two-factor authentication is required for your account."
        static let invalid2FACode = "Invalid 2FA code. Please check your authenticator app or email and try again."
        static let twofaCodeExpired = "2FA code has expired. Please request a new code."
        static let twofaMethodNotAvailable = "The selected 2FA method is not available for your account."
        
        // General messages
        static let validationError = "Please check your input and try again."
        static let serverError = "An error occurred on our servers. Please try again later."
        static let networkError = "Network connection error. Please check your internet connection and try again."
        static let sessionExpired = "Your session has expired. Please log in again."
    }
    
    // MARK: - Error Types
    // Categorization of errors for UI handling
    
    enum ErrorType {
        case login
        case registration
        case twoFA
        case validation
        case network
        case server
        case session
        
        init(from errorCode: String) {
            switch errorCode {
            case ErrorCodes.invalidCredentials, ErrorCodes.userNotFound, ErrorCodes.accountLocked,
                 ErrorCodes.emailNotVerified, ErrorCodes.tooManyAttempts:
                self = .login
            case ErrorCodes.emailAlreadyExists, ErrorCodes.usernameAlreadyTaken, ErrorCodes.invalidUsernameFormat,
                 ErrorCodes.invalidPasswordFormat, ErrorCodes.passwordsDontMatch, ErrorCodes.ageRestriction,
                 ErrorCodes.verificationCodeExpired, ErrorCodes.invalidVerificationCode:
                self = .registration
            case ErrorCodes.twofaRequired, ErrorCodes.invalid2FACode, ErrorCodes.twofaCodeExpired,
                 ErrorCodes.twofaMethodNotAvailable:
                self = .twoFA
            case ErrorCodes.validationError:
                self = .validation
            case ErrorCodes.networkError:
                self = .network
            case ErrorCodes.serverError:
                self = .server
            case ErrorCodes.sessionExpired:
                self = .session
            default:
                self = .server
            }
        }
    }
    
    // MARK: - Error Severity
    // Indicates how critical an error is for user experience
    
    enum ErrorSeverity {
        case low      // User can easily fix (validation errors)
        case medium   // User needs to take action (2FA required)
        case high     // User needs help (account locked, server errors)
        case critical // User cannot proceed (network errors, session expired)
        
        init(from errorType: ErrorType) {
            switch errorType {
            case .validation:
                self = .low
            case .twoFA, .login:
                self = .medium
            case .registration, .server:
                self = .high
            case .network, .session:
                self = .critical
            }
        }
    }
}
