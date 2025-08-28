//
//  LoginView.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - Login View
// Multi-step login with native Apple navigation

struct LoginView: View {
    
    // MARK: - Properties
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authService: AuthService
    
    // Navigation state for multi-step login
    @State private var navigationPath = NavigationPath()
    @State private var currentStep: TwoFAStep = .credentials
    
    // Form data
    @State private var identifier = ""
    @State private var password = ""
    @State private var rememberDevice = false
    @State private var twoFAMethod: TwoFAMethod = .email
    @State private var twoFACode = ""
    
    // MARK: - Body
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                // Header
                loginHeader
                
                // Main content based on current step
                mainContent
                
                Spacer()
            }
            .appBackground()
            .navigationDestination(for: TwoFAStep.self) { step in
                switch step {
                case .credentials:
                    credentialsStepView
                case .choose2FA:
                    choose2FAStepView
                case .email2FA:
                    email2FAStepView
                case .totp2FA:
                    totp2FAStepView
                case .complete:
                    loginCompleteView
                }
            }
        }
        .onAppear {
            // Reset to credentials step when view appears
            currentStep = .credentials
        }
        .onReceive(authService.$requires2FA) { requires2FA in
            if requires2FA {
                            if authService.available2FAMethods.count > 1 {
                currentStep = .choose2FA
                navigationPath.append(TwoFAStep.choose2FA)
            } else if let method = authService.available2FAMethods.first {
                if method == "email" {
                    currentStep = .email2FA
                    navigationPath.append(TwoFAStep.email2FA)
                } else if method == "totp" {
                    currentStep = .totp2FA
                    navigationPath.append(TwoFAStep.totp2FA)
                }
            }
            }
        }
        .onReceive(authService.$isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                currentStep = .complete
                navigationPath.append(TwoFAStep.complete)
            }
        }
    }
    
    // MARK: - Header
    private var loginHeader: some View {
        VStack(spacing: 24) {
            // Logo
            Image("logoShuttrlyFit")
                .resizable()
                .scaledToFit()
                .frame(width: 250)
            
            // Welcome text
            Text("Welcome back!")
                .font(.system(size: 40, weight: .bold, design: .serif))
                .foregroundColor(Color("textDefaultColor"))
            
            Text("Sign in to your account")
                .font(.system(size: 18))
                .foregroundColor(Color("textDefaultColor"))
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 48)
        .padding(.top, 120)
    }
    
    // MARK: - Main Content
    @ViewBuilder
    private var mainContent: some View {
        switch currentStep {
        case .credentials:
            credentialsStepView
        case .choose2FA:
            choose2FAStepView
        case .email2FA:
            email2FAStepView
        case .totp2FA:
            totp2FAStepView
        case .complete:
            loginCompleteView
        }
    }
    
    // MARK: - Credentials Step
    private var credentialsStepView: some View {
        VStack(spacing: 32) {
            // Form fields
            VStack(spacing: 24) {
                // Email/Username field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email or Username")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("textDefaultColor"))
                    
                    TextField("Enter your email or username", text: $identifier)
                        .textFieldStyle(ShuttrlyTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .frame(height: 44)
                        .frame(maxWidth: .infinity)
                }
                
                // Password field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("textDefaultColor"))
                    
                    SecureField("Enter your password", text: $password)
                        .textFieldStyle(ShuttrlyTextFieldStyle())
                }
                
                // Remember device toggle
                Toggle("Remember this device", isOn: $rememberDevice)
                    .font(.system(size: 14))
                    .foregroundColor(Color("textDefaultColor"))
                    .tint(Color("primaryDefaultColor"))
            }
            
            // Login button
            Button(action: handleCredentialsSubmit) {
                HStack {
                                    if authService.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text("Sign In")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .font(.system(size: 16, weight: .semibold))
                }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color("primaryDefaultColor"))
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(authService.isLoading || identifier.isEmpty || password.isEmpty)
            .opacity((identifier.isEmpty || password.isEmpty) ? 0.6 : 1.0)
            
            // Error message
            if let errorMessage = authService.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            // Forgot password link
            Button("Forgot password?") {
                // TODO: Navigate to forgot password
            }
            .font(.system(size: 14))
            .foregroundColor(Color("primaryDefaultColor"))
            .padding(.top, 16)
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Choose 2FA Step
    private var choose2FAStepView: some View {
        VStack(spacing: 32) {
            Text("Two-Factor Authentication")
                .font(.system(size: 30, weight: .bold, design: .serif))
                .multilineTextAlignment(.center)
            
            Text("Choose your preferred 2FA method")
                .font(.system(size: 18))
                .foregroundColor(Color("textDefaultColor"))
                .multilineTextAlignment(.center)
            
            VStack(spacing: 24) {
                // Email 2FA option
                Button(action: { select2FAMethod(.email) }) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(Color("primaryDefaultColor"))
                        Text("Email Verification")
                            .font(.system(size: 16, weight: .medium))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color("textDefaultColor"))
                    }
                    .padding(24)
                    .background(Color("backgroundDefaultColor"))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("primaryDefaultColor"), lineWidth: 1)
                    )
                }
                .foregroundColor(Color("textDefaultColor"))
                
                // TOTP 2FA option
                Button(action: { select2FAMethod(.totp) }) {
                    HStack {
                        Image(systemName: "key.fill")
                            .foregroundColor(Color("primaryDefaultColor"))
                        Text("Authenticator App")
                            .font(.system(size: 16, weight: .medium))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color("textDefaultColor"))
                    }
                    .padding(24)
                    .background(Color("backgroundDefaultColor"))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("primaryDefaultColor"), lineWidth: 1)
                    )
                }
                .foregroundColor(Color("textDefaultColor"))
            }
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Email 2FA Step
    private var email2FAStepView: some View {
        VStack(spacing: 32) {
            Text("Email Verification")
                .font(.system(size: 30, weight: .bold, design: .serif))
                .foregroundColor(Color("textDefaultColor"))
                .multilineTextAlignment(.center)
            
            Text("Enter the 6-digit code sent to your email")
                .font(.system(size: 18))
                .foregroundColor(Color("textDefaultColor"))
                .multilineTextAlignment(.center)
            
            // 2FA Code field
            VStack(alignment: .leading, spacing: 8) {
                Text("Verification Code")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("textDefaultColor"))
                
                TextField("Enter 6-digit code", text: $twoFACode)
                    .textFieldStyle(ShuttrlyTextFieldStyle())
                    .keyboardType(.numberPad)
                    .onChange(of: twoFACode) { newValue in
                        // Limit to 6 digits
                        if newValue.count > 6 {
                            twoFACode = String(newValue.prefix(6))
                        }
                    }
            }
            
            // Verify button
            Button(action: handle2FASubmit) {
                HStack {
                    if authService.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Verify Code")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color("primaryDefaultColor"))
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(authService.isLoading || twoFACode.count != 6)
            .opacity(twoFACode.count != 6 ? 0.6 : 1.0)
            
            // Resend code button
            Button("Resend Code") {
                handleResendCode()
            }
            .font(.system(size: 14))
            .foregroundColor(Color("primaryDefaultColor"))
            .padding(.top, 16)
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - TOTP 2FA Step
    private var totp2FAStepView: some View {
        VStack(spacing: 32) {
            Text("Authenticator App")
                .font(.system(size: 30, weight: .bold, design: .serif))
                .foregroundColor(Color("textDefaultColor"))
                .multilineTextAlignment(.center)
            
            Text("Enter the 6-digit code from your authenticator app")
                .font(.system(size: 18))
                .foregroundColor(Color("textDefaultColor"))
                .multilineTextAlignment(.center)
            
            // TOTP Code field
            VStack(alignment: .leading, spacing: 8) {
                Text("TOTP Code")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("textDefaultColor"))
                
                TextField("Enter 6-digit code", text: $twoFACode)
                    .textFieldStyle(ShuttrlyTextFieldStyle())
                    .keyboardType(.numberPad)
                    .onChange(of: twoFACode) { newValue in
                        // Limit to 6 digits
                        if newValue.count > 6 {
                            twoFACode = String(newValue.prefix(6))
                        }
                    }
            }
            
            // Verify button
            Button(action: handle2FASubmit) {
                HStack {
                    if authService.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Verify Code")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color("primaryDefaultColor"))
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(authService.isLoading || twoFACode.count != 6)
            .opacity(twoFACode.count != 6 ? 0.6 : 1.0)
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Login Complete Step
    private var loginCompleteView: some View {
        VStack(spacing: 32) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Welcome back!")
                .font(.system(size: 40, weight: .bold, design: .serif))
                .foregroundColor(Color("textDefaultColor"))
                .multilineTextAlignment(.center)
            
            Text("You have successfully signed in to your account")
                .font(.system(size: 18))
                .foregroundColor(Color("textDefaultColor"))
                .multilineTextAlignment(.center)
            
            // Continue button
            Button("Continue to App") {
                // Close the fullScreenCover and return to ContentView
                // ContentView will automatically show MainAppView since user is authenticated
                authService.current2FAStep = .credentials
            }
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color("primaryDefaultColor"))
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Actions
    private func handleCredentialsSubmit() {
        // Clear previous messages
        authService.errorMessage = nil
        
        // Call login method directly with credentials
        authService.loginStep1(identifier: identifier, password: password, rememberDevice: rememberDevice)
        
        // The response will be handled by the service and will update the published properties
        // We'll observe these changes to navigate accordingly
    }
    
    private func select2FAMethod(_ method: TwoFAMethod) {
        twoFAMethod = method
        authService.loginStep2Choose2FA(method: method.rawValue)
        
        if method == .email {
            currentStep = .email2FA
            navigationPath.append(TwoFAStep.email2FA)
        } else if method == .totp {
            currentStep = .totp2FA
            navigationPath.append(TwoFAStep.totp2FA)
        }
    }
    
    private func handle2FASubmit() {
        // Clear previous error messages
        authService.errorMessage = nil
        
        if twoFAMethod == .email {
            authService.loginStep3Email2FA(code: twoFACode)
        } else if twoFAMethod == .totp {
            authService.loginStep3TOTP2FA(code: twoFACode)
        }
        
        // The response will be handled by the service and will update the published properties
        // We'll observe these changes to navigate accordingly
    }
    
    private func handleResendCode() {
        // Clear previous error messages
        authService.errorMessage = nil
        
        // Call the resend 2FA code method
        authService.resend2FACode()
    }
}

// MARK: - Supporting Types
enum TwoFAMethod: String, CaseIterable {
    case email = "email"
    case totp = "totp"
}

// MARK: - Custom Text Field Style
struct ShuttrlyTextFieldStyle: TextFieldStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color("backgroundDefaultColor"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("primaryDefaultColor"), lineWidth: 1)
            )
            .foregroundColor(Color("textDefaultColor"))
            .frame(height: 50)
            .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
#Preview {
    LoginView()
        .environmentObject(AuthService())
}
