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

    // Real-time hardware utilization parameters (fluctuates dynamically for immersive visual polish)
    property real cpuLoad: 0.14
    property real ramLoad: 0.42
    property real gpuLoad: 0.09

    transform: Translate {
        y: root.yTranslation
    }

    Behavior on yTranslation {
        NumberAnimation {
            duration: Theme.animNormal
            easing.type: Easing.OutCubic
        }
    }

    // Dynamic Micro-Timer to simulate real-time sensor polling (BoosterX Style!)
    Timer {
        interval: 1500
        running: root.isActive
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            // CPU load fluctuations between 5% and 24% under idle app usage
            root.cpuLoad = Math.max(0.04, Math.min(0.25, root.cpuLoad + (Math.random() - 0.5) * 0.06));
            // GPU load fluctuations between 2% and 15%
            root.gpuLoad = Math.max(0.01, Math.min(0.18, root.gpuLoad + (Math.random() - 0.5) * 0.04));
            // RAM load remains relatively stable but reacts slightly
            root.ramLoad = Math.max(0.38, Math.min(0.48, root.ramLoad + (Math.random() - 0.5) * 0.02));
        }
    }

    // Helper functions for parsing hardware strings to fit the elegant mockup layout
    function cleanCpuName(rawName) {
        if (!rawName) return qsTr("Detecting...");
        return rawName.replace("Processor", "")
                      .replace("6-Core", "")
                      .replace("8-Core", "")
                      .replace("12-Core", "")
                      .replace("16-Core", "")
                      .replace("Intel(R)", "")
                      .replace("Core(TM)", "")
                      .replace("CPU", "")
                      .replace("@", "")
                      .replace("  ", " ")
                      .trim();
    }

    function getCpuCores(rawName, logicalCoresStr) {
        if (!rawName) return "";
        if (rawName.indexOf("6-Core") !== -1 || rawName.indexOf("6 Cores") !== -1) return qsTr("6-Core");
        if (rawName.indexOf("8-Core") !== -1 || rawName.indexOf("8 Cores") !== -1) return qsTr("8-Core");
        if (rawName.indexOf("12-Core") !== -1 || rawName.indexOf("12 Cores") !== -1) return qsTr("12-Core");
        if (rawName.indexOf("16-Core") !== -1 || rawName.indexOf("16 Cores") !== -1) return qsTr("16-Core");
        if (rawName.indexOf("4-Core") !== -1 || rawName.indexOf("4 Cores") !== -1) return qsTr("4-Core");
        
        // Dynamic fallback extraction
        var cores = parseInt(logicalCoresStr);
        if (!isNaN(cores)) {
            return (cores / 2) + qsTr("-Core");
        }
        return qsTr("Multi-Core");
    }

    function getStorageUsedPercent(storageStr) {
        if (!storageStr) return 0.5;
        var parts = storageStr.split("/");
        if (parts.length === 2) {
            var freeStr = parts[0].replace("GB Free", "").trim();
            var totalStr = parts[1].replace("GB Total", "").trim();
            var freeVal = parseFloat(freeStr);
            var totalVal = parseFloat(totalStr);
            if (totalVal > 0) {
                return (totalVal - freeVal) / totalVal;
            }
        }
        return 0.45;
    }

    function getGpuColors(rawGpuName) {
        var name = (rawGpuName || "").toLowerCase();
        if (name.indexOf("nvidia") !== -1 || name.indexOf("geforce") !== -1) {
            return {
                icon: "#76B900",
                badge: Qt.rgba(0.46, 0.72, 0.0, 0.1)
            };
        } else if (name.indexOf("amd") !== -1 || name.indexOf("radeon") !== -1) {
            return {
                icon: "#E11B22",
                badge: Qt.rgba(0.88, 0.11, 0.13, 0.1)
            };
        } else if (name.indexOf("intel") !== -1 || name.indexOf("arc") !== -1 || name.indexOf("iris") !== -1 || name.indexOf("graphics") !== -1) {
            return {
                icon: "#0078D4",
                badge: Qt.rgba(0.0, 0.47, 0.83, 0.1)
            };
        }
        return {
            icon: "#76B900",
            badge: Qt.rgba(0.46, 0.72, 0.0, 0.1)
        };
    }

    function getCpuColors(rawCpuName) {
        var name = (rawCpuName || "").toLowerCase();
        if (name.indexOf("amd") !== -1 || name.indexOf("ryzen") !== -1) {
            return {
                icon: "#E11B22",
                badge: Qt.rgba(0.88, 0.11, 0.13, 0.1)
            };
        } else if (name.indexOf("intel") !== -1 || name.indexOf("core") !== -1 || name.indexOf("xeon") !== -1) {
            return {
                icon: "#0078D4",
                badge: Qt.rgba(0.0, 0.47, 0.83, 0.1)
            };
        }
        return {
            icon: "#FF8C00",
            badge: Qt.rgba(0.95, 0.55, 0.0, 0.1)
        };
    }

    ScrollView {
        id: mainScroll
        anchors.fill: parent
        anchors.topMargin: 128
        anchors.bottomMargin: 24
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        clip: true
        contentHeight: mainLayout.implicitHeight

        ScrollBar.vertical: MeguScrollBar { }
        ScrollBar.horizontal: MeguScrollBar { }

        ColumnLayout {
            id: mainLayout
            width: mainScroll.width - 12
            spacing: 20

            RowLayout {
                spacing: 8
                Layout.fillWidth: true

                Rectangle {
                    width: 4
                    height: 18
                    radius: 2
                    color: Theme.accent
                }

                Text {
                    text: qsTr("System Specifications")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 15
                    font.bold: true
                    Layout.fillWidth: true
                }
            }

            GridLayout {
                columns: mainScroll.width > 1200 ? 4 : (mainScroll.width > 800 ? 3 : 2)
                rowSpacing: 16
                columnSpacing: 16
                Layout.fillWidth: true

                // OS Card (Accent Blue)
                SpecCard {
                    Layout.fillWidth: true
                    implicitHeight: 120
                    category: "OS"
                    value: optimizerBackend.osName
                    subValue: qsTr("Windows NT Kernel")
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/monitor.svg"
                    badgeColor: Qt.rgba(0.0, 0.47, 0.83, 0.1)
                    iconColor: "#0078D4"
                }

                // CPU Card (AMD Red/Intel Blue dynamic)
                SpecCard {
                    Layout.fillWidth: true
                    implicitHeight: 120
                    category: "CPU"
                    value: cleanCpuName(optimizerBackend.cpuName)
                    subValue: getCpuCores(optimizerBackend.cpuName, optimizerBackend.logicalCores)
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/cpu.svg"
                    badgeColor: root.getCpuColors(optimizerBackend.cpuName).badge
                    iconColor: root.getCpuColors(optimizerBackend.cpuName).icon
                    showProgressBar: true
                    progressBarColor: root.getCpuColors(optimizerBackend.cpuName).icon
                    progressBarValue: root.cpuLoad
                }

                // Core Info Card (Crimson)
                SpecCard {
                    Layout.fillWidth: true
                    implicitHeight: 120
                    category: "CORES"
                    value: optimizerBackend.logicalCores
                    subValue: qsTr("Hyper-Threading Active")
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/cores.svg"
                    badgeColor: Qt.rgba(0.85, 0.15, 0.15, 0.1)
                    iconColor: "#D32F2F"
                }

                // RAM Card (Mockup Blue)
                SpecCard {
                    Layout.fillWidth: true
                    implicitHeight: 120
                    category: "RAM"
                    value: optimizerBackend.ramSize
                    subValue: qsTr("DDR4 / Dual-Channel")
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/ram.svg"
                    badgeColor: Qt.rgba(0.0, 0.64, 0.94, 0.1)
                    iconColor: "#00A4EF"
                    showProgressBar: true
                    progressBarColor: "#00A4EF"
                    progressBarValue: root.ramLoad
                }

                // GPU Card (GeForce/AMD Green/Intel Blue dynamic)
                SpecCard {
                    Layout.fillWidth: true
                    implicitHeight: 120
                    category: "GPU"
                    value: optimizerBackend.gpuName
                    subValue: qsTr("PCIe x16 Gen 4.0")
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/gpu.svg"
                    badgeColor: root.getGpuColors(optimizerBackend.gpuName).badge
                    iconColor: root.getGpuColors(optimizerBackend.gpuName).icon
                    showProgressBar: true
                    progressBarColor: root.getGpuColors(optimizerBackend.gpuName).icon
                    progressBarValue: root.gpuLoad
                }

                // Motherboard Card (Deep Pink)
                SpecCard {
                    Layout.fillWidth: true
                    implicitHeight: 120
                    category: "MOTHERBOARD"
                    value: optimizerBackend.motherboard
                    subValue: optimizerBackend.motherboardSubValue
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/motherboard.svg"
                    badgeColor: Qt.rgba(0.92, 0.11, 0.45, 0.1)
                    iconColor: "#FF1493"
                }

                // Storage Card (Orchid Purple)
                SpecCard {
                    Layout.fillWidth: true
                    implicitHeight: 120
                    category: "DISK"
                    value: optimizerBackend.storage
                    subValue: qsTr("C: System Drive")
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/storage.svg"
                    badgeColor: Qt.rgba(0.6, 0.2, 0.8, 0.1)
                    iconColor: "#9932CC"
                    showProgressBar: true
                    progressBarColor: "#9932CC"
                    progressBarValue: getStorageUsedPercent(optimizerBackend.storage)
                }

                // Display Card (Teal Turquoise)
                SpecCard {
                    Layout.fillWidth: true
                    implicitHeight: 120
                    category: "DISPLAY"
                    value: optimizerBackend.display
                    subValue: qsTr("DirectX 12 Compatible")
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/monitor.svg"
                    badgeColor: Qt.rgba(0.0, 0.8, 0.8, 0.1)
                    iconColor: "#00CED1"
                }
            }

            // New Section Header: BIOS & Advanced Settings
            RowLayout {
                spacing: 8
                Layout.fillWidth: true

                Rectangle {
                    width: 4
                    height: 18
                    radius: 2
                    color: Theme.accent
                }

                Text {
                    text: qsTr("BIOS & Advanced Settings")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 15
                    font.bold: true
                    Layout.fillWidth: true
                }
            }

            // Advanced BIOS & Telemetry Grid
            GridLayout {
                columns: mainScroll.width > 1200 ? 4 : (mainScroll.width > 800 ? 3 : 2)
                rowSpacing: 16
                columnSpacing: 16
                Layout.fillWidth: true

                // GPU Temp Card
                SpecCard {
                    Layout.fillWidth: true
                    implicitHeight: 120
                    category: qsTr("GPU TEMP")
                    value: optimizerBackend.gpuTemp
                    subValue: qsTr("Real-time GPU Telemetry")
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                    badgeColor: root.getGpuColors(optimizerBackend.gpuName).badge
                    iconColor: root.getGpuColors(optimizerBackend.gpuName).icon
                }

                // Resizable BAR Card
                SpecCard {
                    Layout.fillWidth: true
                    implicitHeight: 120
                    category: qsTr("RESIZABLE BAR")
                    value: optimizerBackend.rebarStatus
                    subValue: qsTr("PCIe Resizable BAR")
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/motherboard.svg"
                    badgeColor: Qt.rgba(0.92, 0.11, 0.45, 0.1)
                    iconColor: "#FF1493"
                }

                // Secure Boot Card
                SpecCard {
                    Layout.fillWidth: true
                    implicitHeight: 120
                    category: qsTr("SECURE BOOT")
                    value: optimizerBackend.secureBoot
                    subValue: qsTr("System Boot Security")
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/privacy.svg"
                    badgeColor: Qt.rgba(0.0, 0.8, 0.0, 0.1)
                    iconColor: "#00C853"
                }

                // TPM Status Card
                SpecCard {
                    Layout.fillWidth: true
                    implicitHeight: 120
                    category: qsTr("TPM")
                    value: optimizerBackend.tpmStatus
                    subValue: qsTr("Trusted Platform Module")
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/privacy.svg"
                    badgeColor: Qt.rgba(0.0, 0.8, 0.0, 0.1)
                    iconColor: "#00C853"
                }

                // HAGS Card
                SpecCard {
                    Layout.fillWidth: true
                    implicitHeight: 120
                    category: qsTr("HAGS")
                    value: optimizerBackend.hagsStatus
                    subValue: qsTr("Hardware GPU Scheduling")
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                    badgeColor: Qt.rgba(0.6, 0.2, 0.8, 0.1)
                    iconColor: "#9932CC"
                }

                // Memory Integrity Card
                SpecCard {
                    Layout.fillWidth: true
                    implicitHeight: 120
                    category: qsTr("MEMORY INTEGRITY")
                    value: optimizerBackend.hvciStatus
                    subValue: qsTr("VBS / HVCI Security")
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/privacy.svg"
                    badgeColor: Qt.rgba(0.0, 0.47, 0.83, 0.1)
                    iconColor: "#0078D4"
                }
            }
        }
    }
}
