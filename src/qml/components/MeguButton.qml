import QtQuick
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects

Item {
    id: control
    
    property string text: ""
    property string iconSource: ""
    property bool accented: false
    property bool flat: false
    property bool hasDropdown: false
    property bool dropdownOpen: false
    property real iconRotation: 0
    
    signal clicked()
    signal dropdownClicked()
    
    readonly property bool isHovered: control.enabled && (mouseArea.containsMouse || (control.hasDropdown && dropdownMouseArea.containsMouse))
    readonly property bool isPressed: control.enabled && (mouseArea.pressed || (control.hasDropdown && dropdownMouseArea.pressed))

    implicitWidth: Math.max(control.hasDropdown ? 130 : 90, buttonLayout.implicitWidth + (control.hasDropdown ? 56 : 28))
    implicitHeight: 34 // Compact and extremely clean height matching modern UI standards
    
    opacity: control.enabled ? 1.0 : 0.35
    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

    scale: control.enabled ? (control.isPressed ? 0.97 : (control.isHovered ? 1.02 : 1.0)) : 1.0
    Behavior on scale {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    // DropShadow glow for accented buttons
    DropShadow {
        anchors.fill: bg
        horizontalOffset: 0
        verticalOffset: control.accented && control.isHovered ? 4 : 2
        radius: control.accented && control.isHovered ? 12 : 6
        color: control.accented ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, control.isHovered ? 0.35 : 0.20) : "transparent"
        source: bg
        visible: control.accented && control.enabled
        
        Behavior on verticalOffset { NumberAnimation { duration: 150 } }
        Behavior on radius { NumberAnimation { duration: 150 } }
        Behavior on color { ColorAnimation { duration: 150 } }
    }
    
    // Main Button Plate
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 8 // Modern, slightly curved corners
        
        color: {
            if (!control.enabled) {
                return control.accented ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.05) : "transparent";
            }
            if (control.hasDropdown && control.dropdownOpen) {
                return Theme.panelBg;
            }
            if (control.accented) {
                return control.isPressed ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.30) : 
                       (control.isHovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.20) : 
                        Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.12));
            } else if (control.flat) {
                if (control.isPressed) return Theme.buttonBgPressed;
                if (control.isHovered) return Theme.buttonBgHover;
                return "transparent";
            } else {
                return control.isPressed ? Theme.buttonBgPressed : (control.isHovered ? Theme.buttonBgHover : Theme.buttonBg);
            }
        }
               
        border.color: {
            if (control.hasDropdown && control.dropdownOpen) {
                return Theme.border;
            }
            if (control.accented) {
                if (!control.enabled) return Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.10);
                return control.isPressed ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.50) : 
                       (control.isHovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.40) : 
                        Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25));
            }
            if (control.flat) {
                return (control.isHovered && control.enabled) ? Theme.borderHover : "transparent";
            }
            return control.isHovered ? Theme.borderHover : Theme.border;
        }
        border.width: 1
        
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }

        // Specular highlight bevel
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.color: "#15FFFFFF" // very subtle top specular edge
            border.width: 1
            anchors.margins: 1
            visible: !control.flat && control.enabled
        }

        // Seamless merge overlay for bottom corners and bottom border when dropdown is open
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 1
            anchors.rightMargin: 1
            anchors.bottomMargin: -1
            height: parent.radius + 1
            color: parent.color
            visible: control.hasDropdown && control.dropdownOpen
        }
    }
    
    // Main content area (left side of button)
    Item {
        id: mainContentArea
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: control.hasDropdown ? separatorLine.left : parent.right
        
        Row {
            id: buttonLayout
            anchors.centerIn: parent
            spacing: 6
            
            // Color-Overlaid Icon Container
            Item {
                id: iconContainer
                width: 14
                height: 14
                visible: control.iconSource !== ""
                anchors.verticalCenter: parent.verticalCenter
                rotation: control.iconRotation
                
                Image {
                    id: btnIcon
                    source: control.iconSource
                    anchors.fill: parent
                    sourceSize.width: 14
                    sourceSize.height: 14
                    visible: false
                }
                
                ColorOverlay {
                    anchors.fill: btnIcon
                    source: btnIcon
                    color: {
                        if (control.accented) return Theme.accent;
                        if (control.flat) {
                            return (mouseArea.containsMouse || dropdownMouseArea.containsMouse) ? Theme.textPrimary : Theme.textSecondary;
                        }
                        return Theme.textPrimary;
                    }
                    opacity: {
                        if (control.accented) return 1.0;
                        if (control.flat) {
                            return (mouseArea.containsMouse || dropdownMouseArea.containsMouse) ? 0.95 : 0.65;
                        }
                        return 0.85;
                    }
                    Behavior on color { ColorAnimation { duration: 100 } }
                    Behavior on opacity { NumberAnimation { duration: 100 } }
                }
            }
            
            Text {
                text: control.text
                color: {
                    if (control.accented) return Theme.textPrimary;
                    if (control.flat) {
                        return (mouseArea.containsMouse || dropdownMouseArea.containsMouse) ? Theme.textPrimary : Theme.textSecondary;
                    }
                    return Theme.textPrimary;
                }
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
                font.letterSpacing: 0.2
                Behavior on color { ColorAnimation { duration: 100 } }
            }
        }
    }
    
    // Vertical Separator
    Rectangle {
        id: separatorLine
        visible: control.hasDropdown
        width: 1
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 6
        anchors.bottomMargin: 6
        anchors.right: parent.right
        anchors.rightMargin: 28
        color: control.accented ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : Theme.border
    }
    
    // Dropdown Chevron Area
    Item {
        id: dropdownArea
        visible: control.hasDropdown
        width: 28
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        
        Item {
            id: chevronWrapper
            width: 8
            height: 8
            anchors.centerIn: parent
            rotation: control.dropdownOpen ? 90 : 0
            
            Behavior on rotation {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.InOutQuad
                }
            }

            Image {
                id: chevronIcon
                source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                anchors.fill: parent
                sourceSize.width: 8
                sourceSize.height: 8
                visible: false
            }
            
            ColorOverlay {
                anchors.fill: parent
                source: chevronIcon
                color: control.accented ? Theme.accent : ((dropdownMouseArea.containsMouse || mouseArea.containsMouse) ? Theme.textPrimary : Theme.textSecondary)
                opacity: control.accented ? 1.0 : ((dropdownMouseArea.containsMouse || mouseArea.containsMouse) ? 0.95 : 0.65)
                
                Behavior on color { ColorAnimation { duration: 100 } }
                Behavior on opacity { NumberAnimation { duration: 100 } }
            }
        }
    }
    
    // Left part click MouseArea
    MouseArea {
        id: mouseArea
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: control.hasDropdown ? separatorLine.left : parent.right
        hoverEnabled: true
        cursorShape: control.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (control.enabled) {
                control.clicked();
            }
        }
    }
    
    // Right part click MouseArea (dropdown chevron)
    MouseArea {
        id: dropdownMouseArea
        enabled: control.hasDropdown
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: control.hasDropdown ? separatorLine.left : parent.right
        hoverEnabled: true
        cursorShape: control.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (control.enabled) {
                control.dropdownClicked();
            }
        }
    }
}
