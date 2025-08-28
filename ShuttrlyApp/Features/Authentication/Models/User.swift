//
//  User.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import Foundation

// MARK: - User Model
// This struct represents a user in the app, matching with the Django API response
struct User: Codable, Identifiable {
    // MARK: - Properties
    
    // Unique identifier for the user (matches with Django's primary key)
    let id: Int
    
    // Username chosen by the user (unique in the system)
    let username: String
    
    // User's email address (used for login and communication)
    let email: String
    
    // Optional first name (user might not provide it)
    let firstName: String?
    
    // Optional last name (user might not provide it)
    let lastName: String?
    
    // Optional profile picture URL or path
    let profilePicture: String?
    
    // Optional user biography or description
    let bio: String?
    
    // Date when user joined the platform (string format from API)
    let dateJoined: String
    
    // Whether the user account is active or deactivated
    let isActive: Bool
    
    // MARK: - Coding Keys
    // This enum maps Swift property names to JSON keys from Django API
    // Django uses snake_case (first_name), Swift uses camelCase (firstName)
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case firstName = "first_name" // Maps firstName to "first_name" in JSON
        case lastName = "last_name" // Maps lastName to "last_name" in JSON
        case profilePicture = "profile_picture" // Maps profilePicture to "profile_picture" in JSON
        case bio
        case dateJoined = "date_joined" // Maps dateJoined to "date_joined" in JSON
        case isActive = "is_active" // Maps isActive to "is_active" in JSON
    }
}


// MARK: - API Requests Models

// Model for login requests sent to Django API
struct LoginRequest: Codable {
    let identifier: String // Email or username
    let password: String
    let rememberDevice: Bool? // Optional 2FA device remembering
    
    enum CodingKeys: String, CodingKey {
        case identifier, password
        case rememberDevice = "remember_device"
    }
}

// Model for login response received from Django API
struct LoginResponse: Codable {
    let access: String     // JWT access token for authenticated requests
    let refresh: String    // JWT refresh token for getting new access tokens
    let user: User         // Complete user profile information
}

// Model for registration requests sent to Django API
struct RegistrationRequest: Codable {
    let email: String      // New user's email address
    let username: String   // New user's chosen username
    let password: String   // New user's chosen password
}


// MARK: - Enhanced Profile Models

// Model for comprehensive user profile (from /user/profile/full/)
struct ComprehensiveUserProfile: Codable {
    let userId: Int
    let basicInfo: BasicUserInfo
    let profilePicture: ProfilePicture
    let accountStatus: AccountStatus
    let verificationStatus: VerificationStatus
    let twoFactorAuth: TwoFactorAuth
    let timestamps: UserTimestamps
    let permissions: UserPermissions
    let photoStatistics: PhotoStatistics
    let collectionStatistics: CollectionStatistics
    let trustedDevices: TrustedDevices
    let securityInfo: SecurityInfo
    
    enum CodingKeys: String, CodingKey {
        case userId = "id"
        case basicInfo = "basic_info"
        case profilePicture = "profile_picture"
        case accountStatus = "account_status"
        case verificationStatus = "verification_status"
        case twoFactorAuth = "two_factor_auth"
        case timestamps
        case permissions
        case photoStatistics = "photo_statistics"
        case collectionStatistics = "collection_statistics"
        case trustedDevices = "trusted_devices"
        case securityInfo = "security_info"
    }
}


// MARK: - Sub-models for comprehensive profile

struct BasicUserInfo: Codable {
    let username: String
    let email: String
    let firstName: String?
    let lastName: String?
    let fullName: String
    let dateOfBirth: String?
    let age: Int?
    let bio: String?
    let isPrivate: Bool
    
    enum CodingKeys: String, CodingKey {
        case username, email
        case firstName = "first_name"
        case lastName = "last_name"
        case fullName = "full_name"
        case dateOfBirth = "date_of_birth"
        case age, bio
        case isPrivate = "is_private"
    }
}

struct AccountStatus: Codable {
    let isActive: Bool
    let isStaff: Bool
    let isSuperuser: Bool
    let isOnline: Bool
    let isAnonymized: Bool
    
    enum CodingKeys: String, CodingKey {
        case isActive = "is_active"
        case isStaff = "is_staff"
        case isSuperuser = "is_superuser"
        case isOnline = "is_online"
        case isAnonymized = "is_anonymized"
    }
}

