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
        interval: 32 // ~30fps, slower refresh
        running: root.currentTheme === "Ргб"
        repeat: true
        onTriggered: {
            root.rgbHue += 0.0003 // much slower color cycling
            if (root.rgbHue > 1.0) {
                root.rgbHue -= 1.0
            }
        }
    }

    // Background Colors
    property color background: {
        if (currentTheme === "Белоснежная") return "#FFFFFF";
        if (currentTheme === "Темная") return "#0B1019";
        if (currentTheme === "Blackout полностью черная") return "#000000";
        if (currentTheme === "Ргб") return "#050508";
        if (currentTheme === "Розовая") return "#FFE3E8";
        if (currentTheme === "Black pink") return "#000000";
        return "#0B1019";
    }

    property color sidebarBg: {
        if (currentTheme === "Белоснежная") return "#F8FAFC";
        if (currentTheme === "Темная") return "#080B12";
        if (currentTheme === "Blackout полностью черная") return "#000000";
        if (currentTheme === "Ргб") return "#020204";
        if (currentTheme === "Розовая") return "#FFB3C1";
        if (currentTheme === "Black pink") return "#0C0C0C";
        return "#080B12";
    }

    property color panelBg: {
        if (currentTheme === "Белоснежная") return "#F1F5F9";
        if (currentTheme === "Темная") return "#131924";
        if (currentTheme === "Blackout полностью черная") return "#0A0A0A";
        if (currentTheme === "Ргб") return "#0A0A0F";
        if (currentTheme === "Розовая") return "#FFF0F3";
        if (currentTheme === "Black pink") return "#141414";
        return "#131924";
    }

    property color headerBg: {
        if (currentTheme === "Белоснежная") return "#E2E8F0";
        if (currentTheme === "Темная") return "#0E1420";
        if (currentTheme === "Blackout полностью черная") return "#050505";
        if (currentTheme === "Ргб") return "#040406";
        if (currentTheme === "Розовая") return "#FFCCD5";
        if (currentTheme === "Black pink") return "#050505";
        return "#0E1420";
    }
    
    // Borders & Outlines
    property color border: {
        if (currentTheme === "Ргб") return rgbAccent;
        if (currentTheme === "Белоснежная") return "#CBD5E1";
        if (currentTheme === "Темная") return "#202D44";
        if (currentTheme === "Blackout полностью черная") return "#1C1C1E";
        if (currentTheme === "Розовая") return "#FF85A2";
        if (currentTheme === "Black pink") return "#FF85A2";
        return "#202D44";
    }

    property color borderHover: {
        if (currentTheme === "Ргб") return rgbAccentLight;
        if (currentTheme === "Белоснежная") return "#94A3B8";
        if (currentTheme === "Темная") return "#304264";
        if (currentTheme === "Blackout полностью черная") return "#2C2C2E";
        if (currentTheme === "Розовая") return "#FF5C8A";
        if (currentTheme === "Black pink") return "#FF5C8A";
        return "#304264";
    }

    property color borderGlow: {
        if (currentTheme === "Ргб") return rgbAccentGlow;
        if (currentTheme === "Белоснежная") return "#00000015";
        if (currentTheme === "Темная") return "#FFBF0025";
        if (currentTheme === "Blackout полностью черная") return "#FFBF0020";
        if (currentTheme === "Розовая") return "#FF5C8A25";
        if (currentTheme === "Black pink") return "#FF5C8A35";
        return "#FFBF0025";
    }
    
    // Text Colors
    property color textPrimary: {
        if (currentTheme === "Белоснежная") return "#0F172A";
        if (currentTheme === "Темная") return "#F8FAFC";
        if (currentTheme === "Blackout полностью черная") return "#FFFFFF";
        if (currentTheme === "Ргб") return "#FFFFFF";
        if (currentTheme === "Розовая") return "#590D22";
        if (currentTheme === "Black pink") return "#FFFFFF";
        return "#F8FAFC";
    }

    property color textSecondary: {
        if (currentTheme === "Белоснежная") return "#475569";
        if (currentTheme === "Темная") return "#99A9C4";
        if (currentTheme === "Blackout полностью черная") return "#8E8E93";
        if (currentTheme === "Ргб") return "#8E8E93";
        if (currentTheme === "Розовая") return "#800F2F";
        if (currentTheme === "Black pink") return "#FFB3C1";
        return "#99A9C4";
    }

    property color textMuted: {
        if (currentTheme === "Белоснежная") return "#94A3B8";
        if (currentTheme === "Темная") return "#5F7499";
        if (currentTheme === "Blackout полностью черная") return "#48484A";
        if (currentTheme === "Ргб") return "#48484A";
        if (currentTheme === "Розовая") return "#A31D44";
        if (currentTheme === "Black pink") return "#FF85A2";
        return "#5F7499";
    }

    property color textInverse: {
        if (currentTheme === "Белоснежная") return "#FFFFFF";
        if (currentTheme === "Темная") return "#0C111A";
        if (currentTheme === "Blackout полностью черная") return "#000000";
        if (currentTheme === "Ргб") return "#000000";
        if (currentTheme === "Розовая") return "#FFEBF0";
        if (currentTheme === "Black pink") return "#000000";
        return "#0C111A";
    }
    
    // Accents (Dynamic based on theme)
    property color accent: {
        if (currentTheme === "Ргб") return rgbAccent;
        if (currentTheme === "Белоснежная" || currentTheme === "Розовая") return "#D97706";
        return "#FFBF00";
    }

    property color accentLight: {
        if (currentTheme === "Ргб") return rgbAccentLight;
        if (currentTheme === "Белоснежная" || currentTheme === "Розовая") return "#F59E0B";
        return "#FFE082";
    }

    property color accentDark: {
        if (currentTheme === "Ргб") return rgbAccentDark;
        if (currentTheme === "Белоснежная" || currentTheme === "Розовая") return "#B45309";
        return "#FF8F00";
    }

    property color yellowAccent: {
        if (currentTheme === "Белоснежная" || currentTheme === "Розовая") return "#D97706";
        return "#FFBF00";
    }

    property color accentGlow: {
        if (currentTheme === "Ргб") return rgbAccentGlow;
        if (currentTheme === "Белоснежная" || currentTheme === "Розовая") return "#D9770630";
        return "#FFBF0035";
    }

    property color accentDim: {
        if (currentTheme === "Ргб") return rgbAccentDim;
        if (currentTheme === "Белоснежная" || currentTheme === "Розовая") return "#D9770612";
        return "#FFBF0015";
    }
    
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
    }
}
