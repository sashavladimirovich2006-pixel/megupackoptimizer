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
    
    // Soft outer neon glow behind the track (zero-overhead native vector glow)
    Rectangle {
        anchors.centerIn: track
        width: track.width + 6
        height: track.height + 6
        radius: track.radius + 3
        color: "#00A6FF"
        opacity: (control.checked && !control.steamStyle) ? (mouseArea.containsMouse ? 0.24 : 0.14) : 0.0
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

        // Thumb circle
        Rectangle {
            id: thumb
            height: 18
            radius: control.steamStyle ? 4 : 9 // Perfect circle if not steam style
            
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
                        return "#CBD5E1"; // Soft shadow at the bottom of unchecked marble
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

            // --- Glassmorphic Glowing Checked Sphere (pure vector multi-layer layout, zero RHI bugs) ---
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
                
                // 1. Base Gradient (rich cyan-to-purple body)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#00E5FF" } // Glowing bright cyan
                    GradientStop { position: 0.5; color: "#0055FF" } // Vibrant blue
                    GradientStop { position: 1.0; color: "#8000FF" } // Deep purple edge
                }
                
                // 2. Specular Highlight Layer 1 (Soft overall top-left light blend, rotated for diagonal alignment)
                Rectangle {
                    width: parent.width * 0.72
                    height: parent.height * 0.72
                    radius: width / 2
                    x: parent.width * 0.07
                    y: parent.height * 0.07
                    rotation: -45
                    
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(255, 255, 255, 0.75) }
                        GradientStop { position: 0.5; color: Qt.rgba(255, 255, 255, 0.25) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
                
                // 3. Specular Highlight Layer 2 (Intense hot-spot core, rotated for diagonal alignment)
                Rectangle {
                    width: parent.width * 0.38
                    height: parent.height * 0.38
                    radius: width / 2
                    x: parent.width * 0.18
                    y: parent.height * 0.18
                    rotation: -45
                    
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(255, 255, 255, 0.95) }
                        GradientStop { position: 0.6; color: Qt.rgba(255, 255, 255, 0.40) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
            }
            
            // --- Shadow Layer 1 (inside thumb, moves and scales automatically, z: -1) ---
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: control.checked ? "#00A6FF" : "#000000"
                opacity: control.checked ? 0.35 : 0.24
                z: -1
                
                // Shift down for offset shadow
                anchors.topMargin: 1.8
                anchors.bottomMargin: -1.8
                
                visible: !control.steamStyle
                Behavior on color { ColorAnimation { duration: 250 } }
                Behavior on opacity { NumberAnimation { duration: 250 } }
            }

            // --- Shadow Layer 2 (inside thumb, moves and scales automatically, z: -2) ---
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: -1
                radius: parent.radius + 1
                color: control.checked ? "#00A6FF" : "#000000"
                opacity: control.checked ? 0.12 : 0.10
                z: -2
                
                // Shift down for offset shadow
                anchors.topMargin: 1.4
                anchors.bottomMargin: -3.4
                
                visible: !control.steamStyle
                Behavior on color { ColorAnimation { duration: 250 } }
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
            PropertyChanges { target: thumb; x: 3; width: 18 }
        },
        State {
            name: "checked"
            PropertyChanges { target: thumb; x: track.width - 18 - 3; width: 18 }
        },
        State {
            name: "indeterminate"
            PropertyChanges { target: thumb; x: (track.width - 18) / 2; width: 18 }
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
                    // Quick stretch to 26px during the first part of the slide
                    NumberAnimation {
                        target: thumb
                        property: "width"
                        to: 26
                        duration: 120
                        easing.type: Easing.OutQuad
                    }
                    // Slow recovery to 18px as it lands
                    NumberAnimation {
                        target: thumb
                        property: "width"
                        to: 18
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
                        to: 26
                        duration: 120
                        easing.type: Easing.OutQuad
                    }
                    NumberAnimation {
                        target: thumb
                        property: "width"
                        to: 18
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                }
            }
        }
    ]
}
