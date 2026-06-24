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
        if (currentTheme === "Белоснежная") return "#F8FAFC";
        if (currentTheme === "Темная") return "#07080C"; // Obsidian midnight-deep
        if (currentTheme === "Blackout полностью черная") return "#000000";
        if (currentTheme === "Ргб") return "#040508";
        if (currentTheme === "Розовая") return "#FFF0F3"; // Pastel rose
        if (currentTheme === "Black pink") return "#07050A"; // Obsidian cyberpunk void
        return "#07080C";
    }

    property color gradientStart: {
        if (currentTheme === "Белоснежная") return "#E0F2FE"; // Light glacier sky
        if (currentTheme === "Темная") return "#052636"; // Glacier aurora teal-blue glow
        if (currentTheme === "Blackout полностью черная") return "#000000";
        if (currentTheme === "Ргб") return Qt.hsla(rgbHue, 0.65, 0.15, 1.0);
        if (currentTheme === "Розовая") return "#FFE3E8"; // Soft pink glow
        if (currentTheme === "Black pink") return "#2B0516"; // Cyber orchid magenta glow
        return "#052636";
    }

    property color gradientEnd: {
        if (currentTheme === "Белоснежная") return "#FFFFFF";
        if (currentTheme === "Темная") return "#040406"; // Deepest dark
        if (currentTheme === "Blackout полностью черная") return "#000000";
        if (currentTheme === "Ргб") return "#040508";
        if (currentTheme === "Розовая") return "#FFF0F3";
        if (currentTheme === "Black pink") return "#07050A";
        return "#040406";
    }

    property color sidebarBg: {
        if (currentTheme === "Белоснежная") return "#FFE2E8F0"; 
        if (currentTheme === "Темная") return "#FF090B10"; // Slate-black sidebar
        if (currentTheme === "Blackout полностью черная") return "#FF000000"; 
        if (currentTheme === "Ргб") return "#FF020204"; 
        if (currentTheme === "Розовая") return "#FFFFECEF"; 
        if (currentTheme === "Black pink") return "#FF09070D"; 
        return "#FF090B10";
    }

    property color panelBg: {
        if (currentTheme === "Белоснежная") return "#E6FFFFFF"; // 90% Translucent White
        if (currentTheme === "Темная") return "#E60B0E14"; // 90% Translucent Obsidian Glass
        if (currentTheme === "Blackout полностью черная") return "#E6080808"; 
        if (currentTheme === "Ргб") return "#E6050508"; 
        if (currentTheme === "Розовая") return "#E6FFEBF0"; 
        if (currentTheme === "Black pink") return "#E60D0B12"; 
        return "#E60B0E14";
    }

    property color buttonBg: {
        if (currentTheme === "Белоснежная") return "#0D000000"; // 5% dark
        if (currentTheme === "Темная") return "#0CFFFFFF"; // 4.7% white
        if (currentTheme === "Blackout полностью черная") return "#10FFFFFF"; 
        if (currentTheme === "Ргб") return "#0CFFFFFF"; 
        if (currentTheme === "Розовая") return "#20FF758F"; // Tinted rose
        if (currentTheme === "Black pink") return "#1CFFFFFF"; 
        return "#0CFFFFFF";
    }

    property color buttonBgHover: {
        if (currentTheme === "Белоснежная") return "#15000000";
        if (currentTheme === "Темная") return "#17FFFFFF"; // 9% white
        if (currentTheme === "Blackout полностью черная") return "#1BFFFFFF"; 
        if (currentTheme === "Ргб") return "#17FFFFFF"; 
        if (currentTheme === "Розовая") return "#35FF758F"; 
        if (currentTheme === "Black pink") return "#28FFFFFF"; 
        return "#17FFFFFF";
    }

    property color buttonBgPressed: {
        if (currentTheme === "Белоснежная") return "#22000000";
        if (currentTheme === "Темная") return "#24FFFFFF"; // 14% white
        if (currentTheme === "Blackout полностью черная") return "#28FFFFFF"; 
        if (currentTheme === "Ргб") return "#24FFFFFF"; 
        if (currentTheme === "Розовая") return "#50FF758F"; 
        if (currentTheme === "Black pink") return "#38FFFFFF"; 
        return "#24FFFFFF";
    }

    property color headerBg: {
        if (currentTheme === "Белоснежная") return "#F1F5F9"; 
        if (currentTheme === "Темная") return "#F807080C"; 
        if (currentTheme === "Blackout полностью черная") return "#F8000000"; 
        if (currentTheme === "Ргб") return "#F8040508"; 
        if (currentTheme === "Розовая") return "#FFF0F3"; 
        if (currentTheme === "Black pink") return "#F807050A"; 
        return "#F807080C";
    }
    
    // 2. Borders & Outlines
    property color border: {
        if (currentTheme === "Ргб") return rgbAccent;
        if (currentTheme === "Белоснежная") return "#E2E8F0";
        if (currentTheme === "Темная") return "#182232"; // Fine glacier slate border
        if (currentTheme === "Blackout полностью черная") return "#141414";
        if (currentTheme === "Розовая") return "#F7C5D0";
        if (currentTheme === "Black pink") return "#2A1522";
        return "#182232";
    }

    property color borderHover: {
        if (currentTheme === "Ргб") return rgbAccentLight;
        if (currentTheme === "Белоснежная") return "#94A3B8";
        if (currentTheme === "Темная") return "#283A54"; // Active cold highlight
        if (currentTheme === "Blackout полностью черная") return "#282828";
        if (currentTheme === "Розовая") return "#FF85A2";
        if (currentTheme === "Black pink") return "#522541";
        return "#283A54";
    }

    property color borderGlow: {
        if (currentTheme === "Ргб") return rgbAccentGlow;
        if (currentTheme === "Белоснежная") return "#200284C7";
        if (currentTheme === "Темная") return "#3000FFC4"; // Mint glow
        if (currentTheme === "Blackout полностью черная") return "#3000FF87";
        if (currentTheme === "Розовая") return "#30FF758F";
        if (currentTheme === "Black pink") return "#30FF2A85";
        return "#3000FFC4";
    }
    
    // 3. Text Colors
    property color textPrimary: {
        if (currentTheme === "Белоснежная") return "#0F172A"; // Deep slate
        if (currentTheme === "Темная") return "#F1F5F9"; // Cool glacier white
        if (currentTheme === "Blackout полностью черная") return "#FFFFFF";
        if (currentTheme === "Ргб") return "#FFFFFF";
        if (currentTheme === "Розовая") return "#3D1B22";
        if (currentTheme === "Black pink") return "#F8F9FA";
        return "#F1F5F9";
    }

    property color textSecondary: {
        if (currentTheme === "Белоснежная") return "#475569";
        if (currentTheme === "Темная") return "#94A3B8"; // Medium slate-blue
        if (currentTheme === "Blackout полностью черная") return "#A1A1A6";
        if (currentTheme === "Ргб") return "#A1A1A6";
        if (currentTheme === "Розовая") return "#8E5764";
        if (currentTheme === "Black pink") return "#D63384";
        return "#94A3B8";
    }

    property color textMuted: {
        if (currentTheme === "Белоснежная") return "#94A3B8";
        if (currentTheme === "Темная") return "#64748B"; // Subdued slate
        if (currentTheme === "Blackout полностью черная") return "#515154";
        if (currentTheme === "Ргб") return "#515154";
        if (currentTheme === "Розовая") return "#B88B96";
        if (currentTheme === "Black pink") return "#864B6B";
        return "#64748B";
    }

    property color textInverse: {
        if (currentTheme === "Белоснежная") return "#FFFFFF";
        if (currentTheme === "Темная") return "#040508"; // Contrast black for toggles
        if (currentTheme === "Blackout полностью черная") return "#000000";
        if (currentTheme === "Ргб") return "#000000";
        if (currentTheme === "Розовая") return "#FFFFFF";
        if (currentTheme === "Black pink") return "#000000";
        return "#040508";
    }
    
    // 4. Accent Overhaul
    property color accent: {
        if (currentTheme === "Ргб") return rgbAccent;
        if (currentTheme === "Белоснежная") return "#0284C7"; // Royal blue
        if (currentTheme === "Blackout полностью черная") return "#00FF87"; // Neon Emerald
        if (currentTheme === "Розовая") return "#FF758F"; // Cyber Pink
        if (currentTheme === "Black pink") return "#FF2A85"; // Neon Pink
        return "#00FFD2"; // Mint-cyan default for "Темная"
    }

    property color accentLight: {
        if (currentTheme === "Ргб") return rgbAccentLight;
        if (currentTheme === "Белоснежная") return "#38BDF8";
        if (currentTheme === "Blackout полностью черная") return "#66FFB2";
        if (currentTheme === "Розовая") return "#FFA4B6";
        if (currentTheme === "Black pink") return "#FF70B0";
        return "#66FFDF"; // Light Mint
    }

    property color accentDark: {
        if (currentTheme === "Ргб") return rgbAccentDark;
        if (currentTheme === "Белоснежная") return "#0369A1";
        if (currentTheme === "Blackout полностью черная") return "#00C853";
        if (currentTheme === "Розовая") return "#D63D5C";
        if (currentTheme === "Black pink") return "#C1005E";
        return "#00B392"; // Deep Mint
    }

    property color yellowAccent: {
        return accent;
    }

    property color accentGlow: {
        if (currentTheme === "Ргб") return rgbAccentGlow;
        if (currentTheme === "Белоснежная") return "#300284C7";
        if (currentTheme === "Blackout полностью черная") return "#3000FF87";
        if (currentTheme === "Розовая") return "#30FF758F";
        if (currentTheme === "Black pink") return "#30FF2A85";
        return "#3000FFD2";
    }

    property color accentDim: {
        if (currentTheme === "Ргб") return rgbAccentDim;
        if (currentTheme === "Белоснежная") return "#150284C7";
        if (currentTheme === "Blackout полностью черная") return "#1500FF87";
        if (currentTheme === "Розовая") return "#15FF758F";
        if (currentTheme === "Black pink") return "#15FF2A85";
        return "#1500FFD2";
    }

    // 5. Compact card system
    property color cardBg: {
        if (currentTheme === "Белоснежная") return "#F2FFFFFF";
        if (currentTheme === "Blackout полностью черная") return "#F0040404";
        if (currentTheme === "Ргб") return "#EE050508";
        if (currentTheme === "Розовая") return "#F2FFE8EE";
        if (currentTheme === "Black pink") return "#F00B0810";
        return "#F00A0D13";
    }

    property color cardBgHover: {
        if (currentTheme === "Белоснежная") return "#FFFFFFFF";
        if (currentTheme === "Blackout полностью черная") return "#FF070707";
        if (currentTheme === "Ргб") return "#FF080911";
        if (currentTheme === "Розовая") return "#FFFFF1F5";
        if (currentTheme === "Black pink") return "#FF100B17";
        return "#FF0E131D";
    }

    property color cardStroke: {
        if (currentTheme === "Белоснежная") return "#D7E2E8F0";
        if (currentTheme === "Blackout полностью черная") return "#FF171717";
        if (currentTheme === "Ргб") return rgbAccentDim;
        if (currentTheme === "Розовая") return "#E6F7BBC9";
        if (currentTheme === "Black pink") return "#FF301526";
        return "#D71A2638";
    }

    property color cardStrokeHover: {
        if (currentTheme === "Белоснежная") return "#B30284C7";
        if (currentTheme === "Blackout полностью черная") return "#8800FF87";
        if (currentTheme === "Ргб") return rgbAccentLight;
        if (currentTheme === "Розовая") return "#B3FF758F";
        if (currentTheme === "Black pink") return "#B3FF2A85";
        return "#8A00FFD2";
    }

    property color cardTopSheen: {
        if (currentTheme === "Белоснежная") return "#CCFFFFFF";
        if (currentTheme === "Розовая") return "#B3FFFFFF";
        return "#22FFFFFF";
    }

    property color cardShadow: {
        if (currentTheme === "Белоснежная") return "#260284C7";
        if (currentTheme === "Розовая") return "#24FF758F";
        if (currentTheme === "Black pink") return "#33000000";
        return "#55000000";
    }

    // 6. Functional Colors
    readonly property color success: "#10B981"
    readonly property color warning: "#F59E0B"
    readonly property color error: "#EF4444"
    readonly property color info: "#00C2FF"

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
