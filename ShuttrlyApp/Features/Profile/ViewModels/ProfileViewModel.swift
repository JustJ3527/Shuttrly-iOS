//
//  ProfileViewModel.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import Foundation
import Combine

// MARK: - Profile ViewModel
// Manages profile state and UI logic for SwiftUI

class ProfileViewModel: ObservableObject {
    
    // MARK: - Properties
    
    // Profile service
    private let profileService: ProfileService
    
    // Published properties for SwiftUI binding
    @Published var profile: ComprehensiveUserProfile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    // Profile editing state
    @Published var isEditing: Bool = false
    @Published var hasUnsavedChanges: Bool = false
    
    // Form data for editing
    @Published var editFirstName: String = ""
    @Published var editLastName: String = ""
    @Published var editBio: String = ""
    @Published var editIsPrivate: Bool = false
    @Published var editDateOfBirth: Date = Date()
    
    // Private properties
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Preview Mode Detection
    
    /// Check if running in Xcode preview mode
    var isPreviewMode: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    /// Get colors that work properly in preview mode
    var previewColors: (primary: String, secondary: String, background: String) {
        if isPreviewMode {
            // Force specific colors for previews to avoid blue tint
            return (
                primary: "primaryDefaultColor",
                secondary: "secondaryDefaultColor", 
                background: "backgroundDefaultColor"
            )
        } else {
            // Use dynamic colors in normal mode
            return (
                primary: "primaryDefaultColor",
                secondary: "secondaryDefaultColor",
                background: "backgroundDefaultColor"
            )
        }
    }
    
    // MARK: - Initialization
    
