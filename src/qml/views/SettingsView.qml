import QtQuick
import QtQuick.Controls
import MeguPackOptimizer 1.0
import "../components"

Item {
    id: root

    Row {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Left Side: Main Optimizations (Image and Sound)
        Column {
            width: (parent.width * 0.50) - 10
            height: parent.height
            spacing: 16

            // Image Optimization Panel
            AcrylicPanel {
                width: parent.width
                height: 250

                Column {
                    anchors.fill: parent
                    spacing: 12

                    Text {
                        text: qsTr("Texture Optimization Options")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        font.bold: true
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.border
                    }

                    MeguSwitch {
                        text: qsTr("Enable Texture Resolution Processing")
                        checked: settingsBackend.optimizeImages
                        onToggled: (checked) => settingsBackend.optimizeImages = checked
                    }

                    // Resolution selector row
                    Column {
                        spacing: 8
                        width: parent.width
                        opacity: settingsBackend.optimizeImages ? 1.0 : 0.4
                        
                        Text {
                            text: qsTr("Maximum Texture Resolution Limit")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                        }

                        Row {
                            spacing: 8
                            
                            Repeater {
                                model: [16, 32, 64, 128, 256, 512]
                                
                                delegate: Rectangle {
                                    width: 52
                                    height: 32
                                    radius: Theme.radiusSmall
                                    color: settingsBackend.maxImageResolution === modelData ? Theme.accent : "#1E293B"
                                    border.color: settingsBackend.maxImageResolution === modelData ? "transparent" : Theme.border
                                    border.width: 1

                                    Text {
                                        text: modelData + "px"
                                        color: settingsBackend.maxImageResolution === modelData ? Theme.textInverse : Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: settingsBackend.optimizeImages
                                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        onClicked: settingsBackend.maxImageResolution = modelData
                                    }
                                }
                            }
                        }
                        
                        Text {
                            text: qsTr("Textures exceeding the chosen limit will be downscaled, keeping resource footprint small.")
                            color: Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }
                    }

                    Item { width: parent.width; height: 4 }

                    MeguSwitch {
                        text: qsTr("Convert PNG textures to WebP compression format")
                        checked: settingsBackend.pngToWebp
                        enabled: settingsBackend.optimizeImages
                        onToggled: (checked) => settingsBackend.pngToWebp = checked
                    }
                }
            }

            // Audio Optimization Panel
            AcrylicPanel {
                width: parent.width
                height: parent.height - 250 - 16

                Column {
                    anchors.fill: parent
                    spacing: 12

                    Text {
                        text: qsTr("Audio Assets Processing")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        font.bold: true
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.border
                    }

                    MeguSwitch {
                        text: qsTr("Enable Audio Downsampling & Compression")
                        checked: settingsBackend.optimizeAudio
                        onToggled: (checked) => settingsBackend.optimizeAudio = checked
                    }

                    Text {
                        text: qsTr("Analyzes ogg, wav, and mp3 files, reduces sample bitrates (e.g. down to 22.05kHz mono) and re-encodes under high-compression Ogg Vorbis to minimize audio footprint.")
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
            }
        }

        // Right Side: Code and Workflow Options
        Column {
            width: (parent.width * 0.50) - 10
            height: parent.height
            spacing: 16

            // JSON Optimization Panel
            AcrylicPanel {
                width: parent.width
                height: 190

                Column {
                    anchors.fill: parent
                    spacing: 12

                    Text {
                        text: qsTr("JSON & Meta Document Options")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        font.bold: true
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.border
                    }

                    MeguSwitch {
                        text: qsTr("Minify JSON structures (remove linebreaks and margins)")
                        checked: settingsBackend.minifyJson
                        onToggled: (checked) => settingsBackend.minifyJson = checked
                    }

                    MeguSwitch {
                        text: qsTr("Strip documentation comments and developer metadata")
                        checked: settingsBackend.stripJsonComments
                        onToggled: (checked) => settingsBackend.stripJsonComments = checked
                    }

                    Text {
                        text: qsTr("Strips unneeded whitespace and internal elements from MCMeta, blockstates, and models.")
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
            }

            // Language Selection Panel
            AcrylicPanel {
                width: parent.width
                height: 120

                Column {
                    anchors.fill: parent
                    spacing: 12

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
                    }

                    Row {
                        spacing: 12

                        Repeater {
                            model: [
                                { "code": "en", "name": qsTr("English") },
                                { "code": "uk", "name": qsTr("Ukrainian") }
                            ]

                            delegate: Rectangle {
                                width: 120
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
                }
            }

            // Workflow Optimization Panel
            AcrylicPanel {
                width: parent.width
                height: parent.height - 190 - 120 - 32

                Column {
                    anchors.fill: parent
                    spacing: 12

                    Text {
                        text: qsTr("General Workflow Options")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        font.bold: true
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.border
                    }

                    MeguSwitch {
                        text: qsTr("Auto-create backup archive (.zip) before optimizer runs")
                        checked: settingsBackend.createBackup
                        onToggled: (checked) => settingsBackend.createBackup = checked
                    }

                    MeguSwitch {
                        text: qsTr("Delete temporary directories after compiling optimized pack")
                        checked: settingsBackend.deleteTempFiles
                        onToggled: (checked) => settingsBackend.deleteTempFiles = checked
                    }

                    Text {
                        text: qsTr("Settings are automatically serialized and stored locally in megu_settings.json. Toggles apply immediately to the active thread configuration.")
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
            }
        }
    }
}
