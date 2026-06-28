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
    
    // --- Dynamic Proportion Metrics (scales perfectly from 54x24 up to 140x56) ---
    readonly property real thumbPadding: Math.max(3, Math.round(track.height * 0.1))
    readonly property real thumbSize: track.height - (thumbPadding * 2)
    
    // Ambient soft glow behind the entire track (matching the .toggle-active-glow class from Stitch)
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
            
            // Matches the radial ambient glow from the CSS exactly:
            // radial-gradient(circle at center, rgba(0, 210, 255, 0.28) 0%, rgba(162, 82, 248, 0.14) 40%, transparent 70%)
            var grad = ctx.createRadialGradient(cx, cy, 0, cx, cy, r);
            grad.addColorStop(0.0, "rgba(0, 210, 255, 0.28)");
            grad.addColorStop(0.4, "rgba(162, 82, 248, 0.14)");
            grad.addColorStop(0.7, "rgba(162, 82, 248, 0.02)");
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
                        return isLightTheme ? "#e5efff" : Qt.rgba(162, 82, 248, 0.12);
                    }
                }
                GradientStop { 
                    position: 1.0
                    color: {
                        if (control.steamStyle) return "#10161f";
                        var isLightTheme = (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая");
                        return isLightTheme ? "#e5efff" : Qt.rgba(0, 210, 255, 0.16);
                    }
                }
            }
            
            border.color: {
                if (control.steamStyle) return Theme.accent;
                return Qt.rgba(0, 210, 255, 0.25);
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
        

        // Thumb capsule
        Item {
            id: thumb
            height: control.thumbSize
            anchors.verticalCenter: parent.verticalCenter
            
            // --- High-Fidelity Vector Radial Gradient Shadow Stack (zero banding, zero RHI bugs) ---
            Canvas {
                id: shadowCanvas
                anchors.centerIn: parent
                width: parent.height * 4.5 // Larger bounds for wide blur profile
                height: parent.height * 4.5
                z: -1
                visible: !control.steamStyle
                
                property real checkedProgress: thumbCanvas.checkedProgress
                onCheckedProgressChanged: requestPaint()
                
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    
                    var cx = width / 2;
                    var cy = height / 2;
                    
                    // --- 1. Draw Inactive State Soft Shadow ---
                    if (checkedProgress < 1.0) {
                        ctx.save();
                        ctx.globalAlpha = 1.0 - checkedProgress;
                        
                        var darkY = cy + (thumb.height * (4.0 / 44.0));
                        var darkRadius = thumb.height * (16.0 / 44.0) * 2.0;
                        
                        var gradDark = ctx.createRadialGradient(cx, darkY, 0, cx, darkY, darkRadius);
                        gradDark.addColorStop(0.0, "rgba(13, 28, 45, 0.18)");
                        gradDark.addColorStop(0.4, "rgba(13, 28, 45, 0.08)");
                        gradDark.addColorStop(1.0, "rgba(13, 28, 45, 0.0)");
                        
                        ctx.fillStyle = gradDark;
                        ctx.beginPath();
                        ctx.arc(cx, darkY, darkRadius, 0, 2 * Math.PI);
                        ctx.fill();
                        
                        ctx.restore();
                    }
                    
                    // --- 2. Draw Active State Glowing Shadows ---
                    if (checkedProgress > 0.0) {
                        ctx.save();
                        ctx.globalAlpha = checkedProgress;
                        
                        // Cyan Glow on the right side: offset y (10px on 44px thumb), blur: (24px on 44px)
                        var cyanY = cy + (thumb.height * (10.0 / 44.0));
                        var cyanRadius = thumb.height * (24.0 / 44.0) * 1.8;
                        
                        var gradCyan = ctx.createRadialGradient(cx, cyanY, 0, cx, cyanY, cyanRadius);
                        gradCyan.addColorStop(0.0, "rgba(0, 210, 255, 0.45)");
                        gradCyan.addColorStop(0.3, "rgba(0, 210, 255, 0.22)");
                        gradCyan.addColorStop(0.6, "rgba(0, 210, 255, 0.08)");
                        gradCyan.addColorStop(1.0, "rgba(0, 210, 255, 0.0)");
                        
                        ctx.fillStyle = gradCyan;
                        ctx.beginPath();
                        ctx.arc(cx, cyanY, cyanRadius, 0, 2 * Math.PI);
                        ctx.fill();
                        
                        // Purple Glow on the left side: offset y (6px on 44px thumb), blur: (12px on 44px)
                        var purpleY = cy + (thumb.height * (6.0 / 44.0));
                        var purpleRadius = thumb.height * (12.0 / 44.0) * 1.8;
                        
                        var gradPurple = ctx.createRadialGradient(cx, purpleY, 0, cx, purpleY, purpleRadius);
                        gradPurple.addColorStop(0.0, "rgba(162, 82, 248, 0.38)");
                        gradPurple.addColorStop(0.4, "rgba(162, 82, 248, 0.16)");
                        gradPurple.addColorStop(1.0, "rgba(162, 82, 248, 0.0)");
                        
                        ctx.fillStyle = gradPurple;
                        ctx.beginPath();
                        ctx.arc(cx, purpleY, purpleRadius, 0, 2 * Math.PI);
                        ctx.fill();
                        
                        ctx.restore();
                    }
                }
                
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
            }
            
            // --- Pure 2D Canvas-Based Glassmorphic Morphing Thumb (morps colors during slide!) ---
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
                
                onCheckedProgressChanged: requestPaint()
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    
                    var cx = width / 2;
                    var cy = height / 2;
                    var r = height / 2; // Radius is half-height to keep pill ends rounded
                    
                    // Capsule drawing helper path (handles circle and squished pill geometries)
                    var drawCapsule = function() {
                        ctx.beginPath();
                        ctx.moveTo(r, 0);
                        ctx.lineTo(width - r, 0);
                        ctx.arc(width - r, r, r - 0.2, 1.5 * Math.PI, 0.5 * Math.PI, false);
                        ctx.lineTo(r, height);
                        ctx.arc(r, r, r - 0.2, 0.5 * Math.PI, 1.5 * Math.PI, false);
                        ctx.closePath();
                    };
                    
                    // --- 1. Draw Unchecked State (3D White Marble) ---
                    if (checkedProgress < 1.0) {
                        ctx.save();
                        ctx.globalAlpha = 1.0 - checkedProgress;
                        
                        drawCapsule();
                        
                        var gradUnchecked = ctx.createLinearGradient(0, 0, width, height);
                        gradUnchecked.addColorStop(0.0, "#FFFFFF");
                        var isLightTheme = (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая");
                        gradUnchecked.addColorStop(1.0, isLightTheme ? "#F1F5F9" : "#CBD5E1");
                        
                        ctx.fillStyle = gradUnchecked;
                        ctx.fill();
                        
                        ctx.restore();
                    }
                    
                    // --- 2. Draw Checked State (Glowing Glass Orb) ---
                    if (checkedProgress > 0.0) {
                        ctx.save();
                        ctx.globalAlpha = checkedProgress;
                        
                        drawCapsule();
                        
                        // Base Purple-to-Cyan linear gradient (135deg diagonal matching #a252f8 to #00d2ff)
                        var gradChecked = ctx.createLinearGradient(0, 0, width, height);
                        gradChecked.addColorStop(0.0, "#a252f8"); // Premium purple-indigo
                        gradChecked.addColorStop(1.0, "#00d2ff"); // Premium sky-blue/cyan
                        
                        ctx.fillStyle = gradChecked;
                        ctx.fill();
                        
                        // Soft white core radial glow right at the center of the orb
                        var gradCore = ctx.createRadialGradient(cx, cy, 0, cx, cy, r * 0.76);
                        gradCore.addColorStop(0.0, "rgba(255, 255, 255, 0.88)");
                        gradCore.addColorStop(0.4, "rgba(255, 255, 255, 0.40)");
                        gradCore.addColorStop(0.75, "rgba(255, 255, 255, 0.08)");
                        gradCore.addColorStop(1.0, "rgba(255, 255, 255, 0.0)");
                        
                        ctx.fillStyle = gradCore;
                        ctx.beginPath();
                        ctx.arc(cx, cy, r * 0.76, 0, 2 * Math.PI);
                        ctx.fill();
                        
                        ctx.restore();
                    }
                    
                    // --- 3. Draw Common Specular Top Highlight Rim ---
                    ctx.save();
                    ctx.globalAlpha = 1.0;
                    
                    var rimGrad = ctx.createLinearGradient(cx, 0, cx, 3);
                    rimGrad.addColorStop(0.0, "rgba(255, 255, 255, 0.60)");
                    rimGrad.addColorStop(1.0, "rgba(255, 255, 255, 0.0)");
                    
                    ctx.strokeStyle = rimGrad;
                    ctx.lineWidth = 1.2;
                    ctx.beginPath();
                    ctx.arc(r, r, r - 0.75, 1.15 * Math.PI, 1.5 * Math.PI, false);
                    ctx.lineTo(width - r, 0.75);
                    ctx.arc(width - r, r, r - 0.75, 1.5 * Math.PI, 1.85 * Math.PI, false);
                    ctx.stroke();
                    
                    ctx.restore();
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
