pragma Singleton
import QtQuick

Item {
    id: root

    property string currentTheme: "Темная"

    // RGB Cycling Logic
    property real rgbHue: 0.0
    property color rgbAccent: Qt.hsla(rgbHue, 1.0, 0.5, 1.0)
    property color rgbAccentLight: Qt.hsla(rgbHue, 1.0, 0.65, 1.0)
    property color rgbAccentDark: Qt.hsla(rgbHue, 1.0, 0.35, 1.0)
    property color rgbAccentGlow: Qt.hsla(rgbHue, 1.0, 0.5, 0.25)
    property color rgbAccentDim: Qt.hsla(rgbHue, 1.0, 0.5, 0.15)

    Timer {
        id: rgbTimer
        interval: 16 // smooth 60fps cycling
        running: root.currentTheme === "Ргб"
        repeat: true
        onTriggered: {
            root.rgbHue += 0.001
            if (root.rgbHue > 1.0) {
                root.rgbHue -= 1.0
            }
        }
    }

    // 1. Core Background Colors
    property color background: {
        if (currentTheme === "Белоснежная") return "#FAFAFA";
        if (currentTheme === "Темная") return "#0B1019";
        if (currentTheme === "Blackout полностью черная") return "#000000";
        if (currentTheme === "Ргб") return "#050508";
        if (currentTheme === "Розовая") return "#FCF8F9";
        if (currentTheme === "Black pink") return "#050406";
        return "#0B1019";
    }

    property color sidebarBg: {
        if (currentTheme === "Белоснежная") return "#F3F4F6";
        if (currentTheme === "Темная") return "#070A10";
        if (currentTheme === "Blackout полностью черная") return "#000000";
        if (currentTheme === "Ргб") return "#020204";
        if (currentTheme === "Розовая") return "#F5EBED";
        if (currentTheme === "Black pink") return "#0A090D";
        return "#070A10";
    }

    property color panelBg: {
        if (currentTheme === "Белоснежная") return "#FFFFFF";
        if (currentTheme === "Темная") return "#131924";
        if (currentTheme === "Blackout полностью черная") return "#0C0C0C";
        if (currentTheme === "Ргб") return "#0A0A0F";
        if (currentTheme === "Розовая") return "#FFFFFF";
        if (currentTheme === "Black pink") return "#110F15";
        return "#131924";
    }

    property color buttonBg: {
        if (currentTheme === "Белоснежная") return "#F1F5F9";
        if (currentTheme === "Темная") return "#1C2533";
        if (currentTheme === "Blackout полностью черная") return "#121212";
        if (currentTheme === "Ргб") return "#0E0E14";
        if (currentTheme === "Розовая") return "#F4E3E5";
        if (currentTheme === "Black pink") return "#141016";
        return "#1C2533";
    }

    property color buttonBgHover: {
        if (currentTheme === "Белоснежная") return "#E2E8F0";
        if (currentTheme === "Темная") return "#2A374C";
        if (currentTheme === "Blackout полностью черная") return "#1C1C1E";
        if (currentTheme === "Ргб") return "#1A1A26";
        if (currentTheme === "Розовая") return "#EACCD1";
        if (currentTheme === "Black pink") return "#241626";
        return "#2A374C";
    }

    property color buttonBgPressed: {
        if (currentTheme === "Белоснежная") return "#CBD5E1";
        if (currentTheme === "Темная") return "#0C1017";
        if (currentTheme === "Blackout полностью черная") return "#0A0A0A";
        if (currentTheme === "Ргб") return "#06060A";
        if (currentTheme === "Розовая") return "#D5A3AE";
        if (currentTheme === "Black pink") return "#0F0A0F";
        return "#0C1017";
    }

    property color headerBg: {
        if (currentTheme === "Белоснежная") return "#E5E7EB";
        if (currentTheme === "Темная") return "#0E1420";
        if (currentTheme === "Blackout полностью черная") return "#080808";
        if (currentTheme === "Ргб") return "#040406";
        if (currentTheme === "Розовая") return "#F0E0E3";
        if (currentTheme === "Black pink") return "#0D0B10";
        return "#0E1420";
    }
    
    // 2. Borders & Outlines
    property color border: {
        if (currentTheme === "Ргб") return rgbAccent;
        if (currentTheme === "Белоснежная") return "#E2E8F0";
        if (currentTheme === "Темная") return "#202D44";
        if (currentTheme === "Blackout полностью черная") return "#1F1F1F";
        if (currentTheme === "Розовая") return "#E5CCD1";
        if (currentTheme === "Black pink") return "#3A1E2A";
        return "#202D44";
    }

    property color borderHover: {
        if (currentTheme === "Ргб") return rgbAccentLight;
        if (currentTheme === "Белоснежная") return "#CBD5E1";
        if (currentTheme === "Темная") return "#304264";
        if (currentTheme === "Blackout полностью черная") return "#2C2C2E";
        if (currentTheme === "Розовая") return "#D4A3AE";
        if (currentTheme === "Black pink") return "#FF5E97";
        return "#304264";
    }

    property color borderGlow: {
        if (currentTheme === "Ргб") return rgbAccentGlow;
        if (currentTheme === "Белоснежная") return "#3B82F620";
        if (currentTheme === "Темная") return "#FFBF0025";
        if (currentTheme === "Blackout полностью черная") return "#FF9F0A20";
        if (currentTheme === "Розовая") return "#D48C9C20";
        if (currentTheme === "Black pink") return "#FF5E9720";
        return "#FFBF0025";
    }
    
    // 3. Text Colors (Overhauled for maximum readability!)
    property color textPrimary: {
        if (currentTheme === "Белоснежная") return "#1E293B";
        if (currentTheme === "Темная") return "#F8FAFC";
        if (currentTheme === "Blackout полностью черная") return "#FFFFFF";
        if (currentTheme === "Ргб") return "#FFFFFF";
        if (currentTheme === "Розовая") return "#3D2228";
        if (currentTheme === "Black pink") return "#F8F9FA";
        return "#F8FAFC";
    }

    property color textSecondary: {
        if (currentTheme === "Белоснежная") return "#64748B";
        if (currentTheme === "Темная") return "#94A3B8";
        if (currentTheme === "Blackout полностью черная") return "#A1A1A6";
        if (currentTheme === "Ргб") return "#A1A1A6";
        if (currentTheme === "Розовая") return "#6E4951";
        if (currentTheme === "Black pink") return "#E598B7";
        return "#94A3B8";
    }

    property color textMuted: {
        if (currentTheme === "Белоснежная") return "#94A3B8";
        if (currentTheme === "Темная") return "#64748B";
        if (currentTheme === "Blackout полностью черная") return "#515154";
        if (currentTheme === "Ргб") return "#515154";
        if (currentTheme === "Розовая") return "#9C737C";
        if (currentTheme === "Black pink") return "#A37389";
        return "#64748B";
    }

    property color textInverse: {
        if (currentTheme === "Белоснежная") return "#FFFFFF";
        if (currentTheme === "Темная") return "#0B1019";
        if (currentTheme === "Blackout полностью черная") return "#000000";
        if (currentTheme === "Ргб") return "#000000";
        if (currentTheme === "Розовая") return "#3D2228";
        if (currentTheme === "Black pink") return "#050406";
        return "#0B1019";
    }
    
    // 4. Accent Overhaul (Gorgeous, bug-free brand colors!)
    property color accent: {
        if (currentTheme === "Ргб") return rgbAccent;
        if (currentTheme === "Белоснежная") return "#3B82F6"; // Fluent Blue
        if (currentTheme === "Blackout полностью черная") return "#FF9F0A"; // Neon Gold
        if (currentTheme === "Розовая") return "#D48C9C"; // Premium Blush Rose Gold
        if (currentTheme === "Black pink") return "#FF5E97"; // Cyber Blush Orchid
        return "#FFBF00"; // Dark Slate Zune Amber
    }

    property color accentLight: {
        if (currentTheme === "Ргб") return rgbAccentLight;
        if (currentTheme === "Белоснежная") return "#60A5FA";
        if (currentTheme === "Blackout полностью черная") return "#FFE082";
        if (currentTheme === "Розовая") return "#E5B3BE";
        if (currentTheme === "Black pink") return "#FF85B2";
        return "#FFE082";
    }

    property color accentDark: {
        if (currentTheme === "Ргб") return rgbAccentDark;
        if (currentTheme === "Белоснежная") return "#1D4ED8";
        if (currentTheme === "Blackout полностью черная") return "#FF8F00";
        if (currentTheme === "Розовая") return "#B26A7A";
        if (currentTheme === "Black pink") return "#D6336B";
        return "#FF8F00";
    }

    property color yellowAccent: {
        return accent; // Keep it unified with the main accent for dynamic consistency!
    }

    property color accentGlow: {
        if (currentTheme === "Ргб") return rgbAccentGlow;
        if (currentTheme === "Белоснежная") return "#3B82F635";
        if (currentTheme === "Blackout полностью черная") return "#FF9F0A30";
        if (currentTheme === "Розовая") return "#D48C9C35";
        if (currentTheme === "Black pink") return "#FF5E9735";
        return "#FFBF0035";
    }

    property color accentDim: {
        if (currentTheme === "Ргб") return rgbAccentDim;
        if (currentTheme === "Белоснежная") return "#3B82F615";
        if (currentTheme === "Blackout полностью черная") return "#FF9F0A15";
        if (currentTheme === "Розовая") return "#D48C9C15";
        if (currentTheme === "Black pink") return "#FF5E9715";
        return "#FFBF0015";
    }
    
    // 5. Functional Colors
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
    }
}
