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
        if (currentTheme === "Темная") return "#080B11"; // Deeper space black-blue
        if (currentTheme === "Blackout полностью черная") return "#000000";
        if (currentTheme === "Ргб") return "#050508";
        if (currentTheme === "Розовая") return "#FCF8F9";
        if (currentTheme === "Black pink") return "#050406";
        return "#080B11";
    }

    property color sidebarBg: {
        if (currentTheme === "Белоснежная") return "#F2F3F4F6"; // 95% opacity
        if (currentTheme === "Темная") return "#E605080E"; // 90% opacity deep dark
        if (currentTheme === "Blackout полностью черная") return "#E6000000"; // 90% opacity
        if (currentTheme === "Ргб") return "#E6020204"; // 90%
        if (currentTheme === "Розовая") return "#F2F5EBED"; // 95% opacity
        if (currentTheme === "Black pink") return "#E60A090D"; // 90% opacity
        return "#E605080E";
    }

    property color panelBg: {
        if (currentTheme === "Белоснежная") return "#CCFFFFFF"; // 80% translucent white
        if (currentTheme === "Темная") return "#B30F1524"; // 70% translucent deep slate
        if (currentTheme === "Blackout полностью черная") return "#B30C0C0C"; // 70% translucent black
        if (currentTheme === "Ргб") return "#B3050508"; // 70% translucent
        if (currentTheme === "Розовая") return "#CCD9E5EC"; // 80% translucent soft blush white
        if (currentTheme === "Black pink") return "#B30A090D"; // 70% translucent orchid
        return "#B30F1524";
    }

    property color buttonBg: {
        if (currentTheme === "Белоснежная") return "#B3F1F5F9"; // 70% translucent
        if (currentTheme === "Темная") return "#731C2533"; // 45% translucent
        if (currentTheme === "Blackout полностью черная") return "#73121212"; // 45% translucent
        if (currentTheme === "Ргб") return "#730E0E14"; // 45% translucent
        if (currentTheme === "Розовая") return "#B3F4E3E5"; // 70% translucent
        if (currentTheme === "Black pink") return "#73141016"; // 45% translucent
        return "#731C2533";
    }

    property color buttonBgHover: {
        if (currentTheme === "Белоснежная") return "#CCE2E8F0"; // 80% translucent
        if (currentTheme === "Темная") return "#992A374C"; // 60% translucent
        if (currentTheme === "Blackout полностью черная") return "#991C1C1E"; // 60% translucent
        if (currentTheme === "Ргб") return "#991A1A26"; // 60% translucent
        if (currentTheme === "Розовая") return "#CCEACCD1"; // 80% translucent
        if (currentTheme === "Black pink") return "#99241626"; // 60% translucent
        return "#992A374C";
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
        if (currentTheme === "Белоснежная") return "#E6E5E7EB"; // 90% translucent
        if (currentTheme === "Темная") return "#D90B0F18"; // 85% translucent
        if (currentTheme === "Blackout полностью черная") return "#D9050505"; // 85% translucent
        if (currentTheme === "Ргб") return "#D9040406"; // 85% translucent
        if (currentTheme === "Розовая") return "#E6F0E0E3"; // 90% translucent
        if (currentTheme === "Black pink") return "#D90D0B10"; // 85% translucent
        return "#D90B0F18";
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
