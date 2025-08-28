//
//  ColorConstants.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - HSL Color Extension
extension Color {
    /// Create a color from HSL values
    /// - Parameters:
    ///   - hue: Hue value (0-360 degrees)
    ///   - saturation: Saturation value (0-100%)
    ///   - lightness: Lightness value (0-100%)
    ///   - alpha: Alpha value (0-1), defaults to 1.0
    init(hue: Double, saturation: Double, lightness: Double, alpha: Double = 1.0) {
        let h = hue / 360.0
        let s = saturation / 100.0
        let l = lightness / 100.0
        
        let q = l < 0.5 ? l * (1 + s) : l + s - l * s
        let p = 2 * l - q
        
        func hueToRGB(_ t: Double) -> Double {
            let t = t < 0 ? t + 1 : t > 1 ? t - 1 : t
            if t < 1/6 { return p + (q - p) * 6 * t }
            if t < 1/2 { return q }
            if t < 2/3 { return p + (q - p) * (2/3 - t) * 6 }
            return p
        }
        
        let r = hueToRGB(h + 1/3)
        let g = hueToRGB(h)
        let b = hueToRGB(h - 1/3)
        
        self.init(red: r, green: g, blue: b, opacity: alpha)
    }
}

// MARK: - Color Constants
// Based on your SCSS variables for perfect consistency

struct ColorConstants {
    
    // MARK: - Light Theme Colors
    struct Light {
        // Text colors
        static let textDefault = Color(hue: 86, saturation: 17, lightness: 8)
        static let text50 = Color(hue: 75, saturation: 15, lightness: 95)
        static let text100 = Color(hue: 87, saturation: 18, lightness: 90)
        static let text200 = Color(hue: 87, saturation: 18, lightness: 80)
        static let text300 = Color(hue: 87, saturation: 18, lightness: 70)
        static let text400 = Color(hue: 86, saturation: 17, lightness: 60)
        static let text500 = Color(hue: 87, saturation: 17, lightness: 50)
        static let text600 = Color(hue: 86, saturation: 17, lightness: 40)
        static let text700 = Color(hue: 87, saturation: 18, lightness: 30)
        static let text800 = Color(hue: 87, saturation: 18, lightness: 20)
        static let text900 = Color(hue: 87, saturation: 18, lightness: 10)
        static let text950 = Color(hue: 90, saturation: 15, lightness: 5)
        
        // Background colors
        static let backgroundDefault = Color(hue: 80, saturation: 5, lightness: 88)
        static let background50 = Color(hue: 120, saturation: 4, lightness: 95)
        static let background100 = Color(hue: 80, saturation: 6, lightness: 90)
        static let background200 = Color(hue: 80, saturation: 6, lightness: 80)
        static let background300 = Color(hue: 77, saturation: 5, lightness: 70)
        static let background400 = Color(hue: 78, saturation: 5, lightness: 60)
        static let background500 = Color(hue: 78, saturation: 5, lightness: 50)
        static let background600 = Color(hue: 78, saturation: 5, lightness: 40)
        static let background700 = Color(hue: 77, saturation: 5, lightness: 30)
        static let background800 = Color(hue: 80, saturation: 6, lightness: 20)
        static let background900 = Color(hue: 80, saturation: 6, lightness: 10)
        static let background950 = Color(hue: 60, saturation: 4, lightness: 5)
        
        // Primary colors
        static let primaryDefault = Color(hue: 81, saturation: 31, lightness: 52)
        static let primary50 = Color(hue: 83, saturation: 31, lightness: 95)
        static let primary100 = Color(hue: 80, saturation: 29, lightness: 90)
        static let primary200 = Color(hue: 81, saturation: 31, lightness: 80)
        static let primary300 = Color(hue: 80, saturation: 31, lightness: 70)
        static let primary400 = Color(hue: 82, saturation: 31, lightness: 60)
        static let primary500 = Color(hue: 81, saturation: 31, lightness: 50)
        static let primary600 = Color(hue: 82, saturation: 31, lightness: 40)
        static let primary700 = Color(hue: 80, saturation: 31, lightness: 30)
        static let primary800 = Color(hue: 81, saturation: 31, lightness: 20)
        static let primary900 = Color(hue: 80, saturation: 29, lightness: 10)
        static let primary950 = Color(hue: 83, saturation: 31, lightness: 5)
        
