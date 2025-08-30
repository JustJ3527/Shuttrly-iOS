//
//  AuthError.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import Foundation

// MARK: - Authentication Error Model
// Structured error model that matches the Django API response format

struct AuthError: Codable, Identifiable, Error {
    
    // MARK: - Properties
    
    // Unique identifier for the error (matches Django API error codes)
    let id: String
    
    // User-friendly error message
    let message: String
    
    // Error type for categorization
    let type: String
    
    // Additional error details (optional)
    let details: [String: AnyCodable]?
    
    // MARK: - Computed Properties
    
    /// Error type enum for easier handling
    var errorType: AuthErrorConstants.ErrorType {
        return AuthErrorConstants.ErrorType(from: id)
    }
    
    /// Error severity for UI prioritization
    var severity: AuthErrorConstants.ErrorSeverity {
        return AuthErrorConstants.ErrorSeverity(from: errorType)
    }
    
    /// Whether this is a validation error that user can easily fix
    var isUserFixable: Bool {
        return severity == .low || severity == .medium
    }
    
    /// Whether this error requires user action (2FA, verification, etc.)
    var requiresUserAction: Bool {
        return errorType == .twoFA || errorType == .login || errorType == .registration
    }
    
    /// Whether this is a critical error that blocks user progress
    var isCritical: Bool {
        return severity == .critical
    }
    
    // MARK: - Coding Keys
    // Maps Swift property names to JSON keys from Django API
    
    enum CodingKeys: String, CodingKey {
        case id = "code"
        case message
        case type
        case details
    }
    
    // MARK: - Initialization
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        message = try container.decode(String.self, forKey: .message)
        type = try container.decode(String.self, forKey: .type)
        details = try container.decodeIfPresent([String: AnyCodable].self, forKey: .details)
    }
    
    // Custom initializer for creating errors programmatically
    init(code: String, message: String, type: String = "authentication_error", details: [String: AnyCodable]? = nil) {
        self.id = code
        self.message = message
        self.type = type
        self.details = details
    }
    
    // MARK: - Convenience Initializers
    
    /// Create error from Django API error code
    static func fromCode(_ code: String, details: [String: AnyCodable]? = nil) -> AuthError {
        let message = AuthErrorConstants.ErrorMessages.message(for: code)
        return AuthError(code: code, message: message, details: details)
    }
    
    /// Create error from Django API error code with custom message
    static func fromCode(_ code: String, customMessage: String, details: [String: AnyCodable]? = nil) -> AuthError {
        return AuthError(code: code, message: customMessage, details: details)
    }
    
    // MARK: - Error Factory Methods
    
    /// Create login-related errors
    static func invalidCredentials(details: [String: AnyCodable]? = nil) -> AuthError {
        return AuthError.fromCode(AuthErrorConstants.ErrorCodes.invalidCredentials, details: details)
    }
    
    static func userNotFound(identifier: String) -> AuthError {
        let details = ["identifier": AnyCodable(identifier)]
        return AuthError.fromCode(AuthErrorConstants.ErrorCodes.userNotFound, details: details)
    }
    
    static func accountLocked(lockoutUntil: String? = nil) -> AuthError {
        var details: [String: AnyCodable] = [:]
        if let lockoutUntil = lockoutUntil {
            details["lockout_until"] = AnyCodable(lockoutUntil)
        }
        return AuthError.fromCode(AuthErrorConstants.ErrorCodes.accountLocked, details: details)
    }
    
    static func emailNotVerified(email: String) -> AuthError {
        let details = ["email": AnyCodable(email)]
        return AuthError.fromCode(AuthErrorConstants.ErrorCodes.emailNotVerified, details: details)
    }
    
    static func tooManyAttempts(attemptsRemaining: Int = 0) -> AuthError {
        var details: [String: AnyCodable] = [:]
        if attemptsRemaining > 0 {
            details["attempts_remaining"] = AnyCodable(attemptsRemaining)
        }
        return AuthError.fromCode(AuthErrorConstants.ErrorCodes.tooManyAttempts, details: details)
    }
    
    /// Create registration-related errors
    static func emailAlreadyExists(email: String) -> AuthError {
        let details = ["email": AnyCodable(email)]
        return AuthError.fromCode(AuthErrorConstants.ErrorCodes.emailAlreadyExists, details: details)
    }
    
    static func usernameAlreadyTaken(username: String) -> AuthError {
        let details = ["username": AnyCodable(username)]
        return AuthError.fromCode(AuthErrorConstants.ErrorCodes.usernameAlreadyTaken, details: details)
    }
    
    static func invalidUsernameFormat(username: String, validationErrors: [String]? = nil) -> AuthError {
        var details: [String: AnyCodable] = ["username": AnyCodable(username)]
        if let validationErrors = validationErrors {
            details["validation_errors"] = AnyCodable(validationErrors)
        }
        return AuthError.fromCode(AuthErrorConstants.ErrorCodes.invalidUsernameFormat, details: details)
    }
    
    static func invalidPasswordFormat(validationErrors: [String]? = nil) -> AuthError {
        var details: [String: AnyCodable] = [:]
        if let validationErrors = validationErrors {
            details["validation_errors"] = AnyCodable(validationErrors)
        }
        return AuthError.fromCode(AuthErrorConstants.ErrorCodes.invalidPasswordFormat, details: details)
    }
    
    static func passwordsDontMatch() -> AuthError {
        return AuthError.fromCode(AuthErrorConstants.ErrorCodes.passwordsDontMatch)
    }
    
    static func ageRestriction(minimumAge: Int = 16) -> AuthError {
        let details = ["minimum_age": AnyCodable(minimumAge)]
        return AuthError.fromCode(AuthErrorConstants.ErrorCodes.ageRestriction, details: details)
    }
    
    static func verificationCodeExpired() -> AuthError {
        return AuthError.fromCode(AuthErrorConstants.ErrorCodes.verificationCodeExpired)
    }
    
    static func invalidVerificationCode() -> AuthError {
        return AuthError.fromCode(AuthErrorConstants.ErrorCodes.invalidVerificationCode)
    }
    
    /// Create 2FA-related errors
    static func twofaRequired() -> AuthError {
        return AuthError.fromCode(AuthErrorConstants.ErrorCodes.twofaRequired)
    }
    
    static func invalid2FACode() -> AuthError {
        return AuthError.fromCode(AuthErrorConstants.ErrorCodes.invalid2FACode)
    }
    
    static func twofaCodeExpired() -> AuthError {
        return AuthError.fromCode(AuthErrorConstants.ErrorCodes.twofaCodeExpired)
    }
    
    static func twofaMethodNotAvailable(method: String) -> AuthError {
        let details = ["method": AnyCodable(method)]
        return AuthError.fromCode(AuthErrorConstants.ErrorCodes.twofaMethodNotAvailable, details: details)
    }
    
    /// Create general errors
    static func validationError(validationErrors: [String: Any]) -> AuthError {
        let details = ["validation_errors": AnyCodable(validationErrors)]
        return AuthError.fromCode(AuthErrorConstants.ErrorCodes.validationError, details: details)
    }
    
    static func serverError(details: [String: AnyCodable]? = nil) -> AuthError {
        return AuthError.fromCode(AuthErrorConstants.ErrorCodes.serverError, details: details)
    }
    
    static func networkError() -> AuthError {
        return AuthError.fromCode(AuthErrorConstants.ErrorCodes.networkError)
    }
    
    static func sessionExpired() -> AuthError {
        return AuthError.fromCode(AuthErrorConstants.ErrorCodes.sessionExpired)
    }
    
    // MARK: - Error Handling
    
    /// Get localized error message for UI display
    var localizedMessage: String {
        // For now, return the message as-is
        // In the future, this could integrate with Localizable.strings
        return message
    }
    
    /// Get error icon name for UI display
    var iconName: String {
        switch errorType {
        case .login:
            return "exclamationmark.triangle"
        case .registration:
            return "person.badge.plus"
        case .twoFA:
            return "lock.shield"
        case .validation:
            return "checkmark.circle"
        case .network:
            return "wifi.slash"
        case .server:
            return "server.rack"
        case .session:
            return "clock.arrow.circlepath"
        }
    }
    
    /// Get error color for UI display
    var colorName: String {
        switch severity {
        case .low:
            return "primaryDefaultColor"
        case .medium:
            return "primaryDefaultColor"
        case .high:
            return "warningBackgroundColor"
        case .critical:
            return "warningBackgroundColor"
        }
    }
}

