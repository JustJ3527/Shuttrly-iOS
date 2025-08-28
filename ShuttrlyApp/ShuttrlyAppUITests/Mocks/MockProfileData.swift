//
//  MockProfileData.swift
//  ShuttrlyAppUITests
//
//  Created by Jules Antoine on 28/08/2025.
//

import Foundation

// MARK: - Mock Profile Data
// Comprehensive mock data for ProfileView preview and testing

struct MockProfileData {
    
    // MARK: - Sample Profile (Complete User)
    static let sampleProfile = ComprehensiveUserProfile(
        basicInfo: BasicUserInfo(
            username: "jules_antoine",
            email: "jules.antoine@shuttrly.com",
            firstName: "Jules",
            lastName: "Antoine",
            fullName: "Jules Antoine",
            bio: "Passionate photographer capturing life's beautiful moments. Love exploring new places and sharing stories through images. 📸✨",
            dateOfBirth: "1995-03-15",
            isPrivate: false
        ),
        verificationStatus: VerificationStatus(
            isEmailVerified: true,
            isPhoneVerified: false,
            isTwoFactorEnabled: true
        ),
        photoStatistics: PhotoStatistics(
            totalPhotos: 1247,
            publicPhotos: 892,
            privatePhotos: 355,
            totalLikes: 15420,
            totalViews: 89250
        ),
        collectionStatistics: CollectionStatistics(
            totalCollections: 23,
            publicCollections: 18,
            privateCollections: 5,
            totalFollowers: 1240,
            totalFollowing: 567
        ),
        trustedDevices: TrustedDevices(
            devices: [
                TrustedDevice(
                    deviceToken: "iphone_15_pro_max_001",
                    deviceType: "iPhone 15 Pro Max",
                    deviceFamily: "iOS",
                    lastUsed: "2025-08-28T10:30:00Z",
                    location: DeviceLocation(
                        city: "Paris",
                        region: "Île-de-France",
                        country: "France"
                    )
                ),
                TrustedDevice(
                    deviceToken: "macbook_pro_m3_002",
                    deviceType: "MacBook Pro M3",
                    deviceFamily: "macOS",
                    lastUsed: "2025-08-28T09:15:00Z",
                    location: DeviceLocation(
                        city: "Paris",
                        region: "Île-de-France",
                        country: "France"
                    )
                ),
                TrustedDevice(
                    deviceToken: "ipad_pro_11_003",
                    deviceType: "iPad Pro 11-inch",
                    deviceFamily: "iPadOS",
                    lastUsed: "2025-08-27T16:45:00Z",
                    location: DeviceLocation(
                        city: "Paris",
                        region: "Île-de-France",
                        country: "France"
                    )
                )
            ]
        ),
        timestamps: Timestamps(
            dateJoined: "2023-01-15T08:00:00Z",
            lastActive: "2025-08-28T10:30:00Z",
            lastLogin: "2025-08-28T10:30:00Z"
        ),
        profilePicture: ProfilePicture(
            url: "https://example.com/profile/jules_antoine.jpg",
            thumbnailUrl: "https://example.com/profile/jules_antoine_thumb.jpg",
            lastUpdated: "2025-08-15T14:20:00Z"
        )
    )
    
    // MARK: - Empty Profile (New User)
    static let emptyProfile = ComprehensiveUserProfile(
        basicInfo: BasicUserInfo(
            username: "new_user",
            email: "new@shuttrly.com",
            firstName: nil,
            lastName: nil,
            fullName: nil,
            bio: nil,
            dateOfBirth: nil,
            isPrivate: false
        ),
        verificationStatus: VerificationStatus(
            isEmailVerified: false,
            isPhoneVerified: false,
            isTwoFactorEnabled: false
        ),
        photoStatistics: PhotoStatistics(
            totalPhotos: 0,
            publicPhotos: 0,
            privatePhotos: 0,
            totalLikes: 0,
            totalViews: 0
        ),
        collectionStatistics: CollectionStatistics(
            totalCollections: 0,
            publicCollections: 0,
            privateCollections: 0,
            totalFollowers: 0,
            totalFollowing: 0
        ),
        trustedDevices: TrustedDevices(devices: []),
        timestamps: Timestamps(
            dateJoined: "2025-08-28T00:00:00Z",
            lastActive: "2025-08-28T00:00:00Z",
            lastLogin: "2025-08-28T00:00:00Z"
        ),
        profilePicture: ProfilePicture(
            url: nil,
            thumbnailUrl: nil,
            lastUpdated: nil
        )
    )
    
    // MARK: - Private Profile
    static let privateProfile = ComprehensiveUserProfile(
        basicInfo: BasicUserInfo(
            username: "private_user",
            email: "private@shuttrly.com",
            firstName: "Private",
            lastName: "User",
            fullName: "Private User",
            bio: "I prefer to keep my profile private",
            dateOfBirth: "1990-06-20",
            isPrivate: true
        ),
        verificationStatus: VerificationStatus(
            isEmailVerified: true,
            isPhoneVerified: true,
            isTwoFactorEnabled: true
        ),
        photoStatistics: PhotoStatistics(
            totalPhotos: 50,
            publicPhotos: 0,
            privatePhotos: 50,
            totalLikes: 0,
            totalViews: 0
        ),
        collectionStatistics: CollectionStatistics(
            totalCollections: 5,
            publicCollections: 0,
            privateCollections: 5,
            totalFollowers: 0,
            totalFollowing: 0
        ),
        trustedDevices: TrustedDevices(
            devices: [
                TrustedDevice(
                    deviceToken: "iphone_14_private",
                    deviceType: "iPhone 14",
                    deviceFamily: "iOS",
                    lastUsed: "2025-08-28T08:00:00Z",
                    location: nil
                )
            ]
        ),
        timestamps: Timestamps(
            dateJoined: "2024-03-10T12:00:00Z",
            lastActive: "2025-08-28T08:00:00Z",
            lastLogin: "2025-08-28T08:00:00Z"
        ),
        profilePicture: ProfilePicture(
            url: nil,
            thumbnailUrl: nil,
            lastUpdated: nil
        )
    )
}

