//
//  PreviewColorHelper.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - Preview Color Helper
// Ensures colors display correctly in Xcode previews

struct PreviewColorHelper {
    
    // MARK: - Preview Mode Detection
    
    /// Check if running in Xcode preview mode
    static var isPreviewMode: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    // MARK: - Color Methods
    
    /// Get primary color that works in both preview and normal mode
    static func primaryColor() -> Color {
        if isPreviewMode {
            // Force specific color for previews to avoid blue tint
            return Color("primaryDefaultColor")
        } else {
            // Use dynamic color in normal mode
            return Color("primaryDefaultColor")
        }
    }
    
    /// Get secondary color that works in both preview and normal mode
    static func secondaryColor() -> Color {
        if isPreviewMode {
            // Force specific color for previews to avoid blue tint
            return Color("secondaryDefaultColor")
        } else {
            // Use dynamic color in normal mode
            return Color("secondaryDefaultColor")
        }
    }
    
    /// Get background color that works in both preview and normal mode
    static func backgroundColor() -> Color {
        if isPreviewMode {
            // Force specific color for previews to avoid blue tint
            return Color("backgroundDefaultColor")
        } else {
            // Use dynamic color in normal mode
            return Color("backgroundDefaultColor")
        }
    }
    
    /// Get accent color that works in both preview and normal mode
    static func accentColor() -> Color {
        if isPreviewMode {
            // Force specific color for previews to avoid blue tint
            return Color("accentDefaultColor")
        } else {
            // Use dynamic color in normal mode
            return Color("accentDefaultColor")
        }
    }
    
    // MARK: - Icon Color Methods
    
    /// Get icon color that works in both preview and normal mode
    static func iconColor() -> Color {
        if isPreviewMode {
            // Force specific color for previews to avoid blue tint
            return Color("iconDefaultColor")
        } else {
            // Use dynamic color in normal mode
            return Color("iconDefaultColor")
        }
    }
    
    /// Get text color that works in both preview and normal mode
    static func textColor() -> Color {
        if isPreviewMode {
            // Force specific color for previews to avoid blue tint
            return Color("textDefaultColor")
        } else {
            // Use dynamic color in normal mode
            return Color("textDefaultColor")
        }
    }
}

// MARK: - Color Extensions for Preview Support

extension Color {
    /// Preview-safe primary color
    static var previewPrimary: Color {
        PreviewColorHelper.primaryColor()
    }
    
    /// Preview-safe secondary color
    static var previewSecondary: Color {
        PreviewColorHelper.secondaryColor()
    }
    
    /// Preview-safe background color
    static var previewBackground: Color {
        PreviewColorHelper.backgroundColor()
    }
    
    /// Preview-safe accent color
    static var previewAccent: Color {
        PreviewColorHelper.accentColor()
    }
    
    /// Preview-safe icon color
    static var previewIcon: Color {
        PreviewColorHelper.iconColor()
    }
    
    /// Preview-safe text color
    static var previewText: Color {
        PreviewColorHelper.textColor()
    }
}
