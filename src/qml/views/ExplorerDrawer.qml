import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects
import "../components"

Column {
    id: explorerColumn
    width: parent.width
    spacing: 16

    Text {
        text: qsTr("Customization of Windows Explorer settings, views, and defaults.")
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: 11
        font.bold: true
        bottomPadding: 8
    }

    // Restart Explorer Box (if pending changes exist)
    Rectangle {
        width: parent.width
        height: visible ? Math.max(56, restartRow.implicitHeight + 16) : 0
        radius: 8
        color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1)
        border.color: Theme.accent
        border.width: 1
        visible: (optimizerBackend.explorerClassicRibbon !== optimizerBackend.originalExplorerClassicRibbon) ||
                 (optimizerBackend.explorerPinHome !== optimizerBackend.originalExplorerPinHome) ||
                 (optimizerBackend.explorerPinGallery !== optimizerBackend.originalExplorerPinGallery) ||
                 (optimizerBackend.explorerPinRecycleBin !== optimizerBackend.originalExplorerPinRecycleBin) ||
                 (optimizerBackend.explorerShowPreviewPane !== optimizerBackend.originalExplorerShowPreviewPane)
        clip: true

        Behavior on height { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

        RowLayout {
            id: restartRow
            anchors.fill: parent
            anchors.margins: 8
            spacing: 12

            Text {
                Layout.fillWidth: true
                text: qsTr("🔄 Some changes (Classic Ribbon, Preview Pane, Recycle Bin, Home, Gallery) require restarting Windows Explorer to take effect.")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                wrapMode: Text.WordWrap
            }

            MeguButton {
                text: qsTr("Restart Explorer")
                accented: true
                onClicked: {
                    optimizerBackend.restartExplorer();
                }
            }
        }
    }

    // 1. Show file extensions
    Rectangle {
        width: parent.width
        height: Math.max(56, extCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: extCol
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: extSwitch.left
            anchors.rightMargin: 12
            spacing: 2

            Text {
                text: qsTr("Show file extensions")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: qsTr("Display file extensions (e.g. .txt, .exe) in File Explorer.")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        MeguSwitch {
            id: extSwitch
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            checked: optimizerBackend.explorerShowExtensions
            onToggled: (isChecked) => { optimizerBackend.explorerShowExtensions = isChecked; }
        }
    }

    // 2. Show hidden and system items
    Rectangle {
        width: parent.width
        height: Math.max(56, hiddenCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: hiddenCol
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: hiddenSwitch.left
            anchors.rightMargin: 12
            spacing: 2

            Text {
                text: qsTr("Show hidden files and folders")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: qsTr("Display hidden files, folders, and protected operating system files.")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        MeguSwitch {
            id: hiddenSwitch
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            checked: optimizerBackend.explorerShowHidden
            onToggled: (isChecked) => { optimizerBackend.explorerShowHidden = isChecked; }
        }
    }

    // 3. Show files after extraction is complete
    Rectangle {
        width: parent.width
        height: Math.max(56, extractCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: extractCol
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: extractSwitch.left
            anchors.rightMargin: 12
            spacing: 2

            Text {
                text: qsTr("Show extracted files")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: qsTr("Automatically open File Explorer to display extracted files when ZIP archive extraction completes.")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        MeguSwitch {
            id: extractSwitch
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            checked: optimizerBackend.explorerShowExtractFiles
            onToggled: (isChecked) => { optimizerBackend.explorerShowExtractFiles = isChecked; }
        }
    }

    // 4. Classic interface (Windows 10 ribbon)
    Rectangle {
        width: parent.width
        height: Math.max(56, ribbonCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: ribbonCol
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: ribbonSwitch.left
            anchors.rightMargin: 12
            spacing: 2

            Text {
                text: qsTr("Classic Windows 10 Ribbon")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: qsTr("Restore the Windows 10 style top ribbon menu in File Explorer (requires restart).")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        MeguSwitch {
            id: ribbonSwitch
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            checked: optimizerBackend.explorerClassicRibbon
            onToggled: (isChecked) => { optimizerBackend.explorerClassicRibbon = isChecked; }
        }
    }

    // 5. Show the preview pane for files
    Rectangle {
        width: parent.width
        height: Math.max(56, previewCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: previewCol
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: previewSwitch.left
            anchors.rightMargin: 12
            spacing: 2

            Text {
                text: qsTr("Show preview pane")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: qsTr("Enable the preview pane to view contents of text, images, and other files without opening them.")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        MeguSwitch {
            id: previewSwitch
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            checked: optimizerBackend.explorerShowPreviewPane
            onToggled: (isChecked) => { optimizerBackend.explorerShowPreviewPane = isChecked; }
        }
    }

    // 6. Recycle Bin navigation pane item
    Rectangle {
        width: parent.width
        height: Math.max(56, recycleNavCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: recycleNavCol
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: recycleNavSwitch.left
            anchors.rightMargin: 12
            spacing: 2

            Text {
                text: qsTr("Show Recycle Bin in navigation pane")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: qsTr("Pin the 'Recycle Bin' navigation link to the left sidebar of File Explorer (requires restart).")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        MeguSwitch {
            id: recycleNavSwitch
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            checked: optimizerBackend.explorerPinRecycleBin
            onToggled: (isChecked) => { optimizerBackend.explorerPinRecycleBin = isChecked; }
        }
    }

    // 7. Home navigation pane item
    Rectangle {
        width: parent.width
        height: Math.max(56, homeCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: homeCol
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: homeSwitch.left
            anchors.rightMargin: 12
            spacing: 2

            Text {
                text: qsTr("Show Home in navigation pane")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: qsTr("Pin the 'Home' navigation link to the left sidebar of File Explorer (requires restart).")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        MeguSwitch {
            id: homeSwitch
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            checked: optimizerBackend.explorerPinHome
            onToggled: (isChecked) => { optimizerBackend.explorerPinHome = isChecked; }
        }
    }

    // 8. Gallery navigation pane item
    Rectangle {
        width: parent.width
        height: Math.max(56, galleryCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: galleryCol
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: gallerySwitch.left
            anchors.rightMargin: 12
            spacing: 2

            Text {
                text: qsTr("Show Gallery in navigation pane")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: qsTr("Pin the 'Gallery' photo navigation link to the left sidebar of File Explorer (requires restart).")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        MeguSwitch {
            id: gallerySwitch
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            checked: optimizerBackend.explorerPinGallery
            onToggled: (isChecked) => { optimizerBackend.explorerPinGallery = isChecked; }
        }
    }

    // 9. Use checkboxes to select items
    Rectangle {
        width: parent.width
        height: Math.max(56, checkboxesCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: checkboxesCol
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: checkboxesSwitch.left
            anchors.rightMargin: 12
            spacing: 2

            Text {
                text: qsTr("Use checkboxes to select items")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: qsTr("Show a checkbox next to items in File Explorer to make multi-selection easier.")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        MeguSwitch {
            id: checkboxesSwitch
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            checked: optimizerBackend.explorerUseCheckboxes
            onToggled: (isChecked) => { optimizerBackend.explorerUseCheckboxes = isChecked; }
        }
    }

    // 10. Sync provider notifications
    Rectangle {
        width: parent.width
        height: Math.max(56, syncCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: syncCol
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: syncSwitch.left
            anchors.rightMargin: 12
            spacing: 2

            Text {
                text: qsTr("Sync provider notifications")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: qsTr("Show notifications from your cloud storage providers (e.g. OneDrive) in File Explorer.")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        MeguSwitch {
            id: syncSwitch
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            checked: optimizerBackend.explorerSyncNotifications
            onToggled: (isChecked) => { optimizerBackend.explorerSyncNotifications = isChecked; }
        }
    }

    // 11. Open to (Launch target dropdown)
    Rectangle {
        width: parent.width
        height: Math.max(56, openToCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: openToCol
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: openToDropdown.left
            anchors.rightMargin: 12
            spacing: 2

            Text {
                text: qsTr("Open File Explorer to")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: qsTr("Choose the default folder to open when starting File Explorer.")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        Rectangle {
            id: openToDropdown
            width: 140
            height: 32
            radius: 6
            color: "#05FFFFFF"
            border.color: Theme.border
            border.width: 1
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter

            property int currentVal: optimizerBackend.explorerLaunchTo

            readonly property var options: [
                { id: 1, label: qsTr("This PC") },
                { id: 2, label: qsTr("Home") },
                { id: 3, label: qsTr("Downloads") }
            ]

            function getLabelForVal(v) {
                for (var i = 0; i < options.length; i++) {
                    if (options[i].id === v) return options[i].label;
                }
                return qsTr("This PC");
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: openToDropdown.getLabelForVal(openToDropdown.currentVal)
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 11
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: "⌵"
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    openToMenu.open();
                }
                onEntered: openToDropdown.border.color = Theme.accent
                onExited: openToDropdown.border.color = Theme.border
            }

            Menu {
                id: openToMenu
                y: openToDropdown.height + 4
                width: openToDropdown.width
                
                background: Rectangle {
                    color: Theme.sidebarBg
                    border.color: Theme.border
                    border.width: 1
                    radius: 6
                }

                Instantiator {
                    model: openToDropdown.options
                    onObjectAdded: (index, object) => openToMenu.insertItem(index, object)
                    onObjectRemoved: (index, object) => openToMenu.removeItem(object)

                    delegate: MenuItem {
                        text: modelData.label
                        width: openToMenu.width
                        height: 32
                        
                        contentItem: Text {
                            text: parent.text
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            color: parent.highlighted ? Theme.accent : Theme.textPrimary
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 12
                        }

                        background: Rectangle {
                            color: parent.highlighted ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : "transparent"
                        }

                        onTriggered: {
                            optimizerBackend.explorerLaunchTo = modelData.id;
                        }
                    }
                }
            }
        }
    }
}
