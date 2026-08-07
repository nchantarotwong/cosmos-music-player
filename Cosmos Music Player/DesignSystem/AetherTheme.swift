//
//  AetherTheme.swift
//  Cosmos Music Player
//
//  Semantic design tokens for the Aether "Shelves" redesign. Define visual
//  values ONCE here — colors, spacing, corner radii, typography helpers — so
//  feature views never hardcode magic values. See
//  docs/design/aether/AETHER_OPTION3_SHELVES.md.
//
//  Aether is dark by default: a deep near-black cool base, a restrained
//  lavender/violet accent, and artwork supplying the color. Values are the
//  brief's starting points, expressed as literal RGB so this file has no
//  dependency on any other Color helper.
//

import SwiftUI

enum Aether {

    // MARK: - Colors

    enum Color {
        /// Near-black with a very slight cool/navy bias — the base canvas. ≈ #080B10
        static let background = SwiftUI.Color(red: 0.031, green: 0.043, blue: 0.063)
        /// Lifted dark surface for grouped content. ≈ #12121A
        static let surface = SwiftUI.Color(red: 0.071, green: 0.071, blue: 0.102)
        /// Elevated surface for cards and the mini player. ≈ #181825
        static let surfaceElevated = SwiftUI.Color(red: 0.094, green: 0.094, blue: 0.145)
        /// Restrained lavender/violet accent — used sparingly for emphasis. ≈ #A386FF
        static let primary = SwiftUI.Color(red: 0.639, green: 0.525, blue: 1.000)
        /// Near-white primary text. ≈ #ECECF2
        static let textPrimary = SwiftUI.Color(red: 0.925, green: 0.925, blue: 0.949)
        /// Cool gray secondary text. ≈ #A1A1B3
        static let textSecondary = SwiftUI.Color(red: 0.631, green: 0.631, blue: 0.702)
        /// Dim gray tertiary text. ≈ #6E6E80
        static let textTertiary = SwiftUI.Color(red: 0.431, green: 0.431, blue: 0.502)
        /// Hairline separators — prefer subtle lines over boxed containers.
        static let separator = SwiftUI.Color.white.opacity(0.08)
    }

    // MARK: - Spacing

    /// Generous, consistent spacing. Prefer these over ad-hoc padding.
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        /// Vertical gap between Home shelves — the calm, spacious rhythm.
        static let shelfGap: CGFloat = 28
        /// Horizontal screen margin.
        static let screenMargin: CGFloat = 16
    }

    // MARK: - Corner radii

    enum Radius {
        static let artwork: CGFloat = 10   // 8–12pt: covers sit close to the background
        static let featureCard: CGFloat = 18 // 16–20pt: Continue Listening
        static let miniPlayer: CGFloat = 16  // 14–18pt
    }

    // MARK: - Shelf metrics

    enum Metrics {
        /// Square shelf artwork edge; ~4 items visible so the trailing item clips.
        static let shelfItemArtwork: CGFloat = 132
        /// Fixed label width beneath a shelf item (keeps rows aligned).
        static let shelfItemWidth: CGFloat = 132
        /// Continue Listening card height.
        static let continueCardHeight: CGFloat = 108
        /// Mini player height (excluding safe-area inset).
        static let miniPlayerHeight: CGFloat = 60
    }

    // MARK: - Typography

    /// The `A E T H E R` wordmark: light system font with expanded tracking.
    /// Branding, not a navigation label.
    static func wordmark(_ text: String = "AETHER") -> some View {
        Text(text.map(String.init).joined(separator: "\u{2009}"))
            .font(.system(.title2, design: .default).weight(.light))
            .tracking(6)
            .foregroundStyle(Aether.Color.textPrimary)
            .accessibilityLabel("Aether")
    }
}

// MARK: - Convenience view modifiers

extension View {
    /// Fill the screen with the Aether base background, ignoring safe areas.
    func aetherBackground() -> some View {
        background(Aether.Color.background.ignoresSafeArea())
    }

    /// Standard section header styling (e.g. "Recently Added") with an optional
    /// chevron affordance when the header is tappable to open the full list.
    func aetherSectionHeader() -> some View {
        font(.headline)
            .foregroundStyle(Aether.Color.textPrimary)
    }
}
