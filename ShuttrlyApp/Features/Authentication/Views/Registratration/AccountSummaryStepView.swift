//
//  AccountSummaryStepView.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - Account Summary Step View
// Step 6: Account summary and final confirmation

struct AccountSummaryStepView: View {
    
    // MARK: - Properties
    let email: String
    let firstName: String
    let lastName: String
    let dateOfBirth: Date
    let username: String
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
                    Text("Review Your Information")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(Color("textDefaultColor"))
                        .multilineTextAlignment(.center)
                    
                    Text("Please review your information before creating your account")
                        .font(.system(size: 16))
                        .foregroundColor(Color("textDefaultColor").opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
            .padding(.top, 60)
            
            // Summary content
            ScrollView {
                VStack(spacing: 24) {
                    // Personal Information Section
                    SummarySection(
                        title: "Personal Information",
                        items: [
                            SummaryItem(label: "First Name", value: firstName),
                            SummaryItem(label: "Last Name", value: lastName),
                            SummaryItem(label: "Date of Birth", value: formatDate(dateOfBirth))
                        ]
                    )
                    
                    // Account Information Section
                    SummarySection(
                        title: "Account Information",
                        items: [
                            SummaryItem(label: "Email", value: email),
                            SummaryItem(label: "Username", value: username)
                        ]
                    )
                    
                    // Security Note
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 16))
                            
                            Text("Security & Privacy")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color("textDefaultColor"))
                        }
                        
                        Text("Your password is encrypted and your personal information is protected according to our privacy policy.")
                            .font(.system(size: 14))
                            .foregroundColor(Color("textDefaultColor").opacity(0.7))
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color("backgroundDefaultColor").opacity(0.5))
                    .cornerRadius(12)
                    
                    // Submit Button
                    CustomButton.primary(
                        title: "Create My Account",
                        action: onSubmit
                    )
                    .padding(.top, 16)
                    
                    // Help text
                    VStack(spacing: 8) {
                        Text("By creating your account, you agree to our Terms of Service and Privacy Policy")
                            .font(.system(size: 12))
                            .foregroundColor(Color("textDefaultColor").opacity(0.5))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 16)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
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
    
    // MARK: - Helper Methods
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Summary Section
struct SummarySection: View {
    let title: String
    let items: [SummaryItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color("textDefaultColor"))
            
            VStack(spacing: 12) {
                ForEach(items, id: \.label) { item in
                    SummaryItemRow(item: item)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color("backgroundDefaultColor").opacity(0.5))
        .cornerRadius(12)
    }
}

// MARK: - Summary Item
struct SummaryItem {
    let label: String
    let value: String
}

// MARK: - Summary Item Row
struct SummaryItemRow: View {
    let item: SummaryItem
    
    var body: some View {
        HStack {
            Text(item.label)
                .font(.system(size: 14))
                .foregroundColor(Color("textDefaultColor").opacity(0.7))
                .frame(width: 100, alignment: .leading)
            
            Spacer()
            
            Text(item.value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color("textDefaultColor"))
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Preview
#Preview {
    AccountSummaryStepView(
        email: "john.doe@example.com",
        firstName: "John",
        lastName: "Doe",
        dateOfBirth: Date(),
        username: "johndoe",
        onSubmit: {},
        onBack: {}
    )
    .background(Color("backgroundDefaultColor"))
}
