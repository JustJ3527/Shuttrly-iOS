//
//  ProfileService.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import Foundation
import Combine

// MARK: - Profile Service
// Handles user profile management (fetching, updating, statistics)

class ProfileService: ObservableObject {
    
    // MARK: - Properties
    
    // Published properties for SwiftUI binding
    @Published var currentProfile: ComprehensiveUserProfile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    // Profile editing state
    @Published var isEditing: Bool = false
    @Published var hasUnsavedChanges: Bool = false
    
    // Private properties
    private let networkManager: NetworkManager
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initialization
    
    init(networkManager: NetworkManager = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    // MARK: - Public Methods
    
    /// Fetch the complete user profile
    func fetchProfile() {
        isLoading = true
        errorMessage = nil
        
        networkManager.performRequest(
            endpoint: AppConstants.API.Endpoints.userProfileFull,
            responseType: ComprehensiveUserProfile.self
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.handleError(error)
                }
            },
            receiveValue: { [weak self] profile in
                self?.handleProfileReceived(profile)
            }
        )
        .store(in: &cancellables)
    }
    
    /// Update user profile information
    func updateProfile(_ request: ProfileUpdateRequest) {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        networkManager.performRequest(
            endpoint: AppConstants.API.Endpoints.updateProfile,
            method: .PUT,
            requestBody: request,
            responseType: ProfileUpdateResponse.self
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.handleError(error)
                }
            },
            receiveValue: { [weak self] response in
                self?.handleProfileUpdated(response)
            }
        )
        .store(in: &cancellables)
    }
    
    /// Delete a trusted device
    func deleteTrustedDevice(_ deviceToken: String) {
        isLoading = true
        errorMessage = nil
        
        let deleteRequest = DeleteDeviceRequest(deviceToken: deviceToken)
        
        networkManager.performRequest(
            endpoint: AppConstants.API.Endpoints.deleteTrustedDevice,
            method: .DELETE,
            requestBody: deleteRequest,
            responseType: DeleteDeviceResponse.self
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.handleError(error)
                }
            },
            receiveValue: { [weak self] response in
                self?.handleDeviceDeleted(response)
            }
        )
        .store(in: &cancellables)
    }
    
    /// Upload a new profile picture
    func uploadProfilePicture(_ imageData: Data) {
        isLoading = true
        errorMessage = nil
        
        // Create multipart form data
        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: AppConstants.API.baseURL + AppConstants.API.Endpoints.uploadProfilePicture)!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add image data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"profile_picture\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add boundary end
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        // Perform upload using NetworkManager
        networkManager.performCustomRequest(request)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] data in
                    self?.handleProfilePictureUploaded(data)
                }
            )
            .store(in: &cancellables)
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
    
    private func handleProfileReceived(_ profile: ComprehensiveUserProfile) {
        currentProfile = profile
        print("✅ Profile loaded successfully for user: \(profile.basicInfo.username)")
    }
    
    private func handleProfileUpdated(_ response: ProfileUpdateResponse) {
        successMessage = response.message
        // Refresh profile data
        fetchProfile()
        print("✅ Profile updated successfully: \(response.message)")
        
        // Notify that editing should stop
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotificationCenter.default.post(name: .profileUpdateCompleted, object: nil)
        }
    }
    
    private func handleDeviceDeleted(_ response: DeleteDeviceResponse) {
        successMessage = "Device removed successfully"
        // Refresh profile data to update trusted devices list
        fetchProfile()
        print("✅ Trusted device deleted successfully")
    }
    
    private func handleProfilePictureUploaded(_ data: Data) {
        successMessage = "Profile picture updated successfully"
        // Refresh profile data to show new picture
        fetchProfile()
        print("✅ Profile picture uploaded successfully")
    }
    
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .unauthorized:
                errorMessage = "Session expired. Please log in again."
            case .forbidden:
                errorMessage = "You don't have permission to perform this action."
            case .notFound:
                errorMessage = "Profile not found."
            case .serverError:
                errorMessage = "Server error. Please try again later."
            case .decodingError(let decodingError):
                errorMessage = "Data error: \(decodingError.localizedDescription)"
            default:
                errorMessage = "An error occurred: \(networkError.localizedDescription)"
            }
        } else {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
        
        print("❌ Profile service error: \(error)")
    }
}

// MARK: - Supporting Models

struct DeleteDeviceRequest: Codable {
    let deviceToken: String
    
    enum CodingKeys: String, CodingKey {
        case deviceToken = "device_token"
    }
}

struct DeleteDeviceResponse: Codable {
    let success: Bool
    let message: String
}
