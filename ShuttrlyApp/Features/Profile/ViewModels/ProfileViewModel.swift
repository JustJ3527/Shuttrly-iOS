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
    
    // MARK: - Initialization
    
    init(profileService: ProfileService = ProfileService()) {
        self.profileService = profileService
        setupBindings()
    }
    
    // MARK: - Public Methods
    
    /// Load user profile
    func loadProfile() {
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
