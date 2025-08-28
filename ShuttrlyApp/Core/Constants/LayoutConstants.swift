//
//  LayoutConstants.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - Layout Constants

struct LayoutConstants {
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Border Radius
    struct BorderRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let full: CGFloat = 999
    }
    
    // MARK: - Component Heights
    struct Heights {
        static let button: CGFloat = 50
        static let inputField: CGFloat = 48
        static let navbar: CGFloat = 70
        static let mobileNavbar: CGFloat = 80
    }
    
    // MARK: - Component Widths
    struct Widths {
        static let sidebar: CGFloat = 250
        static let mobileSidebar: CGFloat = 80
        static let maxContent: CGFloat = 1200
    }
    
    // MARK: - Blur Effects
    struct Blur {
        static let amount: CGFloat = 20
        static let navbar: CGFloat = 20
    }
    
    // MARK: - Transitions
    struct Transitions {
        static let sidebar: Double = 0.3
        static let button: Double = 0.2
        static let color: Double = 0.3
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let small = Color.black.opacity(0.1)
        static let medium = Color.black.opacity(0.15)
        static let large = Color.black.opacity(0.2)
    }
}
