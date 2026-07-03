import AppKit
import SwiftUI

/// Campbell — the default Windows Terminal color scheme.
enum Theme {
    // ANSI 0-15
    static let ansi: [NSColor] = [
        NSColor(hex: 0x0C0C0C), // black
        NSColor(hex: 0xC50F1F), // red
        NSColor(hex: 0x13A10E), // green
        NSColor(hex: 0xC19C00), // yellow
        NSColor(hex: 0x0037DA), // blue
        NSColor(hex: 0x881798), // magenta
        NSColor(hex: 0x3A96DD), // cyan
        NSColor(hex: 0xCCCCCC), // white
        NSColor(hex: 0x767676), // bright black
        NSColor(hex: 0xE74856), // bright red
        NSColor(hex: 0x16C60C), // bright green
        NSColor(hex: 0xF9F158), // bright yellow
        NSColor(hex: 0x3B78FF), // bright blue
        NSColor(hex: 0xB4009E), // bright magenta
        NSColor(hex: 0x61D6D6), // bright cyan
        NSColor(hex: 0xF2F2F2), // bright white
    ]

    static let background = NSColor(hex: 0x0C0C0C)
    static let foreground = NSColor(hex: 0xCCCCCC)
    static let cursor = NSColor(hex: 0xFFFFFF)
    static let selection = NSColor(hex: 0x264F78)

    /// How translucent the terminal pane is (acrylic effect).
    static let paneOpacity: CGFloat = 0.82

    // Tab bar metrics — mirrors Windows Terminal's compact title-bar tabs.
    static let tabBarHeight: CGFloat = 40
    static let tabHeight: CGFloat = 30
    static let tabMaxWidth: CGFloat = 216
    static let tabMinWidth: CGFloat = 120

    /// Cascadia Mono is Windows Terminal's default; fall back gracefully.
    static func terminalFont(size: CGFloat) -> NSFont {
        let candidates = [
            "CaskaydiaCoveNerdFontComplete-Regular",
            "CaskaydiaCove Nerd Font",
            "Cascadia Mono",
            "Cascadia Code",
            "JetBrainsMono-Regular",
            "FiraCode-Regular",
        ]
        for name in candidates {
            if let f = NSFont(name: name, size: size) { return f }
        }
        return .monospacedSystemFont(ofSize: size, weight: .regular)
    }
}

extension NSColor {
    convenience init(hex: UInt32) {
        self.init(
            srgbRed: CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >> 8) & 0xFF) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
}

extension Color {
    init(hex: UInt32, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }
}