struct VerificationStatus: Codable {
    let isEmailVerified: Bool
    let canSendVerificationCode: Bool
    
    enum CodingKeys: String, CodingKey {
        case isEmailVerified = "is_email_verified"
        case canSendVerificationCode = "can_send_verification_code"
    }
}

struct TwoFactorAuth: Codable {
    let email2FAEnabled: Bool
    let totpEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case email2FAEnabled = "email_2fa_enabled"
        case totpEnabled = "totp_enabled"
    }
}

struct TrustedDevices: Codable {
    let count: Int
    let devices: [TrustedDevice]
}

struct TrustedDevice: Codable {
    let deviceToken: String
    let deviceType: String
    let deviceFamily: String
    let browserFamily: String?
    let browserVersion: String?
    let osFamily: String?
    let osVersion: String?
    let ipAddress: String?
    let location: String?
    let createdAt: String
    let lastUsedAt: String?
    let expiresAt: String?
    
    enum CodingKeys: String, CodingKey {
        case deviceToken = "device_token"
        case deviceType = "device_type"
        case deviceFamily = "device_family"
        case browserFamily = "browser_family"
        case browserVersion = "browser_version"
        case osFamily = "os_family"
        case osVersion = "os_version"
        case ipAddress = "ip_address"
        case location
        case createdAt = "created_at"
        case lastUsedAt = "last_used_at"
        case expiresAt = "expires_at"
        case createdAt = "created_at"
        case lastUsedAt = "last_used_at"
        case expiresAt = "expires_at"
    }
}

struct SecurityInfo: Codable {
    let passwordChanged: String?
    let failedLoginAttempts: Int
    let accountLockedUntil: String?
    
    enum CodingKeys: String, CodingKey {
        case passwordChanged = "password_changed"
        case failedLoginAttempts = "failed_login_attempts"
        case accountLockedUntil = "account_locked_until"
    }
}

struct UserTimestamps: Codable {
    let dateJoined: String
    let lastLoginDate: String?
    let lastLoginIP: String?
    
    enum CodingKeys: String, CodingKey {
        case dateJoined = "date_joined"
        case lastLoginDate = "last_login_date"
        case lastLoginIP = "last_login_ip"
    }
}

struct UserPermissions: Codable {
    let userPermissions: [String]
    let groups: [String]
    let isStaff: Bool
    let isSuperuser: Bool
    
    enum CodingKeys: String, CodingKey {
        case userPermissions = "user_permissions"
        case groups
        case isStaff = "is_staff"
        case isSuperuser = "is_superuser"
    }
}

struct PhotoStatistics: Codable {
    let totalPhotos: Int
    let publicPhotos: Int
    let privatePhotos: Int
    
    enum CodingKeys: String, CodingKey {
        case totalPhotos = "total_photos"
        case publicPhotos = "public_photos"
        case privatePhotos = "private_photos"
    }
}

struct CollectionStatistics: Codable {
    let totalCollections: Int
    let publicCollections: Int
    let privateCollections: Int
    
    enum CodingKeys: String, CodingKey {
        case totalCollections = "total_collections"
        case publicCollections = "public_collections"
        case privateCollections = "private_collections"
    }
}

// Model for READING profile picture (from API response)
struct ProfilePicture: Codable {
    let url: String?
    let filename: String?
    let isDefault: Bool
    
    enum CodingKeys: String, CodingKey {
        case url, filename
        case isDefault = "is_default"
    }
}

// Model for UPDATING profile (sent to API)
struct ProfileUpdateRequest: Codable {
    let firstName: String?
    let lastName: String?
    let bio: String?
    let isPrivate: Bool?
    let profilePicture: String?
    let dateOfBirth: String? // Format: "YYYY-MM-DD"
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
        case isPrivate = "is_private"
        case profilePicture = "profile_picture"
        case dateOfBirth = "date_of_birth"
    }
}

// Model for profile response
struct ProfileResponse: Codable {
    let user: User
    let photoCount: Int
    let collectionCount: Int
    let profilePicture: ProfilePicture? //ProfilePicture model
    
    enum CodingKeys: String, CodingKey {
        case user
        case photoCount = "photo_count"
        case collectionCount = "collection_count"
        case profilePicture = "profile_picture"
    }
}


// MARK: - Error Models

// Model for checking username availability
struct UsernameCheckRequest: Codable {
    let username: String
}

struct UsernameUserCheckResponse: Codable {
    let available: Bool
    let message: String
}
