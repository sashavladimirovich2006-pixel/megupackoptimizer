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
        if (currentTheme === "Темная") return "#070709"; // Ultra-sleek premium charcoal black
        if (currentTheme === "Blackout полностью черная") return "#000000";
        if (currentTheme === "Ргб") return "#050508";
        if (currentTheme === "Розовая") return "#FCE5E8"; // Beautiful pastel rose background
        if (currentTheme === "Black pink") return "#050406";
        return "#070709";
    }

    property color sidebarBg: {
        if (currentTheme === "Белоснежная") return "#FFF3F4F6"; // 100% opacity
        if (currentTheme === "Темная") return "#FF0A0B0E"; // Sleek solid dark gray sidebar
        if (currentTheme === "Blackout полностью черная") return "#FF000000"; 
        if (currentTheme === "Ргб") return "#FF020204"; 
        if (currentTheme === "Розовая") return "#FFF4D0D5"; // Translucent warm rose-grey sidebar
        if (currentTheme === "Black pink") return "#FF0A090D"; 
        return "#FF0A0B0E";
    }

    property color panelBg: {
        if (currentTheme === "Белоснежная") return "#CCFFFFFF"; // 80% translucent white
        if (currentTheme === "Темная") return "#F80D0E12"; // 97% opaque sleek slate-black (matching reference!)
        if (currentTheme === "Blackout полностью черная") return "#F8080808"; // 97% opaque charcoal
        if (currentTheme === "Ргб") return "#F8050508"; 
        if (currentTheme === "Розовая") return "#CCF6E9EB"; // 80% translucent warm pastel pink card
        if (currentTheme === "Black pink") return "#F80A090D"; 
        return "#F80D0E12";
    }

    property color buttonBg: {
        if (currentTheme === "Белоснежная") return "#10000000"; // 6% translucent dark on white
        if (currentTheme === "Темная") return "#16FFFFFF"; // 8.6% translucent white on slate
        if (currentTheme === "Blackout полностью черная") return "#16FFFFFF"; 
        if (currentTheme === "Ргб") return "#16FFFFFF"; 
        if (currentTheme === "Розовая") return "#40FFFFFF"; // 25% translucent white on pink
        if (currentTheme === "Black pink") return "#16FFFFFF"; 
        return "#16FFFFFF";
    }

    property color buttonBgHover: {
        if (currentTheme === "Белоснежная") return "#1D000000"; // 11.4% translucent
        if (currentTheme === "Темная") return "#26FFFFFF"; // 15% translucent white on slate
        if (currentTheme === "Blackout полностью черная") return "#26FFFFFF"; 
        if (currentTheme === "Ргб") return "#26FFFFFF"; 
        if (currentTheme === "Розовая") return "#60FFFFFF"; // 37.6% translucent white
        if (currentTheme === "Black pink") return "#26FFFFFF"; 
        return "#26FFFFFF";
    }

    property color buttonBgPressed: {
        if (currentTheme === "Белоснежная") return "#2A000000"; // 16.5% translucent
        if (currentTheme === "Темная") return "#36FFFFFF"; // 21% translucent white on slate
        if (currentTheme === "Blackout полностью черная") return "#36FFFFFF"; 
        if (currentTheme === "Ргб") return "#36FFFFFF"; 
        if (currentTheme === "Розовая") return "#80FFFFFF"; // 50% translucent white
        if (currentTheme === "Black pink") return "#36FFFFFF"; 
        return "#36FFFFFF";
    }

    property color headerBg: {
        if (currentTheme === "Белоснежная") return "#E6E5E7EB"; 
        if (currentTheme === "Темная") return "#F8070709"; // Matches solid background
        if (currentTheme === "Blackout полностью черная") return "#F8000000"; 
        if (currentTheme === "Ргб") return "#F8040406"; 
        if (currentTheme === "Розовая") return "#E6FADCE1"; 
        if (currentTheme === "Black pink") return "#F80D0B10"; 
        return "#F8070709";
    }
    
    // 2. Borders & Outlines
    property color border: {
        if (currentTheme === "Ргб") return rgbAccent;
        if (currentTheme === "Белоснежная") return "#E2E8F0";
        if (currentTheme === "Темная") return "#1C1C22"; // Extremely thin sleek border (matching reference!)
        if (currentTheme === "Blackout полностью черная") return "#141414";
        if (currentTheme === "Розовая") return "#E5CCD1";
        if (currentTheme === "Black pink") return "#26151D";
        return "#1C1C22";
    }

    property color borderHover: {
        if (currentTheme === "Ргб") return rgbAccentLight;
        if (currentTheme === "Белоснежная") return "#CBD5E1";
        if (currentTheme === "Темная") return "#2E2F38"; // Subtle high-end hover highlight (matching reference!)
        if (currentTheme === "Blackout полностью черная") return "#242424";
        if (currentTheme === "Розовая") return "#D4A3AE";
        if (currentTheme === "Black pink") return "#4C2436";
        return "#2E2F38";
    }

    property color borderGlow: {
        if (currentTheme === "Ргб") return rgbAccentGlow;
        if (currentTheme === "Белоснежная") return "#20FF9F0A";
        if (currentTheme === "Темная") return "#20FF9F0A";
        if (currentTheme === "Blackout полностью черная") return "#20FF9F0A";
        if (currentTheme === "Розовая") return "#20D48C9C";
        if (currentTheme === "Black pink") return "#20FF5E97";
        return "#20FF9F0A";
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
        if (currentTheme === "Темная") return "#8A9CB2"; // Slate blue-gray secondary
        if (currentTheme === "Blackout полностью черная") return "#A1A1A6";
        if (currentTheme === "Ргб") return "#A1A1A6";
        if (currentTheme === "Розовая") return "#6E4951";
        if (currentTheme === "Black pink") return "#E598B7";
        return "#8A9CB2";
    }

    property color textMuted: {
        if (currentTheme === "Белоснежная") return "#94A3B8";
        if (currentTheme === "Темная") return "#55677D";
        if (currentTheme === "Blackout полностью черная") return "#515154";
        if (currentTheme === "Ргб") return "#515154";
        if (currentTheme === "Розовая") return "#9C737C";
        if (currentTheme === "Black pink") return "#A37389";
        return "#55677D";
    }

    property color textInverse: {
        if (currentTheme === "Белоснежная") return "#05070B";
        if (currentTheme === "Темная") return "#05070B";
        if (currentTheme === "Blackout полностью черная") return "#000000";
        if (currentTheme === "Ргб") return "#000000";
        if (currentTheme === "Розовая") return "#3D2228";
        if (currentTheme === "Black pink") return "#050406";
        return "#05070B";
    }
    
    // 4. Accent Overhaul (Gorgeous, bug-free brand colors!)
    property color accent: {
        if (currentTheme === "Ргб") return rgbAccent;
        if (currentTheme === "Белоснежная") return "#FF9F0A"; // Amber Orange
        if (currentTheme === "Blackout полностью черная") return "#FF9F0A"; // Neon Gold
        if (currentTheme === "Розовая") return "#D48C9C"; // Premium Blush Rose Gold
        if (currentTheme === "Black pink") return "#FF5E97"; // Cyber Blush Orchid
        return "#FF9F0A"; // Default for "Темная"
    }

    property color accentLight: {
        if (currentTheme === "Ргб") return rgbAccentLight;
        if (currentTheme === "Белоснежная") return "#FFE082";
        if (currentTheme === "Blackout полностью черная") return "#FFE082";
        if (currentTheme === "Розовая") return "#E5B3BE";
        if (currentTheme === "Black pink") return "#FF85B2";
        return "#FFE082"; // Default for "Темная"
    }

    property color accentDark: {
        if (currentTheme === "Ргб") return rgbAccentDark;
        if (currentTheme === "Белоснежная") return "#FF8F00";
        if (currentTheme === "Blackout полностью черная") return "#FF8F00";
        if (currentTheme === "Розовая") return "#B26A7A";
        if (currentTheme === "Black pink") return "#D6336B";
        return "#FF8F00"; // Default for "Темная"
    }

    property color yellowAccent: {
        return accent; // Keep it unified with the main accent for dynamic consistency!
    }

    property color accentGlow: {
        if (currentTheme === "Ргб") return rgbAccentGlow;
        if (currentTheme === "Белоснежная") return "#30FF9F0A";
        if (currentTheme === "Blackout полностью черная") return "#30FF9F0A";
        if (currentTheme === "Розовая") return "#35D48C9C";
        if (currentTheme === "Black pink") return "#35FF5E97";
        return "#30FF9F0A";
    }

    property color accentDim: {
        if (currentTheme === "Ргб") return rgbAccentDim;
        if (currentTheme === "Белоснежная") return "#15FF9F0A";
        if (currentTheme === "Blackout полностью черная") return "#15FF9F0A";
        if (currentTheme === "Розовая") return "#15D48C9C";
        if (currentTheme === "Black pink") return "#15FF5E97";
        return "#15FF9F0A";
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
