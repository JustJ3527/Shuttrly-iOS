//
//  ContentView.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 27/08/2025.
//

import SwiftUI

// MARK: - Main Content View
// Manages navigation between authentication and main app features

struct ContentView: View {
    
    // MARK: - Properties
    
    @StateObject private var authService = AuthService()
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                // User is authenticated, show main app
                MainAppView()
                    .environmentObject(authService)
            } else {
                // User is not authenticated, show authentication
                AuthenticationView()
                    .environmentObject(authService)
            }
        }
        .onAppear {
            // Check if user is already authenticated (e.g., from stored tokens)
            authService.checkAuthenticationStatus()
        }
    }
}

// MARK: - Authentication View
// Handles login and registration

struct AuthenticationView: View {
    
    @EnvironmentObject var authService: AuthService
    @State private var showingRegistration = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // App Logo/Title
                VStack(spacing: 16) {
                    Image(systemName: "camera.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(ColorConstants.currentTheme(.light).primary)
                    
                    Text("Shuttrly")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Share your moments")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        // This will trigger the fullScreenCover to show LoginView
                        authService.current2FAStep = .choose2FA
                    }) {
                        Text("Sign In")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(ColorConstants.currentTheme(.light).primary)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        showingRegistration = true
                    }) {
                        Text("Create Account")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(ColorConstants.currentTheme(.light).primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(ColorConstants.currentTheme(.light).primary, lineWidth: 2)
                            )
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 60)
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingRegistration) {
            // TODO: Show registration flow
            Text("Registration coming soon...")
        }
        .fullScreenCover(isPresented: .constant(authService.current2FAStep != .credentials)) {
            // Show 2FA or login flow
            LoginView()
                .environmentObject(authService)
        }
    }
}

// MARK: - Main App View
// Main app interface after authentication

struct MainAppView: View {
    
    @EnvironmentObject var authService: AuthService
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
                .tag(0)
            
            // Photos Tab (placeholder)
            VStack {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                Text("Photos")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Coming soon...")
                    .foregroundColor(.secondary)
            }
            .tabItem {
                Image(systemName: "photo.on.rectangle")
                Text("Photos")
            }
            .tag(1)
            
            // Collections Tab (placeholder)
            VStack {
                Image(systemName: "folder")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                Text("Collections")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Coming soon...")
                    .foregroundColor(.secondary)
            }
            .tabItem {
                Image(systemName: "folder")
                Text("Collections")
            }
            .tag(2)
            
            // Settings Tab
            VStack {
                Image(systemName: "gearshape")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Button("Sign Out") {
                    authService.logout()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .padding()
            }
            .tabItem {
                Image(systemName: "gearshape")
                Text("Settings")
            }
            .tag(3)
        }
        .accentColor(ColorConstants.currentTheme(.light).primary)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(AuthService())
}
