//
//  TwoFATestView.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - 2FA Test View
// Test harness for the new modular 2FA system

struct TwoFATestView: View {
    
    // MARK: - Properties
    
    @State private var showLogin = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("2FA System Test")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Test the new modular 2FA authentication system")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)
                
                // Test Button
                Button("Test 2FA Login") {
                    showLogin = true
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .padding(.horizontal, 40)
                
                // Information
                VStack(spacing: 16) {
                    Text("What's New:")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        FeatureRow(icon: "checkmark.circle.fill", text: "Independent step management")
                        FeatureRow(icon: "checkmark.circle.fill", text: "Direct API communication")
                        FeatureRow(icon: "checkmark.circle.fill", text: "Clean navigation flow")
                        FeatureRow(icon: "checkmark.circle.fill", text: "No more state conflicts")
                        FeatureRow(icon: "checkmark.circle.fill", text: "Better error handling")
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showLogin) {
            TwoFACoordinatorView()
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .font(.title3)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    TwoFATestView()
}