        // Secondary colors
        static let secondaryDefault = Color(hue: 112, saturation: 24, lightness: 69)
        static let secondary50 = Color(hue: 110, saturation: 23, lightness: 95)
        static let secondary100 = Color(hue: 111, saturation: 25, lightness: 90)
        static let secondary200 = Color(hue: 113, saturation: 24, lightness: 80)
        static let secondary300 = Color(hue: 112, saturation: 24, lightness: 70)
        static let secondary400 = Color(hue: 112, saturation: 24, lightness: 60)
        static let secondary500 = Color(hue: 112, saturation: 24, lightness: 50)
        static let secondary600 = Color(hue: 113, saturation: 24, lightness: 40)
        static let secondary700 = Color(hue: 112, saturation: 24, lightness: 30)
        static let secondary800 = Color(hue: 113, saturation: 24, lightness: 20)
        static let secondary900 = Color(hue: 111, saturation: 25, lightness: 10)
        static let secondary950 = Color(hue: 110, saturation: 23, lightness: 5)
        
        // Accent colors
        static let accentDefault = Color(hue: 188, saturation: 31, lightness: 50)
        static let accent50 = Color(hue: 187, saturation: 31, lightness: 95)
        static let accent100 = Color(hue: 188, saturation: 29, lightness: 90)
        static let accent200 = Color(hue: 188, saturation: 31, lightness: 80)
        static let accent300 = Color(hue: 188, saturation: 31, lightness: 70)
        static let accent400 = Color(hue: 188, saturation: 31, lightness: 60)
        static let accent500 = Color(hue: 188, saturation: 31, lightness: 50)
        static let accent600 = Color(hue: 188, saturation: 31, lightness: 40)
        static let accent700 = Color(hue: 188, saturation: 31, lightness: 30)
        static let accent800 = Color(hue: 188, saturation: 31, lightness: 20)
        static let accent900 = Color(hue: 188, saturation: 29, lightness: 10)
        static let accent950 = Color(hue: 187, saturation: 31, lightness: 95)
        
        // Special colors
        static let backgroundNavbar = Color(hue: 80, saturation: 5, lightness: 88, alpha: 0.54)
        static let opacityBackgroundBefore: Double = 0.3
    }
    
    // MARK: - Dark Theme Colors
    struct Dark {
        // Text colors (inverted from light)
        static let textDefault = Color(hue: 86, saturation: 17, lightness: 92)
        static let text50 = Color(hue: 90, saturation: 15, lightness: 5)
        static let text100 = Color(hue: 87, saturation: 18, lightness: 10)
        static let text200 = Color(hue: 87, saturation: 18, lightness: 20)
        static let text300 = Color(hue: 87, saturation: 18, lightness: 30)
        static let text400 = Color(hue: 86, saturation: 17, lightness: 40)
        static let text500 = Color(hue: 87, saturation: 17, lightness: 50)
        static let text600 = Color(hue: 86, saturation: 17, lightness: 60)
        static let text700 = Color(hue: 87, saturation: 18, lightness: 70)
        static let text800 = Color(hue: 87, saturation: 18, lightness: 80)
        static let text900 = Color(hue: 87, saturation: 18, lightness: 90)
        static let text950 = Color(hue: 75, saturation: 15, lightness: 95)
        
        // Background colors (inverted from light)
        static let backgroundDefault = Color(hue: 80, saturation: 5, lightness: 12)
        static let background50 = Color(hue: 60, saturation: 4, lightness: 5)
        static let background100 = Color(hue: 80, saturation: 6, lightness: 10)
        static let background200 = Color(hue: 80, saturation: 6, lightness: 20)
        static let background300 = Color(hue: 77, saturation: 5, lightness: 30)
        static let background400 = Color(hue: 78, saturation: 5, lightness: 40)
        static let background500 = Color(hue: 78, saturation: 5, lightness: 50)
        static let background600 = Color(hue: 78, saturation: 5, lightness: 60)
        static let background700 = Color(hue: 77, saturation: 5, lightness: 70)
        static let background800 = Color(hue: 80, saturation: 6, lightness: 80)
        static let background900 = Color(hue: 80, saturation: 6, lightness: 90)
        static let background950 = Color(hue: 120, saturation: 4, lightness: 95)
        
        // Primary colors (adjusted for dark theme)
        static let primaryDefault = Color(hue: 81, saturation: 31, lightness: 48)
        static let primary50 = Color(hue: 83, saturation: 31, lightness: 5)
        static let primary100 = Color(hue: 80, saturation: 29, lightness: 10)
        static let primary200 = Color(hue: 81, saturation: 31, lightness: 20)
        static let primary300 = Color(hue: 80, saturation: 31, lightness: 30)
        static let primary400 = Color(hue: 82, saturation: 31, lightness: 40)
        static let primary500 = Color(hue: 81, saturation: 31, lightness: 50)
        static let primary600 = Color(hue: 82, saturation: 31, lightness: 60)
        static let primary700 = Color(hue: 80, saturation: 31, lightness: 70)
        static let primary800 = Color(hue: 81, saturation: 31, lightness: 80)
        static let primary900 = Color(hue: 80, saturation: 29, lightness: 90)
        static let primary950 = Color(hue: 83, saturation: 31, lightness: 95)
        
