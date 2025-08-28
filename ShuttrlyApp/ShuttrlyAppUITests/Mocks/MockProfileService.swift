//
//  MockProfileService.swift
//  ShuttrlyAppUITests
//
//  Created by Jules Antoine on 28/08/2025.
//

import Foundation
import Combine

// MARK: - Mock Profile Service
// Provides instant mock data for ProfileView previews

class MockProfileService: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentProfile: ComprehensiveUserProfile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    // MARK: - Mock Data
    private let mockProfiles: [String: ComprehensiveUserProfile] = [
        "sample": MockProfileData.sampleProfile,
        "empty": MockProfileData.emptyProfile,
        "private": MockProfileData.privateProfile
    ]
    
    // MARK: - Initialization
    init(profileType: String = "sample") {
        // Simulate a brief loading state for realism
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
            self.currentProfile = self.mockProfiles[profileType] ?? self.mockProfiles["sample"]
        }
    }
    
    // MARK: - Mock Methods
    func fetchProfile() {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.isLoading = false
            self.currentProfile = self.mockProfiles["sample"]
        }
    }
    
    func updateProfile(_ request: ProfileUpdateRequest) {
        isLoading = true
        errorMessage = nil
        
        // Simulate update delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            
            // Simulate success
            if Bool.random() {
                self.successMessage = "Profile updated successfully!"
                // Update the current profile with new data
                if var updatedProfile = self.currentProfile {
                    updatedProfile.basicInfo.firstName = request.firstName
                    updatedProfile.basicInfo.lastName = request.lastName
                    updatedProfile.basicInfo.bio = request.bio
                    updatedProfile.basicInfo.isPrivate = request.isPrivate
                    self.currentProfile = updatedProfile
                }
            } else {
                // Simulate occasional error
                self.errorMessage = "Failed to update profile. Please try again."
            }
        }
    }
    
    func uploadProfilePicture(_ imageData: Data) {
        isLoading = true
        errorMessage = nil
        
        // Simulate upload delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isLoading = false
            
            if Bool.random() {
                self.successMessage = "Profile picture updated successfully!"
                // Update profile picture URL
                if var updatedProfile = self.currentProfile {
                    updatedProfile.profilePicture.url = "https://example.com/profile/updated_\(Date().timeIntervalSince1970).jpg"
                    updatedProfile.profilePicture.lastUpdated = ISO8601DateFormatter().string(from: Date())
                    self.currentProfile = updatedProfile
                }
            } else {
                self.errorMessage = "Failed to upload profile picture. Please try again."
            }
        }
    }
    
    // MARK: - Utility Methods
    func switchToProfile(_ profileType: String) {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isLoading = false
            self.currentProfile = self.mockProfiles[profileType] ?? self.mockProfiles["sample"]
        }
    }
    
    func simulateError() {
        errorMessage = "This is a simulated error for testing purposes."
    }
    
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}

