import QtQuick
import MeguPackOptimizer 1.0

Item {
    id: control
    
    property string text: ""
    property bool checked: false
    property bool indeterminate: false
    property bool steamStyle: false
    
    signal toggled(bool isChecked)
    
    implicitWidth: text !== "" ? 200 : height
    implicitHeight: Math.max(28, labelText.visible ? labelText.height + 4 : 24)
    
    opacity: enabled ? 1.0 : 0.4
    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
    
    // --- Quantum Theme Accent Colors (extracted directly from Stitch Quantum Gate Toggle) ---
    readonly property color quantumPrimary: "#4648d4"
    readonly property color quantumPrimaryContainer: "#6063ee"
    readonly property color quantumGlowColor: "#c0c1ff"
    

    
    // Smooth check transition progress (0.0 to 1.0)
    property real checkedProgress: control.checked ? 1.0 : 0.0
    Behavior on checkedProgress {
        NumberAnimation {
            duration: 350
            easing.type: Easing.InOutQuad
        }
    }

    // --- Quantum Gate Button (Perfect Circle, aligned to the right) ---
    Item {
        id: quantumButton
        width: parent.height
        height: parent.height
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        
        // --- 1. Ambient Background Glow (matching the #ambient-glow class from Stitch) ---
        Canvas {
            id: ambientGlow
            anchors.centerIn: parent
            width: parent.height * 4.0
            height: parent.height * 4.0
            z: -3
            visible: !control.steamStyle
            
            property real progress: control.checkedProgress
            onProgressChanged: requestPaint()
            
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                
                var cx = width / 2;
                var cy = height / 2;
                var maxR = width / 2;
                
                ctx.save();
                // Interpolate ambient glow size and intensity: w-300 bg-primary/5 blur-100 to w-600 bg-primary/20 blur-120
                var currentGlowOpacity = 0.05 + (0.15 * progress);
                var currentGlowRadius = maxR * (0.6 + (0.4 * progress));
                
                var grad = ctx.createRadialGradient(cx, cy, 0, cx, cy, currentGlowRadius);
                grad.addColorStop(0.0, "rgba(70, 72, 212, " + currentGlowOpacity + ")");
                grad.addColorStop(0.5, "rgba(70, 72, 212, " + (currentGlowOpacity * 0.4) + ")");
                grad.addColorStop(1.0, "rgba(0, 0, 0, 0.0)");
                
                ctx.fillStyle = grad;
                ctx.beginPath();
                ctx.arc(cx, cy, currentGlowRadius, 0, 2 * Math.PI);
                ctx.fill();
                
                ctx.restore();
            }
        }

        // --- 2. Pulsing Ring (Off state only, breathes and fades out) ---
        Rectangle {
            anchors.centerIn: parent
            width: parent.height
            height: parent.height
            radius: width / 2
            color: "transparent"
            border.width: 1.0
            border.color: control.quantumPrimary
            opacity: (!control.checked && !control.steamStyle) ? 0.35 : 0.0
            visible: opacity > 0.0
            z: -2
            
            PropertyAnimation on scale {
                running: !control.checked && !control.steamStyle
                loops: Animation.Infinite
                from: 0.80
                to: 1.25
                duration: 3000
                easing.type: Easing.OutQuad
            }
            PropertyAnimation on opacity {
                running: !control.checked && !control.steamStyle
                loops: Animation.Infinite
                from: 0.50
                to: 0.0
                duration: 3000
                easing.type: Easing.OutQuad
            }
        }

        // --- 3. High-Fidelity Vector Radial Shadow Stack (Canvas) ---
        Canvas {
            id: shadowCanvas
            anchors.centerIn: parent
            width: parent.height * 5.0
            height: parent.height * 5.0
            z: -1
            visible: !control.steamStyle
            
            property real progress: control.checkedProgress
            onProgressChanged: requestPaint()
            
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                
                var cx = width / 2;
                var cy = height / 2;
                
                if (progress > 0.0) {
                    ctx.save();
                    ctx.globalAlpha = progress;
                    
                    // state-on shadow: box-shadow: 0 0 30px var(--tw-colors-primary-fixed-dim), inset 0 0 20px var(--tw-colors-primary)
                    var glowRadius = thumb.height * (30.0 / 44.0) * 2.2;
                    var grad = ctx.createRadialGradient(cx, cy, 0, cx, cy, glowRadius);
                    grad.addColorStop(0.0, "rgba(192, 193, 255, 0.45)"); // Primary fixed dim glow
                    grad.addColorStop(0.4, "rgba(70, 72, 212, 0.22)");   // Primary glow
                    grad.addColorStop(0.7, "rgba(70, 72, 212, 0.05)");
                    grad.addColorStop(1.0, "rgba(0, 0, 0, 0.0)");
                    
                    ctx.fillStyle = grad;
                    ctx.beginPath();
                    ctx.arc(cx, cy, glowRadius, 0, 2 * Math.PI);
                    ctx.fill();
                    
                    ctx.restore();
                } else {
                    // Soft default drop shadow
                    ctx.save();
                    
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

        // --- 4. The Quantum Gate Ring & Dense Core ---
        Item {
            id: thumb
            anchors.fill: parent
            
            // Ring smoothly scales up to 1.1x when checked (Quantum Ring scale!)
            scale: control.steamStyle ? 1.0 : (1.0 + (0.10 * control.checkedProgress))
            Behavior on scale { 
                NumberAnimation { 
                    duration: 300 
                    easing.type: Easing.OutQuad 
                } 
            }
            
            // Base Ring (Hollow Circle)
            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "transparent"
                
                border.width: control.steamStyle ? 0.0 : (control.checked ? 1.5 : 1.0)
                border.color: {
                    if (control.steamStyle) return "transparent";
                    if (control.checked) {
                        return control.quantumPrimary;
                    }
                    var isLightTheme = (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая");
                    return isLightTheme ? Qt.rgba(13, 28, 45, 0.22) : Qt.rgba(255, 255, 255, 0.22);
                }
                
                Behavior on border.color { ColorAnimation { duration: 300 } }
                Behavior on border.width { NumberAnimation { duration: 300 } }
                
                // Steam style solid thumb fill fallback
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    visible: control.steamStyle
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: control.checked ? "#FFFFFF" : "#5d6d7e" }
                        GradientStop { position: 1.0; color: control.checked ? "#E2E8F0" : "#4b5a6c" }
                    }
                }
            }

            
            // --- 6. Dense Glowing Core (Expands and fades in at center when checked) ---
            Canvas {
                id: denseCore
                anchors.centerIn: parent
                // Dense core size matches inset -20% from Stitch, so 140% of parent height!
                width: parent.height * 1.4
                height: parent.height * 1.4
                visible: !control.steamStyle
                
                // Scale core from 0.1 to 1.0
                scale: 0.1 + (0.9 * control.checkedProgress)
                opacity: control.checkedProgress
                
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    
                    var cx = width / 2;
                    var cy = height / 2;
                    var r = width / 2;
                    
                    ctx.save();
                    
                    // Radial gradient representing var(--tw-colors-primary-container) with mix-blend-screen
                    var grad = ctx.createRadialGradient(cx, cy, 0, cx, cy, r);
                    grad.addColorStop(0.0, "rgba(96, 99, 238, 0.85)"); // Luminous core center
                    grad.addColorStop(0.4, "rgba(70, 72, 212, 0.35)");   // Soft violet bloom
                    grad.addColorStop(0.7, "rgba(70, 72, 212, 0.08)");
                    grad.addColorStop(1.0, "rgba(0, 0, 0, 0.0)");
                    
                    ctx.fillStyle = grad;
                    ctx.beginPath();
                    ctx.arc(cx, cy, r, 0, 2 * Math.PI);
                    ctx.fill();
                    
                    ctx.restore();
                }
                
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
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
        
        anchors.left: parent.left
        anchors.right: quantumButton.left
        anchors.rightMargin: 10
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
}
