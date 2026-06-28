import QtQuick
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects

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
    
    // Glowing neon halo behind the track (glowing aura)
    DropShadow {
        anchors.fill: track
        horizontalOffset: 0
        verticalOffset: 0
        radius: 8
        samples: 17
        color: (control.checked && !control.steamStyle) 
            ? (mouseArea.containsMouse ? Qt.rgba(0, 166, 255, 0.35) : Qt.rgba(0, 166, 255, 0.22)) 
            : "transparent"
        source: track
        cached: true
        visible: !control.steamStyle
        
        Behavior on color {
            ColorAnimation {
                duration: 250
            }
        }
    }

    Rectangle {
        id: track
        width: 54
        height: 24
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        radius: control.steamStyle ? 5 : 12 // Perfect capsule when not steam style
        
        color: "transparent" // Controlled entirely by gradient
        
        gradient: Gradient {
            GradientStop { 
                position: 0.0
                color: {
                    if (control.steamStyle) return "#10161f";
                    if (control.checked) return Qt.rgba(0, 166, 255, 0.15);
                    var isLightTheme = (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая");
                    return isLightTheme ? "#D3DAE2" : "#080C14"; // Recessed top shade
                }
            }
            GradientStop { 
                position: 1.0
                color: {
                    if (control.steamStyle) return "#10161f";
                    if (control.checked) return Qt.rgba(0, 166, 255, 0.08);
                    var isLightTheme = (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая");
                    return isLightTheme ? "#EDF2F7" : "#131C2E"; // Lighter bottom
                }
            }
        }
        
        border.color: {
            if (control.steamStyle) {
                return control.checked ? Theme.accent : (mouseArea.containsMouse ? Theme.borderHover : "#3c485c");
            }
            if (control.checked) {
                return Qt.rgba(0, 166, 255, 0.45);
            }
            var isLightTheme = (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая");
            return mouseArea.containsMouse 
                ? (isLightTheme ? Qt.rgba(0, 166, 255, 0.3) : Qt.rgba(255, 255, 255, 0.2)) 
                : (isLightTheme ? Qt.rgba(0, 0, 0, 0.08) : Qt.rgba(255, 255, 255, 0.08));
        }
        border.width: 1
        
        Behavior on color { ColorAnimation { duration: 250 } }
        Behavior on border.color { ColorAnimation { duration: 250 } }
        
        // Indeterminate fill (keeps original behavior in accentDim)
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            opacity: (control.indeterminate && !control.steamStyle) ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
            color: Theme.accentDim
        }

        // Soft top-left inner border for simulated neumorphic depth (sunken socket effect)
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: "transparent"
            border.color: {
                if (control.checked) return Qt.rgba(0, 0, 0, 0.12);
                var isLightTheme = (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая");
                return isLightTheme ? Qt.rgba(0, 0, 0, 0.06) : Qt.rgba(0, 0, 0, 0.2);
            }
            border.width: 1
            visible: !control.steamStyle
        }

        // --- High-Performance 3D Volumetric Soft Shadow (RadialGradient instead of live DropShadow) ---
        RadialGradient {
            id: thumbShadow
            width: thumb.width + 16 // Extra width for soft fade
            height: thumb.height + 16 // Extra height for soft fade
            anchors.centerIn: thumb
            horizontalOffset: 0
            verticalOffset: 2.2
            visible: !control.steamStyle
            
            gradient: Gradient {
                GradientStop { 
                    position: 0.0 
                    color: control.checked ? Qt.rgba(0, 166, 255, 0.38) : Qt.rgba(0, 0, 0, 0.30) 
                }
                GradientStop { 
                    position: 0.35 
                    color: control.checked ? Qt.rgba(0, 166, 255, 0.12) : Qt.rgba(0, 0, 0, 0.10) 
                }
                GradientStop { 
                    position: 1.0 
                    color: "transparent" 
                }
            }
            
            Behavior on color {
                ColorAnimation {
                    duration: 250
                }
            }
        }

        // Thumb circle
        Rectangle {
            id: thumb
            width: mouseArea.pressed ? 26 : 18 // High-fidelity squish (reaches 26px when pressed)
            height: 18
            radius: control.steamStyle ? 4 : 9 // Perfect circle if not steam style
            
            // Base background gradient: adapts to steam style or outputs solid white
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: {
                        if (control.steamStyle) return control.checked ? "#FFFFFF" : "#5d6d7e";
                        return "#FFFFFF";
                    }
                }
                GradientStop {
                    position: 1.0
                    color: {
                        if (control.steamStyle) return control.checked ? "#E2E8F0" : "#4b5a6c";
                        return "#FFFFFF";
                    }
                }
            }
            
            border.color: "transparent"
            border.width: 0
            anchors.verticalCenter: parent.verticalCenter
            
            // Specular top highlight line for glossy 3D look in steam style
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 1
                height: 1
                radius: 0.5
                color: "#FFFFFF"
                opacity: 0.3
                visible: control.steamStyle
            }

            // --- Glassmorphic Glowing Checked Sphere (using OpacityMask to clip the RadialGradient to a circle) ---
            
            // 1. Mask Source (defines the shape of the clip - tracks the thumb's width/height/radius)
            Rectangle {
                id: thumbMask
                anchors.fill: parent
                radius: parent.radius
                color: "black"
                visible: false
            }

            // 2. Gradient Source (defines the colors)
            RadialGradient {
                id: checkedRadialSource
                anchors.fill: parent
                visible: false
                
                // Shift center slightly top-left to simulate light source
                horizontalOffset: -2
                verticalOffset: -2
                
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#FFFFFF" }        // Glowing white core
                    GradientStop { position: 0.25; color: "#DCEFFE" }       // Light blue reflection
                    GradientStop { position: 0.55; color: "#00A6FF" }       // Vibrant cyan body
                    GradientStop { position: 0.85; color: "#553CFF" }       // Blue-violet shade
                    GradientStop { position: 1.0; color: "#8B2CFF" }        // Deep purple outer edge
                }
            }

            // 3. Combined Masked Output
            OpacityMask {
                anchors.fill: parent
                source: checkedRadialSource
                maskSource: thumbMask
                opacity: (control.checked && !control.steamStyle) ? 1.0 : 0.0
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
            }
            
            // Slide positioning (horizontal limits: 3px padding from left/right)
            x: control.indeterminate 
                ? ((track.width - width) / 2) 
                : (control.checked ? (track.width - width - 3) : 3)
            
            Behavior on x {
                NumberAnimation {
                    duration: 320 // Ultra-smooth deceleration
                    easing.type: Easing.OutQuint
                }
            }
            Behavior on width {
                NumberAnimation {
                    duration: 280 // Organic squash & stretch timing
                    easing.type: Easing.OutQuint
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
}
