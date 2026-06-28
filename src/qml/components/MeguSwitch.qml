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
    
    // Soft outer neon glow behind the track (horizontal purple-to-cyan gradient matching the mockup)
    Rectangle {
        anchors.centerIn: track
        width: track.width + 6
        height: track.height + 6
        radius: track.radius + 3
        
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(162, 82, 248, 0.22) } // Purple glow (left)
            GradientStop { position: 1.0; color: Qt.rgba(0, 210, 255, 0.32) }  // Cyan glow (right)
        }
        
        opacity: (control.checked && !control.steamStyle) ? (mouseArea.containsMouse ? 1.0 : 0.65) : 0.0
        visible: opacity > 0.0
        
        Behavior on opacity { 
            NumberAnimation { 
                duration: 250 
                easing.type: Easing.OutQuad 
            } 
        }
    }

    Rectangle {
        id: track
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - (labelText.visible ? labelText.width - 10 : 0)
        height: parent.height
        radius: control.steamStyle ? 5 : height / 2 // Perfect capsule
        
        color: "transparent" // Controlled entirely by gradient
        
        gradient: Gradient {
            orientation: (control.checked && !control.steamStyle) ? Gradient.Horizontal : Gradient.Vertical
            
            GradientStop { 
                position: 0.0
                color: {
                    if (control.steamStyle) return "#10161f";
                    var isLightTheme = (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая");
                    if (control.checked) {
                        return isLightTheme ? "#e5efff" : Qt.rgba(162, 82, 248, 0.12); // Soft purple (left)
                    }
                    return isLightTheme ? "#eef4ff" : "#080C14"; // Recessed top shade
                }
            }
            GradientStop { 
                position: 1.0
                color: {
                    if (control.steamStyle) return "#10161f";
                    var isLightTheme = (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая");
                    if (control.checked) {
                        return isLightTheme ? "#e5efff" : Qt.rgba(0, 210, 255, 0.16);  // Soft cyan (right)
                    }
                    return isLightTheme ? "#eef4ff" : "#131C2E"; // Lighter bottom
                }
            }
        }
        
        border.color: {
            if (control.steamStyle) {
                return control.checked ? Theme.accent : (mouseArea.containsMouse ? Theme.borderHover : "#3c485c");
            }
            if (control.checked) {
                return Qt.rgba(0, 210, 255, 0.25); // Extremely soft, premium cyan border matching the mockup
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

        // Soft glowing aura behind the thumb (simulates the light bleed / glow of the glass orb)
        Rectangle {
            anchors.centerIn: thumb
            width: thumb.width + 6
            height: thumb.height + 6
            radius: width / 2
            
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Qt.rgba(162, 82, 248, 0.35) } // Purple bleed
                GradientStop { position: 1.0; color: Qt.rgba(0, 210, 255, 0.45) }  // Cyan bleed
            }
            
            opacity: (control.checked && !control.steamStyle) ? 1.0 : 0.0
            visible: opacity > 0.0
            
            Behavior on opacity { 
                NumberAnimation { 
                    duration: 250 
                    easing.type: Easing.OutQuad 
                } 
            }
        }

        // Thumb circle
        Rectangle {
            id: thumb
            height: control.thumbSize
            radius: control.steamStyle ? 4 : height / 2 // Perfect pill rounded shape
            
            // Base background gradient of the thumb (smooth 3D plastic ball for unchecked state)
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: {
                        if (control.steamStyle) return control.checked ? "#FFFFFF" : "#5d6d7e";
                        return "#FFFFFF"; // Solid white top
                    }
                }
                GradientStop {
                    position: 1.0
                    color: {
                        if (control.steamStyle) return control.checked ? "#E2E8F0" : "#4b5a6c";
                        var isLightTheme = (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая");
                        return isLightTheme ? "#F1F5F9" : "#CBD5E1"; // Soft shadow at the bottom of unchecked marble
                    }
                }
            }
            
            border.color: "transparent"
            border.width: 0
            anchors.verticalCenter: parent.verticalCenter
            
            // Specular top highlight line for glossy 3D look in standard style (inset 0 2px 4px #ffffff)
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 1
                height: 1
                radius: 0.5
                color: "#FFFFFF"
                opacity: 0.5
                visible: !control.steamStyle
            }

            // --- Glassmorphic Glowing Checked Sphere (pure vector horizontal gradient, zero RHI bugs) ---
            Rectangle {
                id: checkedSphere
                anchors.fill: parent
                radius: parent.radius
                opacity: (control.checked && !control.steamStyle) ? 1.0 : 0.0
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
                
                // 1. Base Gradient (completely opaque, vibrant purple-to-cyan matching the mockup)
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#B766FF" } // Glowing purple
                    GradientStop { position: 1.0; color: "#00F0FF" } // Glowing cyan
                }
                
                // 2. Inner Glass Border (simulates light refraction at the edge of the glass sphere)
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "transparent"
                    border.color: Qt.rgba(255, 255, 255, 0.25)
                    border.width: 1
                }
                
                // 3. Diffused white specular core (kept circular and anchored to top-left for realistic reflection)
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: parent.height * 0.1
                    anchors.leftMargin: parent.height * 0.1
                    width: parent.height * 0.65
                    height: parent.height * 0.65
                    radius: width / 2
                    rotation: -45
                    
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(255, 255, 255, 0.90) } // Intense white top-left
                        GradientStop { position: 0.4; color: Qt.rgba(255, 255, 255, 0.55) } // Diffused glow
                        GradientStop { position: 0.8; color: Qt.rgba(255, 255, 255, 0.10) } // Fading edge
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
                
                // 4. Center hot-spot highlight (positioned on top-left to make the reflection pop)
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: parent.height * 0.22
                    anchors.leftMargin: parent.height * 0.22
                    width: parent.height * 0.25
                    height: parent.height * 0.25
                    radius: width / 2
                    color: "#FFFFFF"
                    opacity: 0.8
                }
            }
            
            // --- Simulated Checked Gaussian Blur Glow Stack (zero RHI bugs, extremely soft & premium) ---
            // Glow Layer 1 (Largest, most diffused ambient bloom)
            Rectangle {
                anchors.centerIn: parent
                width: parent.height + 12
                height: parent.height + 12
                radius: width / 2
                color: control.checked ? "#00D2FF" : "transparent"
                opacity: control.checked ? 0.05 : 0.0
                z: -4
                visible: !control.steamStyle
                Behavior on opacity { NumberAnimation { duration: 250 } }
            }
            
            // Glow Layer 2 (Medium diffused ambient bloom)
            Rectangle {
                anchors.centerIn: parent
                width: parent.height + 8
                height: parent.height + 8
                radius: width / 2
                color: control.checked ? "#00D2FF" : "transparent"
                opacity: control.checked ? 0.10 : 0.0
                z: -3
                visible: !control.steamStyle
                Behavior on opacity { NumberAnimation { duration: 250 } }
            }

            // Glow Layer 3 (Inner cyan shadow layer, shifted down)
            Rectangle {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 1.5 // Shift down for y-offset shadow
                width: parent.height + 4
                height: parent.height + 4
                radius: width / 2
                color: control.checked ? "#00D2FF" : "transparent"
                opacity: control.checked ? 0.22 : 0.0
                z: -2
                visible: !control.steamStyle
                Behavior on opacity { NumberAnimation { duration: 250 } }
            }

            // Glow Layer 4 (Core purple shadow layer, shifted down)
            Rectangle {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 1.0 // Shift down for y-offset shadow
                width: parent.height + 1
                height: parent.height + 1
                radius: width / 2
                color: control.checked ? "#A252F8" : "transparent"
                opacity: control.checked ? 0.30 : 0.0
                z: -1
                visible: !control.steamStyle
                Behavior on opacity { NumberAnimation { duration: 250 } }
            }

            // --- Unchecked State Shadow Stack (soft dark navy shadows) ---
            // Unchecked Shadow Layer 1 (Outer soft shadow)
            Rectangle {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 1.5
                width: parent.height + 3
                height: parent.height + 3
                radius: width / 2
                color: "#0D1C2D"
                opacity: (!control.checked && !control.steamStyle) ? 0.12 : 0.0
                z: -2
                visible: !control.steamStyle
                Behavior on opacity { NumberAnimation { duration: 250 } }
            }
            
            // Unchecked Shadow Layer 2 (Inner crisp shadow)
            Rectangle {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 0.8
                width: parent.height
                height: parent.height
                radius: width / 2
                color: "#0D1C2D"
                opacity: (!control.checked && !control.steamStyle) ? 0.18 : 0.0
                z: -1
                visible: !control.steamStyle
                Behavior on opacity { NumberAnimation { duration: 250 } }
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
