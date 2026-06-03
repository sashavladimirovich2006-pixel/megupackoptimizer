import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects
import "../components"

Column {
    id: desktopColumn
    width: parent.width
    spacing: 16

    Text {
        text: qsTr("Customization of desktop icons, taskbar elements, window behavior, and wallpaper quality.")
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
        visible: false
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
                text: qsTr("🔄 Some changes (Classic Context Menu, Shortcut Arrows) require restarting Windows Explorer to take effect.")
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

    // 1. Show This PC
    Rectangle {
        width: parent.width
        height: Math.max(56, thisPcCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: thisPcCol
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: thisPcSwitch.left
            anchors.rightMargin: 12
            spacing: 2

            Text {
                text: qsTr("Show \"This PC\" icon on Desktop")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: qsTr("Display the \"This PC\" folder icon on the Windows desktop.")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        MeguSwitch {
            id: thisPcSwitch
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            checked: optimizerBackend.desktopShowThisPC
            onToggled: (isChecked) => { optimizerBackend.desktopShowThisPC = isChecked; }
        }
    }

    // 2. Show Recycle Bin
    Rectangle {
        width: parent.width
        height: Math.max(56, recycleCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: recycleCol
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: recycleSwitch.left
            anchors.rightMargin: 12
            spacing: 2

            Text {
                text: qsTr("Show Recycle Bin icon on Desktop")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: qsTr("Display the Recycle Bin icon on the Windows desktop.")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        MeguSwitch {
            id: recycleSwitch
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            checked: optimizerBackend.explorerShowRecycleBin
            onToggled: (isChecked) => { optimizerBackend.explorerShowRecycleBin = isChecked; }
        }
    }

    // 3. Show Widgets button on Taskbar
    Rectangle {
        width: parent.width
        height: Math.max(56, widgetsCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: widgetsCol
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: widgetsSwitch.left
            anchors.rightMargin: 12
            spacing: 2

            Text {
                text: qsTr("Show Widgets button on Taskbar")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: qsTr("Show the Widgets (weather and interests) icon on the taskbar.")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        MeguSwitch {
            id: widgetsSwitch
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            checked: optimizerBackend.desktopShowWidgets
            onToggled: (isChecked) => { optimizerBackend.desktopShowWidgets = isChecked; }
        }
    }

    // 4. Shortcut Arrow Overlays
    Rectangle {
        width: parent.width
        height: Math.max(56, shortcutCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: shortcutCol
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: shortcutSwitch.left
            anchors.rightMargin: 12
            spacing: 2

            Text {
                text: qsTr("Shortcut Arrow Overlays")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: qsTr("Show or hide the arrow overlay icon on desktop and Explorer shortcuts.")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        MeguSwitch {
            id: shortcutSwitch
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            checked: optimizerBackend.shortcutArrowsActive
            onToggled: (isChecked) => { optimizerBackend.shortcutArrowsActive = isChecked; }
        }
    }

    // 5. Drop Shadows for Icon Labels
    Rectangle {
        width: parent.width
        height: Math.max(56, shadowsCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: shadowsCol
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: shadowsSwitch.left
            anchors.rightMargin: 12
            spacing: 2

            Text {
                text: qsTr("Drop shadows for icon labels")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: qsTr("Display drop shadows under shortcut and folder labels on the desktop to make text more readable.")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        MeguSwitch {
            id: shadowsSwitch
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            checked: optimizerBackend.desktopIconShadows
            onToggled: (isChecked) => { optimizerBackend.desktopIconShadows = isChecked; }
        }
    }

    // 6. Show desktop button on Taskbar
    Rectangle {
        width: parent.width
        height: Math.max(56, showDesktopCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: showDesktopCol
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: showDesktopSwitch.left
            anchors.rightMargin: 12
            spacing: 2

            Text {
                text: qsTr("Show desktop button on Taskbar")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: qsTr("Enable the thin vertical strip button at the far right corner of the taskbar to minimize all windows.")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        MeguSwitch {
            id: showDesktopSwitch
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            checked: optimizerBackend.desktopShowDesktopButton
            onToggled: (isChecked) => { optimizerBackend.desktopShowDesktopButton = isChecked; }
        }
    }

    // 7. Aero Shake
    Rectangle {
        width: parent.width
        height: Math.max(56, shakeCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: shakeCol
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: shakeSwitch.left
            anchors.rightMargin: 12
            spacing: 2

            Text {
                text: qsTr("Titlebar window shake (Aero Shake)")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: qsTr("When enabled, shaking a window's title bar will minimize all other open windows.")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        MeguSwitch {
            id: shakeSwitch
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            checked: optimizerBackend.desktopAeroShake
            onToggled: (isChecked) => { optimizerBackend.desktopAeroShake = isChecked; }
        }
    }

    // 8. Classic Context Menu
    Rectangle {
        width: parent.width
        height: Math.max(56, classicCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: classicCol
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: classicSwitch.left
            anchors.rightMargin: 12
            spacing: 2

            Text {
                text: qsTr("Classic Context Menu")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: qsTr("Disable the Windows 11 Fluent context menu and restore the classic Windows 10 style context menu.")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        MeguSwitch {
            id: classicSwitch
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            checked: optimizerBackend.classicContextMenuActive
            onToggled: (isChecked) => { optimizerBackend.classicContextMenuActive = isChecked; }
        }
    }

    // 9. Wallpaper Quality
    Rectangle {
        width: parent.width
        height: Math.max(80, sliderCol.implicitHeight + 24)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: sliderCol
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: parent.right
            anchors.rightMargin: 12
            spacing: 8

            RowLayout {
                width: parent.width

                Column {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: qsTr("Wallpaper quality")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Specify the compression quality of imported JPEG wallpapers. 100% means no compression (highest quality).")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                }

                Text {
                    text: Math.round(wallpaperSlider.value) + "%"
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            Slider {
                id: wallpaperSlider
                width: parent.width
                from: 50
                to: 100
                value: optimizerBackend.desktopWallpaperQuality
                stepSize: 1
                live: true
                onMoved: {
                    optimizerBackend.desktopWallpaperQuality = Math.round(value);
                }

                background: Rectangle {
                    x: wallpaperSlider.leftPadding
                    y: wallpaperSlider.topPadding + wallpaperSlider.availableHeight / 2 - height / 2
                    implicitWidth: 200
                    implicitHeight: 4
                    width: wallpaperSlider.availableWidth
                    height: implicitHeight
                    radius: 2
                    color: Theme.border

                    Rectangle {
                        width: wallpaperSlider.visualPosition * parent.width
                        height: parent.height
                        color: Theme.accent
                        radius: 2
                    }
                }

                handle: Rectangle {
                    x: wallpaperSlider.leftPadding + wallpaperSlider.visualPosition * (wallpaperSlider.availableWidth - width)
                    y: wallpaperSlider.topPadding + wallpaperSlider.availableHeight / 2 - height / 2
                    implicitWidth: 16
                    implicitHeight: 16
                    radius: 8
                    color: wallpaperSlider.pressed ? Theme.accent : Theme.textPrimary
                    border.color: Theme.accent
                    border.width: wallpaperSlider.hovered ? 2 : 0

                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    Behavior on scale { NumberAnimation { duration: Theme.animFast } }
                    scale: wallpaperSlider.pressed ? 1.2 : (wallpaperSlider.hovered ? 1.1 : 1.0)
                }
            }
        }
    }
}
