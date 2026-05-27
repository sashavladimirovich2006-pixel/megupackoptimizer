import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects
import "../components"

Column {
    id: powerColumn
    width: parent.width
    spacing: 20
    

    Column {
        width: parent.width
        spacing: 8
        Text {
            text: qsTr("Ultimate Performance Scheme")
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.bold: true
        }
        Text {
            text: qsTr("Unlocks and enables the hidden Windows Ultimate Performance power scheme for zero latencies.")
            color: Theme.textMuted
            font.family: Theme.fontFamily
            font.pixelSize: 10
            wrapMode: Text.Wrap
            width: parent.width
        }
    }

    MeguButton {
        text: {
            if (optimizerBackend.deleteUltimateStaged) {
                return qsTr("Cancel Deletion");
            }
            return optimizerBackend.ultimateSchemeUnlocked ? qsTr("Delete Ultimate Performance Scheme") : qsTr("Activate Ultimate Performance");
        }
        iconSource: "qrc:/MeguPackOptimizer/src/resources/bolt.svg"
        accented: !optimizerBackend.deleteUltimateStaged && !optimizerBackend.ultimateSchemeUnlocked
        enabled: !optimizerBackend.isOptimizingSystem
        width: parent.width
        height: 38
        onClicked: {
            if (optimizerBackend.deleteUltimateStaged) {
                optimizerBackend.deleteUltimateStaged = false;
                // Re-select active power scheme
                optimizerBackend.selectPowerScheme(optimizerBackend.activePowerSchemeGuid);
            } else if (optimizerBackend.ultimateSchemeUnlocked) {
                optimizerBackend.deleteUltimateStaged = true;
                // Select a non-ultimate scheme as target
                var targetFound = false;
                for (var i = 0; i < optimizerBackend.powerSchemes.length; i++) {
                    if (!optimizerBackend.powerSchemes[i].isUltimate) {
                        optimizerBackend.selectPowerScheme(optimizerBackend.powerSchemes[i].guid);
                        targetFound = true;
                        break;
                    }
                }
                if (!targetFound) {
                    optimizerBackend.selectPowerScheme("{381B4222-F694-41F0-9685-FF5BB260DF2E}"); // Balanced
                }
            } else {
                optimizerBackend.activateUltimatePerformance();
            }
        }
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.border
    }

    Text {
        text: qsTr("Available Power Schemes:")
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: 11
        font.bold: true
    }

    // Display the list of detected power schemes
    Column {
        width: parent.width
        spacing: 10

        Repeater {
            model: optimizerBackend.powerSchemes
            delegate: AcrylicPanel {
                id: schemePanel
                width: parent.width
                height: 50
                
                // Custom active border color
                border.color: (modelData.isUltimate && optimizerBackend.deleteUltimateStaged) ? Theme.error : ((modelData.guid === optimizerBackend.targetPowerSchemeGuid) ? Theme.accent : (schemeMouse.containsMouse ? Theme.borderHover : Theme.border))
                color: (modelData.isUltimate && optimizerBackend.deleteUltimateStaged) ? Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.05) : ((modelData.guid === optimizerBackend.targetPowerSchemeGuid) ? Theme.accentDim : (schemeMouse.containsMouse ? Theme.buttonBgHover : Theme.buttonBg))

                Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
                Behavior on color { ColorAnimation { duration: Theme.animFast } }

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 12
                    spacing: 12

                    Item {
                        width: 20
                        height: 20
                        anchors.verticalCenter: parent.verticalCenter
                        Image {
                            id: planIcon
                            source: "qrc:/MeguPackOptimizer/src/resources/bolt.svg"
                            anchors.fill: parent
                            sourceSize.width: 20
                            sourceSize.height: 20
                            visible: false
                        }
                        ColorOverlay {
                            anchors.fill: planIcon
                            source: planIcon
                            color: (modelData.isUltimate && optimizerBackend.deleteUltimateStaged) ? Theme.error : ((modelData.guid === optimizerBackend.targetPowerSchemeGuid) ? Theme.accent : Theme.textMuted)
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 1

                        Row {
                            spacing: 8
                            Text {
                                text: {
                                    var rawName = modelData.name;
                                    // Clean up trailing translations from friendly name
                                    return rawName.split(' (')[0];
                                }
                                color: (modelData.isUltimate && optimizerBackend.deleteUltimateStaged) ? Theme.error : Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                                font.strikeout: modelData.isUltimate && optimizerBackend.deleteUltimateStaged
                            }

                            Rectangle {
                                visible: modelData.isUltimate && optimizerBackend.deleteUltimateStaged
                                height: 14
                                width: stagedDeleteBadgeText.contentWidth + 10
                                radius: 3
                                color: Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.15)
                                border.color: Theme.error
                                border.width: 1
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    id: stagedDeleteBadgeText
                                    text: qsTr("Staged for deletion")
                                    color: Theme.error
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 8
                                    font.bold: true
                                    anchors.centerIn: parent
                                }
                            }
                        }

                        Text {
                            text: modelData.guid
                            color: Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: 8
                        }
                    }
                }

                MouseArea {
                    id: schemeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData.isUltimate) {
                            optimizerBackend.deleteUltimateStaged = false;
                        }
                        optimizerBackend.selectPowerScheme(modelData.guid);
                    }
                }
            }
        }
    }
}
