import QtQuick
import MeguPackOptimizer 1.0

Item {
    id: control
    
    property string text: ""
    property bool checked: false
    property bool indeterminate: false
    property bool steamStyle: false
    
    signal toggled(bool isChecked)
    
    implicitWidth: text !== "" ? 200 : 54
    implicitHeight: Math.max(28, labelText.visible ? labelText.height + 4 : 24)
    
    opacity: enabled ? 1.0 : 0.4
    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
    
    // --- Dynamic Proportion Metrics ---
    readonly property real thumbPadding: Math.max(3, Math.round(track.height * 0.1))
    readonly property real thumbSize: track.height - (thumbPadding * 2)
    
    // --- Quantum Theme Accent Colors (extracted directly from Stitch Quantum Gate Toggle) ---
    readonly property color quantumPrimary: "#4648d4"
    readonly property color quantumPrimaryContainer: "#6063ee"
    readonly property color quantumGlowColor: "#c0c1ff"
    
    // Ambient soft glow behind the entire track
    Canvas {
        id: trackGlow
        anchors.centerIn: track
        width: track.width * 2.5
        height: track.height * 4.0
        z: -2
        visible: control.checked && !control.steamStyle
        
        property bool checkedState: control.checked
        onCheckedStateChanged: requestPaint()
        
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            
            var cx = width / 2;
            var cy = height / 2;
            var r = width / 2;
            
            var grad = ctx.createRadialGradient(cx, cy, 0, cx, cy, r);
            grad.addColorStop(0.0, "rgba(96, 99, 238, 0.24)");
            grad.addColorStop(0.5, "rgba(70, 72, 212, 0.10)");
            grad.addColorStop(1.0, "rgba(0, 0, 0, 0.0)");
            
            ctx.fillStyle = grad;
            ctx.beginPath();
            ctx.arc(cx, cy, r, 0, 2 * Math.PI);
            ctx.fill();
        }
        
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    // --- Track Container ---
    Item {
        id: track
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - (labelText.visible ? labelText.width - 10 : 0)
        height: parent.height
        
        // 1. Unchecked Track Plate (cross-fades out)
        Rectangle {
            anchors.fill: parent
            radius: control.steamStyle ? 5 : height / 2
            opacity: 1.0 - thumbCanvas.checkedProgress
            
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { 
                    position: 0.0
                    color: {
                        if (control.steamStyle) return "#10161f";
                        var isLightTheme = (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая");
                        return isLightTheme ? "#eef4ff" : "#080C14";
                    }
                }
                GradientStop { 
                    position: 1.0
                    color: {
                        if (control.steamStyle) return "#10161f";
                        var isLightTheme = (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая");
                        return isLightTheme ? "#eef4ff" : "#131C2E";
                    }
                }
            }
            
            border.color: {
                if (control.steamStyle) return "#3c485c";
                var isLightTheme = (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая");
                return mouseArea.containsMouse 
                    ? (isLightTheme ? Qt.rgba(0, 166, 255, 0.3) : Qt.rgba(255, 255, 255, 0.2)) 
                    : (isLightTheme ? Qt.rgba(0, 0, 0, 0.08) : Qt.rgba(255, 255, 255, 0.08));
            }
            border.width: 1
        }
        
        // 2. Checked Track Plate (cross-fades in)
        Rectangle {
            anchors.fill: parent
            radius: control.steamStyle ? 5 : height / 2
            opacity: thumbCanvas.checkedProgress
            
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { 
                    position: 0.0
                    color: {
                        if (control.steamStyle) return "#10161f";
                        var isLightTheme = (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая");
                        return isLightTheme ? "#e5efff" : Qt.rgba(70, 72, 212, 0.12);
                    }
                }
                GradientStop { 
                    position: 1.0
                    color: {
                        if (control.steamStyle) return "#10161f";
                        var isLightTheme = (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая");
                        return isLightTheme ? "#e5efff" : Qt.rgba(96, 99, 238, 0.16);
                    }
                }
            }
            
            border.color: {
                if (control.steamStyle) return Theme.accent;
                var isLightTheme = (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая");
                return isLightTheme ? Qt.rgba(70, 72, 212, 0.3) : Qt.rgba(96, 99, 238, 0.35);
            }
            border.width: 1
        }
        
        // Soft top-left inner border for simulated neumorphic depth (sunken socket effect)
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: control.steamStyle ? 4 : (height / 2) - 1
            color: "transparent"
            border.color: {
                var isLightTheme = (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая");
                var baseColor = isLightTheme ? Qt.rgba(0, 0, 0, 0.06) : Qt.rgba(0, 0, 0, 0.2);
                return Qt.binding(function() {
                    return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseColor.a * (1.0 - thumbCanvas.checkedProgress) + 0.12 * thumbCanvas.checkedProgress);
                });
            }
            border.width: 1
            visible: !control.steamStyle
        }

        // Thumb Container
        Item {
            id: thumb
            height: control.thumbSize
            anchors.verticalCenter: parent.verticalCenter
            
            // --- 1. Pulsing Quantum Ring (Off state only, breathes and fades out) ---
            Rectangle {
                anchors.centerIn: parent
                width: parent.height
                height: parent.height
                radius: width / 2
                color: "transparent"
                border.width: 1.0
                border.color: control.steamStyle ? "#4b5a6c" : control.quantumPrimaryContainer
                visible: !control.checked && !control.steamStyle
                
                PropertyAnimation on scale {
                    running: !control.checked && !control.steamStyle
                    loops: Animation.Infinite
                    from: 0.85
                    to: 1.45
                    duration: 2500
                    easing.type: Easing.OutQuad
                }
                PropertyAnimation on opacity {
                    running: !control.checked && !control.steamStyle
                    loops: Animation.Infinite
                    from: 0.60
                    to: 0.0
                    duration: 2500
                    easing.type: Easing.OutQuad
                }
            }

            // --- 2. High-Fidelity Vector Radial Gradient Shadow Stack (Canvas) ---
            Canvas {
                id: shadowCanvas
                anchors.centerIn: parent
                width: parent.height * 5.0
                height: parent.height * 5.0
                z: -1
                visible: !control.steamStyle
                
                property real checkedProgress: thumbCanvas.checkedProgress
                onCheckedProgressChanged: requestPaint()
                
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    
                    var cx = width / 2;
                    var cy = height / 2;
                    
                    if (checkedProgress > 0.0) {
                        ctx.save();
                        ctx.globalAlpha = checkedProgress;
                        
                        // Quantum Gate Active Glow: 0 0 30px var(--tw-colors-primary-fixed-dim)
                        var glowRadius = thumb.height * (30.0 / 44.0) * 2.0;
                        
                        var grad = ctx.createRadialGradient(cx, cy, 0, cx, cy, glowRadius);
                        grad.addColorStop(0.0, "rgba(192, 193, 255, 0.45)"); // Primary fixed dim glow
                        grad.addColorStop(0.3, "rgba(70, 72, 212, 0.22)");   // Primary glow
                        grad.addColorStop(0.7, "rgba(70, 72, 212, 0.05)");
                        grad.addColorStop(1.0, "rgba(0, 0, 0, 0.0)");
                        
                        ctx.fillStyle = grad;
                        ctx.beginPath();
                        ctx.arc(cx, cy, glowRadius, 0, 2 * Math.PI);
                        ctx.fill();
                        
                        ctx.restore();
                    } else {
                        // Inactive soft drop shadow
                        ctx.save();
                        ctx.globalAlpha = 1.0;
                        
                        var darkY = cy + (thumb.height * (2.0 / 44.0));
                        var darkRadius = thumb.height * (12.0 / 44.0) * 1.5;
                        
                        var gradDark = ctx.createRadialGradient(cx, darkY, 0, cx, darkY, darkRadius);
                        gradDark.addColorStop(0.0, "rgba(13, 28, 45, 0.12)");
                        gradDark.addColorStop(0.5, "rgba(13, 28, 45, 0.04)");
                        gradDark.addColorStop(1.0, "rgba(0, 0, 0, 0.0)");
                        
                        ctx.fillStyle = gradDark;
                        ctx.beginPath();
                        ctx.arc(cx, darkY, darkRadius, 0, 2 * Math.PI);
                        ctx.fill();
                        
                        ctx.restore();
                    }
                }
                
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
            }
            
            // --- 3. Pure 2D Canvas-Based Quantum Gate Morphing Thumb ---
            Canvas {
                id: thumbCanvas
                anchors.fill: parent
                
                property real checkedProgress: control.checked ? 1.0 : 0.0
                
                Behavior on checkedProgress {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
                
                // Ring scale expands smoothly from 1.0 to 1.15 when active (Quantum Ring scaling!)
                scale: control.steamStyle ? 1.0 : (1.0 + (0.15 * checkedProgress))
                Behavior on scale { 
                    NumberAnimation { 
                        duration: 250 
                        easing.type: Easing.OutQuad 
                    } 
                }
                
                onCheckedProgressChanged: requestPaint()
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    
                    var cx = width / 2;
                    var cy = height / 2;
                    var r = height / 2; // Keep perfectly circular
                    
                    // --- 1. Draw Hollow Quantum Ring ---
                    ctx.save();
                    
                    // Stroke color interpolates from grey (unchecked) to quantumPrimary (checked)
                    var isLightTheme = (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая");
                    var borderUnchecked = isLightTheme ? "rgba(13, 28, 45, 0.35)" : "rgba(255, 255, 255, 0.35)";
                    var borderChecked = control.quantumPrimary.toString();
                    
                    ctx.beginPath();
                    ctx.arc(cx, cy, r - 1.0, 0, 2 * Math.PI);
                    
                    // Set stroke gradient or interpolated color
                    ctx.strokeStyle = isLightTheme 
                        ? (control.checked ? "rgba(70, 72, 212, 0.85)" : borderUnchecked)
                        : (control.checked ? "rgba(192, 193, 255, 0.90)" : borderUnchecked);
                        
                    ctx.lineWidth = control.steamStyle ? 0.0 : (control.checked ? 1.6 : 1.2);
                    
                    // If not steam style, fill background with transparent/hollow color
                    if (!control.steamStyle) {
                        ctx.fillStyle = "transparent";
                        ctx.fill();
                    } else {
                        // Steam style has solid fill
                        var gradSteam = ctx.createLinearGradient(0, 0, width, height);
                        gradSteam.addColorStop(0.0, control.checked ? "#FFFFFF" : "#5d6d7e");
                        gradSteam.addColorStop(1.0, control.checked ? "#E2E8F0" : "#4b5a6c");
                        ctx.fillStyle = gradSteam;
                        ctx.fill();
                    }
                    
                    if (!control.steamStyle) {
                        ctx.stroke();
                    }
                    ctx.restore();
                    
                    // --- 2. Draw Dense Core (fades in and expands inside ring when checked) ---
                    if (checkedProgress > 0.0 && !control.steamStyle) {
                        ctx.save();
                        ctx.globalAlpha = checkedProgress;
                        
                        // Dense core expands slightly outside the ring boundaries (up to inset -20%, which is scale 1.4x)
                        var coreRadius = r * 1.25;
                        var gradCore = ctx.createRadialGradient(cx, cy, 0, cx, cy, coreRadius);
                        
                        // Matches: radial-gradient(circle, var(--tw-colors-primary-container) 0%, transparent 70%)
                        gradCore.addColorStop(0.0, "rgba(96, 99, 238, 0.85)"); // Intense primary-container
                        gradCore.addColorStop(0.4, "rgba(70, 72, 212, 0.40)");
                        gradCore.addColorStop(0.7, "rgba(70, 72, 212, 0.12)");
                        gradCore.addColorStop(1.0, "rgba(0, 0, 0, 0.0)");
                        
                        ctx.fillStyle = gradCore;
                        ctx.beginPath();
                        ctx.arc(cx, cy, coreRadius, 0, 2 * Math.PI);
                        ctx.fill();
                        
                        ctx.restore();
                    }
                }
            }
        }
    }
    
    // Label Text
    Text {
        id: labelText
        text: control.text
        color: Theme.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: 13
        font.bold: false
        
        anchors.left: track.right
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        
        wrapMode: Text.WordWrap
        visible: control.text !== ""
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: control.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (control.enabled) {
                var nextState = control.indeterminate ? true : !control.checked;
                control.toggled(nextState);
            }
        }
    }

    // --- State and Transition System for Coordinated Smooth Squish and Motion ---
    state: control.indeterminate ? "indeterminate" : (control.checked ? "checked" : "unchecked")

    states: [
        State {
            name: "unchecked"
            PropertyChanges { target: thumb; x: control.thumbPadding; width: control.thumbSize }
        },
        State {
            name: "checked"
            PropertyChanges { target: thumb; x: track.width - control.thumbSize - control.thumbPadding; width: control.thumbSize }
        },
        State {
            name: "indeterminate"
            PropertyChanges { target: thumb; x: (track.width - control.thumbSize) / 2; width: control.thumbSize }
        }
    ]

    transitions: [
        Transition {
            from: "unchecked"; to: "checked"
            ParallelAnimation {
                NumberAnimation {
                    target: thumb
                    property: "x"
                    duration: 320
                    easing.type: Easing.OutQuint // Luxurious decelerating slide
                }
                SequentialAnimation {
                    // Quick stretch during the first part of the slide
                    NumberAnimation {
                        target: thumb
                        property: "width"
                        to: control.thumbSize * 1.44
                        duration: 120
                        easing.type: Easing.OutQuad
                    }
                    // Slow recovery as it lands
                    NumberAnimation {
                        target: thumb
                        property: "width"
                        to: control.thumbSize
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                }
            }
        },
        Transition {
            from: "checked"; to: "unchecked"
            ParallelAnimation {
                NumberAnimation {
                    target: thumb
                    property: "x"
                    duration: 320
                    easing.type: Easing.OutQuint
                }
                SequentialAnimation {
                    NumberAnimation {
                        target: thumb
                        property: "width"
                        to: control.thumbSize * 1.44
                        duration: 120
                        easing.type: Easing.OutQuad
                    }
                    NumberAnimation {
                        target: thumb
                        property: "width"
                        to: control.thumbSize
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                }
            }
        }
    ]
}
