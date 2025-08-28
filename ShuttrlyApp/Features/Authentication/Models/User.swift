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
    
    // User's email address (used for login and communication) - can be null from API
    let email: String?
    
    // Optional first name (user might not provide it)
    let firstName: String?
    
    // Optional last name (user might not provide it)
    let lastName: String?
    
    // Optional date of birth (user might not provide it)
    let dateOfBirth: String?
    
    // Optional profile picture URL or path
    let profilePicture: String?
    
    // Optional user biography or description
    let bio: String?
    
    // Whether the user profile is private
    let isPrivate: Bool
    
    // Whether the user's email is verified
    let isEmailVerified: Bool
    
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
        case dateOfBirth = "date_of_birth" // Maps dateOfBirth to "date_of_birth" in JSON
        case profilePicture = "profile_picture" // Maps profilePicture to "profile_picture" in JSON
        case bio
        case isPrivate = "is_private" // Maps isPrivate to "is_private" in JSON
        case isEmailVerified = "is_email_verified" // Maps isEmailVerified to "is_email_verified" in JSON
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
    let apiEndpoints: APIEndpoints
    let webUrls: WebURLs
    let gdprCompliance: GDPRCompliance
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
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
        case apiEndpoints = "api_endpoints"
        case webUrls = "web_urls"
        case gdprCompliance = "gdpr_compliance"
    }
}


// MARK: - Sub-models for comprehensive profile

struct BasicUserInfo: Codable {
    let username: String
    let email: String?
    let firstName: String?
    let lastName: String?
    let fullName: String?
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
    let emailVerificationCode: String?
    let verificationCodeSentAt: String?
    let canSendVerificationCode: Bool
    
    enum CodingKeys: String, CodingKey {
        case isEmailVerified = "is_email_verified"
        case emailVerificationCode = "email_verification_code"
        case verificationCodeSentAt = "verification_code_sent_at"
        case canSendVerificationCode = "can_send_verification_code"
    }
}

struct TwoFactorAuth: Codable {
    let email2FAEnabled: Bool
    let email2FACode: String?
    let email2FASentAt: String?
    let totpEnabled: Bool
    let twoFATOTPSecret: String?
    
    enum CodingKeys: String, CodingKey {
        case email2FAEnabled = "email_2fa_enabled"
        case email2FACode = "email_2fa_code"
        case email2FASentAt = "email_2fa_sent_at"
        case totpEnabled = "totp_enabled"
        case twoFATOTPSecret = "twofa_totp_secret"
    }
}

struct TrustedDevices: Codable {
    let count: Int
    let devices: [TrustedDevice]
}

struct DeviceLocation: Codable {
    let city: String?
    let region: String?
    let country: String?
    
    // Custom decoder pour gérer les cas où location est une string JSON ou un dict
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // Essayer d'abord comme une string (cas le plus probable)
        if let stringValue = try? container.decode(String.self) {
            // Nettoyer la string pour enlever les caractères problématiques
            let cleanString = stringValue
                .replacingOccurrences(of: "'", with: "\"")
                .replacingOccurrences(of: "None", with: "null")
            
            // Essayer de parser comme JSON
            if let data = cleanString.data(using: .utf8),
               let locationDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                
                // Extraire les valeurs en gérant les "null" et les valeurs vides
                if let city = locationDict["city"] as? String, city != "null" && !city.isEmpty {
                    self.city = city
                } else {
                    self.city = nil
                }
                
                if let region = locationDict["region"] as? String, region != "null" && !region.isEmpty {
                    self.region = region
                } else {
                    self.region = nil
                }
                
                if let country = locationDict["country"] as? String, country != "null" && !country.isEmpty {
                    self.country = country
                } else {
                    self.country = nil
                }
            } else {
                // Si ce n'est pas du JSON valide, traiter comme une string simple
                self.city = stringValue.isEmpty ? nil : stringValue
                self.region = nil
                self.country = nil
            }
        } else {
            // Fallback: essayer comme dictionnaire
            let dict = try container.decode([String: String?].self)
            self.city = dict["city"] ?? nil
            self.region = dict["region"] ?? nil
            self.country = dict["country"] ?? nil
        }
    }
    
    // Encoder normal
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(city, forKey: .city)
        try container.encode(region, forKey: .region)
        try container.encode(country, forKey: .country)
    }
    
    private enum CodingKeys: String, CodingKey {
        case city, region, country
    }
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
    let location: DeviceLocation?
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
    let ipAddress: String?
    
    enum CodingKeys: String, CodingKey {
        case dateJoined = "date_joined"
        case lastLoginDate = "last_login_date"
        case lastLoginIP = "last_login_ip"
        case ipAddress = "ip_address"
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
    let totalSizeBytes: Int
    let totalSizeMB: Double
    let rawPhotos: Int
    let jpegPhotos: Int
    let recentPhotos: Int
    
    enum CodingKeys: String, CodingKey {
        case totalPhotos = "total_photos"
        case totalSizeBytes = "total_size_bytes"
        case totalSizeMB = "total_size_mb"
        case rawPhotos = "raw_photos"
        case jpegPhotos = "jpeg_photos"
        case recentPhotos = "recent_photos"
    }
}

struct CollectionStatistics: Codable {
    let totalCollections: Int
    let privateCollections: Int
    let publicCollections: Int
    let collections: [Collection]
    
    enum CodingKeys: String, CodingKey {
        case totalCollections = "total_collections"
        case privateCollections = "private_collections"
        case publicCollections = "public_collections"
        case collections
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

// Model for profile response (full profile)
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

// Model for profile update response (simplified)
struct ProfileUpdateResponse: Codable {
    let success: Bool
    let message: String
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case success, message, user
    }
}

// MARK: - Additional Profile Models

struct APIEndpoints: Codable {
    let profile: String
    let profileFull: String
    let updateProfile: String
    let photos: String
    let collections: String
    let stats: String
    
    enum CodingKeys: String, CodingKey {
        case profile
        case profileFull = "profile_full"
        case updateProfile = "update_profile"
        case photos
        case collections
        case stats
    }
}

struct WebURLs: Codable {
    let profilePage: String
    let photosPage: String
    let collectionsPage: String
    let settingsPage: String
    
    enum CodingKeys: String, CodingKey {
        case profilePage = "profile_page"
        case collectionsPage = "collections_page"
        case settingsPage = "settings_page"
        case photosPage = "photos_page"
    }
}

struct GDPRCompliance: Codable {
    let isAnonymized: Bool
    let dataRetentionPolicy: String
    let rightToBeForgotten: String
    let dataPortability: String
    
    enum CodingKeys: String, CodingKey {
        case isAnonymized = "is_anonymized"
        case dataRetentionPolicy = "data_retention_policy"
        case rightToBeForgotten = "right_to_be_forgotten"
        case dataPortability = "data_portability"
    }
}

struct Collection: Codable {
    let id: Int
    let name: String
    let description: String
    let isPrivate: Bool
    let photoCount: Int
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case isPrivate = "is_private"
        case photoCount = "photo_count"
        case createdAt = "created_at"
    }
}
