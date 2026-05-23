pragma Singleton
import QtQuick

QtObject {
    id: root

    property string currentTheme: "Dark"

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
    
    // Accents
    property color accent: "#3B82F6"
    property color accentLight: "#60A5FA"
    property color accentDark: "#1D4ED8"
    property color yellowAccent: "#FFBF00" // Amber
    property color accentGlow: "#3B82F635"
    property color accentDim: "#3B82F615"
    
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
        if (name === "Light Mode") {
            background = "#F1F5F9";
            sidebarBg = "#E2E8F0";
            panelBg = "#FFFFFF";
            headerBg = "#CBD5E1";
            border = "#CBD5E1";
            borderHover = "#94A3B8";
            borderGlow = "#2563EB25";
            textPrimary = "#0F172A";
            textSecondary = "#475569";
            textMuted = "#94A3B8";
            textInverse = "#F8FAFC";
            accent = "#2563EB";
            accentLight = "#3B82F6";
            accentDark = "#1D4ED8";
            yellowAccent = "#D97706";
            accentGlow = "#2563EB35";
            accentDim = "#2563EB15";
        } else if (name === "Dark") {
            background = "#0B1019";
            sidebarBg = "#080B12";
            panelBg = "#131924";
            headerBg = "#0E1420";
            border = "#202D44";
            borderHover = "#304264";
            borderGlow = "#3B82F625";
            textPrimary = "#F8FAFC";
            textSecondary = "#99A9C4";
            textMuted = "#5F7499";
            textInverse = "#0C111A";
            accent = "#3B82F6";
            accentLight = "#60A5FA";
            accentDark = "#1D4ED8";
            yellowAccent = "#FFBF00";
            accentGlow = "#3B82F635";
            accentDim = "#3B82F615";
        } else if (name === "OLED Blackout") {
            background = "#000000";
            sidebarBg = "#000000";
            panelBg = "#0C0C0C";
            headerBg = "#050505";
            border = "#1E1E1E";
            borderHover = "#2E2E2E";
            borderGlow = "#FFFFFF25";
            textPrimary = "#FFFFFF";
            textSecondary = "#A0A0A0";
            textMuted = "#505050";
            textInverse = "#000000";
            accent = "#FFFFFF";
            accentLight = "#E0E0E0";
            accentDark = "#808080";
            yellowAccent = "#FFBF00";
            accentGlow = "#FFFFFF35";
            accentDim = "#FFFFFF15";
        } else if (name === "RGB Gamer") {
            background = "#0B0B0F";
            sidebarBg = "#050508";
            panelBg = "#12121A";
            headerBg = "#08080C";
            border = "#EF4444";
            borderHover = "#F87171";
            borderGlow = "#FF007F25";
            textPrimary = "#00FF66";
            textSecondary = "#00FFFF";
            textMuted = "#666688";
            textInverse = "#0C111A";
            accent = "#FF007F";
            accentLight = "#FF66B2";
            accentDark = "#C70039";
            yellowAccent = "#FFCC00";
            accentGlow = "#FF007F35";
            accentDim = "#FF007F15";
        } else if (name === "Sakura Pink") {
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
            accent = "#FF85A2";
            accentLight = "#FFA4B6";
            accentDark = "#F26487";
            yellowAccent = "#FFB703";
            accentGlow = "#FF85A235";
            accentDim = "#FF85A215";
        }
    }
}
