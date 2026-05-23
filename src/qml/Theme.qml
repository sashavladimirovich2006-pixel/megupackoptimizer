pragma Singleton
import QtQuick

QtObject {
    id: root

    property string currentTheme: "Темная"

    // Background Colors
    property color background: "#0B1019"
    property color sidebarBg: "#080B12"
    property color panelBg: "#131924"
    property color headerBg: "#0E1420"
    
    // Borders & Outlines
    property color border: "#202D44"
    property color borderHover: "#304264"
    property color borderGlow: "#3B82F625"
    
    // Text Colors
    property color textPrimary: "#F8FAFC"
    property color textSecondary: "#99A9C4"
    property color textMuted: "#5F7499"
    property color textInverse: "#0C111A"
    
    // Accents (Default: Amber Orange)
    property color accent: "#FFBF00"
    property color accentLight: "#FFE082"
    property color accentDark: "#FF8F00"
    property color yellowAccent: "#FFBF00" // Amber
    property color accentGlow: "#FFBF0035"
    property color accentDim: "#FFBF0015"
    
    // Functional Colors
    readonly property color success: "#10B981"
    readonly property color warning: "#F59E0B"
    readonly property color error: "#EF4444"
    readonly property color info: "#3B82F6"

    // Typography
    readonly property string fontFamily: "Segoe UI Variable, Inter, Outfit, -apple-system, sans-serif"

    // UI Metrics & Geometry
    readonly property int radiusLarge: 16
    readonly property int radiusNormal: 10
    readonly property int radiusSmall: 6

    // Animation Durations
    readonly property int animFast: 120
    readonly property int animNormal: 250
    readonly property int animSlow: 400

    function setTheme(name) {
        currentTheme = name;
        if (name === "Белоснежная") {
            background = "#FFFFFF";
            sidebarBg = "#F8FAFC";
            panelBg = "#F1F5F9";
            headerBg = "#E2E8F0";
            border = "#CBD5E1";
            borderHover = "#94A3B8";
            borderGlow = "#00000015";
            textPrimary = "#0F172A";
            textSecondary = "#475569";
            textMuted = "#94A3B8";
            textInverse = "#FFFFFF";
            // Amber-Orange accent optimized for light background readability
            accent = "#D97706";
            accentLight = "#F59E0B";
            accentDark = "#B45309";
            yellowAccent = "#D97706";
            accentGlow = "#D9770630";
            accentDim = "#D9770612";
        } else if (name === "Темная") {
            background = "#0B1019";
            sidebarBg = "#080B12";
            panelBg = "#131924";
            headerBg = "#0E1420";
            border = "#202D44";
            borderHover = "#304264";
            borderGlow = "#FFBF0025";
            textPrimary = "#F8FAFC";
            textSecondary = "#99A9C4";
            textMuted = "#5F7499";
            textInverse = "#0C111A";
            // Amber-Orange accent
            accent = "#FFBF00";
            accentLight = "#FFE082";
            accentDark = "#FF8F00";
            yellowAccent = "#FFBF00";
            accentGlow = "#FFBF0035";
            accentDim = "#FFBF0015";
        } else if (name === "Blackout полностью черная") {
            background = "#000000";
            sidebarBg = "#000000";
            panelBg = "#0A0A0A";
            headerBg = "#050505";
            border = "#1C1C1E";
            borderHover = "#2C2C2E";
            borderGlow = "#FFBF0020";
            textPrimary = "#FFFFFF";
            textSecondary = "#8E8E93";
            textMuted = "#48484A";
            textInverse = "#000000";
            // Amber-Orange accent
            accent = "#FFBF00";
            accentLight = "#FFE082";
            accentDark = "#FF8F00";
            yellowAccent = "#FFBF00";
            accentGlow = "#FFBF0035";
            accentDim = "#FFBF0015";
        } else if (name === "Ргб") {
            background = "#0B0B0F";
            sidebarBg = "#050508";
            panelBg = "#12121A";
            headerBg = "#08080C";
            border = "#FF8F00"; // Orange gaming border
            borderHover = "#FFBF00";
            borderGlow = "#FFBF0025";
            textPrimary = "#00FF66"; // Keep gamer green text primary
            textSecondary = "#00FFFF";
            textMuted = "#666688";
            textInverse = "#0C111A";
            // Amber-Orange accent
            accent = "#FF8F00";
            accentLight = "#FFBF00";
            accentDark = "#D56F00";
            yellowAccent = "#FFBF00";
            accentGlow = "#FF8F0035";
            accentDim = "#FF8F0015";
        } else if (name === "Розовая") {
            background = "#FFF0F3";
            sidebarBg = "#FFE3E8";
            panelBg = "#FFFFFF";
            headerBg = "#FFD3DA";
            border = "#FFCCD5";
            borderHover = "#FFB3C1";
            borderGlow = "#FF85A225";
            textPrimary = "#593D44";
            textSecondary = "#805E66";
            textMuted = "#C299A2";
            textInverse = "#FFF0F3";
            // Amber-Orange accent readable on pink/light layout
            accent = "#D97706";
            accentLight = "#F59E0B";
            accentDark = "#B45309";
            yellowAccent = "#D97706";
            accentGlow = "#D9770630";
            accentDim = "#D9770612";
        } else if (name === "Black pink") {
            background = "#000000";
            sidebarBg = "#0C0C0C";
            panelBg = "#141414";
            headerBg = "#050505";
            border = "#444444";
            borderHover = "#FF8F00";
            borderGlow = "#FFBF0025";
            textPrimary = "#FFFFFF";
            textSecondary = "#FFB3C1";
            textMuted = "#C299A2";
            textInverse = "#000000";
            // Amber-Orange accent
            accent = "#FFBF00";
            accentLight = "#FFE082";
            accentDark = "#FF8F00";
            yellowAccent = "#FFBF00";
            accentGlow = "#FFBF0035";
            accentDim = "#FFBF0015";
        }
    }
}
