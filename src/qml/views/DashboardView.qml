import QtQuick
import QtQuick.Layouts
import MeguPackOptimizer 1.0
import "../components"

Item {
    id: root
    anchors.fill: parent
    anchors.margins: 24

    ColumnLayout {
        anchors.fill: parent
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
            Layout.fillHeight: true

            SpecCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: qsTr("Operating System")
                value: optimizerBackend.osName
                iconSource: "qrc:/MeguPackOptimizer/src/resources/monitor.svg"
            }

            SpecCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: qsTr("Processor (CPU)")
                value: optimizerBackend.cpuName
                iconSource: "qrc:/MeguPackOptimizer/src/resources/cpu.svg"
            }

            SpecCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: qsTr("Logical Cores")
                value: optimizerBackend.logicalCores
                iconSource: "qrc:/MeguPackOptimizer/src/resources/cores.svg"
            }

            SpecCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: qsTr("Memory (RAM)")
                value: optimizerBackend.ramSize
                iconSource: "qrc:/MeguPackOptimizer/src/resources/ram.svg"
            }

            SpecCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: qsTr("Graphics Card (GPU)")
                value: optimizerBackend.gpuName
                iconSource: "qrc:/MeguPackOptimizer/src/resources/gpu.svg"
            }

            SpecCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: qsTr("Motherboard")
                value: optimizerBackend.motherboard
                iconSource: "qrc:/MeguPackOptimizer/src/resources/motherboard.svg"
            }

            SpecCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: qsTr("Storage (C:)")
                value: optimizerBackend.storage
                iconSource: "qrc:/MeguPackOptimizer/src/resources/storage.svg"
            }

            SpecCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: qsTr("Primary Display")
                value: optimizerBackend.display
                iconSource: "qrc:/MeguPackOptimizer/src/resources/monitor.svg"
            }
        }
    }
}
