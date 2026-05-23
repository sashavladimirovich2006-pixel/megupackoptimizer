import QtQuick
import QtQuick.Controls
import MeguPackOptimizer 1.0
import "../components"

Item {
    id: root
    anchors.fill: parent

    // Center the settings card in the page
    AcrylicPanel {
        width: 360
        height: 240
        anchors.centerIn: parent

        Column {
            anchors.fill: parent
            spacing: 12

            // Language Settings Title
            Text {
                text: qsTr("Language Settings")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 14
                font.bold: true
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
                Behavior on color { ColorAnimation { duration: Theme.animNormal } }
            }

            Row {
                spacing: 12
                anchors.horizontalCenter: parent.horizontalCenter

                Repeater {
                    model: [
                        { "code": "en", "name": qsTr("English") },
                        { "code": "uk", "name": qsTr("Ukrainian") }
                    ]

                    delegate: Rectangle {
                        width: 140
                        height: 32
                        radius: Theme.radiusSmall
                        color: settingsBackend.language === modelData.code ? Theme.accent : "#1E293B"
                        border.color: settingsBackend.language === modelData.code ? "transparent" : Theme.border
                        border.width: 1

                        Text {
                            text: modelData.name
                            color: settingsBackend.language === modelData.code ? Theme.textInverse : Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: settingsBackend.language = modelData.code
                        }
                    }
                }
            }

            Item { width: 1; height: 6 } // Small spacer

            // Theme Customization Title
            Text {
                text: qsTr("Theme Customization")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 14
                font.bold: true
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
                Behavior on color { ColorAnimation { duration: Theme.animNormal } }
            }

            // Theme select button box
            Rectangle {
                width: parent.width
                height: 40
                radius: Theme.radiusSmall
                color: Theme.accentDim
                border.color: Theme.border
                border.width: 1
                anchors.horizontalCenter: parent.horizontalCenter

                Behavior on color { ColorAnimation { duration: Theme.animNormal } }
                Behavior on border.color { ColorAnimation { duration: Theme.animNormal } }

                Text {
                    text: qsTr("Active:") + " " + Theme.currentTheme
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                }

                MeguButton {
                    text: qsTr("Select Theme")
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    width: 120
                    accented: true
                    onClicked: themeSidebar.isOpen = true
                }
            }
        }
    }

    // Dimmed backdrop when theme sidebar is open
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: "#000000"
        opacity: themeSidebar.isOpen ? 0.5 : 0.0
        visible: opacity > 0.0
        
        Behavior on opacity {
            NumberAnimation { duration: Theme.animNormal }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                themeSidebar.isOpen = false;
                // Reset sliding page back to main list when closing
                slidingPages.showSubPage = false;
            }
        }
    }

    // Sliding Sidebar Drawer for Theme Selection
    Rectangle {
        id: themeSidebar
        width: 320
        height: parent.height
        anchors.right: parent.right
        anchors.rightMargin: isOpen ? 0 : -width
        color: Theme.sidebarBg
        border.color: Theme.border
        border.width: 1

        property bool isOpen: false

        Behavior on color { ColorAnimation { duration: Theme.animNormal } }
        Behavior on border.color { ColorAnimation { duration: Theme.animNormal } }
        Behavior on anchors.rightMargin {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }

        // Inner highlight edge line
        Rectangle {
            width: 1
            height: parent.height
            anchors.left: parent.left
            color: Theme.border
            Behavior on color { ColorAnimation { duration: Theme.animNormal } }
        }

        Item {
            anchors.fill: parent
            anchors.margins: 20
            clip: true

            // Row containing the primary list and secondary list (for sliding transition)
            Row {
                id: slidingPages
                height: parent.height
                width: 560 // 280 width per page inside the padded container
                
                x: showSubPage ? -280 : 0
                Behavior on x {
                    NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
                }

                property bool showSubPage: false

                // Page 1: Main Theme List
                Column {
                    width: 280
                    height: parent.height
                    spacing: 16

                    Text {
                        text: qsTr("THEME SELECTION")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.bold: true
                        font.letterSpacing: 1.5
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.border
                        Behavior on color { ColorAnimation { duration: Theme.animNormal } }
                    }

                    // Theme Selection List
                    Column {
                        width: parent.width
                        spacing: 8

                        Repeater {
                            model: [
                                { name: "Белоснежная", desc: qsTr("Pure snow white theme"), hasSub: false },
                                { name: "Темная", desc: qsTr("Classic deep slate dark theme"), hasSub: false },
                                { name: "Blackout полностью черная", desc: qsTr("Absolute black OLED theme"), hasSub: false },
                                { name: "Ргб", desc: qsTr("Glowing orange gaming theme"), hasSub: false },
                                { name: "Розовая", desc: qsTr("Vibrant soft pink theme"), hasSub: true }
                            ]

                            delegate: Rectangle {
                                width: parent.width
                                height: 46
                                radius: Theme.radiusSmall
                                color: Theme.currentTheme === modelData.name ? Theme.accentDim : (itemMouseArea.containsMouse ? "#0CFFFFFF" : "transparent")
                                border.color: Theme.currentTheme === modelData.name ? Theme.accent : Theme.border
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                                Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 8

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: modelData.hasSub ? parent.width - 32 : parent.width

                                        Text {
                                            text: modelData.name
                                            color: Theme.currentTheme === modelData.name ? Theme.accent : Theme.textPrimary
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                        Text {
                                            text: modelData.desc
                                            color: Theme.textMuted
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 9
                                        }
                                    }

                                    // Right arrow next to Pink theme
                                    Rectangle {
                                        width: 24
                                        height: 24
                                        radius: 12
                                        color: arrowMouseArea.containsMouse ? Theme.accentDim : "transparent"
                                        border.color: arrowMouseArea.containsMouse ? Theme.accent : "transparent"
                                        border.width: 1
                                        visible: modelData.hasSub
                                        anchors.verticalCenter: parent.verticalCenter

                                        Behavior on color { ColorAnimation { duration: Theme.animFast } }

                                        Text {
                                            text: "→"
                                            color: Theme.accent
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 14
                                            font.bold: true
                                            anchors.centerIn: parent
                                        }

                                        MouseArea {
                                            id: arrowMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                Theme.setTheme("Розовая");
                                                slidingPages.showSubPage = true;
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    id: itemMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        Theme.setTheme(modelData.name);
                                    }
                                }
                            }
                        }
                    }
                }

                // Page 2: Sub-Theme Selector (Black pink)
                Column {
                    width: 280
                    height: parent.height
                    spacing: 16

                    // Back Navigation Bar
                    Row {
                        spacing: 10
                        width: parent.width

                        MeguButton {
                            text: qsTr("Back")
                            iconSource: "qrc:/MeguPackOptimizer/src/resources/close.svg"
                            width: 70
                            onClicked: slidingPages.showSubPage = false
                        }

                        Text {
                            text: qsTr("SPECIAL THEME")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                            font.bold: true
                            font.letterSpacing: 1.5
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.border
                        Behavior on color { ColorAnimation { duration: Theme.animNormal } }
                    }

                    // Special Black Pink Theme Item
                    Rectangle {
                        width: parent.width
                        height: 46
                        radius: Theme.radiusSmall
                        color: Theme.currentTheme === "Black pink" ? Theme.accentDim : (subMouseArea.containsMouse ? "#0CFFFFFF" : "transparent")
                        border.color: Theme.currentTheme === "Black pink" ? Theme.accent : Theme.border
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                        Column {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 2
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: "Black pink"
                                color: Theme.currentTheme === "Black pink" ? Theme.accent : Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                            }
                            Text {
                                text: qsTr("High contrast black and glowing pink accents")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 9
                            }
                        }

                        MouseArea {
                            id: subMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Theme.setTheme("Black pink")
                        }
                    }
                }
            }
        }
    }
}
