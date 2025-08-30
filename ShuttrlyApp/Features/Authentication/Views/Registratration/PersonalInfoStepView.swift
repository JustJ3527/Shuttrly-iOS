//
//  PersonalInfoStepView.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - Personal Info Step View
// Step 3: Personal information input

struct PersonalInfoStepView: View {
    
    // MARK: - Properties
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var dateOfBirth: Date
    let onSubmit: () -> Void
    let onBack: () -> Void
    
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
                    Text("Tell Us About Yourself")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(Color("textDefaultColor"))
                        .multilineTextAlignment(.center)
                    
                    Text("Help us personalize your experience")
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
                // First Name Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("First Name")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("textDefaultColor"))
                    
                    TextField("Enter your first name", text: $firstName)
                        .textFieldStyle(CustomTextFieldStyle())
                        .textContentType(.givenName)
                        .autocapitalization(.words)
                        .autocorrectionDisabled()
                }
                
                // Last Name Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Last Name")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("textDefaultColor"))
                    
                    TextField("Enter your last name", text: $lastName)
                        .textFieldStyle(CustomTextFieldStyle())
                        .textContentType(.familyName)
                        .autocapitalization(.words)
                        .autocorrectionDisabled()
                }
                
                // Date of Birth Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Date of Birth")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("textDefaultColor"))
                    
                    DatePicker("", selection: $dateOfBirth, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color("backgroundDefaultColor"))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("primaryDefaultColor").opacity(0.3), lineWidth: 1)
                        )
                }
                
                // Submit Button
                CustomButton.primary(
                    title: "Continue",
                    action: onSubmit,
                    isEnabled: isFormValid
                )
                .padding(.top, 16)
                
                // Help text
                VStack(spacing: 8) {
                    Text("You must be at least 16 years old to create an account")
                        .font(.system(size: 14))
                        .foregroundColor(Color("textDefaultColor").opacity(0.6))
                        .multilineTextAlignment(.center)
                    
                    Text("Your information is kept private and secure")
                        .font(.system(size: 12))
                        .foregroundColor(Color("textDefaultColor").opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 16)
                
                Spacer(minLength: 0) // Push content to fill available space
            }
            .padding(.horizontal, 32)
        }
        .appBackground()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    onBack()
                }
                .foregroundColor(Color("primaryDefaultColor"))
            }
        }
    }
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
        let sixteenYearsAgo = Calendar.current.date(byAdding: .year, value: -16, to: Date()) ?? Date()
        return !firstName.isEmpty && !lastName.isEmpty && dateOfBirth <= sixteenYearsAgo
    }
}

// MARK: - Custom Text Field Style
struct PersonalInfoTextFieldStyle: TextFieldStyle {
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
    PersonalInfoStepView(
        firstName: .constant("John"),
        lastName: .constant("Doe"),
        dateOfBirth: .constant(Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()),
        onSubmit: {},
        onBack: {}
    )
    .background(Color("backgroundDefaultColor"))
}
