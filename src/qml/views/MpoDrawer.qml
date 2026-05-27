import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects
import "../components"

Column {
    id: mpoColumn
    width: parent.width
    spacing: 20
    

    Column {
        width: parent.width
        spacing: 8
        Text {
            text: qsTr("Multi-Plane Overlay Value")
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.bold: true
        }
        Text {
            text: qsTr("Choose any MPO overlay flag from 0 to 5. 5 disables MPO completely to resolve driver bugs, while 0 restores Windows default.")
            color: Theme.textMuted
            font.family: Theme.fontFamily
            font.pixelSize: 10
            wrapMode: Text.Wrap
            width: parent.width
        }
    }

    Column {
        id: mpoContainer
        spacing: 16
        width: parent.width
        
        property int selectedVal: optimizerBackend.mpoValue

        Grid {
            columns: 2
            spacing: 10
            width: parent.width

            // Row 0
            Row {
                spacing: 6
                width: (parent.width - 10) / 2
                MeguButton {
                    text: "0"
                    width: parent.width - 24
                    height: 32
                    accented: mpoContainer.selectedVal === 0
                    onClicked: mpoContainer.selectedVal = 0
                }
                Image {
                    source: "qrc:/MeguPackOptimizer/src/resources/help.svg"
                    width: 18
                    height: 18
                    sourceSize.width: 18
                    sourceSize.height: 18
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: helpMouse0.containsMouse ? 1.0 : 0.6
                    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                    MouseArea {
                        id: helpMouse0
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mpoContainer.selectedVal = 0
                    }
                    ToolTip {
                        id: tip0
                        visible: helpMouse0.containsMouse
                        delay: 150
                        timeout: 5000
                        contentItem: Text {
                            text: qsTr("0 (Default): Dynamic overlays are fully active. Lowest latency in windowed games, but causes micro-stuttering, Chromium browser lags, or black screen flickering on modern GPU drivers.")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            wrapMode: Text.Wrap
                        }
                        background: Rectangle {
                            color: Theme.sidebarBg
                            border.color: Theme.accent
                            border.width: 1
                            radius: 6
                        }
                    }
                }
            }

            // Row 1
            Row {
                spacing: 6
                width: (parent.width - 10) / 2
                MeguButton {
                    text: "1"
                    width: parent.width - 24
                    height: 32
                    accented: mpoContainer.selectedVal === 1
                    onClicked: mpoContainer.selectedVal = 1
                }
                Image {
                    source: "qrc:/MeguPackOptimizer/src/resources/help.svg"
                    width: 18
                    height: 18
                    sourceSize.width: 18
                    sourceSize.height: 18
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: helpMouse1.containsMouse ? 1.0 : 0.6
                    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                    MouseArea {
                        id: helpMouse1
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mpoContainer.selectedVal = 1
                    }
                    ToolTip {
                        id: tip1
                        visible: helpMouse1.containsMouse
                        delay: 150
                        timeout: 5000
                        contentItem: Text {
                            text: qsTr("1: Disables hardware MPO overlay promotion. Direct GPU rendering is bypassed, which can fix dual-monitor desktop stuttering.")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            wrapMode: Text.Wrap
                        }
                        background: Rectangle {
                            color: Theme.sidebarBg
                            border.color: Theme.accent
                            border.width: 1
                            radius: 6
                        }
                    }
                }
            }

            // Row 2
            Row {
                spacing: 6
                width: (parent.width - 10) / 2
                MeguButton {
                    text: "2"
                    width: parent.width - 24
                    height: 32
                    accented: mpoContainer.selectedVal === 2
                    onClicked: mpoContainer.selectedVal = 2
                }
                Image {
                    source: "qrc:/MeguPackOptimizer/src/resources/help.svg"
                    width: 18
                    height: 18
                    sourceSize.width: 18
                    sourceSize.height: 18
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: helpMouse2.containsMouse ? 1.0 : 0.6
                    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                    MouseArea {
                        id: helpMouse2
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mpoContainer.selectedVal = 2
                    }
                    ToolTip {
                        id: tip2
                        visible: helpMouse2.containsMouse
                        delay: 150
                        timeout: 5000
                        contentItem: Text {
                            text: qsTr("2: Disables software-emulated MPO overlays, forcing DWM to only allocate native hardware paths.")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            wrapMode: Text.Wrap
                        }
                        background: Rectangle {
                            color: Theme.sidebarBg
                            border.color: Theme.accent
                            border.width: 1
                            radius: 6
                        }
                    }
                }
            }

            // Row 3
            Row {
                spacing: 6
                width: (parent.width - 10) / 2
                MeguButton {
                    text: "3"
                    width: parent.width - 24
                    height: 32
                    accented: mpoContainer.selectedVal === 3
                    onClicked: mpoContainer.selectedVal = 3
                }
                Image {
                    source: "qrc:/MeguPackOptimizer/src/resources/help.svg"
                    width: 18
                    height: 18
                    sourceSize.width: 18
                    sourceSize.height: 18
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: helpMouse3.containsMouse ? 1.0 : 0.6
                    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                    MouseArea {
                        id: helpMouse3
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mpoContainer.selectedVal = 3
                    }
                    ToolTip {
                        id: tip3
                        visible: helpMouse3.containsMouse
                        delay: 150
                        timeout: 5000
                        contentItem: Text {
                            text: qsTr("3: Disables both hardware and software overlays. Forces legacy composition limits.")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            wrapMode: Text.Wrap
                        }
                        background: Rectangle {
                            color: Theme.sidebarBg
                            border.color: Theme.accent
                            border.width: 1
                            radius: 6
                        }
                    }
                }
            }

            // Row 4
            Row {
                spacing: 6
                width: (parent.width - 10) / 2
                MeguButton {
                    text: "4"
                    width: parent.width - 24
                    height: 32
                    accented: mpoContainer.selectedVal === 4
                    onClicked: mpoContainer.selectedVal = 4
                }
                Image {
                    source: "qrc:/MeguPackOptimizer/src/resources/help.svg"
                    width: 18
                    height: 18
                    sourceSize.width: 18
                    sourceSize.height: 18
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: helpMouse4.containsMouse ? 1.0 : 0.6
                    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                    MouseArea {
                        id: helpMouse4
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mpoContainer.selectedVal = 4
                    }
                    ToolTip {
                        id: tip4
                        visible: helpMouse4.containsMouse
                        delay: 150
                        timeout: 5000
                        contentItem: Text {
                            text: qsTr("4: Forces complete DWM composition. Promotes zero window structures to independent planes.")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            wrapMode: Text.Wrap
                        }
                        background: Rectangle {
                            color: Theme.sidebarBg
                            border.color: Theme.accent
                            border.width: 1
                            radius: 6
                        }
                    }
                }
            }

            // Row 5
            Row {
                spacing: 6
                width: (parent.width - 10) / 2
                MeguButton {
                    text: "5"
                    width: parent.width - 24
                    height: 32
                    accented: mpoContainer.selectedVal === 5
                    onClicked: mpoContainer.selectedVal = 5
                }
                Image {
                    source: "qrc:/MeguPackOptimizer/src/resources/help.svg"
                    width: 18
                    height: 18
                    sourceSize.width: 18
                    sourceSize.height: 18
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: helpMouse5.containsMouse ? 1.0 : 0.6
                    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                    MouseArea {
                        id: helpMouse5
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mpoContainer.selectedVal = 5
                    }
                    ToolTip {
                        id: tip5
                        visible: helpMouse5.containsMouse
                        delay: 150
                        timeout: 5000
                        contentItem: Text {
                            text: qsTr("5 (Recommended): Completely disables all MPO modes. Official NVIDIA/AMD hotfix to eliminate stuttering, browser lag, and screen flickers.")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            wrapMode: Text.Wrap
                        }
                        background: Rectangle {
                            color: Theme.sidebarBg
                            border.color: Theme.accent
                            border.width: 1
                            radius: 6
                        }
                    }
                }
            }
        }

        // Thin divider
        Rectangle {
            width: parent.width
            height: 1
            color: Theme.border
        }

        // Dynamic high-fidelity explanation text
        Text {
            text: {
                if (mpoContainer.selectedVal === 0) return qsTr("0 (Default): Dynamic overlays are fully active. Lowest latency in windowed games, but causes micro-stuttering, Chromium browser lags, or black screen flickering on modern GPU drivers.");
                if (mpoContainer.selectedVal === 1) return qsTr("1: Disables hardware MPO overlay promotion. Direct GPU rendering is bypassed, which can fix dual-monitor desktop stuttering.");
                if (mpoContainer.selectedVal === 2) return qsTr("2: Disables software-emulated MPO overlays, forcing DWM to only allocate native hardware paths.");
                if (mpoContainer.selectedVal === 3) return qsTr("3: Disables both hardware and software overlays. Forces legacy composition limits.");
                if (mpoContainer.selectedVal === 4) return qsTr("4: Forces complete DWM composition. Promotes zero window structures to independent planes.");
                if (mpoContainer.selectedVal === 5) return qsTr("5 (Recommended): Completely disables all MPO modes. Official NVIDIA/AMD hotfix to eliminate stuttering, browser lag, and screen flickers.");
                return "";
            }
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: 10
            wrapMode: Text.Wrap
            width: parent.width
        }

        MeguButton {
            text: qsTr("Apply")
            iconSource: "qrc:/MeguPackOptimizer/src/resources/play.svg"
            accented: true
            enabled: mpoContainer.selectedVal !== optimizerBackend.mpoValue && !optimizerBackend.isOptimizingSystem
            width: parent.width
            height: 38
            onClicked: {
                root.activeDrawer = "";
                stepLogModel.clear();
                optimizerBackend.applyMpoValue(mpoContainer.selectedVal);
            }
        }
    }
}
