//
//  ProfileView.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - Profile View
// Main profile view for displaying and editing user profile

struct ProfileView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        if let profile = viewModel.profile {
                            profileHeader(profile)
                            profileStats(profile)
                            profileDetails(profile)
                            trustedDevices(profile)
                        } else if viewModel.isLoading {
                            loadingView
                        } else {
                            emptyStateView
                        }
                    }
                    .background(Color.clear)
                    .padding()
                }
                .appBackground()
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    toolbarContent
                }
                .refreshable {
                    viewModel.loadProfile()
                }
            }
        }
        .onAppear {
            viewModel.loadProfile()
        }
        .alert("Error", isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.clearError() }
        )) {
            Button("OK") { viewModel.clearError() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("Success", isPresented: Binding<Bool>(
            get: { viewModel.successMessage != nil },
            set: { _ in viewModel.clearSuccess() }
        )) {
            Button("OK") { viewModel.clearSuccess() }
        } message: {
            Text(viewModel.successMessage ?? "")
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private func profileHeader(_ profile: ComprehensiveUserProfile) -> some View {
        VStack(spacing: 16) {
            // Profile Picture
            ZStack {
                if let profilePicture = profile.profilePicture.url, !profilePicture.isEmpty {
                    AsyncImage(url: URL(string: profilePicture)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundColor(Color("primaryDefaultColor"))
                }
                
                // Edit button overlay
                if viewModel.isEditing {
                    Button(action: {
                        // TODO: Implement image picker
                    }) {
                        Image(systemName: "camera.fill")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color("primaryDefaultColor"))
                            .clipShape(Circle())
                    }
                    .offset(x: 40, y: 40)
                }
            }
            
            // User Info
            VStack(spacing: 8) {
                Text(profile.basicInfo.fullName ?? "User")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("@\(profile.basicInfo.username)")
                    .font(.subheadline)
                    .foregroundColor(Color("textDefaultColor"))
                
                if let bio = profile.basicInfo.bio, !bio.isEmpty {
                    Text(bio)
                        .font(.body)
                        .foregroundColor(Color("textDefaultColor"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
        }
        .padding()
        .cornerRadius(16)
    }
    
    @ViewBuilder
    private func profileStats(_ profile: ComprehensiveUserProfile) -> some View {
        HStack(spacing: 20) {
            StatCard(
                title: "Photos",
                value: "\(profile.photoStatistics.totalPhotos)",
                icon: "photo.fill"
            )
            
            StatCard(
                title: "Collections",
                value: "\(profile.collectionStatistics.totalCollections)",
                icon: "folder.fill"
            )
            
            StatCard(
                title: "Devices",
                value: "\(profile.trustedDevices.count)",
                icon: "iphone"
            )
        }
    }
    
    @ViewBuilder
    private func profileDetails(_ profile: ComprehensiveUserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Profile Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            if viewModel.isEditing {
                profileEditForm
            } else {
                profileInfoDisplay(profile)
            }
        }
        .padding()
        .cornerRadius(16)
    }
    
    @ViewBuilder
    private func profileInfoDisplay(_ profile: ComprehensiveUserProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            InfoRow(title: "First Name", value: profile.basicInfo.firstName ?? "Not set")
            InfoRow(title: "Last Name", value: profile.basicInfo.lastName ?? "Not set")
            InfoRow(title: "Date of Birth", value: profile.basicInfo.dateOfBirth ?? "Not set")
            InfoRow(title: "Privacy", value: profile.basicInfo.isPrivate ? "Private" : "Public")
            InfoRow(title: "Email Verified", value: profile.verificationStatus.isEmailVerified ? "Yes" : "No")
            InfoRow(title: "Member Since", value: formatDate(profile.timestamps.dateJoined))
        }
    }
    
    @ViewBuilder
    private var profileEditForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("First Name")
                    .font(.subheadline)
                    .fontWeight(.medium)
                TextField("First Name", text: $viewModel.editFirstName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Last Name")
                    .font(.subheadline)
                    .fontWeight(.medium)
                TextField("Last Name", text: $viewModel.editLastName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Bio")
                    .font(.subheadline)
                    .fontWeight(.medium)
                TextField("Tell us about yourself", text: $viewModel.editBio, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Date of Birth")
                    .font(.subheadline)
                    .fontWeight(.medium)
                DatePicker("", selection: $viewModel.editDateOfBirth, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
            }
            
            Toggle("Private Profile", isOn: $viewModel.editIsPrivate)
                .font(.subheadline)
        }
    }
    
    @ViewBuilder
    private func trustedDevices(_ profile: ComprehensiveUserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trusted Devices")
                .font(.headline)
                .fontWeight(.semibold)
            
            if profile.trustedDevices.devices.isEmpty {
                Text("No trusted devices")
                    .foregroundColor(Color("textDefaultColor"))
                    .italic()
            } else {
                ForEach(profile.trustedDevices.devices, id: \.deviceToken) { device in
                    DeviceRow(device: device) {
                        viewModel.deleteTrustedDevice(device.deviceToken)
                    }
                }
            }
        }
        .padding()
        .cornerRadius(16)
    }
    
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading profile...")
                .foregroundColor(Color("textDefaultColor"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(Color("textDefaultColor"))
            
            Text("Profile Not Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Unable to load your profile. Please try again.")
                .foregroundColor(Color("textDefaultColor"))
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                viewModel.loadProfile()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if viewModel.isEditing {
                HStack {
                    Button("Cancel") {
                        viewModel.cancelEditing()
                    }
                    
                    Button("Save") {
                        viewModel.saveProfile()
                    }
                    .disabled(!viewModel.hasUnsavedChanges)
                    .fontWeight(.semibold)
                }
            } else {
                Button("Edit") {
                    viewModel.startEditing()
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        
        return dateString
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
        }
    }
}

struct DeviceRow: View {
    let device: TrustedDevice
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            // Device icon
            Image(systemName: deviceIcon(for: device.deviceType))
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(device.deviceType)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(device.deviceFamily)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let location = device.location {
                    let locationText = formatLocation(location)
                    Text(locationText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Unknown location")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
    
    // MARK: - Helper Methods
    
    private func formatLocation(_ location: DeviceLocation) -> String {
        var parts: [String] = []
        
        // Extraire les valeurs non-nil et non-vides
        if let city = location.city, !city.isEmpty {
            parts.append(city)
        }
        
        if let region = location.region, !region.isEmpty {
            parts.append(region)
        }
        
        if let country = location.country, !country.isEmpty {
            parts.append(country)
        }
        
        // Retourner "Unknown location" si aucune information valide
        if parts.isEmpty {
            return "Unknown location"
        }
        
        // Joindre les parties avec des virgules
        return parts.joined(separator: ", ")
    }
    
    private func deviceIcon(for deviceType: String) -> String {
        let lowercasedType = deviceType.lowercased()
        
        switch lowercasedType {
        case "iphone", "mobile", "smartphone":
            return "iphone"
        case "ipad", "tablet":
            return "ipad"
        case "mac", "macbook", "imac", "macbook pro", "macbook air":
            return "laptopcomputer"
        case "windows", "pc", "desktop", "computer":
            return "desktopcomputer"
        case "linux", "ubuntu", "debian":
            return "terminal"
        case "android":
            return "smartphone"
        case "web", "browser":
            return "globe"
        default:
            return "desktopcomputer"
        }
    }
}

// MARK: - Preview

#Preview("Sample Profile") {
    ProfileView()
        .environmentObject(ProfileViewModel())
}

#Preview("Empty Profile") {
    let viewModel = ProfileViewModel()
    // Simulate empty state
    viewModel.profile = nil
    viewModel.isLoading = false
    
    return ProfileView()
        .environmentObject(viewModel)
}

#Preview("Loading State") {
    let viewModel = ProfileViewModel()
    viewModel.isLoading = true
    viewModel.profile = nil
    
    return ProfileView()
        .environmentObject(viewModel)
}

#Preview("Error State") {
    let viewModel = ProfileViewModel()
    viewModel.errorMessage = "Failed to load profile. Please check your connection and try again."
    
    return ProfileView()
        .environmentObject(viewModel)
}

#Preview("Profile with Data") {
    ProfileView()
        .environmentObject(ProfileViewModel())
}
