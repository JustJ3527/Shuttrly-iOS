//
//  RegistrationModels.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import Foundation
import Combine

// MARK: - Registration Step Models
// These models correspond to the 5-step registration process

// MARK: - Step 1: Email Verification
struct RegisterStep1Request: Codable {
    let email: String
}

struct RegisterStep1Response: Codable {
    let success: Bool
    let message: String
    let email: String
    let tempUserId: Int
    
    enum CodingKeys: String, CodingKey {
        case success, message, email
        case tempUserId = "temp_user_id"
    }
}

// MARK: - Step 2: Email Code Verification
struct RegisterStep2Request: Codable {
    let email: String
    let verificationCode: String
    
    enum CodingKeys: String, CodingKey {
        case email
        case verificationCode = "verification_code"
    }
}

struct RegisterStep2Response: Codable {
    let success: Bool
    let message: String
    let emailVerified: Bool
     
    enum CodingKeys: String, CodingKey {
        case success, message
        case emailVerified = "email_verified"
    }
}

// MARK: - Step 3: Personal Information
struct RegisterStep3Request: Codable {
    let firstName: String
    let lastName: String
    let dateOfBirth: String // Format: "YYYY-MM-DD"
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case dateOfBirth = "date_of_birth"
    }
}

// MARK: - Step 4: Username Selection with real-time validation
struct RegisterStep4Request: Codable {
    let username: String
}

// Real-time username availability check
struct UsernameAvailabilityRequest: Codable {
    let username: String
}

struct UsernameAvailabilityResponse: Codable {
    let success: Bool
    let message: String
    let username: String
    
    // Computed property to maintain compatibility with existing code
    var available: Bool {
        return success
    }
}

// MARK: - Step 5: Password Creation
struct RegisterStep5Request: Codable {
    let password1: String
    let password2: String
}

// MARK: - Complete Registration
struct RegisterCompleteRequest: Codable {
    let email: String
    let firstName: String
    let lastName: String
    let dateOfBirth: String
    let username: String
    let password1: String
    let password2: String
    
    enum CodingKeys: String, CodingKey {
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case dateOfBirth = "date_of_birth"
        case username
        case password1
        case password2
    }
}

// MARK: - Registration State Management
// This enum tracks the current step in the registration process
enum RegistrationStep: Int, CaseIterable {
    case email = 1           // Step 1: Enter email
    case verification = 2    // Step 2: Verify email code
    case personalInfo = 3    // Step 3: Enter personal details
    case username = 4        // Step 4: Choose username
    case password = 5        // Step 5: Create password
    case accountSummary = 6  // Step 6: Review account information
    case complete = 7        // Registration complete
 
    var title: String {
        switch self {
        case .email: return "Email Verification"
        case .verification: return "Verify Email"
        case .personalInfo: return "Personal Information"
        case .username: return "Choose Username"
        case .password: return "Create Password"
        case .accountSummary: return "Review Information"
        case .complete: return "Welcome!"
        }
    }
    
    var description: String {
        switch self {
        case .email: return "Enter your email address to get started"
        case .verification: return "Enter the 6-digit code sent to your email"
        case .personalInfo: return "Tell us about yourself"
        case .username: return "Choose a unique username"
        case .password: return "Create a strong password"
        case .accountSummary: return "Review your information before creating your account"
        case .complete: return "Your account has been created successfully!"
        }
    }
    
    var progress: Double {
        return Double(self.rawValue) / Double(RegistrationStep.allCases.count - 1)
    }
}

// MARK: - Registration Data Container
// This class holds all registration data throughout the process
class RegistrationData: ObservableObject {
    @Published var email: String = ""
    @Published var tempUserId: Int?
    @Published var verificationCode: String = "" // Added for step 2
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var dateOfBirth: Date = Date()
    @Published var username: String = ""
    @Published var password1: String = ""
    @Published var password2: String = ""
    
    // Username validation state
    @Published var isUsernameChecking: Bool = false
    @Published var isUsernameAvailable: Bool = false
    @Published var usernameValidationMessage: String = ""
    
    // Helper method to create the final registration request
    func createCompleteRequest() -> RegisterCompleteRequest {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return RegisterCompleteRequest(
            email: email,
            firstName: firstName,
            lastName: lastName,
            dateOfBirth: dateFormatter.string(from: dateOfBirth),
            username: username,
            password1: password1,
            password2: password2
        )
    }
    
    // Enhanced validation methods
    var isStep1Valid: Bool {
        return !email.isEmpty && email.contains("@")
    }
    
    var isStep2Valid: Bool {
        return !verificationCode.isEmpty && verificationCode.count == 6
    }
    
    var isStep3Valid: Bool {
        let sixteenYearsAgo = Calendar.current.date(byAdding: .year, value: -16, to: Date()) ?? Date()
        return !firstName.isEmpty && !lastName.isEmpty && dateOfBirth <= sixteenYearsAgo
    }
    
    var isStep4Valid: Bool {
        return username.count >= 3 && username.count <= 30 && isUsernameAvailable
    }
    
    var isStep5Valid: Bool {
        return password1.count >= 8 && password1 == password2
    }
    
    // Username validation methods
    func validateUsername(_ username: String) {
        self.username = username
        self.isUsernameChecking = true
        self.isUsernameAvailable = false
        self.usernameValidationMessage = "Checking availability..."
    }
    
    func updateUsernameAvailability(_ available: Bool, message: String) {
        self.isUsernameChecking = false
        self.isUsernameAvailable = available
        self.usernameValidationMessage = message
    }
}

// MARK: - Registration Response Models

struct RegisterCompleteResponse: Codable {
    let success: Bool
    let message: String
    let user: User
    let access: String
    let refresh: String
}

// MARK: - Error Handling for Registration

struct RegistrationError: Codable {
    let success: Bool
    let message: String
    let errors: [String: [String]]?
    
    enum CodingKeys: String, CodingKey {
        case success, message, errors
    }
}

// MARK: - Resend Code Models

struct ResendCodeRequest: Codable {
    let email: String
}

struct ResendCodeResponse: Codable {
    let success: Bool
    let message: String
    let canResend: Bool
    
    enum CodingKeys: String, CodingKey {
        case success, message
        case canResend = "can_resend"
    }
}
