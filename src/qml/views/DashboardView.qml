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
        anchors.margins: 24
        clip: true
        contentHeight: mainLayout.implicitHeight

        ScrollBar.vertical: MeguScrollBar { }
        ScrollBar.horizontal: MeguScrollBar { }

        ColumnLayout {
            id: mainLayout
            width: mainScroll.width - 12
            spacing: 20

            Text {
                text: qsTr("SYSTEM SPECIFICATIONS")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 14
                font.bold: true
                font.letterSpacing: 2
                Layout.fillWidth: true
            }

            GridLayout {
                columns: 2
                rowSpacing: 12
                columnSpacing: 12
                Layout.fillWidth: true

                SpecCard {
                    Layout.fillWidth: true
                    implicitHeight: 72
                    title: qsTr("Operating System")
                    value: optimizerBackend.osName
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/monitor.svg"
                }

                SpecCard {
                    Layout.fillWidth: true
                    implicitHeight: 72
                    title: qsTr("Processor (CPU)")
                    value: optimizerBackend.cpuName
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/cpu.svg"
                }

                SpecCard {
                    Layout.fillWidth: true
                    implicitHeight: 72
                    title: qsTr("Logical Cores")
                    value: optimizerBackend.logicalCores
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/cores.svg"
                }

                SpecCard {
                    Layout.fillWidth: true
                    implicitHeight: 72
                    title: qsTr("Memory (RAM)")
                    value: optimizerBackend.ramSize
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/ram.svg"
                }

                SpecCard {
                    Layout.fillWidth: true
                    implicitHeight: 72
                    title: qsTr("Graphics Card (GPU)")
                    value: optimizerBackend.gpuName
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/gpu.svg"
                }

                SpecCard {
                    Layout.fillWidth: true
                    implicitHeight: 72
                    title: qsTr("Motherboard")
                    value: optimizerBackend.motherboard
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/motherboard.svg"
                }

                SpecCard {
                    Layout.fillWidth: true
                    implicitHeight: 72
                    title: qsTr("Storage (C:)")
                    value: optimizerBackend.storage
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/storage.svg"
                }

                SpecCard {
                    Layout.fillWidth: true
                    implicitHeight: 72
                    title: qsTr("Primary Display")
                    value: optimizerBackend.display
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/monitor.svg"
                }
            }
        }
    }
}
