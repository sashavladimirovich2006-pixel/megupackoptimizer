import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeguPackOptimizer 1.0
import "../components"

Item {
    id: root
    anchors.fill: parent

    // Premium reactive entry transition (runs butter-smooth on every tab switch!)
    property bool isActive: opacity > 0.1
    property real yTranslation: isActive ? 0 : 15

    transform: Translate {
        y: root.yTranslation
    }

    Behavior on yTranslation {
        NumberAnimation {
            duration: Theme.animNormal
            easing.type: Easing.OutCubic
        }
    }

    ScrollView {
        id: mainScroll
        anchors.fill: parent
        anchors.margins: 20
        clip: true
        contentHeight: mainLayout.implicitHeight

        RowLayout {
            id: mainLayout
            width: mainScroll.width - 12
            spacing: 20

            // 1. LEFT DIAGNOSTIC HEART CORE PANEL
            AcrylicPanel {
                id: coreHeartPanel
                Layout.preferredWidth: 280
                Layout.preferredHeight: 332
                Layout.alignment: Qt.AlignTop
                clip: true

                Column {
                    anchors.fill: parent
                    spacing: 16
                    anchors.margins: 16

                    Text {
                        text: qsTr("SYSTEM CORE HEALTH")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1.5
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    // Rotating Cyber-Gauge Container
                    Item {
                        width: 170
                        height: 170
                        anchors.horizontalCenter: parent.horizontalCenter

                        // Ambient glowing background halo
                        Rectangle {
                            width: 130
                            height: 130
                            radius: 65
                            color: Theme.accent
                            opacity: 0.05
                            anchors.centerIn: parent
                            
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.12; duration: 2000; easing.type: Easing.InOutQuad }
                                NumberAnimation { to: 0.05; duration: 2000; easing.type: Easing.InOutQuad }
                            }
                        }

                        // Outer Canvas Ring for main segment progress (98%)
                        Canvas {
                            id: gaugeCanvas
                            anchors.fill: parent
                            rotation: -90 // Start arc at the top!
                            
                            property real progress: 0.98

                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)
                                
                                var cx = width / 2
                                var cy = height / 2
                                var r = Math.min(width, height) / 2 - 10
                                
                                // Background empty track
                                ctx.beginPath()
                                ctx.arc(cx, cy, r, 0, 2 * Math.PI)
                                ctx.lineWidth = 4
                                ctx.strokeStyle = (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая") ? "#E2E8F0" : "#141D2C"
                                ctx.stroke()
                                
                                // Soft glow under-arc
                                ctx.beginPath()
                                ctx.arc(cx, cy, r, 0, progress * 2 * Math.PI)
                                ctx.lineWidth = 8
                                ctx.strokeStyle = Theme.accentDim
                                ctx.stroke()
                                
                                // Main accent progress arc
                                ctx.beginPath()
                                ctx.arc(cx, cy, r, 0, progress * 2 * Math.PI)
                                ctx.lineWidth = 4
                                ctx.strokeStyle = Theme.accent
                                ctx.stroke()
                            }
                        }

                        // Concentric spinning ring with active neon bead (macOS Diagnostic style)
                        Rectangle {
                            width: 122
                            height: 122
                            radius: 61
                            color: "transparent"
                            border.color: Theme.accent
                            border.width: 1
                            anchors.centerIn: parent
                            opacity: 0.4
                            
                            Rectangle {
                                width: 6
                                height: 6
                                radius: 3
                                color: Theme.accentLight
                                x: parent.width / 2 - 3
                                y: -3
                            }
                            
                            RotationAnimation on rotation {
                                from: 0
                                to: 360
                                duration: 8000
                                loops: Animation.Infinite
                            }
                        }

                        // Inner opposite spinning ring with smaller bead
                        Rectangle {
                            width: 98
                            height: 98
                            radius: 49
                            color: "transparent"
                            border.color: Theme.border
                            border.width: 1
                            anchors.centerIn: parent
                            opacity: 0.25
                            
                            Rectangle {
                                width: 4
                                height: 4
                                radius: 2
                                color: Theme.accent
                                x: parent.width / 2 - 2
                                y: -2
                            }
                            
                            RotationAnimation on rotation {
                                from: 360
                                to: 0
                                duration: 5500
                                loops: Animation.Infinite
                            }
                        }

                        // Central Status text labels
                        Column {
                            anchors.centerIn: parent
                            spacing: 1

                            Text {
                                text: "98%"
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 26
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: qsTr("OPTIMIZED")
                                color: Theme.accent
                                font.family: Theme.fontFamily
                                font.pixelSize: 8
                                font.bold: true
                                font.letterSpacing: 1.5
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    // Divider
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.border
                    }

                    // Active core status info
                    Row {
                        spacing: 8
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: Theme.success
                            anchors.verticalCenter: parent.verticalCenter
                            
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.3; duration: 1200; easing.type: Easing.InOutQuad }
                                NumberAnimation { to: 1.0; duration: 1200; easing.type: Easing.InOutQuad }
                            }
                        }
                        
                        Text {
                            text: qsTr("CORE SYSTEMS OPTIMIZED")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 9
                            font.bold: true
                            font.letterSpacing: 1
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Text {
                        text: qsTr("Your system components are fully tuned for low input latency and gaming load efficiency.")
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                        wrapMode: Text.Wrap
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // 2. RIGHT SYSTEM SPECIFICATIONS GRID
            ColumnLayout {
                spacing: 12
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop

                Text {
                    text: qsTr("DETECTED HARDWARE SPECIFICATIONS")
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1.5
                    Layout.fillWidth: true
                }

                GridLayout {
                    columns: 2
                    rowSpacing: 10
                    columnSpacing: 10
                    Layout.fillWidth: true

                    SpecCard {
                        Layout.fillWidth: true
                        implicitHeight: 68
                        title: qsTr("Operating System")
                        value: optimizerBackend.osName
                        iconSource: "qrc:/MeguPackOptimizer/src/resources/monitor.svg"
                    }

                    SpecCard {
                        Layout.fillWidth: true
                        implicitHeight: 68
                        title: qsTr("Processor (CPU)")
                        value: optimizerBackend.cpuName
                        iconSource: "qrc:/MeguPackOptimizer/src/resources/cpu.svg"
                    }

                    SpecCard {
                        Layout.fillWidth: true
                        implicitHeight: 68
                        title: qsTr("Logical Cores")
                        value: optimizerBackend.logicalCores
                        iconSource: "qrc:/MeguPackOptimizer/src/resources/cores.svg"
                    }

                    SpecCard {
                        Layout.fillWidth: true
                        implicitHeight: 68
                        title: qsTr("Memory (RAM)")
                        value: optimizerBackend.ramSize
                        iconSource: "qrc:/MeguPackOptimizer/src/resources/ram.svg"
                    }

                    SpecCard {
                        Layout.fillWidth: true
                        implicitHeight: 68
                        title: qsTr("Graphics Card (GPU)")
                        value: optimizerBackend.gpuName
                        iconSource: "qrc:/MeguPackOptimizer/src/resources/gpu.svg"
                    }

                    SpecCard {
                        Layout.fillWidth: true
                        implicitHeight: 68
                        title: qsTr("Motherboard")
                        value: optimizerBackend.motherboard
                        iconSource: "qrc:/MeguPackOptimizer/src/resources/motherboard.svg"
                    }

                    SpecCard {
                        Layout.fillWidth: true
                        implicitHeight: 68
                        title: qsTr("Storage (C:)")
                        value: optimizerBackend.storage
                        iconSource: "qrc:/MeguPackOptimizer/src/resources/storage.svg"
                    }

                    SpecCard {
                        Layout.fillWidth: true
                        implicitHeight: 68
                        title: qsTr("Primary Display")
                        value: optimizerBackend.display
                        iconSource: "qrc:/MeguPackOptimizer/src/resources/monitor.svg"
                    }
                }
            }
        }
    }
}
