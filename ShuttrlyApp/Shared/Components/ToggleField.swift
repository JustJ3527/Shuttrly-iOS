//
//  ToggleField.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 30/08/2025.
//

import SwiftUI

// MARK: - Toggle Field Component
// Reusable toggle component for authentication and settings views

struct ToggleField: View {
    
    // MARK: - Properties
    let title: String
    let subtitle: String?
    let icon: String?
    @Binding var isOn: Bool
    let onToggle: ((Bool) -> Void)?
    
    // MARK: - Initializers
    init(
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        isOn: Binding<Bool>,
        onToggle: ((Bool) -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self._isOn = isOn
        self.onToggle = onToggle
    }
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 16) {
            // Icon (optional)
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color("primaryDefaultColor"))
                    .frame(width: 24, height: 24)
            }
            
            // Text content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("textDefaultColor"))
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(Color("textDefaultColor").opacity(0.7))
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Toggle
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color("primaryDefaultColor"))
                .onChange(of: isOn) { newValue in
                    onToggle?(newValue)
                }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("backgroundDefaultColor"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("textDefaultColor").opacity(0.1), lineWidth: 1)
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isOn)
    }
}

// MARK: - Convenience Initializers
extension ToggleField {
    /// Simple toggle with just title
    static func simple(
        title: String,
        isOn: Binding<Bool>,
        onToggle: ((Bool) -> Void)? = nil
    ) -> ToggleField {
        ToggleField(
            title: title,
            isOn: isOn,
            onToggle: onToggle
        )
    }
    
    /// Toggle with subtitle for additional context
    static func withSubtitle(
        title: String,
        subtitle: String,
        isOn: Binding<Bool>,
        onToggle: ((Bool) -> Void)? = nil
    ) -> ToggleField {
        ToggleField(
            title: title,
            subtitle: subtitle,
            isOn: isOn,
            onToggle: onToggle
        )
    }
    
    /// Toggle with icon for visual enhancement
    static func withIcon(
        title: String,
        icon: String,
        isOn: Binding<Bool>,
        onToggle: ((Bool) -> Void)? = nil
    ) -> ToggleField {
        ToggleField(
            title: title,
            icon: icon,
            isOn: isOn,
            onToggle: onToggle
        )
    }
    
    /// Full featured toggle with icon and subtitle
    static func full(
        title: String,
        subtitle: String,
        icon: String,
        isOn: Binding<Bool>,
        onToggle: ((Bool) -> Void)? = nil
    ) -> ToggleField {
        ToggleField(
            title: title,
            subtitle: subtitle,
            icon: icon,
            isOn: isOn,
            onToggle: onToggle
        )
    }
}

// MARK: - Alternative Subtle Toggle Style
extension ToggleField {
    /// Subtle toggle that reveals the toggle control on interaction
    static func subtle(
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        isOn: Binding<Bool>,
        onToggle: ((Bool) -> Void)? = nil
    ) -> SubtleToggleField {
        SubtleToggleField(
            title: title,
            subtitle: subtitle,
            icon: icon,
            isOn: isOn,
            onToggle: onToggle
        )
    }
}

// MARK: - Subtle Toggle Field
struct SubtleToggleField: View {
    
    // MARK: - Properties
    let title: String
    let subtitle: String?
    let icon: String?
    @Binding var isOn: Bool
    let onToggle: ((Bool) -> Void)?
    
