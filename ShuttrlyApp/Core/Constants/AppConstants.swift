//
//  AppConstants.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 27/08/2025.
//

import Foundation

struct AppConstants {
    
    // MARK: - API Configuration
    struct API {
        static let baseURL = "http://192.168.1.65:8000/api/v1"
        static let timeout: TimeInterval = 30
        
        // Endpoints
        struct Endpoints {
            // Authentification
            static let login = "/auth/login/"
            static let logout = "/auth/logout/"
            static let refreshSession = "/auth/refresh-session/"
            static let refreshToken = "/auth/refresh/"
            static let resend2FACode = "/auth/resend-2fa-code/"
            
            // Registration
            static let registerStep1 = "/auth/register/step1/"
            static let registerStep2 = "/auth/register/step2/"
            static let registerComplete = "/auth/register/complete/"
            static let checkUsername = "/auth/check-username/"
            static let resendCode = "/auth/resend-code/"
            
            // Profile
            static let userProfileFull = "/user/profile/full/"
            static let updateProfile = "/user/update/"
            static let uploadProfilePicture = "/user/profile/picture/"
            static let deleteTrustedDevice = "/user/devices/delete/"
        }
    }
    
    // MARK: - UI Configuration
    struct UI {
        static let cornerRadius: CGFloat = 12
        static let padding: CGFloat = 16
        static let buttonHeight: CGFloat = 50
                
        // Colors
        static let primaryColor = "PrimaryColor"
        static let secondaryColor = "SecondaryColor"
        static let backgroundColor = "BackgroundColor"
    }
            
    // MARK: - Storage Keys
    struct StorageKeys {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let userProfile = "userProfile"
    }
}
