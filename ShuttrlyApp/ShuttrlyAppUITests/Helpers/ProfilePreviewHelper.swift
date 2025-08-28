//
//  ProfilePreviewHelper.swift
//  ShuttrlyAppUITests
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - Profile Preview Helper
// Provides easy preview configurations for ProfileView

struct ProfilePreviewHelper {
    
    // MARK: - Preview Configurations
    
    /// ProfileView with sample user data (complete profile)
    static func sampleProfile() -> some View {
        ProfileView()
            .environmentObject(MockProfileService(profileType: "sample"))
    }
    
    /// ProfileView with empty user data (new user)
    static func emptyProfile() -> some View {
        ProfileView()
            .environmentObject(MockProfileService(profileType: "empty"))
    }
    
    /// ProfileView with private user data
    static func privateProfile() -> some View {
        ProfileView()
            .environmentObject(MockProfileService(profileType: "private"))
    }
    
    /// ProfileView in loading state
    static func loadingProfile() -> some View {
        let mockService = MockProfileService(profileType: "sample")
        mockService.isLoading = true
        mockService.currentProfile = nil
        
        return ProfileView()
            .environmentObject(mockService)
    }
    
    /// ProfileView with error state
    static func errorProfile() -> some View {
        let mockService = MockProfileService(profileType: "sample")
        mockService.errorMessage = "Failed to load profile. Please check your connection and try again."
        
        return ProfileView()
            .environmentObject(mockService)
    }
    
    /// ProfileView in editing mode
    static func editingProfile() -> some View {
        let mockService = MockProfileService(profileType: "sample")
        
        return ProfileView()
            .environmentObject(mockService)
            .onAppear {
                // Simulate editing mode after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    // This would trigger editing mode in the actual view
                }
            }
    }
    
    // MARK: - Multiple Preview Scenarios
    
    /// All preview scenarios in a tab view
    static func allScenarios() -> some View {
        TabView {
            sampleProfile()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Sample")
                }
            
            emptyProfile()
                .tabItem {
                    Image(systemName: "person.badge.plus")
                    Text("Empty")
                }
            
            privateProfile()
                .tabItem {
                    Image(systemName: "lock.fill")
                    Text("Private")
                }
            
            loadingProfile()
                .tabItem {
                    Image(systemName: "arrow.clockwise")
                    Text("Loading")
                }
            
            errorProfile()
                .tabItem {
                    Image(systemName: "exclamationmark.triangle")
                    Text("Error")
                }
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}

// MARK: - Preview Extensions

extension ProfileView {
    
    /// Preview with sample data
    static var samplePreview: some View {
        ProfilePreviewHelper.sampleProfile()
    }
    
    /// Preview with empty data
    static var emptyPreview: some View {
        ProfilePreviewHelper.emptyProfile()
    }
    
    /// Preview with private data
    static var privatePreview: some View {
        ProfilePreviewHelper.privateProfile()
    }
    
    /// Preview in loading state
    static var loadingPreview: some View {
        ProfilePreviewHelper.loadingProfile()
    }
    
    /// Preview with error state
    static var errorPreview: some View {
        ProfilePreviewHelper.errorProfile()
    }
    
    /// All preview scenarios
    static var allScenariosPreview: some View {
        ProfilePreviewHelper.allScenarios()
    }
}

