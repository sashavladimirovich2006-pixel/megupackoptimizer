import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import MeguPackOptimizer 1.0

Item {
    id: control

    property var model: []
    property int currentIndex: 0
    property string displayText: ""
    property var textFormatter: null

    signal activated(int index)

    implicitWidth: 160
    implicitHeight: 32

    readonly property bool isHovered: enabled && (mouseArea.containsMouse || dropdownPopup.opened)
    readonly property bool isPressed: enabled && mouseArea.pressed

    // Premium scale transition on hover and press
    scale: enabled ? (isPressed ? 0.97 : (isHovered ? 1.02 : 1.0)) : 1.0
    Behavior on scale {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    // Outer Glow / Shadow for the Button
    DropShadow {
        anchors.fill: bg
        horizontalOffset: 0
        verticalOffset: control.isHovered ? 4 : 1
        radius: control.isHovered ? 8 : 4
        color: control.isHovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.20) : "transparent"
        source: bg
        visible: control.isHovered && control.enabled
        
        Behavior on verticalOffset { NumberAnimation { duration: 150 } }
        Behavior on radius { NumberAnimation { duration: 150 } }
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    // Button Base Plate
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: Theme.radiusSmall
        
        color: {
            if (!control.enabled) return "transparent";
            if (dropdownPopup.opened) return Theme.panelBg;
            return control.isHovered ? Theme.buttonBgHover : Theme.buttonBg;
        }
        
        border.color: (control.isHovered || dropdownPopup.opened) ? Theme.accent : Theme.border
        border.width: 1
        
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }

        // Specular highlight bevel
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.color: "#15FFFFFF"
            border.width: 1
            anchors.margins: 1
            visible: control.enabled
        }
    }

    // Display Text Label
    Text {
        id: labelText
        text: {
            if (control.displayText !== "") {
                return control.displayText;
            }
            if (control.model && control.model.length > control.currentIndex) {
                var item = control.model[control.currentIndex];
                return control.textFormatter !== null ? control.textFormatter(item) : item.toString();
            }
            return "";
        }
        color: Theme.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: 13
        font.bold: true
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.right: chevronWrapper.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        elide: Text.ElideRight
        
        Behavior on color { ColorAnimation { duration: 100 } }
    }

    // Chevron arrow on the right
    Item {
        id: chevronWrapper
        width: 8
        height: 8
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        rotation: dropdownPopup.opened ? 270 : 90
        
        Behavior on rotation {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
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
            color: (control.isHovered || dropdownPopup.opened) ? Theme.accent : Theme.textSecondary
            opacity: (control.isHovered || dropdownPopup.opened) ? 1.0 : 0.65
            
            Behavior on color { ColorAnimation { duration: 100 } }
            Behavior on opacity { NumberAnimation { duration: 100 } }
        }
    }

    // Header Mouse Click Area
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: control.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (control.enabled) {
                if (dropdownPopup.opened) {
                    dropdownPopup.close();
                } else {
                    dropdownPopup.open();
                }
            }
        }
    }

    // Dropdown List Popup
    Popup {
        id: dropdownPopup
        y: control.height + 4
        x: 0
        width: control.width
        height: Math.min(180, listView.contentHeight + 12)
        padding: 6
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent | Popup.CloseOnPressOutside
        
        background: Item {
            id: popupBgContainer
            anchors.fill: parent
            
            Rectangle {
                id: popupBgRect
                anchors.fill: parent
                radius: Theme.radiusNormal
                color: Theme.panelBg
                border.color: Theme.border
                border.width: 1
            }
            
            DropShadow {
                anchors.fill: popupBgRect
                horizontalOffset: 0
                verticalOffset: 6
                radius: 16
                color: Theme.cardShadow
                source: popupBgRect
                z: -1
            }
        }

        contentItem: ListView {
            id: listView
            model: control.model
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: MeguScrollBar { }

            delegate: Item {
                id: itemControl
                width: listView.width
                height: 32
                
                readonly property bool isSelected: index === control.currentIndex
                readonly property bool isHovered: itemMouseArea.containsMouse
                
                // Hover/Selected background pill
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 2
                    radius: Theme.radiusSmall
                    color: itemControl.isSelected ? Theme.accentDim : (itemControl.isHovered ? Theme.buttonBgHover : "transparent")
                    
                    border.color: itemControl.isSelected ? Theme.accent : "transparent"
                    border.width: itemControl.isSelected ? 1 : 0
                    
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
                }
                
                // Active selection left accent line
                Rectangle {
                    id: accentLine
                    width: 3
                    height: itemControl.isSelected ? 14 : (itemControl.isHovered ? 8 : 0)
                    radius: 1.5
                    color: Theme.accent
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Behavior on height {
                        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                
                Text {
                    text: control.textFormatter !== null ? control.textFormatter(modelData) : modelData
                    color: itemControl.isSelected ? Theme.accent : (itemControl.isHovered ? Theme.textPrimary : Theme.textSecondary)
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    font.bold: itemControl.isSelected
                    anchors.left: accentLine.right
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                }
                
                MouseArea {
                    id: itemMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        control.currentIndex = index;
                        control.activated(index);
                        dropdownPopup.close();
                    }
                }
            }
        }

        // Slick slide & fade transitions
        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150; easing.type: Easing.OutCubic }
            NumberAnimation { property: "y"; from: control.height - 4; to: control.height + 4; duration: 150; easing.type: Easing.OutCubic }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 120; easing.type: Easing.OutCubic }
            NumberAnimation { property: "y"; from: control.height + 4; to: control.height - 4; duration: 120; easing.type: Easing.OutCubic }
        }
    }
}
