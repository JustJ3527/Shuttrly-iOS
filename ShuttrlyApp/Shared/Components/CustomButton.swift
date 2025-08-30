//
//  CustomButton.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 27/08/2025.
//

import SwiftUI

// MARK: - Custom Button Component
// Reusable button component for authentication views

struct CustomButton: View {
    
    // MARK: - Properties
    let title: String
    let action: () -> Void
    let isEnabled: Bool
    let isLoading: Bool
    let style: ButtonStyle
    
    // MARK: - Initializers
    init(
        title: String,
        action: @escaping () -> Void,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        style: ButtonStyle = .primary
    ) {
        self.title = title
        self.action = action
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.style = style
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.textColor))
                        .scaleEffect(0.8)
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(style.textColor)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(style.backgroundColor)
            .cornerRadius(12)
        }
        .disabled(!isEnabled || isLoading)
        .opacity((isEnabled && !isLoading) ? 1.0 : 0.5)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}

// MARK: - Button Styles
extension CustomButton {
    enum ButtonStyle {
        case primary
        case secondary
        case success
        case danger
        case disabled
        
        var backgroundColor: Color {
            switch self {
            case .primary:
                return Color("primaryDefaultColor")
            case .secondary:
                return Color("primaryDefaultColor").opacity(0.1)
            case .success:
                return Color.green
            case .danger:
                return Color.red
            case .disabled:
                return Color.gray.opacity(0.3)
            }
        }
        
        var textColor: Color {
            switch self {
            case .primary, .success, .danger:
                return .white
            case .secondary:
                return Color("primaryDefaultColor")
            case .disabled:
                return Color.gray
            }
        }
    }
}

// MARK: - Convenience Initializers
extension CustomButton {
    /// Primary button (default)
    static func primary(
        title: String,
        action: @escaping () -> Void,
        isEnabled: Bool = true,
        isLoading: Bool = false
    ) -> CustomButton {
        CustomButton(
            title: title,
            action: action,
            isEnabled: isEnabled,
            isLoading: isLoading,
            style: .primary
        )
    }
    
    /// Secondary button
    static func secondary(
        title: String,
        action: @escaping () -> Void,
        isEnabled: Bool = true,
        isLoading: Bool = false
    ) -> CustomButton {
        CustomButton(
            title: title,
            action: action,
            isEnabled: isEnabled,
            isLoading: isLoading,
            style: .secondary
        )
    }
    
    /// Success button
    static func success(
        title: String,
        action: @escaping () -> Void,
        isEnabled: Bool = true,
        isLoading: Bool = false
    ) -> CustomButton {
        CustomButton(
            title: title,
            action: action,
            isEnabled: isEnabled,
            isLoading: isLoading,
            style: .success
        )
    }
    
    /// Danger button
    static func danger(
        title: String,
        action: @escaping () -> Void,
        isEnabled: Bool = true,
        isLoading: Bool = false
    ) -> CustomButton {
        CustomButton(
            title: title,
            action: action,
            isEnabled: isEnabled,
            isLoading: isLoading,
            style: .danger
        )
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        CustomButton.primary(title: "Primary Button", action: {})
        CustomButton.secondary(title: "Secondary Button", action: {})
        CustomButton.success(title: "Success Button", action: {})
        CustomButton.danger(title: "Danger Button", action: {})
        CustomButton.primary(title: "Loading Button", action: {}, isLoading: true)
        CustomButton.primary(title: "Disabled Button", action: {}, isEnabled: false)
    }
    .padding()
    .background(Color("backgroundDefaultColor"))
}