// MARK: - Supporting Types

/// Wrapper for Any type to make it Codable
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self.value {
        case is NSNull:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyCodable value cannot be encoded")
            throw EncodingError.invalidValue(self.value, context)
        }
    }
}

// MARK: - Extensions

extension AuthErrorConstants.ErrorMessages {
    /// Get error message for a specific error code
    static func message(for code: String) -> String {
        switch code {
        case AuthErrorConstants.ErrorCodes.invalidCredentials:
            return invalidCredentials
        case AuthErrorConstants.ErrorCodes.userNotFound:
            return userNotFound
        case AuthErrorConstants.ErrorCodes.accountLocked:
            return accountLocked
        case AuthErrorConstants.ErrorCodes.emailNotVerified:
            return emailNotVerified
        case AuthErrorConstants.ErrorCodes.tooManyAttempts:
            return tooManyAttempts
        case AuthErrorConstants.ErrorCodes.emailAlreadyExists:
            return emailAlreadyExists
        case AuthErrorConstants.ErrorCodes.usernameAlreadyTaken:
            return usernameAlreadyTaken
        case AuthErrorConstants.ErrorCodes.invalidUsernameFormat:
            return invalidUsernameFormat
        case AuthErrorConstants.ErrorCodes.invalidPasswordFormat:
            return invalidPasswordFormat
        case AuthErrorConstants.ErrorCodes.passwordsDontMatch:
            return passwordsDontMatch
        case AuthErrorConstants.ErrorCodes.ageRestriction:
            return ageRestriction
        case AuthErrorConstants.ErrorCodes.verificationCodeExpired:
            return verificationCodeExpired
        case AuthErrorConstants.ErrorCodes.invalidVerificationCode:
            return invalidVerificationCode
        case AuthErrorConstants.ErrorCodes.twofaRequired:
            return twofaRequired
        case AuthErrorConstants.ErrorCodes.invalid2FACode:
            return invalid2FACode
        case AuthErrorConstants.ErrorCodes.twofaCodeExpired:
            return twofaCodeExpired
        case AuthErrorConstants.ErrorCodes.twofaMethodNotAvailable:
            return twofaMethodNotAvailable
        case AuthErrorConstants.ErrorCodes.validationError:
            return validationError
        case AuthErrorConstants.ErrorCodes.serverError:
            return serverError
        case AuthErrorConstants.ErrorCodes.networkError:
            return networkError
        case AuthErrorConstants.ErrorCodes.sessionExpired:
            return sessionExpired
        default:
            return "An unexpected error occurred. Please try again."
        }
    }
}
