//
//  UsernameStepView.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI
import Combine

// MARK: - Username Step View
// Step 4: Username selection with real-time validation

struct UsernameStepView: View {
    
    // MARK: - Properties
    @Binding var username: String
    @Binding var isChecking: Bool
    @Binding var isAvailable: Bool
    @Binding var validationMessage: String
    let onSubmit: () -> Void
    let onContinue: () -> Void
    let onBack: () -> Void
    
    // MARK: - Animation State
    @State private var checkingText: String = "Checking username availability..."
    @State private var isCheckingTextAnimating: Bool = false
    @State private var debounceTimer: Timer?
    @State private var lastCheckedUsername: String = ""
    
    // MARK: - Computed Properties
    private var isUsernameValid: Bool {
        return username.count >= 3 && username.count <= 30
    }
    
    private var usernameValidationError: String? {
        if username.isEmpty { return nil }
        if username.count < 3 { return "Username must be at least 3 characters long" }
        if username.count > 30 { return "Username must be 30 characters or less" }
        
        // Check for invalid characters
        let allowedCharacters = CharacterSet.letters.union(.decimalDigits).union(CharacterSet(charactersIn: "_"))
        let usernameCharacterSet = CharacterSet(charactersIn: username)
        if !usernameCharacterSet.isSubset(of: allowedCharacters) {
            return "Username can only contain letters, numbers, and underscores"
        }
        
        // Check if starts with number or underscore
        if username.first?.isNumber == true || username.first == "_" {
            return "Username cannot start with numbers or underscores"
        }
        
        // Check if ends with underscore
        if username.last == "_" {
            return "Username cannot end with underscores"
        }
        
        return nil
    }
    
    private var canSubmit: Bool {
        return isUsernameValid && usernameValidationError == nil && !isChecking
    }
    
    private var canContinue: Bool {
        return isAvailable && !isChecking
    }
    

    
    private var isButtonEnabled: Bool {
        // Button is enabled only when username is available and not being checked
        return isAvailable && !isChecking
    }
    
    // MARK: - Username Validation with Debouncing
    private func handleUsernameChange(_ newValue: String) {
        // Convert to lowercase and remove spaces
        let cleanedUsername = newValue.lowercased().replacingOccurrences(of: " ", with: "")
        username = cleanedUsername
        
        // Cancel previous timer
        debounceTimer?.invalidate()
        
        // Reset validation state for short usernames
        if cleanedUsername.count < 3 {
            isAvailable = false
            validationMessage = ""
            return
        }
        
        // Only check if username is different from last checked
        if cleanedUsername == lastCheckedUsername {
            return
        }
        
        // Debounce the API call
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            // Only validate if username hasn't changed during the delay
            if username == cleanedUsername {
                lastCheckedUsername = cleanedUsername
                onSubmit()
            }
        }
    }
    
    // MARK: - Checking Text Update with Enhanced Animation
    private func updateCheckingText() {
        // Always animate for better visibility
        isCheckingTextAnimating = true
        
        // Add a small delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.4)) {
                checkingText = "Checking username availability..."
            }
            
            // Keep animation active for longer with pulsing effect
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isCheckingTextAnimating = false
                }
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 24) {
                // Logo
                Image("logoShuttrlyFit")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                
                // Title and subtitle
                VStack(spacing: 8) {
                    Text("Choose Your Username")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(Color("textDefaultColor"))
                        .multilineTextAlignment(.center)
                    
                    Text("This will be your unique identifier")
                        .font(.system(size: 16))
                        .foregroundColor(Color("textDefaultColor").opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
            .padding(.top, 60)
            
            // Form content
            VStack(spacing: 24) {
                // Username Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Username")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("textDefaultColor"))
                    
                    TextField("Enter your username", text: $username)
                        .textFieldStyle(CustomTextFieldStyle())
                        .textContentType(.username)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .onChange(of: username) { newValue in
                            handleUsernameChange(newValue)
                        }
                }
                
                // Username Validation Status with Enhanced Animations
                if !username.isEmpty {
                    VStack(spacing: 8) {
                        // Validation errors (priority over availability)
                        if let errorMessage = usernameValidationError {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .scaleEffect(isCheckingTextAnimating ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 0.3), value: isCheckingTextAnimating)
                                
                                Text(errorMessage)
                                    .font(.system(size: 14))
                                    .foregroundColor(.orange)
                            }
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                        }
                        // Availability status (only show if no validation errors)
                        else if isChecking {
                            HStack(spacing: 12) {
                                // Enhanced spinner with pulsing effect
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color("primaryDefaultColor")))
                                    .scaleEffect(isCheckingTextAnimating ? 1.3 : 0.7)
                                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isCheckingTextAnimating)
                                
                                // Enhanced checking text with typewriter effect
                                Text(checkingText)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color("primaryDefaultColor"))
                                    .scaleEffect(isCheckingTextAnimating ? 1.05 : 1.0)
                                    .opacity(isCheckingTextAnimating ? 1.0 : 0.7)
                                    .animation(.easeInOut(duration: 0.4), value: isCheckingTextAnimating)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("primaryDefaultColor").opacity(0.15))
                                    .scaleEffect(isCheckingTextAnimating ? 1.02 : 1.0)
                                    .animation(.easeInOut(duration: 0.4), value: isCheckingTextAnimating)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color("primaryDefaultColor").opacity(0.3), lineWidth: 1)
                                    .scaleEffect(isCheckingTextAnimating ? 1.01 : 1.0)
                                    .animation(.easeInOut(duration: 0.4), value: isCheckingTextAnimating)
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                        } else if isAvailable {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .scaleEffect(isCheckingTextAnimating ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 0.3), value: isCheckingTextAnimating)
                                
                                Text("Username is available!")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.green)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.green.opacity(0.1))
                            )
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                        } else if !validationMessage.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .scaleEffect(isCheckingTextAnimating ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 0.3), value: isCheckingTextAnimating)
                                
                                Text(validationMessage)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.red)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.red.opacity(0.1))
                            )
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                        }
                    }
                    .frame(
                        minWidth: 100,
                        maxWidth: .infinity,
                        minHeight: 20,
                        maxHeight: 20
                    )
                    .padding(.top, 8)
                    .animation(.easeInOut(duration: 0.3), value: isChecking)
                    .animation(.easeInOut(duration: 0.3), value: isAvailable)
                    .animation(.easeInOut(duration: 0.3), value: validationMessage)
                }
                
                // Submit Button - Always shows "Continue"
                CustomButton.primary(
                    title: "Continue",
                    action: onContinue,
                    isEnabled: isButtonEnabled,
                    isLoading: isChecking
                )
                .padding(.top, 16)
                
                // Push content to top instead of center
                Spacer()
            }
            .padding(.horizontal, 32)
        }
        .appBackground()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .onChange(of: isChecking) { newValue in
            if newValue {
                updateCheckingText()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    onBack()
                }
                .foregroundColor(Color("primaryDefaultColor"))
            }
        }
        .onDisappear {
            // Clean up timer when view disappears
            debounceTimer?.invalidate()
        }
    }
}

// MARK: - Custom Text Field Style
struct UsernameTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color("backgroundDefaultColor"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("primaryDefaultColor").opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Preview
#Preview {
    UsernameStepView(
        username: .constant("johndoe"),
        isChecking: .constant(false),
        isAvailable: .constant(true),
        validationMessage: .constant("Username is available!"),
        onSubmit: {},
        onContinue: {},
        onBack: {}
    )
    .background(Color("backgroundDefaultColor"))
}