    // State for subtle interaction
    @State private var isHovered = false
    @State private var showToggle = false
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 16) {
            // Icon (optional)
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color("primaryDefaultColor"))
                    .frame(width: 24, height: 24)
            }
            
            // Text content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("textDefaultColor"))
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(Color("textDefaultColor").opacity(0.7))
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Subtle toggle indicator
            HStack(spacing: 8) {
                // Status indicator
                Circle()
                    .fill(isOn ? Color("primaryDefaultColor") : Color("textDefaultColor").opacity(0.3))
                    .frame(width: 8, height: 8)
                    .scaleEffect(showToggle ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: showToggle)
                
                // Toggle control (appears on interaction)
                if showToggle {
                    Toggle("", isOn: $isOn)
                        .labelsHidden()
                        .tint(Color("primaryDefaultColor"))
                        .onChange(of: isOn) { newValue in
                            onToggle?(newValue)
                        }
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("backgroundDefaultColor"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            showToggle ? Color("primaryDefaultColor").opacity(0.3) : Color("textDefaultColor").opacity(0.1),
                            lineWidth: showToggle ? 2 : 1
                        )
                )
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                showToggle.toggle()
            }
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .onAppear {
            // Show toggle briefly on appear for visual feedback
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showToggle = true
                }
                // Hide after a moment
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showToggle = false
                    }
                }
            }
        }
    }
}

// MARK: - Button Style Toggle
extension ToggleField {
    /// Button-style toggle that looks like a modern button
    static func button(
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        isOn: Binding<Bool>,
        onToggle: ((Bool) -> Void)? = nil
    ) -> ButtonToggleField {
        ButtonToggleField(
            title: title,
            subtitle: subtitle,
            icon: icon,
            isOn: isOn,
            onToggle: onToggle
        )
    }
}

// MARK: - Button Toggle Field
struct ButtonToggleField: View {
    
    // MARK: - Properties
    let title: String
    let subtitle: String?
    let icon: String?
    @Binding var isOn: Bool
    let onToggle: ((Bool) -> Void)?
    
    // State for button interaction
    @State private var isPressed = false
    
