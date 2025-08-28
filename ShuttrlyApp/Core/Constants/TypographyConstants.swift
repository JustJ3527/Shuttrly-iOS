//
//  TypographyConstants.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - Typography Constants
// Based on your SCSS font families and sizes

struct TypographyConstants {
    
    // MARK: - Font Families
    struct FontFamily {
        static let tanNimbus = "Tan_Nimbus"
        static let theSeasons = "The_Seasons"
        static let garet = "Garet"
        static let inter = "Inter"
    }
    
    // MARK: - Font Sizes
    struct FontSize {
        static let xs: CGFloat = 12
        static let sm: CGFloat = 14
        static let base: CGFloat = 16
        static let lg: CGFloat = 18
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let h3: CGFloat = 30
        static let h2: CGFloat = 40
        static let h1: CGFloat = 54
    }
    
    // MARK: - Font Weights
    struct FontWeight {
        static let light = Font.Weight.light
        static let regular = Font.Weight.regular
        static let medium = Font.Weight.medium
        static let semibold = Font.Weight.semibold
        static let bold = Font.Weight.bold
        static let heavy = Font.Weight.heavy
    }
    
    // MARK: - Line Heights
    struct LineHeight {
        static let tight: CGFloat = 1.2
        static let normal: CGFloat = 1.5
        static let relaxed: CGFloat = 1.75
    }
    
    // MARK: - Letter Spacing
    struct LetterSpacing {
        static let tight: CGFloat = -0.025
        static let normal: CGFloat = 0
        static let wide: CGFloat = 0.025
        static let wider: CGFloat = 0.05
        static let widest: CGFloat = 0.1
    }
}

// MARK: - Typography Extensions
extension Font {
    static func tanNimbus(size: CGFloat) -> Font {
        return Font.custom(TypographyConstants.FontFamily.tanNimbus, size: size)
    }
    
    static func theSeasons(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return Font.custom(TypographyConstants.FontFamily.theSeasons, size: size)
    }
    
    static func garet(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return Font.custom(TypographyConstants.FontFamily.garet, size: size)
    }
    
    static func inter(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return Font.custom(TypographyConstants.FontFamily.inter, size: size)
    }
}