    init(profileService: ProfileService = ProfileService()) {
        self.profileService = profileService
        
        // Détecter automatiquement le mode preview
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            // Mode preview : charger des données fictives immédiatement
            loadMockData()
        } else {
            // Mode normal : configurer les bindings et charger depuis l'API
            setupBindings()
        }
    }
    
    // MARK: - Public Methods
    
    /// Load user profile
    func loadProfile() {
        // Ne pas charger si on est en mode preview
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else { return }
        profileService.fetchProfile()
    }
    
    /// Start editing profile
    func startEditing() {
        guard let profile = profile else { return }
        
        editFirstName = profile.basicInfo.firstName ?? ""
        editLastName = profile.basicInfo.lastName ?? ""
        editBio = profile.basicInfo.bio ?? ""
        editIsPrivate = profile.basicInfo.isPrivate
        
        if let dateString = profile.basicInfo.dateOfBirth,
           let date = DateFormatter.iso8601.date(from: dateString) {
            editDateOfBirth = date
        }
        
        isEditing = true
        hasUnsavedChanges = false
    }
    
    /// Cancel editing
    func cancelEditing() {
        isEditing = false
        hasUnsavedChanges = false
        clearFormValidation()
    }
    
    /// Stop editing (used after successful save)
    func stopEditing() {
        isEditing = false
        hasUnsavedChanges = false
        clearFormValidation()
    }
    
    /// Save profile changes
    func saveProfile() {
        guard hasUnsavedChanges else { return }
        
        let request = ProfileUpdateRequest(
            firstName: editFirstName.isEmpty ? nil : editFirstName,
            lastName: editLastName.isEmpty ? nil : editLastName,
            bio: editBio.isEmpty ? nil : editBio,
            isPrivate: editIsPrivate,
            profilePicture: nil,
            dateOfBirth: DateFormatter.iso8601.string(from: editDateOfBirth)
        )
        
        profileService.updateProfile(request)
    }
    
    /// Delete trusted device
    func deleteTrustedDevice(_ deviceToken: String) {
        profileService.deleteTrustedDevice(deviceToken)
    }
    
    /// Upload new profile picture
    func uploadProfilePicture(_ imageData: Data) {
        profileService.uploadProfilePicture(imageData)
    }
    
    /// Clear error message
    func clearError() {
        errorMessage = nil
    }
    
    /// Clear success message
    func clearSuccess() {
        successMessage = nil
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Bind profile service properties
        profileService.$currentProfile
            .assign(to: \.profile, on: self)
            .store(in: &cancellables)
        
        profileService.$isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
        
        profileService.$errorMessage
            .assign(to: \.errorMessage, on: self)
            .store(in: &cancellables)
        
        profileService.$successMessage
            .assign(to: \.successMessage, on: self)
            .store(in: &cancellables)
        
        // Monitor form changes (text fields and privacy)
        Publishers.CombineLatest4($editFirstName, $editLastName, $editBio, $editIsPrivate)
            .map { firstName, lastName, bio, isPrivate in
                // Check if any field has changed from original values
                guard let profile = self.profile else { return false }
                
                let firstNameChanged = firstName != (profile.basicInfo.firstName ?? "")
                let lastNameChanged = lastName != (profile.basicInfo.lastName ?? "")
                let bioChanged = bio != (profile.basicInfo.bio ?? "")
                let privacyChanged = isPrivate != profile.basicInfo.isPrivate
                
                return firstNameChanged || lastNameChanged || bioChanged || privacyChanged
            }
            .assign(to: \.hasUnsavedChanges, on: self)
            .store(in: &cancellables)
        
        // Monitor date of birth changes separately
        $editDateOfBirth
            .map { [weak self] dateOfBirth in
                guard let self = self, let profile = self.profile else { return false }
                
                let originalDateString = profile.basicInfo.dateOfBirth
                let currentDateString = DateFormatter.iso8601.string(from: dateOfBirth)
                let dateChanged = originalDateString != currentDateString
                
                // Combine with existing hasUnsavedChanges
                let otherFieldsChanged = self.hasUnsavedChanges
                return otherFieldsChanged || dateChanged
            }
            .assign(to: \.hasUnsavedChanges, on: self)
            .store(in: &cancellables)
        
        // Listen for profile update completion
        NotificationCenter.default.publisher(for: .profileUpdateCompleted)
            .sink { [weak self] _ in
                self?.stopEditing()
            }
            .store(in: &cancellables)
    }
    
    private func clearFormValidation() {
        // Reset form validation state if needed
    }
    
    /// Load mock data for preview mode
    private func loadMockData() {
        self.isLoading = true
        
        // Simuler un délai de chargement réaliste
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.profile = self.createMockProfile()
            self.isLoading = false
            self.errorMessage = nil
            self.successMessage = nil
        }
    }
    
    /// Create comprehensive mock profile for previews
    private func createMockProfile() -> ComprehensiveUserProfile {
        return ComprehensiveUserProfile(
            userId: 1,
            basicInfo: BasicUserInfo(
                username: "jules_antoine",
                email: "jules.antoine@shuttrly.com",
                firstName: "Jules",
                lastName: "Antoine",
                fullName: "Jules Antoine",
                dateOfBirth: "1995-03-15",
                age: 28,
                bio: "Passionate photographer capturing life's beautiful moments. Love exploring new places and sharing stories through images. 📸✨",
                isPrivate: false
            ),
            profilePicture: ProfilePicture(
                url: "https://images.unsplash.com/photo-1483909796554-bb0051ab60ad?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cHJvZmlsJTIwZmlsbGV8ZW58MHx8MHx8fDA%3D",
                filename: "profile.jpg",
                isDefault: false
            ),
            accountStatus: AccountStatus(
                isActive: true,
                isStaff: false,
                isSuperuser: false,
                isOnline: true,
                isAnonymized: false
            ),
            verificationStatus: VerificationStatus(
                isEmailVerified: true,
                emailVerificationCode: nil,
                verificationCodeSentAt: nil,
                canSendVerificationCode: true
            ),
            twoFactorAuth: TwoFactorAuth(
                email2FAEnabled: false,
                email2FACode: nil,
                email2FASentAt: nil,
                totpEnabled: false,
                twoFATOTPSecret: nil
            ),
            timestamps: UserTimestamps(
                dateJoined: "2023-01-15T10:30:00Z",
                lastLoginDate: "2025-08-28T14:20:00Z",
                lastLoginIP: "192.168.1.100",
                ipAddress: "192.168.1.100"
            ),
            permissions: UserPermissions(
                userPermissions: ["view_photos", "upload_photos", "create_collections"],
                groups: ["photographers", "verified_users"],
                isStaff: false,
                isSuperuser: false
            ),
            photoStatistics: PhotoStatistics(
                totalPhotos: 1250,
                totalSizeBytes: 1572864000,
                totalSizeMB: 1500.0,
                rawPhotos: 450,
                jpegPhotos: 800,
                recentPhotos: 25
            ),
            collectionStatistics: CollectionStatistics(
                totalCollections: 8,
                privateCollections: 3,
                publicCollections: 5,
                collections: [
                    Collection(
                        id: 1,
                        name: "Nature Photography",
                        description: "Beautiful landscapes and wildlife",
                        isPrivate: false,
                        photoCount: 150,
                        createdAt: "2024-01-15T09:00:00Z"
                    ),
                    Collection(
                        id: 2,
                        name: "Urban Life",
                        description: "City streets and architecture",
                        isPrivate: false,
                        photoCount: 89,
                        createdAt: "2024-03-20T14:30:00Z"
                    )
                ]
            ),
            trustedDevices: TrustedDevices(
                count: 3,
                devices: [
                    TrustedDevice(
                        deviceToken: "token123",
                        deviceType: "mobile",
                        deviceFamily: "iPhone",
                        browserFamily: "Safari",
                        browserVersion: "16.0",
                        osFamily: "iOS",
                        osVersion: "16.0",
                        ipAddress: "192.168.1.100",
                        location: nil, // DeviceLocation only has custom decoder, use nil for preview
                        createdAt: "2024-01-15T10:30:00Z",
                        lastUsedAt: "2025-08-28T14:20:00Z",
                        expiresAt: "2026-01-15T10:30:00Z"
                    )
                ]
            ),
            securityInfo: SecurityInfo(
                passwordChanged: "2024-06-15T12:00:00Z",
                failedLoginAttempts: 0,
                accountLockedUntil: nil
            ),
            apiEndpoints: APIEndpoints(
                profile: "/api/user/profile/",
                profileFull: "/api/user/profile/full/",
                updateProfile: "/api/user/profile/update/",
                photos: "/api/user/photos/",
                collections: "/api/user/collections/",
                stats: "/api/user/stats/"
            ),
            webUrls: WebURLs(
                profilePage: "https://shuttrly.com/profile/jules_antoine",
                photosPage: "https://shuttrly.com/photos/jules_antoine",
                collectionsPage: "https://shuttrly.com/collections/jules_antoine",
                settingsPage: "https://shuttrly.com/settings"
            ),
            gdprCompliance: GDPRCompliance(
                isAnonymized: false,
                dataRetentionPolicy: "7 years",
                rightToBeForgotten: "https://shuttrly.com/gdpr/forgotten",
                dataPortability: "https://shuttrly.com/gdpr/portability"
            )
        )
    }
}

// MARK: - Date Formatter Extension

extension DateFormatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

// MARK: - Notification Names

extension Notification.Name {
    static let profileUpdateCompleted = Notification.Name("profileUpdateCompleted")
}