    // MARK: - Body
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                isOn.toggle()
                onToggle?(isOn)
            }
        }) {
            HStack(spacing: 16) {
                // Icon (optional)
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isOn ? .white : Color("primaryDefaultColor"))
                        .frame(width: 24, height: 24)
                }
                
                // Text content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isOn ? .white : Color("textDefaultColor"))
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 14))
                            .foregroundColor(isOn ? .white.opacity(0.9) : Color("textDefaultColor").opacity(0.7))
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                // Toggle indicator
                HStack(spacing: 8) {
                    // Status text
                    Text(isOn ? "ON" : "OFF")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(isOn ? .white.opacity(0.9) : Color("textDefaultColor").opacity(0.6))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(isOn ? .white.opacity(0.2) : Color("textDefaultColor").opacity(0.1))
                        )
                    
                    // Toggle switch
                    ZStack {
                        // Background track
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isOn ? .white.opacity(0.3) : Color("textDefaultColor").opacity(0.2))
                            .frame(width: 44, height: 24)
                        
                        // Toggle thumb
                        Circle()
                            .fill(.white)
                            .frame(width: 20, height: 20)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            .offset(x: isOn ? 10 : -10)
                            .animation(.easeInOut(duration: 0.2), value: isOn)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isOn 
                        ? LinearGradient(
                            colors: [Color("primaryDefaultColor"), Color("primaryDefaultColor").opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [Color("backgroundDefaultColor"), Color("backgroundDefaultColor")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isOn ? Color("primaryDefaultColor").opacity(0.3) : Color("textDefaultColor").opacity(0.1),
                                lineWidth: isOn ? 2 : 1
                            )
                    )
                    .shadow(
                        color: isOn ? Color("primaryDefaultColor").opacity(0.3) : .clear,
                        radius: isOn ? 8 : 0,
                        x: 0,
                        y: isOn ? 4 : 0
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Checkbox Button Style Toggle
extension ToggleField {
    /// Checkbox button style that looks like interactive text with checkbox
    static func checkbox(
        title: String,
        isOn: Binding<Bool>,
        onToggle: ((Bool) -> Void)? = nil
    ) -> CheckboxToggleField {
        CheckboxToggleField(
            title: title,
            isOn: isOn,
            onToggle: onToggle
        )
    }
    
    /// Checkbox button with icon
    static func checkboxWithIcon(
        title: String,
        icon: String,
        isOn: Binding<Bool>,
        onToggle: ((Bool) -> Void)? = nil
    ) -> CheckboxToggleField {
        CheckboxToggleField(
            title: title,
            icon: icon,
            isOn: isOn,
            onToggle: onToggle
        )
    }
}

// MARK: - Checkbox Toggle Field
struct CheckboxToggleField: View {
    
    // MARK: - Properties
    let title: String
    let icon: String?
    @Binding var isOn: Bool
    let onToggle: ((Bool) -> Void)?
    
    // State for button interaction
    @State private var isPressed = false
    @State private var isHovered = false
    
    // MARK: - Initializers
    init(
        title: String,
        icon: String? = nil,
        isOn: Binding<Bool>,
        onToggle: ((Bool) -> Void)? = nil
    ) {
        self.title = title
        self.icon = icon
        self._isOn = isOn
        self.onToggle = onToggle
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isOn.toggle()
                onToggle?(isOn)
            }
        }) {
            HStack(spacing: 12) {
                // Checkbox
                ZStack {
                    // Checkbox background
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isOn ? Color("primaryDefaultColor") : Color("textDefaultColor").opacity(0.1))
                        .frame(width: 20, height: 20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(
                                    isOn ? Color("primaryDefaultColor") : Color("textDefaultColor").opacity(0.3),
                                    lineWidth: 2
                                )
                        )
                    
                    // Checkmark
                    if isOn {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .scaleEffect(isOn ? 1.0 : 0.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isOn)
                    }
                }
                
                // Icon (optional)
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isOn ? Color("primaryDefaultColor") : Color("textDefaultColor").opacity(0.7))
                        .frame(width: 20, height: 20)
                }
                
                // Title text
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isOn ? Color("primaryDefaultColor") : Color("textDefaultColor"))
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isOn 
                        ? Color("primaryDefaultColor").opacity(0.1)
                        : (isHovered ? Color("textDefaultColor").opacity(0.05) : Color.clear)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isOn ? Color("primaryDefaultColor").opacity(0.3) : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 20) {
            ToggleField.simple(
                title: "Remember this device",
                isOn: .constant(true)
            )
            
            ToggleField.withSubtitle(
                title: "Enable notifications",
                subtitle: "Receive push notifications for important updates",
                isOn: .constant(false)
            )
            
            ToggleField.withIcon(
                title: "Dark mode",
                icon: "moon.fill",
                isOn: .constant(true)
            )
            
            ToggleField.full(
                title: "Biometric authentication",
                subtitle: "Use Face ID or Touch ID for quick login",
                icon: "faceid",
                isOn: .constant(false)
            )
            
            // New subtle style
            ToggleField.subtle(
                title: "Remember this device",
                subtitle: "Keep me signed in on this device",
                icon: "lock.shield",
                isOn: .constant(true)
            )
            
            ToggleField.subtle(
                title: "Auto-save",
                subtitle: "Automatically save your progress",
                icon: "arrow.clockwise",
                isOn: .constant(false)
            )
            
            // New button style
            ToggleField.button(
                title: "Remember this device",
                subtitle: "Keep me signed in on this device",
                icon: "lock.shield",
                isOn: .constant(true)
            )
            
            ToggleField.button(
                title: "Dark mode",
                subtitle: "Switch to dark theme",
                icon: "moon.fill",
                isOn: .constant(false)
            )
            
            ToggleField.button(
                title: "Notifications",
                icon: "bell.fill",
                isOn: .constant(true)
            )
            
            // New checkbox style
            ToggleField.checkbox(
                title: "Remember this device",
                isOn: .constant(true)
            )
            
            ToggleField.checkboxWithIcon(
                title: "Enable notifications",
                icon: "bell.fill",
                isOn: .constant(false)
            )
            
            ToggleField.checkbox(
                title: "Accept terms and conditions",
                isOn: .constant(false)
            )
            
            ToggleField.checkboxWithIcon(
                title: "Subscribe to newsletter",
                icon: "envelope.fill",
                isOn: .constant(true)
            )
        }
        .padding()
        .background(Color("backgroundDefaultColor"))
    }
}
