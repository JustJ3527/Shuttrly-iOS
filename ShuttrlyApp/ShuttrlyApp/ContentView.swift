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
    @StateObject private var registrationService = RegistrationService()
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                // User is authenticated, show main app
                MainAppView()
                    .environmentObject(authService)
            } else if registrationService.shouldRedirectToProfile {
                // Registration completed, redirect to profile
                ProfileView()
                    .environmentObject(authService)
                    .onAppear {
                        // Reset registration service after redirecting
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            registrationService.resetRegistration()
                        }
                    }
            } else {
                // User is not authenticated, show authentication
                AuthenticationView()
                    .environmentObject(authService)
                    .environmentObject(registrationService)
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
    @State private var showingLogin = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // App Logo/Title
                VStack(spacing: 0) {
                    Image("logoShuttrlyFit")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250)
                        
                    
                    Text("Share your moments")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 120)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    CustomButton.primary(
                        title: "Sign In",
                        action: {
                            showingLogin = true
                        }
                    )
                    
                    CustomButton.secondary(
                        title: "Create Account",
                        action: {
                            showingRegistration = true
                        }
                    )
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 60)
            }
            .appBackground()
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: .constant(showingLogin || showingRegistration)) {
            // Show authentication flow with NavigationStack
            NavigationStack {
                Group {
                    if showingLogin {
                        LoginView(
                            onSwitchToRegistration: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showingLogin = false
                                    showingRegistration = true
                                }
                            }
                        )
                        .environmentObject(authService)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                    } else if showingRegistration {
                        RegistrationView(
                            onSwitchToLogin: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showingRegistration = false
                                    showingLogin = true
                                }
                            }
                        )
                        .environmentObject(RegistrationService())
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: showingLogin)
                .animation(.easeInOut(duration: 0.3), value: showingRegistration)
            }
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
            .appBackground()
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
        .accentColor(Color("primaryDefaultColor"))
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(AuthService())
}
