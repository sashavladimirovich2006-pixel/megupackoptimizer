pragma Singleton
import QtQuick

QtObject {
    id: root

    // --- NEO-LUNA PALETTE (Windows XP + Acrylic + Zune) ---
    
    // Background Colors
    readonly property color background: "#131924"      // Deep Slate Blue Base (60%)
    readonly property color panelBg: "#D8212D44"       // Acrylic Glazed Slate Blue (~85% opaque #212D44)
    readonly property color headerBg: "#E01A2436"      // Acrylic Tint Header
    
    // Borders & Outlines
    readonly property color border: "#354769"          // Clean structural border
    readonly property color borderHover: "#4A618F"     // Border on hover
    readonly property color borderGlow: "#FFBF0025"     // Amber border glow
    
    // Text Colors
    readonly property color textPrimary: "#F8FAFC"     // Crisp white (Slate Blue 50)
    readonly property color textSecondary: "#99A9C4"   // Dimmed slate (Slate Blue 300)
    readonly property color textMuted: "#5F7499"       // Subdued slate (Slate Blue 500)
    readonly property color textInverse: "#0C111A"     // Dark background contrast
    
    // Zune Accent System (10%)
    readonly property color accent: "#FFBF00"          // Amber Orange 500
    readonly property color accentLight: "#FFD033"     // Amber Orange 400 (Hover/Highlight)
    readonly property color accentDark: "#D69F00"      // Amber Orange 600 (Press)
    readonly property color accentGlow: "#FFBF0035"     // Glowing highlight drop shadow
    readonly property color accentDim: "#FFBF0015"      // Low opacity accent
    
    // Functional Colors
    readonly property color success: "#10B981"         // Emerald Green
    readonly property color warning: "#F59E0B"         // Amber Yellow
    readonly property color error: "#EF4444"           // Crimson Red
    readonly property color info: "#3B82F6"            // Bright Blue

    // --- TYPOGRAPHY ---
    readonly property string fontFamily: "Segoe UI Variable, Inter, Outfit, -apple-system, sans-serif"

    // --- UI METRICS & GEOMETRY ---
    // Radius values for the formula R_inner = R_outer - D
    readonly property int radiusLarge: 16
    readonly property int radiusNormal: 10
    readonly property int radiusSmall: 6

    // --- ANIMATION DURATIONS ---
    readonly property int animFast: 120
    readonly property int animNormal: 250
    readonly property int animSlow: 400
}