        // Secondary colors (adjusted for dark theme)
        static let secondaryDefault = Color(hue: 112, saturation: 24, lightness: 31)
        static let secondary50 = Color(hue: 110, saturation: 23, lightness: 5)
        static let secondary100 = Color(hue: 111, saturation: 25, lightness: 10)
        static let secondary200 = Color(hue: 113, saturation: 24, lightness: 20)
        static let secondary300 = Color(hue: 112, saturation: 24, lightness: 30)
        static let secondary400 = Color(hue: 113, saturation: 24, lightness: 40)
        static let secondary500 = Color(hue: 112, saturation: 24, lightness: 50)
        static let secondary600 = Color(hue: 112, saturation: 24, lightness: 60)
        static let secondary700 = Color(hue: 112, saturation: 24, lightness: 70)
        static let secondary800 = Color(hue: 113, saturation: 24, lightness: 80)
        static let secondary900 = Color(hue: 111, saturation: 25, lightness: 90)
        static let secondary950 = Color(hue: 110, saturation: 23, lightness: 95)
        
        // Accent colors (adjusted for dark theme)
        static let accentDefault = Color(hue: 188, saturation: 31, lightness: 50)
        static let accent50 = Color(hue: 188, saturation: 31, lightness: 5)
        static let accent100 = Color(hue: 188, saturation: 29, lightness: 10)
        static let accent200 = Color(hue: 188, saturation: 31, lightness: 20)
        static let accent300 = Color(hue: 188, saturation: 31, lightness: 30)
        static let accent400 = Color(hue: 188, saturation: 31, lightness: 40)
        static let accent500 = Color(hue: 188, saturation: 31, lightness: 50)
        static let accent600 = Color(hue: 188, saturation: 31, lightness: 60)
        static let accent700 = Color(hue: 188, saturation: 31, lightness: 70)
        static let accent800 = Color(hue: 188, saturation: 31, lightness: 80)
        static let accent900 = Color(hue: 188, saturation: 29, lightness: 90)
        static let accent950 = Color(hue: 187, saturation: 31, lightness: 95)
        
        // Special colors
        static let backgroundNavbar = Color(hue: 0, saturation: 0, lightness: 25.88, alpha: 0.74)
        static let opacityBackgroundBefore: Double = 0.3
    }
    
    // MARK: - Common Colors
    static let primaryDefault = Light.primaryDefault
    static let secondaryDefault = Light.secondaryDefault
    static let accentDefault = Light.accentDefault
    
    // MARK: - Current Theme Colors
    static func currentTheme(_ colorScheme: ColorScheme) -> ThemeColors {
        switch colorScheme {
        case .light:
            return ThemeColors(
                text: Light.textDefault,
                background: Light.backgroundDefault,
                primary: Light.primaryDefault,
                secondary: Light.secondaryDefault,
                accent: Light.accentDefault,
                backgroundNavbar: Light.backgroundNavbar,
                text600: Light.text600,
                text400: Light.text400,
                background100: Light.background100,
                primary200: Light.primary200
            )
        case .dark:
            return ThemeColors(
                text: Dark.textDefault,
                background: Dark.backgroundDefault,
                primary: Dark.primaryDefault,
                secondary: Dark.secondaryDefault,
                accent: Dark.accentDefault,
                backgroundNavbar: Dark.backgroundNavbar,
                text600: Dark.text600,
                text400: Dark.text400,
                background100: Dark.background100,
                primary200: Dark.primary200
            )
        @unknown default:
            return ThemeColors(
                text: Light.textDefault,
                background: Light.backgroundDefault,
                primary: Light.primaryDefault,
                secondary: Light.secondaryDefault,
                accent: Light.accentDefault,
                backgroundNavbar: Light.backgroundNavbar,
                text600: Light.text600,
                text400: Light.text400,
                background100: Light.background100,
                primary200: Light.primary200
            )
        }
    }
}

// MARK: - Theme Colors Structure
struct ThemeColors {
    let text: Color
    let background: Color
    let primary: Color
    let secondary: Color
    let accent: Color
    let backgroundNavbar: Color
    
    // Additional colors for specific UI elements
    let text600: Color
    let text400: Color
    let background100: Color
    let primary200: Color
}

// MARK: - Color Extensions for Easy Access
extension Color {
    static let shuttrlyText = ColorConstants.Light.textDefault
    static let shuttrlyBackground = ColorConstants.Light.backgroundDefault
    static let shuttrlyPrimary = ColorConstants.Light.primaryDefault
    static let shuttrlySecondary = ColorConstants.Light.secondaryDefault
    static let shuttrlyAccent = ColorConstants.Light.accentDefault
}

