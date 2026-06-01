import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects
import "../components"

Item {
    id: steamSettingsDrawer
    width: parent.width
    height: dynamicHeight

    property string subPage: "main" // "main", "friends", "chat", "notifications", "ingame", "interface", "library", "download", "storage", "toolbarPrefs", "accessibility", "gamerecording", "voice", "remoteplay", "music"
    property bool steamIsRunning: window.steamIsRunning
    property string steamActiveUserId: window.steamActiveUserId

    Component.onCompleted: {
        optimizerBackend.scanSteamInstalledGames();
        populateGamesModel();
    }

    Connections {
        target: optimizerBackend
        function onSteamInstalledGamesChanged() {
            populateGamesModel();
        }
        function onSteamCacheLog(message, type) {
            if (typeof stepLogModel !== "undefined" && stepLogModel !== null) {
                stepLogModel.append({ "message": message, "type": type });
            }
        }
    }

    function populateGamesModel() {
        steamGamesModel.clear();
        var games = optimizerBackend.steamInstalledGames;
        for (var i = 0; i < games.length; i++) {
            steamGamesModel.append(games[i]);
        }
    }

    property real dynamicHeight: {
        if (subPage === "friends") return steamFriendsPage.implicitHeight;
        if (subPage === "chat") return steamChatPage.implicitHeight;
        if (subPage === "notifications") return steamNotificationsPage.implicitHeight;
        if (subPage === "ingame") return steamInGamePage.implicitHeight;
        if (subPage === "interface") return steamInterfacePage.implicitHeight;
        if (subPage === "library") return steamLibraryPage.implicitHeight;
        if (subPage === "download") return steamDownloadPage.implicitHeight;
        if (subPage === "storage") return steamStoragePage.implicitHeight;
        if (subPage === "toolbarPrefs") return steamToolbarPrefsPage.implicitHeight;
        if (subPage === "accessibility") return steamAccessibilityPage.implicitHeight;
        if (subPage === "gamerecording") return steamGameRecordingPage.implicitHeight;
        if (subPage === "voice") return steamVoicePage.implicitHeight;
        if (subPage === "remoteplay") return steamRemotePlayPage.implicitHeight;
        if (subPage === "music") return steamMusicPage.implicitHeight;
        return steamMainPage.implicitHeight;
    }

    Column {
        width: parent.width
        spacing: 20

        // Main Menu Page
        Column {
        id: steamMainPage
        width: parent.width
        spacing: 12
        visible: steamSettingsDrawer.subPage === "main"

        Text {
            text: qsTr("STEAM CONFIGURATION")
            color: Theme.accent
            font.family: Theme.fontFamily
            font.pixelSize: 13
            font.bold: true
            font.letterSpacing: 1.5
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.border
        }

        // Steam Not Running Warning Card
        Rectangle {
            width: parent.width
            height: warningColumn.implicitHeight + 24
            radius: Theme.radiusNormal
            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.05)
            border.color: Theme.accent
            border.width: 1
            visible: !steamIsRunning || steamActiveUserId === ""

            Column {
                id: warningColumn
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                Row {
                    spacing: 12
                    width: parent.width

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 6
                        color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            text: "⚠️"
                            font.pixelSize: 16
                            anchors.centerIn: parent
                        }
                    }

                    Column {
                        spacing: 2
                        width: parent.width - 32 - 12 - 16
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: !steamIsRunning ? qsTr("Steam is not running") : qsTr("Steam is running but no user is logged in")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                            font.bold: true
                        }

                        Text {
                            text: !steamIsRunning ? qsTr("To configure and optimize Steam, please launch the Steam client first.") : qsTr("Please log in to your Steam account to load and configure your profile settings.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.Wrap
                        }
                    }
                }

                MeguButton {
                    text: qsTr("Launch Steam")
                    accented: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 140
                    height: 28
                    visible: !steamIsRunning
                    onClicked: {
                        optimizerBackend.launchSteam();
                        steamIsRunning = true;
                    }
                }
            }
        }

        Column {
            width: parent.width
            spacing: 12
            enabled: steamIsRunning && steamActiveUserId !== ""
            opacity: (steamIsRunning && steamActiveUserId !== "") ? 1.0 : 0.4
            Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }

            // Friends & Chat Menu Option
        Rectangle {
            width: parent.width
            height: 48
            radius: Theme.radiusSmall
            color: friendsMouse.containsMouse ? Theme.accentDim : "transparent"
            border.color: friendsMouse.containsMouse ? Theme.accent : Theme.border
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
                    width: parent.width - 32

                    Text {
                        text: qsTr("Friends & Chat")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Friends list, avatars, and sign-in preferences")
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                    }
                }

                Text {
                    text: "→"
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: friendsMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: steamSettingsDrawer.subPage = "friends"
            }
        }

        // Chat Settings Menu Option
        Rectangle {
            width: parent.width
            height: 48
            radius: Theme.radiusSmall
            color: chatMouse.containsMouse ? Theme.accentDim : "transparent"
            border.color: chatMouse.containsMouse ? Theme.accent : Theme.border
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
                    width: parent.width - 32

                    Text {
                        text: qsTr("Chat Settings")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Media embedding, spellcheck, and text sizes")
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                    }
                }

                Text {
                    text: "→"
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: chatMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: steamSettingsDrawer.subPage = "chat"
            }
        }

        // Notifications Menu Option
        Rectangle {
            width: parent.width
            height: 48
            radius: Theme.radiusSmall
            color: notifMouse.containsMouse ? Theme.accentDim : "transparent"
            border.color: notifMouse.containsMouse ? Theme.accent : Theme.border
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
                    width: parent.width - 32

                    Text {
                        text: qsTr("Notifications")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Client alerts, sounds, and toast rules")
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                    }
                }

                Text {
                    text: "→"
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: notifMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: steamSettingsDrawer.subPage = "notifications"
            }
        }

        // In Game Menu Option
        Rectangle {
            width: parent.width
            height: 48
            radius: Theme.radiusSmall
            color: inGameMouse.containsMouse ? Theme.accentDim : "transparent"
            border.color: inGameMouse.containsMouse ? Theme.accent : Theme.border
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
                    width: parent.width - 32

                    Text {
                        text: qsTr("In Game")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Steam Overlay settings and in-game preferences")
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                    }
                }

                Text {
                    text: "→"
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: inGameMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: steamSettingsDrawer.subPage = "ingame"
            }
        }

        // Interface Menu Option
        Rectangle {
            width: parent.width
            height: 48
            radius: Theme.radiusSmall
            color: interfaceMouse.containsMouse ? Theme.accentDim : "transparent"
            border.color: interfaceMouse.containsMouse ? Theme.accent : Theme.border
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
                    width: parent.width - 32

                    Text {
                        text: qsTr("Interface")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Scale text, startup location, and GPU accelerated rendering")
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                    }
                }

                Text {
                    text: "→"
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: interfaceMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: steamSettingsDrawer.subPage = "interface"
            }
        }

        // Library Menu Option
        Rectangle {
            width: parent.width
            height: 48
            radius: Theme.radiusSmall
            color: libraryMouse.containsMouse ? Theme.accentDim : "transparent"
            border.color: libraryMouse.containsMouse ? Theme.accent : Theme.border
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
                    width: parent.width - 32

                    Text {
                        text: qsTr("Library")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Bandwidth, performance, and community options")
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                    }
                }

                Text {
                    text: "→"
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: libraryMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: steamSettingsDrawer.subPage = "library"
            }
        }

        // Download Menu Option
        Rectangle {
            width: parent.width
            height: 48
            radius: Theme.radiusSmall
            color: downloadMouse.containsMouse ? Theme.accentDim : "transparent"
            border.color: downloadMouse.containsMouse ? Theme.accent : Theme.border
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
                    width: parent.width - 32

                    Text {
                        text: qsTr("Downloads")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Speed limits, gameplay download rules, and shader pre-caching")
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                    }
                }

                Text {
                    text: "→"
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: downloadMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: steamSettingsDrawer.subPage = "download"
            }
        }

        // Storage Menu Option
        Rectangle {
            width: parent.width
            height: 48
            radius: Theme.radiusSmall
            color: storageMouse.containsMouse ? Theme.accentDim : "transparent"
            border.color: storageMouse.containsMouse ? Theme.accent : Theme.border
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
                    width: parent.width - 32

                    Text {
                        text: qsTr("Storage")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Manage installed games, DLCs, and workshop content sizes")
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                    }
                }

                Text {
                    text: "→"
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: storageMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    optimizerBackend.scanSteamInstalledGames();
                    steamSettingsDrawer.subPage = "storage"
                }
            }
        }

        // Accessibility Menu Option
        Rectangle {
            width: parent.width
            height: 48
            radius: Theme.radiusSmall
            color: accessibilityMouse.containsMouse ? Theme.accentDim : "transparent"
            border.color: accessibilityMouse.containsMouse ? Theme.accent : Theme.border
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
                    width: parent.width - 32

                    Text {
                        text: qsTr("Accessibility")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Configure accessibility and user interface options")
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                    }
                }

                Text {
                    text: "→"
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: accessibilityMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: steamSettingsDrawer.subPage = "accessibility"
            }
        }

        // Game Recording Menu Option
        Rectangle {
            width: parent.width
            height: 48
            radius: Theme.radiusSmall
            color: gameRecordingMouse.containsMouse ? Theme.accentDim : "transparent"
            border.color: gameRecordingMouse.containsMouse ? Theme.accent : Theme.border
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
                    width: parent.width - 32

                    Text {
                        text: qsTr("Game Recording")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Configure game recording and capture options")
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                    }
                }

                Text {
                    text: "→"
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: gameRecordingMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: steamSettingsDrawer.subPage = "gamerecording"
            }
        }

        // Voice Menu Option
        Rectangle {
            width: parent.width
            height: 48
            radius: Theme.radiusSmall
            color: voiceMouse.containsMouse ? Theme.accentDim : "transparent"
            border.color: voiceMouse.containsMouse ? Theme.accent : Theme.border
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
                    width: parent.width - 32

                    Text {
                        text: qsTr("Voice")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Configure voice transmission and advanced voice settings")
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                    }
                }

                Text {
                    text: "→"
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: voiceMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: steamSettingsDrawer.subPage = "voice"
            }
        }

        // Remote Play Menu Option
        Rectangle {
            width: parent.width
            height: 48
            radius: Theme.radiusSmall
            color: remotePlayMouse.containsMouse ? Theme.accentDim : "transparent"
            border.color: remotePlayMouse.containsMouse ? Theme.accent : Theme.border
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
                    width: parent.width - 32

                    Text {
                        text: qsTr("Remote Play")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Configure Remote Play and streaming options")
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                    }
                }

                Text {
                    text: "→"
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: remotePlayMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: steamSettingsDrawer.subPage = "remoteplay"
            }
        }

        // Music Menu Option
        Rectangle {
            width: parent.width
            height: 48
            radius: Theme.radiusSmall
            color: musicMouse.containsMouse ? Theme.accentDim : "transparent"
            border.color: musicMouse.containsMouse ? Theme.accent : Theme.border
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
                    width: parent.width - 32

                    Text {
                        text: qsTr("Music")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Configure Music and soundtrack download options")
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                    }
                }

                Text {
                    text: "→"
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: musicMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: steamSettingsDrawer.subPage = "music"
            }
        }
        }
    }

    // PAGE 1: Friends & Chat Sub-Page
    Column {
        id: steamFriendsPage
        width: parent.width
        spacing: 20
        visible: steamSettingsDrawer.subPage === "friends"

        Row {
            spacing: 10
            width: parent.width

            MeguButton {
                text: qsTr("Back")
                iconRotation: 180

                iconSource: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                width: 80
                onClicked: steamSettingsDrawer.subPage = "main"
            }

            Text {
                text: qsTr("FRIENDS & CHAT")
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
        }

        Column {
            width: parent.width
            spacing: 16

            // Toggle 2
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_1.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_1;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_1.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Group friends together by game")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Optimizes friends list processing by disabling real-time dynamic group sorting.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_1
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bGroupFriendsByGame"] : false
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bGroupFriendsByGame", isChecked); }
                    }
            }

            // Toggle 3
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_2.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_2;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_2.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Hide offline friends in custom categories")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Reduces Steam client memory usage by hiding inactive list items.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_2
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bHideOfflineFriendsInCustomCategories"] : false
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bHideOfflineFriendsInCustomCategories", isChecked); }
                    }
            }

            // Toggle 4
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_3.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_3;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_3.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Hide categorized friends in Online/Offline Friends")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Prevents duplicate rendering of friends list interface elements.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_3
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bHideCategorizedFriendsInOnlineOffline"] : false
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bHideCategorizedFriendsInOnlineOffline", isChecked); }
                    }
            }

            // Toggle 5
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_4.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_4;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_4.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Ignore 'Away' status when sorting friends")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Reduces friends list sorting calculation frequency during user status updates.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_4
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bIgnoreAwayStatusWhenSorting"] : false
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bIgnoreAwayStatusWhenSorting", isChecked); }
                    }
            }

            // Toggle 6
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_5.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_5;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_5.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Sign in to friends when Steam starts")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Disabling accelerates Steam client startup and minimizes initial network/CPU overhead.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_5
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bSignInOnStart"] : false
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bSignInOnStart", isChecked); }
                    }
            }

            // Toggle 7
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_6.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_6;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_6.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Enable Animated Avatars & Animated Avatar Frames")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Disabling completely stops animated avatars in CEF, heavily reducing GPU load and in-game input latency.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_6
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bEnableAnimatedAvatars"] : false
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bEnableAnimatedAvatars", isChecked); }
                    }
            }

            // Toggle 8
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_7.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_7;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_7.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Compact friends list & chat view")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Minimizes Steam client rendering surface area to save GPU resources.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_7
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bCompactFriendsListAndChat"] : false
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bCompactFriendsListAndChat", isChecked); }
                    }
            }

            // Toggle 9
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_8.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_8;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_8.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Compact favorite friends area")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Shrinks avatar sizes in the top section, minimizing layout computation overhead.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_8
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bCompactFavorites"] : false
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bCompactFavorites", isChecked); }
                    }
            }
        }
    }

    // PAGE 2: Chat Sub-Page
    Column {
        id: steamChatPage
        width: parent.width
        spacing: 20
        visible: steamSettingsDrawer.subPage === "chat"

        Row {
            spacing: 10
            width: parent.width

            MeguButton {
                text: qsTr("Back")
                iconRotation: 180

                iconSource: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                width: 80
                onClicked: steamSettingsDrawer.subPage = "main"
            }

            Text {
                text: qsTr("CHAT SETTINGS")
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
        }

        Column {
            width: parent.width
            spacing: 16

            // Toggle 10
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_9.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_9;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_9.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Dock chats to the friends list")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Merges chat and friends list windows, preventing creation of extra CEF rendering processes.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_9
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bDockChats"] : false
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bDockChats", isChecked); }
                    }
            }

            // Toggle 11
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_10.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_10;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_10.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Open a new window for new chats")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Disabling prevents resource-intensive new OS windows from launching for every participant.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_10
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bOpenNewWindowForNewChats"] : false
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bOpenNewWindowForNewChats", isChecked); }
                    }
            }

            // Toggle 12
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_11.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_11;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_11.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Don't embed images and other media inline")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Enabling stops automatic media loading and rendering, preventing sudden in-game frame drops.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_11
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bDontEmbedImages"] : false
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bDontEmbedImages", isChecked); }
                    }
            }

            // Toggle 13
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_12.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_12;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_12.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Remember my open chats")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Disabling reduces disk reads/writes during Steam startup by skipping previous session restorations.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_12
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bRememberOpenChats"] : false
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bRememberOpenChats", isChecked); }
                    }
            }

            // Toggle 14
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_13.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_13;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_13.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Disable spellcheck in chat message entry")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Disables the real-time spellcheck engine, reducing CPU usage during text typing.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_13
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bDisableSpellCheck"] : false
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bDisableSpellCheck", isChecked); }
                    }
            }

            // Toggle 15
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_14.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_14;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_14.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Disable animated room effects")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Stops CPU/GPU-intensive graphical effects (emoji showers, confetti) inside chat rooms.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_14
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bDisableRoomEffects"] : false
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bDisableRoomEffects", isChecked); }
                    }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.border
        }

        // FontSize Segmented Selector
        Column {
            width: parent.width
            spacing: 8

            Text {
                text: qsTr("Chat Font Size")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 13
                font.bold: true
            }

            Row {
                id: fontSizeRow
                width: parent.width
                spacing: 8

                property string currentSize: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["fontSize"] || "default" : "default"

                Repeater {
                    model: {
                        var lang = settingsBackend.language;
                        return [
                            { id: "small", label: qsTr("Small") },
                            { id: "default", label: qsTr("Default") },
                            { id: "large", label: qsTr("Large") }
                        ];
                    }
                    delegate: Rectangle {
                        height: 32
                        width: (parent.width - 16) / 3
                        radius: 6
                        color: (fontSizeRow.currentSize === modelData.id) ? Theme.accentDim : (btnMouse.containsMouse ? "#0DFFFFFF" : "#05FFFFFF")
                        border.color: (fontSizeRow.currentSize === modelData.id) ? Theme.accent : Theme.border
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                        Text {
                            text: modelData.label
                            color: (fontSizeRow.currentSize === modelData.id) ? Theme.accent : Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            id: btnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.toggleSteamFriendsSetting("fontSize", modelData.id);
                            }
                        }
                    }
                }
            }

            Text {
                text: qsTr("Sets the font size of the Steam chat interface.")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
            }
        }
    }

    // PAGE 3: Notifications Sub-Page
    Column {
        id: steamNotificationsPage
        width: parent.width
        spacing: 20
        visible: steamSettingsDrawer.subPage === "notifications"

        Row {
            spacing: 10
            width: parent.width

            MeguButton {
                text: qsTr("Back")
                iconRotation: 180

                iconSource: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                width: 80
                onClicked: steamSettingsDrawer.subPage = "main"
            }

            Text {
                text: qsTr("NOTIFICATIONS")
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
        }

        // Global Sound Toggle
        Rectangle {
            width: parent.width
                height: Math.max(50, steamToggleCol_15.implicitHeight + 12)
            color: "transparent"
                Column { id: steamToggleCol_15;
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_15.left
                        anchors.rightMargin: 12
                    Text {
                        text: qsTr("Play a sound when a toast is displayed")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Enables or disables standard sound notifications inside the Steam client interface.")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                }
                MeguSwitch {
                    id: steamToggleSwitch_15
                    anchors.right: parent.right

                    steamStyle: true
                    checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bPlayNotificationSounds"] : true
                    anchors.verticalCenter: parent.verticalCenter
                    onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bPlayNotificationSounds", isChecked); }
                }
        }

        // Column headers
        Row {
            width: parent.width
            height: 20

            Text {
                text: qsTr("CLIENT & FRIEND EVENTS")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 10
                font.bold: true
                font.letterSpacing: 1.0
                width: parent.width - 120
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: qsTr("TOAST")
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: 9
                font.bold: true
                width: 60
                horizontalAlignment: Text.AlignHCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: qsTr("SOUND")
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: 9
                font.bold: true
                width: 60
                horizontalAlignment: Text.AlignHCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Sub-Options Toggles
        Column {
            width: parent.width
            spacing: 12

            // 1. Achievements
            Rectangle {
                width: parent.width
                height: 40
                color: "transparent"

                Text {
                    text: qsTr("When I unlock an achievement")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 120
                    wrapMode: Text.WordWrap
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 20

                    MeguSwitch {


                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bAchievementShowToast"] : true
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bAchievementShowToast", isChecked); }
                    }

                    MeguSwitch {
                        id: achSoundSwitch
                        steamStyle: true
                        enabled: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bPlayNotificationSounds"] : true
                        checked: achSoundSwitch.enabled && (optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bAchievementPlaySound"] : true)
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bAchievementPlaySound", isChecked); }
                    }
                }
            }

            // 2. Controller Connect
            Rectangle {
                width: parent.width
                height: 40
                color: "transparent"

                Text {
                    text: qsTr("When I connect a controller")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 120
                    wrapMode: Text.WordWrap
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 20

                    MeguSwitch {


                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bControllerShowToast"] : true
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bControllerShowToast", isChecked); }
                    }

                    MeguSwitch {
                        id: ctrlSoundSwitch
                        steamStyle: true
                        enabled: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bPlayNotificationSounds"] : true
                        checked: ctrlSoundSwitch.enabled && (optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bControllerPlaySound"] : false)
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bControllerPlaySound", isChecked); }
                    }
                }
            }

            // 3. Controller Low Battery
            Rectangle {
                width: parent.width
                height: 40
                color: "transparent"

                Text {
                    text: qsTr("When a controller's battery is low")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 120
                    wrapMode: Text.WordWrap
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 20

                    MeguSwitch {


                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bControllerLowShowToast"] : true
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bControllerLowShowToast", isChecked); }
                    }

                    MeguSwitch {
                        id: ctrlLowSoundSwitch
                        steamStyle: true
                        enabled: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bPlayNotificationSounds"] : true
                        checked: ctrlLowSoundSwitch.enabled && (optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bControllerLowPlaySound"] : false)
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bControllerLowPlaySound", isChecked); }
                    }
                }
            }

            // 4. Friend Joins Game
            Rectangle {
                width: parent.width
                height: 40
                color: "transparent"

                Text {
                    text: qsTr("When a friend joins a game")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 120
                    wrapMode: Text.WordWrap
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 20

                    MeguSwitch {


                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bFriendJoinShowToast"] : true
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bFriendJoinShowToast", isChecked); }
                    }

                    MeguSwitch {
                        id: friendJoinSoundSwitch
                        steamStyle: true
                        enabled: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bPlayNotificationSounds"] : true
                        checked: friendJoinSoundSwitch.enabled && (optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bFriendJoinPlaySound"] : false)
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bFriendJoinPlaySound", isChecked); }
                    }
                }
            }

            // 5. Friend Comes Online
            Rectangle {
                width: parent.width
                height: 40
                color: "transparent"

                Text {
                    text: qsTr("When a friend comes online")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 120
                    wrapMode: Text.WordWrap
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 20

                    MeguSwitch {


                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bFriendOnlineShowToast"] : false
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bFriendOnlineShowToast", isChecked); }
                    }

                    MeguSwitch {
                        id: friendOnlineSoundSwitch
                        steamStyle: true
                        enabled: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bPlayNotificationSounds"] : true
                        checked: friendOnlineSoundSwitch.enabled && (optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bFriendOnlinePlaySound"] : false)
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bFriendOnlinePlaySound", isChecked); }
                    }
                }
            }

            // 6. Direct Message
            Rectangle {
                width: parent.width
                height: 40
                color: "transparent"

                Text {
                    text: qsTr("When I receive a direct chat message")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 120
                    wrapMode: Text.WordWrap
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 20

                    MeguSwitch {


                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bFriendMsgShowToast"] : true
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bFriendMsgShowToast", isChecked); }
                    }

                    MeguSwitch {
                        id: friendMsgSoundSwitch
                        steamStyle: true
                        enabled: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bPlayNotificationSounds"] : true
                        checked: friendMsgSoundSwitch.enabled && (optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bFriendMsgPlaySound"] : true)
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bFriendMsgPlaySound", isChecked); }
                    }
                }
            }

            // 7. Chat Room Toast
            Rectangle {
                width: parent.width
                height: 40
                color: "transparent"

                Text {
                    text: qsTr("When I receive a chat room notification")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 120
                    wrapMode: Text.WordWrap
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 20

                    MeguSwitch {


                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bChatRoomShowToast"] : true
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bChatRoomShowToast", isChecked); }
                    }

                    MeguSwitch {
                        id: chatRoomSoundSwitch
                        steamStyle: true
                        enabled: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bPlayNotificationSounds"] : true
                        checked: chatRoomSoundSwitch.enabled && (optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bChatRoomPlaySound"] : true)
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bChatRoomPlaySound", isChecked); }
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.border
        }

        // Window Flashing option
        Column {
            width: parent.width
            spacing: 8

            Text {
                text: qsTr("Flash window when receive chat message:")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }

            Row {
                id: flashModeRow
                width: parent.width
                spacing: 8

                property string flashMode: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["flashWindowOnMessage"] || "always" : "always"

                Repeater {
                    model: {
                        var lang = settingsBackend.language;
                        return [
                            { id: "always", label: qsTr("Always") },
                            { id: "minimized", label: qsTr("Only when minimized") },
                            { id: "never", label: qsTr("Never") }
                        ];
                    }
                    delegate: Rectangle {
                        height: 32
                        width: (parent.width - 16) / 3
                        radius: 6
                        color: (flashModeRow.flashMode === modelData.id) ? Theme.accentDim : (flashBtnMouse.containsMouse ? "#0DFFFFFF" : "#05FFFFFF")
                        border.color: (flashModeRow.flashMode === modelData.id) ? Theme.accent : Theme.border
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                        Text {
                            text: modelData.label
                            color: (flashModeRow.flashMode === modelData.id) ? Theme.accent : Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            id: flashBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.toggleSteamFriendsSetting("flashWindowOnMessage", modelData.id);
                            }
                        }
                    }
                }
            }
        }
    }

    // PAGE 4: Interface Sub-Page
    Column {
        id: steamInterfacePage
        width: parent.width
        spacing: 20
        visible: steamSettingsDrawer.subPage === "interface"

        Row {
            spacing: 10
            width: parent.width

            MeguButton {
                text: qsTr("Back")
                iconRotation: 180

                iconSource: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                width: 80
                onClicked: steamSettingsDrawer.subPage = "main"
            }

            Text {
                text: qsTr("INTERFACE")
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
        }

        Column {
            width: parent.width
            spacing: 16

            // Toggle 1: Scale text and icons
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_16.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_16;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_16.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Scale text and icons to match monitor settings (requires restart)")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Scales Steam interface to monitor DPI settings automatically.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_16
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bScaleTextAndIcons"] : true
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bScaleTextAndIcons", isChecked); }
                    }
            }

            // Toggle 2: Run Steam on startup
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_17.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_17;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_17.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Run Steam when my computer starts")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Launches Steam automatically during system logon.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_17
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bRunOnStartup"] : true
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bRunOnStartup", isChecked); }
                    }
            }


            // Toggle 5: Enable smooth scrolling
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_20.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_20;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_20.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Enable smooth scrolling in web views (requires restart)")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Enables kinetic smooth scrolling transitions in Store and Community pages.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_20
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bSmoothScrolling"] : true
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bSmoothScrolling", isChecked); }
                    }
            }

            // Toggle 6: Enable GPU accelerated rendering
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_21.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_21;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_21.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Enable GPU accelerated rendering in web views (requires restart)")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Leverages graphics card processor resources to render Steam UI elements faster.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_21
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bGPUAcceleratedRendering"] : true
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => {
                            root.toggleSteamFriendsSetting("bGPUAcceleratedRendering", isChecked);
                            if (!isChecked) {
                                root.toggleSteamFriendsSetting("bHardwareVideoDecoding", false);
                            }
                        }
                    }
            }

            // Toggle 7: Enable hardware video decoding
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_22.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_22;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_22.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Enable hardware video decoding, if supported (requires restart)")
                            color: steamToggleSwitch_22.enabled ? Theme.textPrimary : Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Uses dedicated hardware video decoder units on the GPU for storefront media players.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                        Text {
                            visible: !steamToggleSwitch_22.enabled
                            text: qsTr("\"Enable GPU accelerated rendering in web views\" setting must be enabled")
                            color: "#c63939"
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_22
                    anchors.right: parent.right

                        steamStyle: true
                        enabled: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bGPUAcceleratedRendering"] : true
                        checked: enabled && optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bHardwareVideoDecoding"] : false
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bHardwareVideoDecoding", isChecked); }
                    }
            }

            // Toggle 8: Notify me about additions
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_23.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_23;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_23.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Notify me about additions or changes to my games, new releases, and upcoming releases")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Enables storefront marketing and service notifications in the client.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_23
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bNotifyGameAdditions"] : true
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bNotifyGameAdditions", isChecked); }
                    }
            }
        }
    }

    // PAGE: In Game Sub-Page
    Column {
        id: steamInGamePage
        width: parent.width
        spacing: 20
        visible: steamSettingsDrawer.subPage === "ingame"

        Row {
            spacing: 10
            width: parent.width

            MeguButton {
                text: qsTr("Back")
                iconRotation: 180

                iconSource: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                width: 80
                onClicked: steamSettingsDrawer.subPage = "main"
            }

            Text {
                text: qsTr("IN GAME")
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
        }

        Column {
            width: parent.width
            spacing: 16

            Text {
                text: qsTr("The Steam Overlay")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.0
            }

            // Toggle 1: Enable the Steam Overlay while in-game
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_24.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_24;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_24.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Enable the Steam Overlay while in-game")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Allows access to Steam features while playing games.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_24
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamOverlayActive
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { optimizerBackend.steamOverlayActive = isChecked; }
                    }
            }

            // Toggle 3: Restore my previous browser tabs when starting a game
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_26.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_26;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_26.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Restore my previous browser tabs when starting a game")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Saves open browser tabs when you close a game and restores them.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_26
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bRestoreOverlayBrowserTabs"] : true
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bRestoreOverlayBrowserTabs", isChecked); }
                    }
            }

            // Toggle 5: Scale Steam Overlay text and icons to match monitor settings
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_28.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_28;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_28.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Scale Steam Overlay text and icons to match monitor settings")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Adjusts overlay text size and UI scale according to your monitor DPI.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_28
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bScaleOverlayTextAndIcons"] : true
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bScaleOverlayTextAndIcons", isChecked); }
                    }
            }

            // Header: Overlay Performance Monitor
            Column {
                width: parent.width
                spacing: 6

                Text {
                    text: qsTr("Overlay Performance Monitor")
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 1.0
                }

                Text {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    textFormat: Text.RichText
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    text: qsTr("The In-Game overlay is designed to help you understand your game and PC performance. It can render a variety of game and hardware performance information over a running game. <a href='https://support.steampowered.com/kb_article.php?ref=2235-QOMF-3286' style='color:#63b1e2; text-decoration:underline;'>Learn about the performance monitor numbers here.</a>")
                    onLinkActivated: (link) => Qt.openUrlExternally(link)
                }
            }

            // Row: Show performance monitor selector box
            Rectangle {
                width: parent.width
                height: 50
                color: "transparent"

                Text {
                    text: qsTr("Show performance monitor")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Styled Premium ComboBox Dropdown
                Rectangle {
                    id: perfMonitorDropdown
                    width: 140
                    height: 32
                    radius: 6
                    color: "#05FFFFFF"
                    border.color: Theme.border
                    border.width: 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    property string currentVal: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["InGameOverlayShowFPSCorner"] || "0" : "0"

                    readonly property var options: [
                        { id: "0", label: qsTr("Off") },
                        { id: "1", label: qsTr("Top-left") },
                        { id: "5", label: qsTr("Top-center") },
                        { id: "2", label: qsTr("Top-right") },
                        { id: "3", label: qsTr("Bottom-right") },
                        { id: "6", label: qsTr("Bottom-center") },
                        { id: "4", label: qsTr("Bottom-left") }
                    ]

                    function getLabelForVal(v) {
                        for (var i = 0; i < options.length; i++) {
                            if (options[i].id === v) return options[i].label;
                        }
                        return qsTr("Off");
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: perfMonitorDropdown.getLabelForVal(perfMonitorDropdown.currentVal)
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
                            perfMenu.open();
                        }
                        onEntered: perfMonitorDropdown.border.color = Theme.accent
                        onExited: perfMonitorDropdown.border.color = Theme.border
                    }

                    Menu {
                        id: perfMenu
                        y: perfMonitorDropdown.height + 4
                        width: perfMonitorDropdown.width
                        
                        background: Rectangle {
                            color: Theme.sidebarBg
                            border.color: Theme.border
                            border.width: 1
                            radius: 6
                        }

                        Instantiator {
                            model: perfMonitorDropdown.options
                            onObjectAdded: (index, object) => perfMenu.insertItem(index, object)
                            onObjectRemoved: (index, object) => perfMenu.removeItem(object)

                            delegate: MenuItem {
                                text: modelData.label
                                width: perfMenu.width
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
                                    root.toggleSteamFriendsSetting("InGameOverlayShowFPSCorner", modelData.id);
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
            }

            // Action 1: Delete Web Browser Data
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_29.implicitHeight + 12)
                color: "transparent"
                Row {
                    anchors.fill: parent
                    spacing: 12
                    Column { id: steamToggleCol_29;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        width: parent.width - 110
                        Text {
                            text: qsTr("Delete Web Browser Data")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Delete all Steam browser cached files, cookies, and history?")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguButton {
                        text: qsTr("Delete")
                        width: 90
                        height: 30
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            steamBrowserDeleteConfirmDialog.open();
                        }
                    }
                }
            }


        }
    }

    // PAGE: Toolbar Preferences Sub-Page (Mock)
    Column {
        id: steamToolbarPrefsPage
        width: parent.width
        spacing: 20
        visible: steamSettingsDrawer.subPage === "toolbarPrefs"

        Row {
            spacing: 10
            width: parent.width

            MeguButton {
                text: qsTr("Back")
                iconRotation: 180

                iconSource: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                width: 80
                onClicked: steamSettingsDrawer.subPage = "ingame"
            }

            Text {
                text: qsTr("TOOLBAR PREFERENCES")
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
        }

        Column {
            width: parent.width
            spacing: 16

            Text {
                text: qsTr("This feature is currently configured automatically by the optimizer for best performance.")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                width: parent.width
                wrapMode: Text.WordWrap
            }

            Rectangle {
                width: parent.width
                height: 40
                color: "transparent"
                Row {
                    anchors.fill: parent
                    spacing: 12
                    MeguSwitch {

                        steamStyle: true
                        checked: true
                        anchors.verticalCenter: parent.verticalCenter
                        enabled: false
                    }
                    Text {
                        text: qsTr("Show Web Browser")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 40
                color: "transparent"
                Row {
                    anchors.fill: parent
                    spacing: 12
                    MeguSwitch {

                        steamStyle: true
                        checked: true
                        anchors.verticalCenter: parent.verticalCenter
                        enabled: false
                    }
                    Text {
                        text: qsTr("Show Friends List")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 40
                color: "transparent"
                Row {
                    anchors.fill: parent
                    spacing: 12
                    MeguSwitch {

                        steamStyle: true
                        checked: false
                        anchors.verticalCenter: parent.verticalCenter
                        enabled: false
                    }
                    Text {
                        text: qsTr("Show Achievements")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }

    // PAGE: Accessibility Sub-Page
    Column {
        id: steamAccessibilityPage
        width: parent.width
        spacing: 20
        visible: steamSettingsDrawer.subPage === "accessibility"

        Row {
            spacing: 10
            width: parent.width

            MeguButton {
                text: qsTr("Back")
                iconRotation: 180

                iconSource: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                width: 80
                onClicked: steamSettingsDrawer.subPage = "main"
            }

            Text {
                text: qsTr("ACCESSIBILITY")
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
        }

        Column {
            width: parent.width
            spacing: 16

            // Toggle 1: Reduce Motion
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_31.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_31;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_31.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Reduce Motion")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Disable certain Steam animations, effects and transitions to reduce on-screen movement.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_31
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bReduceMotion"] : false
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bReduceMotion", isChecked); }
                    }
            }
        }
    }

    // PAGE: Game Recording Sub-Page
    Column {
        id: steamGameRecordingPage
        width: parent.width
        spacing: 20
        visible: steamSettingsDrawer.subPage === "gamerecording"

        property int currentMode: (optimizerBackend.steamFriendsSettings && typeof optimizerBackend.steamFriendsSettings["BackgroundRecordMode"] !== "undefined") ? optimizerBackend.steamFriendsSettings["BackgroundRecordMode"] : 0

        Row {
            spacing: 10
            width: parent.width

            MeguButton {
                text: qsTr("Back")
                iconRotation: 180

                iconSource: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                width: 80
                onClicked: steamSettingsDrawer.subPage = "main"
            }

            Text {
                text: qsTr("GAME RECORDING")
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
        }

        Text {
            text: qsTr("Select your recording mode:")
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: 11
        }

        Column {
            width: parent.width
            spacing: 12

            // Option 1: Recording Off
            Rectangle {
                width: parent.width
                height: 64
                radius: Theme.radiusSmall
                color: (steamGameRecordingPage.currentMode === 0) ? Theme.accentDim : (mode0Mouse.containsMouse ? "#0DFFFFFF" : "#05FFFFFF")
                border.color: (steamGameRecordingPage.currentMode === 0) ? Theme.accent : Theme.border
                border.width: 1

                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 16

                    // Custom Radio Button
                    Rectangle {
                        width: 18
                        height: 18
                        radius: 9
                        color: "transparent"
                        border.color: (steamGameRecordingPage.currentMode === 0) ? Theme.accent : Theme.textMuted
                        border.width: 2
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            width: 10
                            height: 10
                            radius: 5
                            color: Theme.accent
                            anchors.centerIn: parent
                            visible: steamGameRecordingPage.currentMode === 0
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        width: parent.width - 34

                        Text {
                            text: qsTr("Recording Off")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Steam will not record your gameplay.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                MouseArea {
                    id: mode0Mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { root.toggleSteamFriendsSetting("BackgroundRecordMode", 0); }
                }
            }

            // Option 2: Record in Background
            Rectangle {
                width: parent.width
                height: 110
                radius: Theme.radiusSmall
                color: (steamGameRecordingPage.currentMode === 1) ? Theme.accentDim : (mode1Mouse.containsMouse ? "#0DFFFFFF" : "#05FFFFFF")
                border.color: (steamGameRecordingPage.currentMode === 1) ? Theme.accent : Theme.border
                border.width: 1

                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 16

                    // Custom Radio Button
                    Rectangle {
                        width: 18
                        height: 18
                        radius: 9
                        color: "transparent"
                        border.color: (steamGameRecordingPage.currentMode === 1) ? Theme.accent : Theme.textMuted
                        border.width: 2
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            width: 10
                            height: 10
                            radius: 5
                            color: Theme.accent
                            anchors.centerIn: parent
                            visible: steamGameRecordingPage.currentMode === 1
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        width: parent.width - 34

                        Text {
                            text: qsTr("Record in Background")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Steam will automatically record your gameplay when you start playing, so you don't miss those unexpected moments.<br><br>The last <b>120</b> minutes of video will be kept in a temporary format for you to replay or save as permanent clips.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                            textFormat: Text.RichText
                        }
                    }
                }

                MouseArea {
                    id: mode1Mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { root.toggleSteamFriendsSetting("BackgroundRecordMode", 1); }
                }
            }

            // Option 3: Record Manually
            Rectangle {
                width: parent.width
                height: 64
                radius: Theme.radiusSmall
                color: (steamGameRecordingPage.currentMode === 2) ? Theme.accentDim : (mode2Mouse.containsMouse ? "#0DFFFFFF" : "#05FFFFFF")
                border.color: (steamGameRecordingPage.currentMode === 2) ? Theme.accent : Theme.border
                border.width: 1

                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 16

                    // Custom Radio Button
                    Rectangle {
                        width: 18
                        height: 18
                        radius: 9
                        color: "transparent"
                        border.color: (steamGameRecordingPage.currentMode === 2) ? Theme.accent : Theme.textMuted
                        border.width: 2
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            width: 10
                            height: 10
                            radius: 5
                            color: Theme.accent
                            anchors.centerIn: parent
                            visible: steamGameRecordingPage.currentMode === 2
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        width: parent.width - 34

                        Text {
                            text: qsTr("Record Manually")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Steam will record video only after you press <b>Ctrl+F11</b>.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                            textFormat: Text.RichText
                        }
                    }
                }

                MouseArea {
                    id: mode2Mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { root.toggleSteamFriendsSetting("BackgroundRecordMode", 2); }
                }
            }
        }
    }

    // PAGE: Voice Sub-Page
    Column {
        id: steamVoicePage
        width: parent.width
        spacing: 20
        visible: steamSettingsDrawer.subPage === "voice"

        property int currentThreshold: (optimizerBackend.steamFriendsSettings && typeof optimizerBackend.steamFriendsSettings["noiseGateLevel"] !== "undefined") ? optimizerBackend.steamFriendsSettings["noiseGateLevel"] : 2

        Row {
            spacing: 10
            width: parent.width

            MeguButton {
                text: qsTr("Back")
                iconRotation: 180

                iconSource: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                width: 80
                onClicked: steamSettingsDrawer.subPage = "main"
            }

            Text {
                text: qsTr("VOICE")
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
        }

        Column {
            width: parent.width
            spacing: 16

            // Voice Transmission Threshold Section
            Column {
                width: parent.width
                spacing: 8

                Text {
                    text: qsTr("Voice Transmission Threshold")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                }

                Row {
                    width: parent.width
                    spacing: 8

                    Repeater {
                        model: {
                            var lang = settingsBackend.language;
                            return [
                                { id: 0, label: qsTr("Off") },
                                { id: 2, label: qsTr("Medium (Recommended)") },
                                { id: 3, label: qsTr("High") }
                            ];
                        }
                        delegate: Rectangle {
                            height: 32
                            width: (parent.width - 16) / 3
                            radius: 6
                            color: (steamVoicePage.currentThreshold === modelData.id) ? Theme.accentDim : (voiceBtnMouse.containsMouse ? "#0DFFFFFF" : "#05FFFFFF")
                            border.color: (steamVoicePage.currentThreshold === modelData.id) ? Theme.accent : Theme.border
                            border.width: 1

                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                            Text {
                                text: modelData.label
                                color: (steamVoicePage.currentThreshold === modelData.id) ? Theme.accent : Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                font.bold: true
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                id: voiceBtnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.toggleSteamFriendsSetting("noiseGateLevel", modelData.id);
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
            }

            // Advanced Settings Section
            Text {
                text: qsTr("Advanced Settings")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }

            // Switch 1: Echo cancellation
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_32.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_32;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_32.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Echo cancellation")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Reduces echo from your speakers/microphone")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_32
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["echoCancellation"] : true
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("echoCancellation", isChecked); }
                    }
            }

            // Switch 2: Noise cancellation
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_33.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_33;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_33.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Noise cancellation")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Reduces background noise from your microphone")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_33
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["noiseCancellation"] : true
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("noiseCancellation", isChecked); }
                    }
            }

            // Switch 3: Automatic volume/gain control
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_34.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_34;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_34.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Automatic volume/gain control")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Automatically adjusts your microphone volume/gain level")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_34
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["autoGainControl"] : true
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("autoGainControl", isChecked); }
                    }
            }

        }
    }

    // PAGE: Remote Play Sub-Page
    Column {
        id: steamRemotePlayPage
        width: parent.width
        spacing: 20
        visible: steamSettingsDrawer.subPage === "remoteplay"

        Row {
            spacing: 10
            width: parent.width

            MeguButton {
                text: qsTr("Back")
                iconRotation: 180

                iconSource: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                width: 80
                onClicked: steamSettingsDrawer.subPage = "main"
            }

            Text {
                text: qsTr("REMOTE PLAY")
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
        }

        Column {
            width: parent.width
            spacing: 16

            // Toggle 1: Enable Remote Play
            Rectangle {
                width: parent.width
                height: 64
                color: "transparent"
                Row {
                    anchors.fill: parent
                    spacing: 12
                    MeguSwitch {

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["EnableStreaming"] : true
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("EnableStreaming", isChecked); }
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        width: parent.width - 50
                        Text {
                            text: qsTr("Enable Remote Play")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Stream gameplay between this computer and other devices. To connect, simply log into this same Steam account on another computer, or choose \"Other Computer\" on your Steam Link.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }
    }

    // PAGE: Music Sub-Page
    Column {
        id: steamMusicPage
        width: parent.width
        spacing: 20
        visible: steamSettingsDrawer.subPage === "music"

        Row {
            spacing: 10
            width: parent.width

            MeguButton {
                text: qsTr("Back")
                iconRotation: 180

                iconSource: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                width: 80
                onClicked: steamSettingsDrawer.subPage = "main"
            }

            Text {
                text: qsTr("MUSIC")
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
        }

        Column {
            width: parent.width
            spacing: 16

            // Toggle: Download high quality audio files
            Rectangle {
                width: parent.width
                height: 64
                color: "transparent"
                Row {
                    anchors.fill: parent
                    spacing: 12
                    MeguSwitch {

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["DownloadHighQualityAudio"] : false
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("DownloadHighQualityAudio", isChecked); }
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        width: parent.width - 50
                        Text {
                            text: qsTr("Download high quality audio files")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("When checked, Steam will download high-quality files if they are available for a soundtrack. Otherwise, Steam will only download standard quality MP3s.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }
    }

    // PAGE 5: Library Sub-Page
    Column {
        id: steamLibraryPage
        width: parent.width
        spacing: 20
        visible: steamSettingsDrawer.subPage === "library"

        Row {
            spacing: 10
            width: parent.width

            MeguButton {
                text: qsTr("Back")
                iconRotation: 180

                iconSource: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                width: 80
                onClicked: steamSettingsDrawer.subPage = "main"
            }

            Text {
                text: qsTr("LIBRARY")
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
        }

        Column {
            width: parent.width
            spacing: 16

            // Toggle 1: Low Bandwidth Mode
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_35.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_35;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_35.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Low Bandwidth Mode")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Reduces bandwidth use by disabling features like auto-load of community content")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_35
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["library_low_bandwidth_mode"] : false
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("library_low_bandwidth_mode", isChecked); }
                    }
            }

            // Toggle 2: Low Performance Mode
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_36.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_36;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_36.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Low Performance Mode")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Improves library performance by disabling certain graphical improvements and transitions")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_36
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["library_low_perf_mode"] : false
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("library_low_perf_mode", isChecked); }
                    }
            }

            // Toggle 3: Disable Community Content
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_37.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_37;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_37.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Disable Community Content")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Prevents the automatic load of community content when viewing game details")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_37
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["library_disable_community_content"] : false
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("library_disable_community_content", isChecked); }
                    }
            }

            // Toggle 4: Show game icons in the left column
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_38.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_38;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_38.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Show game icons in the left column")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_38
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? (optimizerBackend.steamFriendsSettings["library_display_icon_in_game_list"] !== false) : true
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("library_display_icon_in_game_list", isChecked); }
                    }
            }

            // Toggle 5: Ready to Play should include streamable games
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_39.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_39;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_39.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Ready to Play should include streamable games")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Should the library include streamable games that aren't installed locally in Ready to Play and also show streaming by default for those games?")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_39
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? (optimizerBackend.steamFriendsSettings["ready_to_play_includes_streaming"] !== false) : true
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("ready_to_play_includes_streaming", isChecked); }
                    }
            }

            // Toggle 6: Show Steam Deck compatibility information in library
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_40.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_40;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_40.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Show Steam Deck compatibility information in library")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_40
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["show_steam_deck_info"] : false
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("show_steam_deck_info", isChecked); }
                    }
            }
        }
    }

    // PAGE 6: Download Sub-Page
    Column {
        id: steamDownloadPage
        width: parent.width
        spacing: 20
        visible: steamSettingsDrawer.subPage === "download"

        Row {
            spacing: 10
            width: parent.width

            MeguButton {
                text: qsTr("Back")
                iconRotation: 180

                iconSource: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                width: 80
                onClicked: steamSettingsDrawer.subPage = "main"
            }

            Text {
                text: qsTr("Download")
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
        }

        Column {
            width: parent.width
            spacing: 16



            // Toggle 3: Allow downloads during gameplay
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_43.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_43;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_43.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Allow downloads during gameplay")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Enabling this may degrade gameplay performance or lead to higher in-game ping.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_43
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bAllowDownloadsDuringGameplay"] : false
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bAllowDownloadsDuringGameplay", isChecked); }
                    }
            }

            // Toggle 4: Throttle downloads while streaming
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_44.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_44;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_44.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Throttle downloads while streaming")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Throttles downloading bandwidth when streaming a game with Remote Play.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_44
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? (optimizerBackend.steamFriendsSettings["bThrottleDownloadsWhileStreaming"] !== false) : true
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bThrottleDownloadsWhileStreaming", isChecked); }
                    }
            }

            // Toggle 5: Display download rates in bits per second
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_45.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_45;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_45.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Display download rates in bits per second")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_45
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? (optimizerBackend.steamFriendsSettings["bDisplayDownloadRatesInBitsPerSecond"] !== false) : true
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bDisplayDownloadRatesInBitsPerSecond", isChecked); }
                    }
            }

            // Toggle 6: Game File Transfer over Local Network
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_46.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_46;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_46.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Game File Transfer over Local Network")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Allows transfers of game files from other PCs on the local network.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_46
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? (optimizerBackend.steamFriendsSettings["bLocalNetworkGameFileTransfer"] !== false) : true
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bLocalNetworkGameFileTransfer", isChecked); }
                    }
            }

            // Clear Download Cache
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_47.implicitHeight + 12)
                color: "transparent"
                Row {
                    anchors.fill: parent
                    spacing: 12

                    Column { id: steamToggleCol_47;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        width: parent.width - 120

                        Text {
                            text: qsTr("Clear Download Cache")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Clearing download cache might resolve issues with downloading or starting games.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }

                    MeguButton {
                        text: qsTr("Clear Cache")
                        anchors.verticalCenter: parent.verticalCenter
                        width: 100
                        onClicked: {
                            steamCacheClearDialog.open();
                        }
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.border
        }

        // Shader Pre-Caching Header
        Column {
            width: parent.width
            spacing: 8

            Text {
                text: qsTr("Shader Pre-Caching")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 13
                font.bold: true
            }

            Text {
                text: qsTr("Shader Pre-Caching allows Steam to download pre-compiled Vulkan and OpenGL shaders tailored to your hardware. This reduces game load times and mitigates in-game stuttering.")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        Column {
            width: parent.width
            spacing: 16

            // Toggle 7: Enable Shader Pre-caching
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_48.implicitHeight + 12)
                color: "transparent"
                    Column { id: steamToggleCol_48;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_48.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Enable Shader Pre-caching")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_48
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? (optimizerBackend.steamFriendsSettings["bEnableShaderPreCaching"] !== false) : true
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bEnableShaderPreCaching", isChecked); }
                    }
            }

            // Toggle 8: Allow background processing of Vulkan shaders
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_49.implicitHeight + 12)
                color: "transparent"
                enabled: steamToggleSwitch_48.checked
                opacity: enabled ? 1.0 : 0.5
                Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }
                    Column { id: steamToggleCol_49;
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        anchors.left: parent.left
                        anchors.right: steamToggleSwitch_49.left
                        anchors.rightMargin: 12
                        Text {
                            text: qsTr("Allow background processing of Vulkan shaders")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                    MeguSwitch {
                    id: steamToggleSwitch_49
                    anchors.right: parent.right

                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bAllowBackgroundProcessingOfVulkanShaders"] : false
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bAllowBackgroundProcessingOfVulkanShaders", isChecked); }
                    }
            }
        }
    }

    // PAGE 7: Storage Sub-Page
    Column {
        id: steamStoragePage
        width: parent.width
        spacing: 20
        visible: steamSettingsDrawer.subPage === "storage"

        // Declare ListModel FIRST so that it exists in scope when properties evaluate
        ListModel {
            id: steamGamesModel
        }

        property var driveInfo: {
            var p = optimizerBackend.steamPath;
            return optimizerBackend.getDriveInfo(p);
        }
        property real totalSize: driveInfo && driveInfo.totalSize > 0 ? driveInfo.totalSize : 722.2 // GB
        property real gamesSize: {
            var sum = 0;
            if (typeof steamGamesModel !== "undefined" && steamGamesModel !== null) {
                for (var i = 0; i < steamGamesModel.count; i++) {
                    var item = steamGamesModel.get(i);
                    if (item && typeof item.sizeBytes !== "undefined") {
                        sum += item.sizeBytes;
                    }
                }
            }
            return sum - dlcSize;
        }
        property real dlcSize: {
            var sum = 0;
            if (typeof steamGamesModel !== "undefined" && steamGamesModel !== null) {
                for (var i = 0; i < steamGamesModel.count; i++) {
                    var item = steamGamesModel.get(i);
                    if (item && item.dlcInfo) {
                        var info = item.dlcInfo.trim();
                        var parts = info.split(/\s+/);
                        if (parts.length >= 3 && parts[0].toUpperCase() === "DLC") {
                            var val = parseFloat(parts[1]);
                            var unit = parts[2].toUpperCase();
                            if (unit === "KB") {
                                val = val / (1024.0 * 1024.0);
                            } else if (unit === "MB") {
                                val = val / 1024.0;
                            } else if (unit === "GB") {
                                val = val;
                            } else {
                                val = 0.0;
                            }
                            sum += val;
                        }
                    }
                }
            }
            return sum;
        }
        property real workshopSize: {
            var sum = 0;
            if (typeof steamGamesModel !== "undefined" && steamGamesModel !== null) {
                for (var i = 0; i < steamGamesModel.count; i++) {
                    var item = steamGamesModel.get(i);
                    if (item && typeof item.workshopBytes !== "undefined") {
                        sum += item.workshopBytes;
                    }
                }
            }
            return sum > 0 ? sum : 0.0;
        }
        property real shadersSize: driveInfo && typeof driveInfo.shadercacheSize !== "undefined" ? driveInfo.shadercacheSize : 0.0
        property real freeSize: driveInfo && driveInfo.freeSize > 0 ? driveInfo.freeSize : 150.0
        property real nonSteamSize: {
            var diff = totalSize - freeSize - gamesSize - dlcSize - workshopSize - shadersSize;
            return diff > 0 ? diff : 0;
        }

        Row {
            spacing: 10
            width: parent.width

            MeguButton {
                text: qsTr("Back")
                iconRotation: 180

                iconSource: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                width: 80
                onClicked: steamSettingsDrawer.subPage = "main"
            }

            Text {
                text: qsTr("Storage")
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
        }

        // Drive selection box (simulated, no points, with path)
        Rectangle {
            width: parent.width
            height: 40
            color: "#161920"
            border.color: Theme.border
            border.width: 1
            radius: Theme.radiusSmall

            Item {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Text {
                        text: "💾"
                        color: Theme.accent
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: {
                            var name = steamStoragePage.driveInfo && steamStoragePage.driveInfo.name ? steamStoragePage.driveInfo.name : qsTr("Local Disk");
                            var letter = steamStoragePage.driveInfo && steamStoragePage.driveInfo.letter ? steamStoragePage.driveInfo.letter : "C";
                            return name + " (" + letter + ":) ★";
                        }
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Text {
                    text: (steamStoragePage.freeSize > 0 ? steamStoragePage.freeSize : 0).toFixed(1) + " GB FREE OF " + (steamStoragePage.totalSize > 0 ? steamStoragePage.totalSize : 0).toFixed(1) + " GB"
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                }
            }
        }

        // Plain Text Path
        Text {
            text: optimizerBackend.steamPath.toUpperCase()
            color: Theme.textMuted
            font.family: Theme.fontFamily
            font.pixelSize: 10
            font.bold: true
        }

        // Multi-colored storage segmented progress bar
        Rectangle {
            width: parent.width
            height: 10
            radius: 5
            color: "#2d3436"
            clip: true

            Row {
                anchors.fill: parent

                Rectangle {
                    height: parent.height
                    width: parent.parent.width * (steamStoragePage.gamesSize / steamStoragePage.totalSize)
                    color: "#1a9fff"
                }
                Rectangle {
                    height: parent.height
                    width: parent.parent.width * (steamStoragePage.dlcSize / steamStoragePage.totalSize)
                    color: "#a347ff"
                }
                Rectangle {
                    height: parent.height
                    width: parent.parent.width * (steamStoragePage.workshopSize / steamStoragePage.totalSize)
                    color: "#2ecc71"
                }
                Rectangle {
                    height: parent.height
                    width: parent.parent.width * (steamStoragePage.shadersSize / steamStoragePage.totalSize)
                    color: "#ff7675"
                }
                Rectangle {
                    height: parent.height
                    width: parent.parent.width * (steamStoragePage.nonSteamSize / steamStoragePage.totalSize)
                    color: "#f1c40f"
                }
                Rectangle {
                    height: parent.height
                    width: parent.parent.width * ((steamStoragePage.freeSize > 0 ? steamStoragePage.freeSize : 0) / steamStoragePage.totalSize)
                    color: "#4a4a4a"
                }
            }
        }

        // Legend
        Flow {
            width: parent.width
            spacing: 12

            // GAMES
            Row {
                spacing: 6
                Rectangle { width: 8; height: 8; radius: 4; color: "#1a9fff"; anchors.verticalCenter: parent.verticalCenter }
                Text {
                    text: qsTr("GAMES") + " " + steamStoragePage.gamesSize.toFixed(2) + " GB"
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                }
            }

            // DLC
            Row {
                spacing: 6
                Rectangle { width: 8; height: 8; radius: 4; color: "#a347ff"; anchors.verticalCenter: parent.verticalCenter }
                Text {
                    text: {
                        var size = steamStoragePage.dlcSize;
                        if (size >= 1.0) {
                            return qsTr("DLC") + " " + size.toFixed(2) + " GB";
                        } else if (size > 0.0) {
                            var mb = size * 1024.0;
                            if (mb >= 1.0) {
                                return qsTr("DLC") + " " + mb.toFixed(2) + " MB";
                            } else {
                                return qsTr("DLC") + " " + (mb * 1024.0).toFixed(2) + " KB";
                            }
                        } else {
                            return qsTr("DLC") + " 0 KB";
                        }
                    }
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                }
            }

            // WORKSHOP
            Row {
                spacing: 6
                Rectangle { width: 8; height: 8; radius: 4; color: "#2ecc71"; anchors.verticalCenter: parent.verticalCenter }
                Text {
                    text: {
                        var size = steamStoragePage.workshopSize;
                        if (size >= 1.0) {
                            return qsTr("WORKSHOP") + " " + size.toFixed(2) + " GB";
                        } else if (size > 0.0) {
                            return qsTr("WORKSHOP") + " " + (size * 1024.0).toFixed(2) + " MB";
                        } else {
                            return qsTr("WORKSHOP") + " 0 MB";
                        }
                    }
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                }
            }

            // SHADERS
            Row {
                spacing: 6
                Rectangle { width: 8; height: 8; radius: 4; color: "#ff7675"; anchors.verticalCenter: parent.verticalCenter }
                Text {
                    text: {
                        var size = steamStoragePage.shadersSize;
                        if (size >= 1.0) {
                            return qsTr("SHADERS") + " " + size.toFixed(2) + " GB";
                        } else if (size > 0.0) {
                            var mb = size * 1024.0;
                            if (mb >= 1.0) {
                                return qsTr("SHADERS") + " " + mb.toFixed(2) + " MB";
                            } else {
                                return qsTr("SHADERS") + " " + (mb * 1024.0).toFixed(2) + " KB";
                            }
                        } else {
                            return qsTr("SHADERS") + " 0 KB";
                        }
                    }
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                }
            }

            // NON-STEAM
            Row {
                spacing: 6
                Rectangle { width: 8; height: 8; radius: 4; color: "#f1c40f"; anchors.verticalCenter: parent.verticalCenter }
                Text {
                    text: qsTr("NON-STEAM") + " " + steamStoragePage.nonSteamSize.toFixed(2) + " GB"
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                }
            }

            // FREE
            Row {
                spacing: 6
                Rectangle { width: 8; height: 8; radius: 4; color: "#4a4a4a"; anchors.verticalCenter: parent.verticalCenter }
                Text {
                    text: qsTr("FREE") + " " + (steamStoragePage.freeSize > 0 ? steamStoragePage.freeSize : 0).toFixed(2) + " GB"
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                }
            }
        }

        // Section divider line
        Rectangle {
            width: parent.width
            height: 1
            color: Theme.border
        }

        // Game Header
        Item {
            width: parent.width
            height: 16

            Text {
                text: qsTr("Items %1").arg(steamGamesModel.count)
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: qsTr("Size on Disk ↕")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Game List
        Column {
            width: parent.width
            spacing: 10

            Repeater {
                model: steamGamesModel
                delegate: Rectangle {
                    id: gameCard
                    width: parent.width
                    height: 64
                    color: model.checked ? "#1a2233" : "#11141a"
                    border.color: model.checked ? Theme.accent : Theme.border
                    border.width: 1
                    radius: Theme.radiusSmall

                    // Game Thumbnail Banner Placeholder with modern theme gradient
                    Rectangle {
                        id: gameThumbnail
                        width: 80
                        height: 48
                        radius: 4
                        color: "#1e222b"
                        clip: true
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter

                        LinearGradient {
                            anchors.fill: parent
                            visible: !gameImg.visible
                            start: Qt.point(0, 0)
                            end: Qt.point(80, 48)
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: Theme.accent }
                                GradientStop { position: 1.0; color: "#0c0d12" }
                            }
                        }

                        Text {
                            text: model.name.substring(0, 2).toUpperCase()
                            visible: !gameImg.visible
                            color: "white"
                            font.family: Theme.fontFamily
                            font.pixelSize: 14
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        Image {
                            id: gameImg
                            anchors.fill: parent
                            source: model.imagePath ? model.imagePath : ""
                            fillMode: Image.PreserveAspectCrop
                            visible: model.imagePath !== ""
                            asynchronous: true
                        }
                    }

                    // Game metadata
                    Column {
                        id: gameMeta
                        anchors.left: gameThumbnail.right
                        anchors.leftMargin: 12
                        anchors.right: gameSizeText.left
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4

                        Text {
                            text: model.name
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: {
                                var details = [];
                                if (model.dlcInfo !== "") details.push(model.dlcInfo);
                                if (model.workshopInfo !== "") details.push(model.workshopInfo);
                                if (model.lastPlayed !== "") details.push(model.lastPlayed);
                                return details.join("  •  ");
                            }
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 9
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }

                    // Size text
                    Text {
                        id: gameSizeText
                        text: model.sizeStr
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                        anchors.right: gameCheckbox.left
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Checkbox
                    Rectangle {
                        id: gameCheckbox
                        width: 16
                        height: 16
                        radius: 3
                        color: model.checked ? Theme.accent : "transparent"
                        border.color: model.checked ? Theme.accent : Theme.border
                        border.width: 1
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: "✓"
                            color: "white"
                            font.pixelSize: 10
                            font.bold: true
                            anchors.centerIn: parent
                            visible: model.checked
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                steamGamesModel.setProperty(index, "checked", !model.checked);
                            }
                        }
                    }
                }
            }
        }

        // Dynamic Uninstall Button
        MeguButton {
            text: qsTr("Uninstall Selected")
            width: parent.width
            visible: {
                var anyChecked = false;
                for (var i = 0; i < steamGamesModel.count; i++) {
                    if (steamGamesModel.get(i).checked) {
                        anyChecked = true;
                        break;
                    }
                }
                return anyChecked;
            }
            onClicked: {
                var uninstalledNames = [];
                for (var i = steamGamesModel.count - 1; i >= 0; i--) {
                    var item = steamGamesModel.get(i);
                    if (item.checked) {
                        uninstalledNames.push(item.name);
                        Qt.openUrlExternally("steam://uninstall/" + (item.appid || item.appId));
                        steamGamesModel.remove(i);
                    }
                }
                if (uninstalledNames.length > 0) {
                    stepLogModel.append({
                        "message": qsTr("Requested Steam to uninstall: %1").arg(uninstalledNames.join(", ")),
                        "type": "SUCCESS"
                    });
                }
            }
        }

        // Close nested Column container
    }
    } // Close outer Column container

    // STEAM CACHE CLEAR WARNING DIALOG
    Rectangle {
        id: steamCacheClearDialog
        anchors.fill: parent
        color: "#CC05070B" // Semi-transparent overlay to focus on dialog
        z: 9999
        visible: false
        opacity: 0.0
        
        Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }
        
        function open() {
            visible = true;
            opacity = 1.0;
        }
        
        function close() {
            opacity = 0.0;
            closeTimer.start();
        }
        
        Timer {
            id: closeTimer
            interval: Theme.animNormal
            onTriggered: steamCacheClearDialog.visible = false;
        }

        MouseArea {
            anchors.fill: parent
            onClicked: steamCacheClearDialog.close();
        }

        AcrylicPanel {
            anchors.centerIn: parent
            width: 360
            height: 180
            radius: 12
            
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
            }

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                Row {
                    spacing: 10
                    width: parent.width
                    
                    Item {
                        width: 20
                        height: 20
                        anchors.verticalCenter: parent.verticalCenter
                        Image {
                            id: cacheWarnImg
                            source: "qrc:/MeguPackOptimizer/src/resources/warning.svg"
                            anchors.fill: parent
                            sourceSize.width: 20
                            sourceSize.height: 20
                            visible: false
                        }
                        ColorOverlay {
                            anchors.fill: cacheWarnImg
                            source: cacheWarnImg
                            color: Theme.accent
                        }
                    }
                    
                    Text {
                        text: qsTr("Clear Download Cache")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Text {
                    text: qsTr("This will clear your local download cache and restart Steam. You will need to login to Steam again. Do you wish to continue?")
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    width: parent.width
                    wrapMode: Text.WordWrap
                    lineHeight: 1.3
                }

                Row {
                    width: parent.width
                    spacing: 10
                    layoutDirection: Qt.RightToLeft

                    MeguButton {
                        text: qsTr("Confirm")
                        accented: true
                        width: 90
                        height: 30
                        onClicked: {
                            steamCacheClearDialog.close();
                            optimizerBackend.clearSteamDownloadCache();
                        }
                    }

                    MeguButton {
                        text: qsTr("Cancel")
                        accented: false
                        width: 90
                        height: 30
                        onClicked: {
                            steamCacheClearDialog.close();
                        }
                    }
                }
            }
        }
    }

    // STEAM BROWSER DATA DELETE WARNING DIALOG
    Rectangle {
        id: steamBrowserDeleteConfirmDialog
        anchors.fill: parent
        color: "#CC05070B" // Semi-transparent overlay to focus on dialog
        z: 9999
        visible: false
        opacity: 0.0
        
        Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }
        
        function open() {
            visible = true;
            opacity = 1.0;
        }
        
        function close() {
            opacity = 0.0;
            browserDeleteCloseTimer.start();
        }
        
        Timer {
            id: browserDeleteCloseTimer
            interval: Theme.animNormal
            onTriggered: steamBrowserDeleteConfirmDialog.visible = false;
        }

        MouseArea {
            anchors.fill: parent
            onClicked: steamBrowserDeleteConfirmDialog.close();
        }

        AcrylicPanel {
            anchors.centerIn: parent
            width: 360
            height: 180
            radius: 12
            
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
            }

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                Row {
                    spacing: 10
                    width: parent.width
                    
                    Item {
                        width: 20
                        height: 20
                        anchors.verticalCenter: parent.verticalCenter
                        Image {
                            id: browserWarnImg
                            source: "qrc:/MeguPackOptimizer/src/resources/warning.svg"
                            anchors.fill: parent
                            sourceSize.width: 20
                            sourceSize.height: 20
                            visible: false
                        }
                        ColorOverlay {
                            anchors.fill: browserWarnImg
                            source: browserWarnImg
                            color: Theme.accent
                        }
                    }
                    
                    Text {
                        text: qsTr("Delete Web Browser Data")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Text {
                    text: qsTr("This will close Steam and delete all Steam web browser cached files, cookies, and history. Do you wish to continue?")
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    width: parent.width
                    wrapMode: Text.WordWrap
                    lineHeight: 1.3
                }

                Row {
                    width: parent.width
                    spacing: 10
                    layoutDirection: Qt.RightToLeft

                    MeguButton {
                        text: qsTr("Confirm")
                        accented: true
                        width: 90
                        height: 30
                        onClicked: {
                            steamBrowserDeleteConfirmDialog.close();
                            optimizerBackend.deleteSteamBrowserData();
                        }
                    }

                    MeguButton {
                        text: qsTr("Cancel")
                        accented: false
                        width: 90
                        height: 30
                        onClicked: {
                            steamBrowserDeleteConfirmDialog.close();
                        }
                    }
                }
            }
        }
    }
}

