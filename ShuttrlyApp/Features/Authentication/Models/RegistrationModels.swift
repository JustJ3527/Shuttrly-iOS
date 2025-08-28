//
//  RegistrationModels.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import Foundation

// MARK: - Registration Step Models
// Theses models correspond to the 5-step registration process

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
    
}