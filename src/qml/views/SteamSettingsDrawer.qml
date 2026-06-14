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

    onSteamIsRunningChanged: {
        if (!steamIsRunning) {
            subPage = "main";
        }
    }

    onSteamActiveUserIdChanged: {
        if (steamActiveUserId === "") {
            subPage = "main";
        }
    }

    Component.onCompleted: {
        optimizerBackend.scanSteamInstalledGames();
        populateGamesModel();
        steamGameRecordingPage.loadAudioAppsCheckedState();
    }

    Connections {
        target: optimizerBackend
        function onSteamInstalledGamesChanged() {
            populateGamesModel();
        }
        function onSteamLibraryPathsChanged() {
            populateGamesModel();
        }
        function onSteamCacheLog(message, type) {
            if (typeof stepLogModel !== "undefined" && stepLogModel !== null) {
                stepLogModel.append({ "message": message, "type": type });
            }
        }
        function onSteamFriendsSettingsChanged() {
            steamGameRecordingPage.loadAudioAppsCheckedState();
        }
    }

    function populateGamesModel() {
        steamGamesModel.clear();
        var games = optimizerBackend.steamInstalledGames;
        var currentLib = (optimizerBackend.steamLibraryPaths && steamStoragePage.selectedLibraryIndex < optimizerBackend.steamLibraryPaths.length) ? optimizerBackend.steamLibraryPaths[steamStoragePage.selectedLibraryIndex] : null;
        var currentLibPath = currentLib && currentLib.path ? currentLib.path.toLowerCase().replace(/\\/g, "/") : "";
        
        for (var i = 0; i < games.length; i++) {
            var game = games[i];
            var gameLibPath = game.libraryPath ? game.libraryPath.toLowerCase().replace(/\\/g, "/") : "";
            if (currentLibPath === "" || gameLibPath === currentLibPath) {
                steamGamesModel.append(game);
            }
        }
    }

    function applyClientPreset(presetName) {
        var current = optimizerBackend.steamFriendsSettings;
        if (!current) return;
        
        var optMap = {};
        var keys = Object.keys(current);
        for (var i = 0; i < keys.length; i++) {
            optMap[keys[i]] = current[keys[i]];
        }
        
        if (presetName === "default") {
            optMap["RemotePlay_VideoQuality"] = 2;
            optMap["RemotePlay_ResolutionWidth"] = 0;
            optMap["RemotePlay_ResolutionHeight"] = 0;
            optMap["RemotePlay_BandwidthLimit"] = -1;
            optMap["RemotePlay_Microphone"] = 0;
            optMap["RemotePlay_WindowedMode"] = false;
            optMap["RemotePlay_HardwareDecoding"] = true;
            optMap["RemotePlay_LowLatencyNetworking"] = false;
            optMap["RemotePlay_HEVC"] = true;
            optMap["RemotePlay_AV1"] = true;
            optMap["RemotePlay_PerformanceOverlay"] = 0;
        } else if (presetName === "1080p") {
            optMap["RemotePlay_VideoQuality"] = 3;
            optMap["RemotePlay_ResolutionWidth"] = 1920;
            optMap["RemotePlay_ResolutionHeight"] = 1080;
            optMap["RemotePlay_BandwidthLimit"] = 30000;
            optMap["RemotePlay_Microphone"] = 1;
            optMap["RemotePlay_WindowedMode"] = true;
            optMap["RemotePlay_HardwareDecoding"] = true;
            optMap["RemotePlay_LowLatencyNetworking"] = true;
            optMap["RemotePlay_HEVC"] = true;
            optMap["RemotePlay_AV1"] = false;
            optMap["RemotePlay_PerformanceOverlay"] = 2;
        } else if (presetName === "4k") {
            optMap["RemotePlay_VideoQuality"] = 3;
            optMap["RemotePlay_ResolutionWidth"] = 3840;
            optMap["RemotePlay_ResolutionHeight"] = 2160;
            optMap["RemotePlay_BandwidthLimit"] = 50000;
            optMap["RemotePlay_Microphone"] = 1;
            optMap["RemotePlay_WindowedMode"] = true;
            optMap["RemotePlay_HardwareDecoding"] = true;
            optMap["RemotePlay_LowLatencyNetworking"] = true;
            optMap["RemotePlay_HEVC"] = true;
            optMap["RemotePlay_AV1"] = false;
            optMap["RemotePlay_PerformanceOverlay"] = 2;
        }
        
        optimizerBackend.steamFriendsSettings = optMap;
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
        if (subPage === "broadcast") return steamBroadcastPage.implicitHeight;
        if (subPage === "controller") return steamControllerPage.implicitHeight;
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

        // Broadcasting Menu Option
        Rectangle {
            width: parent.width
            height: 48
            radius: Theme.radiusSmall
            color: broadcastMouse.containsMouse ? Theme.accentDim : "transparent"
            border.color: broadcastMouse.containsMouse ? Theme.accent : Theme.border
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
                        text: qsTr("Broadcast customization")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Configure game broadcasting and stream preferences")
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
                id: broadcastMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: steamSettingsDrawer.subPage = "broadcast"
            }
        }

        // Controller Customization Menu Option
        Rectangle {
            width: parent.width
            height: 48
            radius: Theme.radiusSmall
            color: controllerMouse.containsMouse ? Theme.accentDim : "transparent"
            border.color: controllerMouse.containsMouse ? Theme.accent : Theme.border
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
                        text: qsTr("Controller customization")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Configure steam controller settings and overlays")
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
                id: controllerMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: steamSettingsDrawer.subPage = "controller"
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

            Text {
                text: qsTr("Optimization")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.0
            }

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

            // Toggle 2: High Contrast Mode
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_hc.implicitHeight + 12)
                color: "transparent"

                Column {
                    id: steamToggleCol_hc
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    anchors.left: parent.left
                    anchors.right: steamToggleSwitch_hc.left
                    anchors.rightMargin: 12

                    Text {
                        text: qsTr("High Contrast Mode")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Make Steam text, buttons and icons more distinct from the background.")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                }

                MeguSwitch {
                    id: steamToggleSwitch_hc
                    anchors.right: parent.right
                    steamStyle: true
                    checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bHighContrastMode"] : false
                    anchors.verticalCenter: parent.verticalCenter
                    onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bHighContrastMode", isChecked); }
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
            }

            Text {
                text: qsTr("Customization")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.0
            }

            // Slider: UI Scale
            Column {
                width: parent.width
                spacing: 8

                Text {
                    text: qsTr("UI Scale")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                }

                Slider {
                    id: uiScaleSlider
                    width: parent.width
                    height: 32
                    from: 0.5
                    to: 2.5
                    stepSize: 0.05
                    value: optimizerBackend.steamFriendsSettings ? (optimizerBackend.steamFriendsSettings["desktop_ui_scale"] !== undefined ? optimizerBackend.steamFriendsSettings["desktop_ui_scale"] : 1.0) : 1.0
                    live: true
                    onMoved: {
                        root.toggleSteamFriendsSetting("desktop_ui_scale", value);
                    }

                    // Static default scale arrow pointing down at 1.0 (25% progress)
                    Canvas {
                        id: defaultScaleArrow
                        width: 8
                        height: 5
                        // x positions at visual position of 1.0 (fraction 0.25)
                        x: uiScaleSlider.leftPadding + 0.25 * (uiScaleSlider.availableWidth - 16) + 4
                        y: uiScaleSlider.topPadding + uiScaleSlider.availableHeight / 2 - 14
                        
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            ctx.fillStyle = "#6d7780"; // Steam gray color
                            ctx.beginPath();
                            ctx.moveTo(0, 0);
                            ctx.lineTo(8, 0);
                            ctx.lineTo(4, 5);
                            ctx.closePath();
                            ctx.fill();
                        }
                        
                        onWidthChanged: requestPaint()
                        onHeightChanged: requestPaint()
                    }

                    background: Rectangle {
                        x: uiScaleSlider.leftPadding
                        y: uiScaleSlider.topPadding + uiScaleSlider.availableHeight / 2 - height / 2
                        implicitWidth: 200
                        implicitHeight: 4
                        width: uiScaleSlider.availableWidth
                        height: implicitHeight
                        radius: 2
                        color: "#3d4450"

                        Rectangle {
                            width: uiScaleSlider.visualPosition * parent.width
                            height: parent.height
                            color: "#1a9fff"
                            radius: 2
                        }
                    }

                    handle: Rectangle {
                        x: uiScaleSlider.leftPadding + uiScaleSlider.visualPosition * (uiScaleSlider.availableWidth - width)
                        y: uiScaleSlider.topPadding + uiScaleSlider.availableHeight / 2 - height / 2
                        implicitWidth: 16
                        implicitHeight: 16
                        radius: 8
                        color: "#ffffff"
                    }
                }

                Item {
                    width: parent.width
                    height: 15
                    Text {
                        text: qsTr("SMALLER TEXT")
                        color: "#6d7780"
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                        font.bold: true
                        anchors.left: parent.left
                    }
                    Text {
                        text: qsTr("LARGER TEXT")
                        color: "#6d7780"
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                        font.bold: true
                        anchors.right: parent.right
                    }
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
        property string recordingKeyName: ""

        function parseSteamKey(vdfKey) {
            if (!vdfKey) return "";
            var parts = vdfKey.split('\t');
            var resultParts = [];
            for (var i = 0; i < parts.length; i++) {
                var p = parts[i].trim();
                if (p === "") continue;
                if (p.startsWith("KEY_")) {
                    resultParts.push(p.substring(4));
                } else {
                    resultParts.push(p);
                }
            }
            return resultParts.join('+');
        }

        function keyEventToSteamString(event) {
            var modifiersStr = "";
            if (event.modifiers & Qt.ControlModifier) {
                modifiersStr += "Ctrl\t";
            }
            if (event.modifiers & Qt.ShiftModifier) {
                modifiersStr += "Shift\t";
            }
            if (event.modifiers & Qt.AltModifier) {
                modifiersStr += "Alt\t";
            }
            
            var keyStr = "";
            var key = event.key;
            
            if (key >= Qt.Key_F1 && key <= Qt.Key_F24) {
                keyStr = "KEY_F" + (key - Qt.Key_F1 + 1);
            }
            else if (key >= Qt.Key_0 && key <= Qt.Key_9) {
                keyStr = "KEY_" + (key - Qt.Key_0);
            }
            else if (key >= Qt.Key_A && key <= Qt.Key_Z) {
                keyStr = "KEY_" + String.fromCharCode(key);
            }
            else {
                switch(key) {
                    case Qt.Key_Escape: keyStr = "KEY_ESCAPE"; break;
                    case Qt.Key_Tab: keyStr = "KEY_TAB"; break;
                    case Qt.Key_Space: keyStr = "KEY_SPACE"; break;
                    case Qt.Key_Backspace: keyStr = "KEY_BACKSPACE"; break;
                    case Qt.Key_Delete: keyStr = "KEY_DELETE"; break;
                    case Qt.Key_Insert: keyStr = "KEY_INSERT"; break;
                    case Qt.Key_Home: keyStr = "KEY_HOME"; break;
                    case Qt.Key_End: keyStr = "KEY_END"; break;
                    case Qt.Key_PageUp: keyStr = "KEY_PAGEUP"; break;
                    case Qt.Key_PageDown: keyStr = "KEY_PAGEDOWN"; break;
                    case Qt.Key_Left: keyStr = "KEY_LEFT"; break;
                    case Qt.Key_Right: keyStr = "KEY_RIGHT"; break;
                    case Qt.Key_Up: keyStr = "KEY_UP"; break;
                    case Qt.Key_Down: keyStr = "KEY_DOWN"; break;
                    case Qt.Key_Minus: keyStr = "KEY_MINUS"; break;
                    case Qt.Key_Equal: keyStr = "KEY_EQUAL"; break;
                    case Qt.Key_BracketLeft: keyStr = "KEY_LBRACKET"; break;
                    case Qt.Key_BracketRight: keyStr = "KEY_RBRACKET"; break;
                    case Qt.Key_Semicolon: keyStr = "KEY_SEMICOLON"; break;
                    case Qt.Key_Apostrophe: keyStr = "KEY_APOSTROPHE"; break;
                    case Qt.Key_Backslash: keyStr = "KEY_BACKSLASH"; break;
                    case Qt.Key_Comma: keyStr = "KEY_COMMA"; break;
                    case Qt.Key_Period: keyStr = "KEY_PERIOD"; break;
                    case Qt.Key_Slash: keyStr = "KEY_SLASH"; break;
                    case Qt.Key_QuoteLeft: keyStr = "KEY_BACKQUOTE"; break;
                    default:
                        if (event.text && event.text.length === 1) {
                            var ch = event.text.toUpperCase();
                            if (ch >= 'A' && ch <= 'Z') {
                                keyStr = "KEY_" + ch;
                            }
                        }
                        break;
                }
            }
            
            if (keyStr === "") return "";
            return modifiersStr + keyStr;
        }

        ListModel {
            id: audioAppsModel
        }
        function loadAudioAppsCheckedState() {
            audioAppsModel.clear();
            var settings = optimizerBackend.steamFriendsSettings;
            var rawApps = settings ? (settings["GR_AudioCaptureApps"] || []) : [];
            var checkedExes = [];
            if (rawApps && typeof rawApps.length === "number" && typeof rawApps !== "string") {
                for (var i = 0; i < rawApps.length; i++) {
                    checkedExes.push(rawApps[i]);
                }
            } else if (typeof rawApps === "string" && rawApps.trim() !== "") {
                checkedExes = rawApps.split(",");
            }
            
            // filter out empty/invalid elements
            checkedExes = checkedExes.filter(function(el) {
                if (typeof el === "object" && el !== null) {
                    return (el.exe && el.exe.trim() !== "") || (el.label && el.label.trim() !== "");
                }
                return typeof el === "string" && el.trim() !== "";
            });
            
            var cleanStr = function(s) {
                return s ? s.toLowerCase().replace(/[\s\-_]/g, "") : "";
            };
            
            var addedExesMap = {};
            var runningApps = optimizerBackend.getRunningAudioProcesses();
            for (var i = 0; i < runningApps.length; i++) {
                var app = runningApps[i];
                var exeLower = app.exe.toLowerCase();
                
                // Is checked if it matches any checked item by exe name or label
                var isChecked = false;
                var savedSessionId = "";
                var savedFromVdf = false;
                for (var j = 0; j < checkedExes.length; j++) {
                    var item = checkedExes[j];
                    var itemExe = (typeof item === "object" && item !== null) ? item.exe : item;
                    var itemLabel = (typeof item === "object" && item !== null) ? item.label : "";
                    
                    if (itemExe && itemExe.toLowerCase() === exeLower) {
                        isChecked = true;
                        if (typeof item === "object" && item !== null) {
                            if (item.name) savedSessionId = item.name;
                            if (item.fromVdf) savedFromVdf = true;
                        }
                        break;
                    }
                    if ((!itemExe || itemExe === "") && itemLabel && app.name && cleanStr(itemLabel) === cleanStr(app.name)) {
                        isChecked = true;
                        if (typeof item === "object" && item !== null) {
                            if (item.name) savedSessionId = item.name;
                            if (item.fromVdf) savedFromVdf = true;
                        }
                        break;
                    }
                }
                
                var finalSessionId = app.sessionIdentifier || savedSessionId || "";

                audioAppsModel.append({
                    name: app.name,
                    exe: app.exe,
                    sessionIdentifier: finalSessionId,
                    appChecked: isChecked,
                    icon: app.icon,
                    running: app.running,
                    fromVdf: savedFromVdf
                });
                addedExesMap[exeLower] = true;
                if (app.name) {
                    addedExesMap[cleanStr(app.name)] = true;
                }
            }

            // Append any previously saved/checked exes that are not currently running
            for (var j = 0; j < checkedExes.length; j++) {
                var item = checkedExes[j];
                var checkedExe = (typeof item === "object" && item !== null) ? item.exe : item;
                var checkedLabel = (typeof item === "object" && item !== null) ? item.label : "";
                
                var key = cleanStr(checkedExe ? checkedExe : checkedLabel);
                if (!key) continue;
                
                var alreadyAdded = addedExesMap[key] || (checkedExe && addedExesMap[cleanStr(checkedExe)]);
                if (!alreadyAdded) {
                    var friendlyName = checkedLabel || checkedExe;
                    var sessionIdentifier = (typeof item === "object" && item !== null && item.name) ? item.name : "";
                    
                    var icon = "qrc:/MeguPackOptimizer/src/resources/generic_audio.svg";
                    var checkedExeLower = checkedExe ? checkedExe.toLowerCase() : "";
                    if (checkedExeLower && checkedExeLower.indexOf("discord") !== -1) { friendlyName = "Discord"; icon = "qrc:/MeguPackOptimizer/src/resources/discord.svg"; }
                    else if (checkedExeLower && checkedExeLower.indexOf("chrome") !== -1) { friendlyName = "Google Chrome"; icon = "qrc:/MeguPackOptimizer/src/resources/chrome.svg"; }
                    else if (checkedExeLower && checkedExeLower.indexOf("firefox") !== -1) { friendlyName = "Mozilla Firefox"; icon = "qrc:/MeguPackOptimizer/src/resources/firefox.svg"; }
                    else if (checkedExeLower && checkedExeLower.indexOf("msedge") !== -1) { friendlyName = "Microsoft Edge"; icon = "qrc:/MeguPackOptimizer/src/resources/msedge.svg"; }
                    else if (checkedExeLower && checkedExeLower.indexOf("obs") !== -1) { friendlyName = "OBS Studio"; icon = "qrc:/MeguPackOptimizer/src/resources/obs.svg"; }
                    else if (checkedExeLower && checkedExeLower.indexOf("telegram") !== -1) { friendlyName = "Telegram Desktop"; icon = "qrc:/MeguPackOptimizer/src/resources/telegram.svg"; }
                    else if (checkedExeLower && checkedExeLower.indexOf("spotify") !== -1) { friendlyName = "Spotify"; icon = "qrc:/MeguPackOptimizer/src/resources/spotify.svg"; }
                    else if (checkedExeLower && checkedExeLower.indexOf("vlc") !== -1) { friendlyName = "VLC Media Player"; icon = "qrc:/MeguPackOptimizer/src/resources/vlc.svg"; }
                    else if (typeof item === "object" && item !== null && item.label) {
                        friendlyName = item.label;
                    } else if (friendlyName) {
                        friendlyName = friendlyName.replace(".exe", "");
                        if (friendlyName.length > 0) {
                            friendlyName = friendlyName.charAt(0).toUpperCase() + friendlyName.slice(1);
                        }
                    }

                    audioAppsModel.append({
                        name: friendlyName,
                        exe: checkedExe || "",
                        sessionIdentifier: sessionIdentifier,
                        appChecked: true,
                        icon: icon,
                        running: false,
                        fromVdf: (typeof item === "object" && item !== null && item.fromVdf) ? true : false
                    });
                    addedExesMap[key] = true;
                    if (checkedExe) {
                        addedExesMap[cleanStr(checkedExe)] = true;
                    }
                }
            }
        }
        function getEstimatedDiskSpace(minutes, quality) {
            var min = parseInt(minutes);
            var qual = parseInt(quality);
            if (qual === 0) { // Low
                var lowVal = (min * 0.033).toFixed(1);
                var highVal = (min * 0.1).toFixed(1);
                return lowVal + " - " + highVal + " GB";
            } else if (qual === 1) { // Medium
                var lowVal = (min * 0.06).toFixed(1);
                var highVal = (min * 0.18).toFixed(1);
                return lowVal + " - " + highVal + " GB";
            } else if (qual === 3) { // Ultra
                var lowVal = (min * 0.15).toFixed(1);
                var highVal = (min * 0.45).toFixed(1);
                return lowVal + " - " + highVal + " GB";
            } else { // High (Default) - qual === 2
                var lowVal = (min * 0.09).toFixed(1);
                var highVal = (min * 0.285).toFixed(1);
                return lowVal + " - " + highVal + " GB";
            }
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

            Text {
                text: qsTr("Optimization")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.0
            }

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

            Item {
                width: 1
                height: 8
            }

            Text {
                text: qsTr("Customization")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.0
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

        // Expanded Game Recording Settings (Visible if not Off)
        Column {
            width: parent.width
            spacing: 16
            visible: steamGameRecordingPage.currentMode !== 0

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
            }

            // SECTION: Shortcut Keys
            Text {
                text: qsTr("Shortcut Keys")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.0
            }

            Rectangle {
                width: parent.width
                height: 32
                color: "transparent"
                Text {
                    text: (steamGameRecordingPage.currentMode === 1) ? qsTr("Start/stop saving a clip") : qsTr("Start/stop recording")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    id: toggleKeyBtn
                    width: 100
                    height: 26
                    radius: 4
                    color: (steamGameRecordingPage.recordingKeyName === "GR_ToggleKey") ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : "#161616"
                    border.color: (steamGameRecordingPage.recordingKeyName === "GR_ToggleKey") ? Theme.accent : (toggleKeyMouse.containsMouse ? Theme.accent : Theme.border)
                    border.width: 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        text: (steamGameRecordingPage.recordingKeyName === "GR_ToggleKey") ? qsTr("Press key...") : steamGameRecordingPage.parseSteamKey((optimizerBackend.steamFriendsSettings && optimizerBackend.steamFriendsSettings["GR_ToggleKey"]) ? optimizerBackend.steamFriendsSettings["GR_ToggleKey"] : "Ctrl\tKEY_F11")
                        color: (steamGameRecordingPage.recordingKeyName === "GR_ToggleKey") ? Theme.accent : Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                        anchors.centerIn: parent
                    }
                    MouseArea {
                        id: toggleKeyMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            steamGameRecordingPage.recordingKeyName = "GR_ToggleKey";
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 32
                color: "transparent"
                Text {
                    text: qsTr("Add a timeline marker")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    id: markerKeyBtn
                    width: 100
                    height: 26
                    radius: 4
                    color: (steamGameRecordingPage.recordingKeyName === "GR_MarkerKey") ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : "#161616"
                    border.color: (steamGameRecordingPage.recordingKeyName === "GR_MarkerKey") ? Theme.accent : (markerKeyMouse.containsMouse ? Theme.accent : Theme.border)
                    border.width: 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        text: (steamGameRecordingPage.recordingKeyName === "GR_MarkerKey") ? qsTr("Press key...") : steamGameRecordingPage.parseSteamKey((optimizerBackend.steamFriendsSettings && optimizerBackend.steamFriendsSettings["GR_MarkerKey"]) ? optimizerBackend.steamFriendsSettings["GR_MarkerKey"] : "Ctrl\tKEY_F12")
                        color: (steamGameRecordingPage.recordingKeyName === "GR_MarkerKey") ? Theme.accent : Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                        anchors.centerIn: parent
                    }
                    MouseArea {
                        id: markerKeyMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            steamGameRecordingPage.recordingKeyName = "GR_MarkerKey";
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 32
                color: "transparent"
                Text {
                    text: qsTr("Take a screenshot")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    id: screenshotKeyBtn
                    width: 100
                    height: 26
                    radius: 4
                    color: (steamGameRecordingPage.recordingKeyName === "ScreenshotKey") ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : "#161616"
                    border.color: (steamGameRecordingPage.recordingKeyName === "ScreenshotKey") ? Theme.accent : (screenshotKeyMouse.containsMouse ? Theme.accent : Theme.border)
                    border.width: 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        text: (steamGameRecordingPage.recordingKeyName === "ScreenshotKey") ? qsTr("Press key...") : steamGameRecordingPage.parseSteamKey((optimizerBackend.steamFriendsSettings && optimizerBackend.steamFriendsSettings["ScreenshotKey"]) ? optimizerBackend.steamFriendsSettings["ScreenshotKey"] : "KEY_F12")
                        color: (steamGameRecordingPage.recordingKeyName === "ScreenshotKey") ? Theme.accent : Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                        anchors.centerIn: parent
                    }
                    MouseArea {
                        id: screenshotKeyMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            steamGameRecordingPage.recordingKeyName = "ScreenshotKey";
                        }
                    }
                }
            }

            // Save the last N seconds (Only visible in Background mode 1)
            Rectangle {
                width: parent.width
                height: 36
                color: "transparent"
                visible: steamGameRecordingPage.currentMode === 1
                
                Row {
                    spacing: 8
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        text: qsTr("Save the last")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Rectangle {
                        width: 50
                        height: 26
                        color: "#10FFFFFF"
                        border.color: Theme.border
                        border.width: 1
                        radius: 4
                        anchors.verticalCenter: parent.verticalCenter
                            TextInput {
                                id: clipSecsInput
                                anchors.fill: parent
                                horizontalAlignment: TextInput.AlignHCenter
                                verticalAlignment: TextInput.AlignVCenter
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                                selectByMouse: true
                                inputMethodHints: Qt.ImhDigitsOnly
                                text: (optimizerBackend.steamFriendsSettings && typeof optimizerBackend.steamFriendsSettings["GR_InstantClipSeconds"] !== "undefined") ? optimizerBackend.steamFriendsSettings["GR_InstantClipSeconds"].toString() : "30"
                                validator: IntValidator { bottom: 5; top: 300; }
                                onTextEdited: {
                                    var val = parseInt(text);
                                    if (!isNaN(val)) {
                                        root.toggleSteamFriendsSetting("GR_InstantClipSeconds", val);
                                    }
                                }
                                onEditingFinished: {
                                    var val = parseInt(text);
                                    if (isNaN(val) || val < 5) {
                                        val = 5;
                                    } else if (val > 300) {
                                        val = 300;
                                    }
                                    text = val.toString();
                                    root.toggleSteamFriendsSetting("GR_InstantClipSeconds", val);
                                }
                            }
                    }
                    Text {
                        text: qsTr("seconds...")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                Rectangle {
                    id: clipKeyBtn
                    width: 100
                    height: 26
                    radius: 4
                    color: (steamGameRecordingPage.recordingKeyName === "GR_ClipKey") ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : "#161616"
                    border.color: (steamGameRecordingPage.recordingKeyName === "GR_ClipKey") ? Theme.accent : (clipKeyMouse.containsMouse ? Theme.accent : Theme.border)
                    border.width: 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        text: (steamGameRecordingPage.recordingKeyName === "GR_ClipKey") ? qsTr("Press key...") : steamGameRecordingPage.parseSteamKey((optimizerBackend.steamFriendsSettings && optimizerBackend.steamFriendsSettings["GR_ClipKey"]) ? optimizerBackend.steamFriendsSettings["GR_ClipKey"] : "Ctrl\tShift\tKEY_F11")
                        color: (steamGameRecordingPage.recordingKeyName === "GR_ClipKey") ? Theme.accent : Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        font.bold: true
                        anchors.centerIn: parent
                    }
                    MouseArea {
                        id: clipKeyMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            steamGameRecordingPage.recordingKeyName = "GR_ClipKey";
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
            }

            // SECTION: Game-specific Settings
            Text {
                text: qsTr("Game-specific Settings")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.0
            }

            Text {
                text: "⚙ " + qsTr("All Games")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }

            Row {
                width: parent.width
                spacing: 16

                Column {
                    width: (parent.width - 16) / 2
                    spacing: 4
                    visible: steamGameRecordingPage.currentMode === 1
                    Text {
                        text: qsTr("Length")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                    }
                    Rectangle {
                        id: lengthDropdown
                        width: parent.width
                        height: 32
                        radius: 6
                        color: "#05FFFFFF"
                        border.color: Theme.border
                        border.width: 1

                        property int currentVal: (optimizerBackend.steamFriendsSettings && typeof optimizerBackend.steamFriendsSettings["GR_MaxKeepMinutes"] !== "undefined") ? optimizerBackend.steamFriendsSettings["GR_MaxKeepMinutes"] : 120

                        readonly property var options: [
                            { id: 15, label: qsTr("15 Minutes") },
                            { id: 30, label: qsTr("30 Minutes") },
                            { id: 60, label: qsTr("60 Minutes") },
                            { id: 120, label: qsTr("120 Minutes") }
                        ]

                        function getLabelForVal(v) {
                            for (var i = 0; i < options.length; i++) {
                                if (options[i].id === v) return options[i].label;
                            }
                            if (v === -1) return qsTr("Unlimited");
                            return qsTr("%1 Minutes").arg(v);
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: lengthDropdown.getLabelForVal(lengthDropdown.currentVal)
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
                            onClicked: lengthMenu.open()
                            onEntered: lengthDropdown.border.color = Theme.accent
                            onExited: lengthDropdown.border.color = Theme.border
                        }

                        Menu {
                            id: lengthMenu
                            y: lengthDropdown.height + 4
                            width: lengthDropdown.width
                            background: Rectangle {
                                color: Theme.sidebarBg
                                border.color: Theme.border
                                border.width: 1
                                radius: 6
                            }
                            Instantiator {
                                model: lengthDropdown.options
                                onObjectAdded: (index, object) => lengthMenu.insertItem(index, object)
                                onObjectRemoved: (index, object) => lengthMenu.removeItem(object)
                                delegate: MenuItem {
                                    text: modelData.label
                                    width: lengthMenu.width
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
                                        root.toggleSteamFriendsSetting("GR_MaxKeepMinutes", modelData.id);
                                    }
                                }
                            }
                        }
                    }
                }

                Column {
                    width: (steamGameRecordingPage.currentMode === 1) ? (parent.width - 16) / 2 : parent.width
                    spacing: 4
                    Text {
                        text: qsTr("Quality")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                    }
                    Rectangle {
                        id: qualityDropdown
                        width: parent.width
                        height: 32
                        radius: 6
                        color: "#05FFFFFF"
                        border.color: Theme.border
                        border.width: 1

                        property int currentVal: (optimizerBackend.steamFriendsSettings && typeof optimizerBackend.steamFriendsSettings["GR_VideoQuality"] !== "undefined") ? optimizerBackend.steamFriendsSettings["GR_VideoQuality"] : 2

                        readonly property var options: [
                            { id: 0, label: qsTr("Low") },
                            { id: 1, label: qsTr("Medium") },
                            { id: 2, label: qsTr("High (Default)") },
                            { id: 3, label: qsTr("Ultra") }
                        ]

                        function getLabelForVal(v) {
                            for (var i = 0; i < options.length; i++) {
                                if (options[i].id === v) return options[i].label;
                            }
                            return qsTr("High (Default)");
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: qualityDropdown.getLabelForVal(qualityDropdown.currentVal)
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
                            onClicked: qualityMenu.open()
                            onEntered: qualityDropdown.border.color = Theme.accent
                            onExited: qualityDropdown.border.color = Theme.border
                        }

                        Menu {
                            id: qualityMenu
                            y: qualityDropdown.height + 4
                            width: qualityDropdown.width
                            background: Rectangle {
                                color: Theme.sidebarBg
                                border.color: Theme.border
                                border.width: 1
                                radius: 6
                            }
                            Instantiator {
                                model: qualityDropdown.options
                                onObjectAdded: (index, object) => qualityMenu.insertItem(index, object)
                                onObjectRemoved: (index, object) => qualityMenu.removeItem(object)
                                delegate: MenuItem {
                                    text: modelData.label
                                    width: qualityMenu.width
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
                                        root.toggleSteamFriendsSetting("GR_VideoQuality", modelData.id);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Row {
                spacing: 6
                visible: steamGameRecordingPage.currentMode === 1
                Text {
                    text: qsTr("Estimated Disk Space:")
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                }
                Text {
                    text: steamGameRecordingPage.getEstimatedDiskSpace(lengthDropdown.currentVal, qualityDropdown.currentVal)
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
            }

            // SECTION: Recordings Folder
            Text {
                text: qsTr("Recordings Folder")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.0
            }

            Rectangle {
                width: parent.width
                height: 36
                color: "transparent"

                Text {
                    id: pathText
                    anchors.left: parent.left
                    anchors.right: folderButtons.left
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        var folder = (optimizerBackend.steamFriendsSettings && optimizerBackend.steamFriendsSettings["GR_RecordingFolder"]) ? optimizerBackend.steamFriendsSettings["GR_RecordingFolder"] : "";
                        if (folder === "") {
                            return optimizerBackend.getDefaultGameRecordingFolder();
                        }
                        return folder;
                    }
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    elide: Text.ElideMiddle
                }

                Row {
                    id: folderButtons
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    MeguButton {
                        id: changeFolderBtn
                        text: qsTr("Change folder")
                        width: 110
                        height: 28
                        onClicked: {
                            var newFolder = optimizerBackend.selectFolder(qsTr("Select Recordings Folder"));
                            if (newFolder !== "") {
                                root.toggleSteamFriendsSetting("GR_RecordingFolder", newFolder);
                            }
                        }
                    }

                    MeguButton {
                        text: "×"
                        width: 28
                        height: 28
                        visible: (optimizerBackend.steamFriendsSettings && optimizerBackend.steamFriendsSettings["GR_RecordingFolder"]) ? true : false
                        onClicked: {
                            root.toggleSteamFriendsSetting("GR_RecordingFolder", "");
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
            }

            // SECTION: Video Recording
            Text {
                text: qsTr("Video Recording")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.0
            }

            // GPU hardware encoding
            Rectangle {
                width: parent.width
                height: Math.max(40, vToggleCol_1.implicitHeight + 8)
                color: "transparent"
                Column {
                    id: vToggleCol_1
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    anchors.left: parent.left
                    anchors.right: vSwitch_1.left
                    anchors.rightMargin: 12
                    Text {
                        text: qsTr("Enable GPU hardware encoding")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
                MeguSwitch {
                    id: vSwitch_1
                    anchors.right: parent.right
                    steamStyle: true
                    checked: (optimizerBackend.steamFriendsSettings && typeof optimizerBackend.steamFriendsSettings["GR_EnableHardwareEncoding"] !== "undefined") ? !!optimizerBackend.steamFriendsSettings["GR_EnableHardwareEncoding"] : true
                    anchors.verticalCenter: parent.verticalCenter
                    onToggled: (isChecked) => {
                        root.toggleSteamFriendsSetting("GR_EnableHardwareEncoding", isChecked);
                        if (!isChecked) {
                            root.toggleSteamFriendsSetting("GR_EnableHEVC", false);
                        }
                    }
                }
            }
 
            // Enable HEVC (H.265)
            Rectangle {
                width: parent.width
                height: Math.max(50, vToggleCol_2.implicitHeight + 8)
                color: "transparent"
                enabled: vSwitch_1.checked
                opacity: enabled ? 1.0 : 0.5
                Column {
                    id: vToggleCol_2
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    anchors.left: parent.left
                    anchors.right: vSwitch_2.left
                    anchors.rightMargin: 12
                    Text {
                        text: qsTr("Enable HEVC (H.265) video codec")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Requires Steam Client GPU Acceleration")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                }
                MeguSwitch {
                    id: vSwitch_2
                    anchors.right: parent.right
                    steamStyle: true
                    checked: vSwitch_1.checked && (optimizerBackend.steamFriendsSettings && typeof optimizerBackend.steamFriendsSettings["GR_EnableHEVC"] !== "undefined") ? !!optimizerBackend.steamFriendsSettings["GR_EnableHEVC"] : false
                    anchors.verticalCenter: parent.verticalCenter
                    onToggled: (isChecked) => { root.toggleSteamFriendsSetting("GR_EnableHEVC", isChecked); }
                }
            }

            // Maximum frame rate
            Rectangle {
                width: parent.width
                height: 36
                color: "transparent"
                Text {
                    text: qsTr("Maximum frame rate")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    id: fpsDropdown
                    width: 120
                    height: 30
                    radius: 6
                    color: "#05FFFFFF"
                    border.color: Theme.border
                    border.width: 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    property int currentVal: (optimizerBackend.steamFriendsSettings && typeof optimizerBackend.steamFriendsSettings["GR_MaxFPS"] !== "undefined") ? optimizerBackend.steamFriendsSettings["GR_MaxFPS"] : 60

                    readonly property var options: [
                        { id: 30, label: "30 FPS" },
                        { id: 60, label: "60 FPS" }
                    ]

                    function getLabelForVal(v) {
                        for (var i = 0; i < options.length; i++) {
                            if (options[i].id === v) return options[i].label;
                        }
                        return "60 FPS";
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: fpsDropdown.getLabelForVal(fpsDropdown.currentVal)
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
                        onClicked: fpsMenu.open()
                        onEntered: fpsDropdown.border.color = Theme.accent
                        onExited: fpsDropdown.border.color = Theme.border
                    }

                    Menu {
                        id: fpsMenu
                        y: fpsDropdown.height + 4
                        width: fpsDropdown.width
                        background: Rectangle {
                            color: Theme.sidebarBg
                            border.color: Theme.border
                            border.width: 1
                            radius: 6
                        }
                        Instantiator {
                            model: fpsDropdown.options
                            onObjectAdded: (index, object) => fpsMenu.insertItem(index, object)
                            onObjectRemoved: (index, object) => fpsMenu.removeItem(object)
                            delegate: MenuItem {
                                text: modelData.label
                                width: fpsMenu.width
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
                                    root.toggleSteamFriendsSetting("GR_MaxFPS", modelData.id);
                                }
                            }
                        }
                    }
                }
            }

            // Maximum video height
            Rectangle {
                width: parent.width
                height: 36
                color: "transparent"
                Text {
                    text: qsTr("Maximum video height")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    id: heightDropdown
                    width: 120
                    height: 30
                    radius: 6
                    color: "#05FFFFFF"
                    border.color: Theme.border
                    border.width: 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    property int currentVal: (optimizerBackend.steamFriendsSettings && typeof optimizerBackend.steamFriendsSettings["GR_MaxVideoHeight"] !== "undefined") ? optimizerBackend.steamFriendsSettings["GR_MaxVideoHeight"] : 0

                    readonly property var options: [
                        { id: 0, label: qsTr("No Limit") },
                        { id: 2160, label: qsTr("2160 pixels") },
                        { id: 1440, label: qsTr("1440 pixels") },
                        { id: 1200, label: qsTr("1200 pixels") },
                        { id: 1080, label: qsTr("1080 pixels") },
                        { id: 720, label: qsTr("720 pixels") },
                        { id: 480, label: qsTr("480 pixels") }
                    ]

                    function getLabelForVal(v) {
                        for (var i = 0; i < options.length; i++) {
                            if (options[i].id === v) return options[i].label;
                        }
                        return qsTr("No Limit");
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: heightDropdown.getLabelForVal(heightDropdown.currentVal)
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
                        onClicked: heightMenu.open()
                        onEntered: heightDropdown.border.color = Theme.accent
                        onExited: heightDropdown.border.color = Theme.border
                    }

                    Menu {
                        id: heightMenu
                        y: heightDropdown.height + 4
                        width: heightDropdown.width
                        background: Rectangle {
                            color: Theme.sidebarBg
                            border.color: Theme.border
                            border.width: 1
                            radius: 6
                        }
                        Instantiator {
                            model: heightDropdown.options
                            onObjectAdded: (index, object) => heightMenu.insertItem(index, object)
                            onObjectRemoved: (index, object) => heightMenu.removeItem(object)
                            delegate: MenuItem {
                                text: modelData.label
                                width: heightMenu.width
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
                                    root.toggleSteamFriendsSetting("GR_MaxVideoHeight", modelData.id);
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

            // SECTION: Audio Recording
            Text {
                text: qsTr("Audio Recording")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.0
            }

            // Record Microphone
            Rectangle {
                width: parent.width
                height: Math.max(50, aToggleCol_1.implicitHeight + 8)
                color: "transparent"
                Column {
                    id: aToggleCol_1
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    anchors.left: parent.left
                    anchors.right: aSwitch_1.left
                    anchors.rightMargin: 12
                    Text {
                        text: qsTr("Record Microphone")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Enables recording of your system microphone in clips")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                }
                MeguSwitch {
                    id: aSwitch_1
                    anchors.right: parent.right
                    steamStyle: true
                    checked: (optimizerBackend.steamFriendsSettings && typeof optimizerBackend.steamFriendsSettings["GR_RecordMicrophone"] !== "undefined") ? !!optimizerBackend.steamFriendsSettings["GR_RecordMicrophone"] : false
                    anchors.verticalCenter: parent.verticalCenter
                    onToggled: (isChecked) => { root.toggleSteamFriendsSetting("GR_RecordMicrophone", isChecked); }
                }
            }

            // Force microphone to mono
            Rectangle {
                width: parent.width
                height: visible ? Math.max(40, monoToggleCol.implicitHeight + 8) : 0
                color: "transparent"
                visible: aSwitch_1.checked
                Column {
                    id: monoToggleCol
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    anchors.left: parent.left
                    anchors.right: monoSwitch.left
                    anchors.rightMargin: 12
                    Text {
                        text: qsTr("Force microphone to mono")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
                MeguSwitch {
                    id: monoSwitch
                    anchors.right: parent.right
                    steamStyle: true
                    checked: (optimizerBackend.steamFriendsSettings && typeof optimizerBackend.steamFriendsSettings["GR_ForceMicMono"] !== "undefined") ? !!optimizerBackend.steamFriendsSettings["GR_ForceMicMono"] : false
                    anchors.verticalCenter: parent.verticalCenter
                    onToggled: (isChecked) => { root.toggleSteamFriendsSetting("GR_ForceMicMono", isChecked); }
                }
            }

            // Enable automatic gain control (AGC)
            Rectangle {
                width: parent.width
                height: visible ? Math.max(40, agcToggleCol.implicitHeight + 8) : 0
                color: "transparent"
                visible: aSwitch_1.checked
                Column {
                    id: agcToggleCol
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    anchors.left: parent.left
                    anchors.right: agcSwitch.left
                    anchors.rightMargin: 12
                    Text {
                        text: qsTr("Enable automatic gain control (AGC)")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
                MeguSwitch {
                    id: agcSwitch
                    anchors.right: parent.right
                    steamStyle: true
                    checked: (optimizerBackend.steamFriendsSettings && typeof optimizerBackend.steamFriendsSettings["GR_AutomaticGainControl"] !== "undefined") ? !!optimizerBackend.steamFriendsSettings["GR_AutomaticGainControl"] : true
                    anchors.verticalCenter: parent.verticalCenter
                    onToggled: (isChecked) => { root.toggleSteamFriendsSetting("GR_AutomaticGainControl", isChecked); }
                }
            }

            // Record Audio from
            Rectangle {
                width: parent.width
                height: 36
                color: "transparent"
                Text {
                    text: qsTr("Record Audio from...")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    id: audioSrcDropdown
                    width: 160
                    height: 30
                    radius: 6
                    color: "#05FFFFFF"
                    border.color: Theme.border
                    border.width: 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    property int currentVal: (optimizerBackend.steamFriendsSettings && typeof optimizerBackend.steamFriendsSettings["GR_AudioSource"] !== "undefined") ? optimizerBackend.steamFriendsSettings["GR_AudioSource"] : 0

                    readonly property var options: [
                        { id: 0, label: qsTr("Game Audio Only") },
                        { id: 1, label: qsTr("All System Audio") },
                        { id: 2, label: qsTr("Game and Selected Programs") }
                    ]

                    function getLabelForVal(v) {
                        for (var i = 0; i < options.length; i++) {
                            if (options[i].id === v) return options[i].label;
                        }
                        return qsTr("Game Audio Only");
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: audioSrcDropdown.getLabelForVal(audioSrcDropdown.currentVal)
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
                        onClicked: audioSrcMenu.open()
                        onEntered: audioSrcDropdown.border.color = Theme.accent
                        onExited: audioSrcDropdown.border.color = Theme.border
                    }

                    Menu {
                        id: audioSrcMenu
                        y: audioSrcDropdown.height + 4
                        width: audioSrcDropdown.width
                        background: Rectangle {
                            color: Theme.sidebarBg
                            border.color: Theme.border
                            border.width: 1
                            radius: 6
                        }
                        Instantiator {
                            model: audioSrcDropdown.options
                            onObjectAdded: (index, object) => audioSrcMenu.insertItem(index, object)
                            onObjectRemoved: (index, object) => audioSrcMenu.removeItem(object)
                            delegate: MenuItem {
                                text: modelData.label
                                width: audioSrcMenu.width
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
                                    root.toggleSteamFriendsSetting("GR_AudioSource", modelData.id);
                                }
                            }
                        }
                    }
                }
            }

            // Select additional programs panel
            Column {
                width: parent.width
                visible: audioSrcDropdown.currentVal === 2
                spacing: 8

                Text {
                    text: qsTr("Select additional programs to record audio from:")
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    anchors.left: parent.left
                }

                Rectangle {
                    width: parent.width
                    height: Math.min(240, audioAppsRepeater.count * 40 + 8)
                    color: "#05FFFFFF"
                    border.color: Theme.border
                    border.width: 1
                    radius: 6
                    clip: true

                    ScrollView {
                        anchors.fill: parent
                        contentWidth: width
                        contentHeight: audioAppsRepeater.count * 40 + 8
                        ScrollBar.vertical.policy: ScrollBar.AsNeeded

                        Column {
                            width: parent.width
                            spacing: 2
                            padding: 4

                            Repeater {
                                id: audioAppsRepeater
                                model: audioAppsModel
                                delegate: Rectangle {
                                    width: parent.width - 8
                                    height: 36
                                    color: mouseArea.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.08) : "transparent"
                                    radius: 4

                                    Row {
                                        anchors.left: parent.left
                                        anchors.leftMargin: 12
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 12
                                        opacity: model.running ? 1.0 : 0.6

                                        Image {
                                             source: model.icon
                                             width: 16
                                             height: 16
                                             fillMode: Image.PreserveAspectFit
                                             anchors.verticalCenter: parent.verticalCenter
                                         }

                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 1
                                            Row {
                                                spacing: 6
                                                Text {
                                                    text: model.name
                                                    color: Theme.textPrimary
                                                    font.family: Theme.fontFamily
                                                    font.pixelSize: 12
                                                    font.bold: true
                                                }
                                                Rectangle {
                                                    width: 6
                                                    height: 6
                                                    radius: 3
                                                    color: "#28a745" // Green dot for running processes
                                                    visible: model.running
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                            }
                                            Text {
                                                text: model.exe
                                                color: Theme.textSecondary
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 9
                                            }
                                        }
                                    }

                                    // Checkbox on the right
                                    Rectangle {
                                        width: 16
                                        height: 16
                                        radius: 3
                                        color: model.appChecked ? Theme.accent : "transparent"
                                        border.color: model.appChecked ? Theme.accent : Theme.border
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
                                            visible: model.appChecked
                                        }
                                    }

                                    MouseArea {
                                        id: mouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            var newVal = !model.appChecked;
                                            audioAppsModel.setProperty(index, "appChecked", newVal);
                                            
                                            // Save state
                                                var checkedAppsList = [];
                                                for (var i = 0; i < audioAppsModel.count; i++) {
                                                    var item = audioAppsModel.get(i);
                                                    if (item.appChecked) {
                                                        checkedAppsList.push({
                                                            "exe": item.exe,
                                                            "name": item.sessionIdentifier || "",
                                                            "label": item.name,
                                                            "fromVdf": item.fromVdf ? true : false
                                                        });
                                                    }
                                                }
                                                root.toggleSteamFriendsSetting("GR_AudioCaptureApps", checkedAppsList);
                                        }
                                    }
                                }
                            }
                        }
                    }
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
        focus: true

        property int currentThreshold: (optimizerBackend.steamFriendsSettings && typeof optimizerBackend.steamFriendsSettings["noiseGateLevel"] !== "undefined") ? optimizerBackend.steamFriendsSettings["noiseGateLevel"] : 2
        property int currentTransmissionType: (optimizerBackend.steamFriendsSettings && typeof optimizerBackend.steamFriendsSettings["voiceTransmissionType"] !== "undefined") ? optimizerBackend.steamFriendsSettings["voiceTransmissionType"] : 0

        property var inputDevices: []
        property var outputDevices: []

        property bool micTesting: false
        property real testVolumeLevel: 0.0

        property bool assigningPTT: false
        property bool assigningMute: false
        property bool showCyrillicWarning: false

        function updateVoiceHotkey(vkCode, keyName) {
            var current = optimizerBackend.steamFriendsSettings;
            if (current) {
                var optMap = {};
                var keys = Object.keys(current);
                for (var i = 0; i < keys.length; i++) {
                    optMap[keys[i]] = current[keys[i]];
                }
                optMap["PushToTalkKey"] = vkCode;
                optMap["muteToggleHotkey"] = keyName;
                optimizerBackend.steamFriendsSettings = optMap;
            }
        }

        function getVkCodeForKey(latinKey) {
            var map = {
                "SPACE": "32",
                "CTRL": "17",
                "SHIFT": "16",
                "ALT": "18",
                "TAB": "9",
                "CAPSLOCK": "20",
                "BACKSPACE": "8",
                "ENTER": "13",
                "ESCAPE": "27",
                "INSERT": "45",
                "DELETE": "46",
                "PAGEUP": "33",
                "PAGEDOWN": "34",
                "END": "35",
                "HOME": "36",
                "LEFT": "37",
                "UP": "38",
                "RIGHT": "39",
                "DOWN": "40",
                "F1": "112", "F2": "113", "F3": "114", "F4": "115", "F5": "116", "F6": "117", "F7": "118", "F8": "119", "F9": "120", "F10": "121", "F11": "122", "F12": "123",
                "A": "65", "B": "66", "C": "67", "D": "68", "E": "69", "F": "70", "G": "71", "H": "72", "I": "73", "J": "74", "K": "75", "L": "76", "M": "77", "N": "78", "O": "79", "P": "80", "Q": "81", "R": "82", "S": "83", "T": "84", "U": "85", "V": "86", "W": "87", "X": "88", "Y": "89", "Z": "90",
                "0": "48", "1": "49", "2": "50", "3": "51", "4": "52", "5": "53", "6": "54", "7": "55", "8": "56", "9": "57",
                ";": "186", "=": "187", ",": "188", "-": "189", ".": "190", "/": "191", "`": "192", "[": "219", "\\": "220", "]": "221", "'": "222"
            };
            return map[latinKey] || "";
        }

        function getKeyNameFromVkCode(vkCode) {
            if (!vkCode || vkCode === "0") return "";
            var map = {
                "8": "BACKSPACE",
                "9": "TAB",
                "13": "ENTER",
                "16": "SHIFT",
                "17": "CTRL",
                "18": "ALT",
                "20": "CAPSLOCK",
                "27": "ESCAPE",
                "32": "SPACE",
                "33": "PAGEUP",
                "34": "PAGEDOWN",
                "35": "END",
                "36": "HOME",
                "37": "LEFT",
                "38": "UP",
                "39": "RIGHT",
                "40": "DOWN",
                "45": "INSERT",
                "46": "DELETE",
                "48": "0", "49": "1", "50": "2", "51": "3", "52": "4", "53": "5", "54": "6", "55": "7", "56": "8", "57": "9",
                "65": "A", "66": "B", "67": "C", "68": "D", "69": "E", "70": "F", "71": "G", "72": "H", "73": "I", "74": "J", "75": "K", "76": "L", "77": "M", "78": "N", "79": "O", "80": "P", "81": "Q", "82": "R", "83": "S", "84": "T", "85": "U", "86": "V", "87": "W", "88": "X", "89": "Y", "90": "Z",
                "96": "0", "97": "1", "98": "2", "99": "3", "100": "4", "101": "5", "102": "6", "103": "7", "104": "8", "105": "9",
                "112": "F1", "113": "F2", "114": "F3", "115": "F4", "116": "F5", "117": "F6", "118": "F7", "119": "F8", "120": "F9", "121": "F10", "122": "F11", "123": "F12",
                "186": ";", "187": "=", "188": ",", "189": "-", "190": ".", "191": "/", "192": "`", "219": "[", "220": "\\", "221": "]", "222": "'"
            };
            return map[vkCode.toString()] || vkCode;
        }

        Timer {
            id: cyrillicWarningTimer
            interval: 4000
            onTriggered: steamVoicePage.showCyrillicWarning = false
        }

        Keys.onPressed: (event) => {
            function isCyrillic(str) {
                for (var i = 0; i < str.length; i++) {
                    var code = str.charCodeAt(i);
                    if (code >= 0x0400 && code <= 0x04FF) {
                        return true;
                    }
                }
                return false;
            }

            function getLatinKey(evt) {
                if (evt.key === Qt.Key_Space) return "SPACE";
                if (evt.key === Qt.Key_Control) return "CTRL";
                if (evt.key === Qt.Key_Shift) return "SHIFT";
                if (evt.key === Qt.Key_Alt) return "ALT";
                if (evt.key === Qt.Key_Tab || evt.key === Qt.Key_Backtab) return "TAB";
                if (evt.key === Qt.Key_CapsLock) return "CAPSLOCK";
                
                // F1-F12
                if (evt.key >= Qt.Key_F1 && evt.key <= Qt.Key_F12) {
                    return "F" + (evt.key - Qt.Key_F1 + 1);
                }
                
                // Letters A-Z
                if (evt.key >= Qt.Key_A && evt.key <= Qt.Key_Z) {
                    return String.fromCharCode(evt.key);
                }
                
                // Numbers 0-9
                if (evt.key >= Qt.Key_0 && evt.key <= Qt.Key_9) {
                    return String.fromCharCode(evt.key);
                }

                // Numpad Numbers 0-9
                if (evt.key >= Qt.Key_Keypad0 && evt.key <= Qt.Key_Keypad9) {
                    return (evt.key - Qt.Key_Keypad0).toString();
                }

                // Punctuation & other common layout-independent mappings
                if (evt.key === Qt.Key_Comma) return ",";
                if (evt.key === Qt.Key_Period) return ".";
                if (evt.key === Qt.Key_Semicolon) return ";";
                if (evt.key === Qt.Key_Slash) return "/";
                if (evt.key === Qt.Key_Backslash) return "\\";
                if (evt.key === Qt.Key_BracketLeft) return "[";
                if (evt.key === Qt.Key_BracketRight) return "]";
                if (evt.key === Qt.Key_Minus) return "-";
                if (evt.key === Qt.Key_Equal) return "=";
                if (evt.key === Qt.Key_QuoteLeft) return "`";
                if (evt.key === Qt.Key_Apostrophe) return "'";

                // Fallback to text character if it is a standard Latin letter
                var txt = evt.text.toUpperCase();
                if (txt.length === 1 && txt >= 'A' && txt <= 'Z') {
                    return txt;
                }
                return "";
            }

            if (steamVoicePage.assigningPTT) {
                if (event.key === Qt.Key_Escape) {
                    steamVoicePage.updateVoiceHotkey("0", "");
                    event.accepted = true;
                    steamVoicePage.assigningPTT = false;
                    steamVoicePage.showCyrillicWarning = false;
                } else if (isCyrillic(event.text)) {
                    steamVoicePage.showCyrillicWarning = true;
                    cyrillicWarningTimer.restart();
                    event.accepted = true;
                } else {
                    var latinKey = getLatinKey(event);
                    if (latinKey !== "") {
                        var vkCode = steamVoicePage.getVkCodeForKey(latinKey);
                        if (vkCode !== "") {
                            steamVoicePage.updateVoiceHotkey(vkCode, latinKey);
                            event.accepted = true;
                            steamVoicePage.assigningPTT = false;
                            steamVoicePage.showCyrillicWarning = false;
                        } else {
                            event.accepted = true;
                        }
                    } else {
                        event.accepted = true;
                    }
                }
            }
        }

        function getDeviceName(list, idVal) {
            if (!list) return idVal === "default" ? qsTr("Default") : idVal;
            for (var i = 0; i < list.length; i++) {
                if (list[i] && list[i].id === idVal) {
                    return list[i].name;
                }
            }
            return idVal === "default" ? qsTr("Default") : idVal;
        }

        function mapGainToSlider(gain) {
            if (gain === undefined) return 0.5;
            var g = parseFloat(gain);
            if (g <= 1.0) {
                return g * 0.5;
            } else {
                return 0.5 + (g - 1.0) / 6.0;
            }
        }

        function mapSliderToGain(sliderVal) {
            var x = parseFloat(sliderVal);
            if (x <= 0.5) {
                return x * 2.0;
            } else {
                return 1.0 + (x - 0.5) * 6.0;
            }
        }

        onVisibleChanged: {
            if (visible) {
                inputDevices = optimizerBackend.getAudioInputDevices();
                outputDevices = optimizerBackend.getAudioOutputDevices();
            } else {
                micTesting = false;
                micTestTimer.stop();
                assigningPTT = false;
                assigningMute = false;
            }
        }

        Timer {
            id: micTestTimer
            interval: 50
            running: steamVoicePage.micTesting
            repeat: true
            onTriggered: {
                var level = optimizerBackend.getMicrophonePeakLevel(micDeviceDropdown.currentVal);
                steamVoicePage.testVolumeLevel = level;
            }
            onRunningChanged: {
                if (!running) {
                    steamVoicePage.testVolumeLevel = 0.0;
                }
            }
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

            // Section: Customization
            Text {
                text: qsTr("Customization")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.0
            }

            // Section: Hardware & Volumes
            Text {
                text: qsTr("Hardware & Volume")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.0
            }

            // Dropdown: Voice Input Device
            Rectangle {
                width: parent.width
                height: 36
                color: "transparent"
                Text {
                    text: qsTr("Voice Input Device")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    id: micDeviceDropdown
                    width: 220
                    height: 32
                    radius: 6
                    color: "#05FFFFFF"
                    border.color: Theme.border
                    border.width: 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    property string currentVal: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["selectedMic"] || "default" : "default"

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.right: parent.right
                        anchors.rightMargin: 28
                        anchors.verticalCenter: parent.verticalCenter
                        text: steamVoicePage.getDeviceName(steamVoicePage.inputDevices, micDeviceDropdown.currentVal)
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\u2304"
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: micDeviceMenu.open()
                        onEntered: micDeviceDropdown.border.color = Theme.accent
                        onExited: micDeviceDropdown.border.color = Theme.border
                    }
                    Menu {
                        id: micDeviceMenu
                        y: micDeviceDropdown.height + 4
                        width: micDeviceDropdown.width
                        background: Rectangle {
                            color: Theme.sidebarBg
                            border.color: Theme.border
                            border.width: 1
                            radius: 6
                        }
                        Instantiator {
                            model: steamVoicePage.inputDevices
                            onObjectAdded: (index, object) => micDeviceMenu.insertItem(index, object)
                            onObjectRemoved: (index, object) => micDeviceMenu.removeItem(object)
                            delegate: MenuItem {
                                text: modelData.name
                                width: micDeviceMenu.width
                                height: 32
                                contentItem: Text {
                                    text: parent.text
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    color: parent.highlighted ? Theme.accent : Theme.textPrimary
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 12
                                    elide: Text.ElideRight
                                }
                                onClicked: {
                                    root.toggleSteamFriendsSetting("selectedMic", modelData.id);
                                }
                            }
                        }
                    }
                }
            }

            // Input Volume Slider
            Rectangle {
                width: parent.width
                height: 54
                color: "transparent"
                Column {
                    anchors.fill: parent
                    spacing: 4
                    Row {
                        width: parent.width
                        Text {
                            text: qsTr("Input Volume")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: Math.round(steamVoicePage.mapSliderToGain(inputVolumeSlider.value) * 100) + "%"
                            color: Theme.accent
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                            anchors.right: parent.right
                        }
                    }
                    Slider {
                        id: inputVolumeSlider
                        width: parent.width
                        from: 0.0
                        to: 1.0
                        value: steamVoicePage.mapGainToSlider(optimizerBackend.steamFriendsSettings ? (optimizerBackend.steamFriendsSettings["inputGain"] !== undefined ? optimizerBackend.steamFriendsSettings["inputGain"] : 1.0) : 1.0)
                        stepSize: 0.005
                        live: true
                        onMoved: {
                            root.toggleSteamFriendsSetting("inputGain", steamVoicePage.mapSliderToGain(value));
                        }
                        background: Rectangle {
                            x: inputVolumeSlider.leftPadding
                            y: inputVolumeSlider.topPadding + inputVolumeSlider.availableHeight / 2 - height / 2
                            width: inputVolumeSlider.availableWidth
                            height: 4
                            radius: 2
                            color: Theme.border
                            Rectangle {
                                width: inputVolumeSlider.visualPosition * parent.width
                                height: parent.height
                                color: Theme.accent
                                radius: 2
                            }
                        }
                        handle: Rectangle {
                            x: inputVolumeSlider.leftPadding + inputVolumeSlider.visualPosition * (inputVolumeSlider.availableWidth - width)
                            y: inputVolumeSlider.topPadding + inputVolumeSlider.availableHeight / 2 - height / 2
                            implicitWidth: 16
                            implicitHeight: 16
                            radius: 8
                            color: inputVolumeSlider.pressed ? Theme.accent : Theme.textPrimary
                            border.color: Theme.accent
                            border.width: inputVolumeSlider.hovered ? 2 : 0
                            scale: inputVolumeSlider.pressed ? 1.2 : (inputVolumeSlider.hovered ? 1.1 : 1.0)
                            Behavior on scale { NumberAnimation { duration: Theme.animFast } }
                        }
                    }
                }
            }

            // Dropdown: Voice Output Device
            Rectangle {
                width: parent.width
                height: 36
                color: "transparent"
                Text {
                    text: qsTr("Voice Output Device")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    id: outputDeviceDropdown
                    width: 220
                    height: 32
                    radius: 6
                    color: "#05FFFFFF"
                    border.color: Theme.border
                    border.width: 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    property string currentVal: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["selectedOutput"] || "default" : "default"

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.right: parent.right
                        anchors.rightMargin: 28
                        anchors.verticalCenter: parent.verticalCenter
                        text: steamVoicePage.getDeviceName(steamVoicePage.outputDevices, outputDeviceDropdown.currentVal)
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\u2304"
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: outputDeviceMenu.open()
                        onEntered: outputDeviceDropdown.border.color = Theme.accent
                        onExited: outputDeviceDropdown.border.color = Theme.border
                    }
                    Menu {
                        id: outputDeviceMenu
                        y: outputDeviceDropdown.height + 4
                        width: outputDeviceDropdown.width
                        background: Rectangle {
                            color: Theme.sidebarBg
                            border.color: Theme.border
                            border.width: 1
                            radius: 6
                        }
                        Instantiator {
                            model: steamVoicePage.outputDevices
                            onObjectAdded: (index, object) => outputDeviceMenu.insertItem(index, object)
                            onObjectRemoved: (index, object) => outputDeviceMenu.removeItem(object)
                            delegate: MenuItem {
                                text: modelData.name
                                width: outputDeviceMenu.width
                                height: 32
                                contentItem: Text {
                                    text: parent.text
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    color: parent.highlighted ? Theme.accent : Theme.textPrimary
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 12
                                    elide: Text.ElideRight
                                }
                                onClicked: {
                                    root.toggleSteamFriendsSetting("selectedOutput", modelData.id);
                                }
                            }
                        }
                    }
                }
            }

            // Output Volume Slider
            Rectangle {
                width: parent.width
                height: 54
                color: "transparent"
                Column {
                    anchors.fill: parent
                    spacing: 4
                    Row {
                        width: parent.width
                        Text {
                            text: qsTr("Output Volume")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: Math.round(steamVoicePage.mapSliderToGain(outputVolumeSlider.value) * 100) + "%"
                            color: Theme.accent
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                            anchors.right: parent.right
                        }
                    }
                    Slider {
                        id: outputVolumeSlider
                        width: parent.width
                        from: 0.0
                        to: 1.0
                        value: steamVoicePage.mapGainToSlider(optimizerBackend.steamFriendsSettings ? (optimizerBackend.steamFriendsSettings["outputGain"] !== undefined ? optimizerBackend.steamFriendsSettings["outputGain"] : 1.0) : 1.0)
                        stepSize: 0.005
                        live: true
                        onMoved: {
                            root.toggleSteamFriendsSetting("outputGain", steamVoicePage.mapSliderToGain(value));
                        }
                        background: Rectangle {
                            x: outputVolumeSlider.leftPadding
                            y: outputVolumeSlider.topPadding + outputVolumeSlider.availableHeight / 2 - height / 2
                            width: outputVolumeSlider.availableWidth
                            height: 4
                            radius: 2
                            color: Theme.border
                            Rectangle {
                                width: outputVolumeSlider.visualPosition * parent.width
                                height: parent.height
                                color: Theme.accent
                                radius: 2
                            }
                        }
                        handle: Rectangle {
                            x: outputVolumeSlider.leftPadding + outputVolumeSlider.visualPosition * (outputVolumeSlider.availableWidth - width)
                            y: outputVolumeSlider.topPadding + outputVolumeSlider.availableHeight / 2 - height / 2
                            implicitWidth: 16
                            implicitHeight: 16
                            radius: 8
                            color: outputVolumeSlider.pressed ? Theme.accent : Theme.textPrimary
                            border.color: Theme.accent
                            border.width: outputVolumeSlider.hovered ? 2 : 0
                            scale: outputVolumeSlider.pressed ? 1.2 : (outputVolumeSlider.hovered ? 1.1 : 1.0)
                            Behavior on scale { NumberAnimation { duration: Theme.animFast } }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
            }

            // Section: Microphone Test
            Text {
                text: qsTr("Microphone Test")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.0
            }

            Rectangle {
                width: parent.width
                height: 36
                color: "transparent"

                MeguButton {
                    id: micTestBtn
                    text: steamVoicePage.micTesting ? qsTr("Stop Test") : qsTr("Start Microphone Test")
                    width: 150
                    height: 32
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: {
                        steamVoicePage.micTesting = !steamVoicePage.micTesting;
                    }
                }

                Rectangle {
                    id: levelMeterTrack
                    anchors.left: micTestBtn.right
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    height: 8
                    radius: 4
                    color: Theme.border

                    Rectangle {
                        height: parent.height
                        radius: parent.radius
                        color: steamVoicePage.testVolumeLevel > 0.7 ? "#FF5555" : (steamVoicePage.testVolumeLevel > 0.4 ? "#FFAA00" : "#44C355")
                        width: parent.width * steamVoicePage.testVolumeLevel
                        Behavior on width { NumberAnimation { duration: 80; easing.type: Easing.OutQuad } }
                        Behavior on color { ColorAnimation { duration: 100 } }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
            }

            // Section: Transmission Type
            Text {
                text: qsTr("Voice Transmission Type")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.0
            }

            Row {
                width: parent.width
                spacing: 8

                Repeater {
                    model: [
                        { id: 0, label: qsTr("Open Microphone") },
                        { id: 1, label: qsTr("Push-to-Talk") },
                        { id: 2, label: qsTr("Push-to-Mute") }
                    ]
                    delegate: Rectangle {
                        height: 32
                        width: (parent.width - 16) / 3
                        radius: 6
                        color: (steamVoicePage.currentTransmissionType === modelData.id) ? Theme.accentDim : (transBtnMouse.containsMouse ? "#0DFFFFFF" : "#05FFFFFF")
                        border.color: (steamVoicePage.currentTransmissionType === modelData.id) ? Theme.accent : Theme.border
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                        Text {
                            text: modelData.label
                            color: (steamVoicePage.currentTransmissionType === modelData.id) ? Theme.accent : Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            id: transBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.toggleSteamFriendsSetting("voiceTransmissionType", modelData.id);
                            }
                        }
                    }
                }
            }

            // Voice Hotkey Row (Visible for all transmission types)
            Rectangle {
                width: parent.width
                height: 36
                color: "transparent"

                Text {
                    text: {
                        if (steamVoicePage.currentTransmissionType === 1) return qsTr("Push-to-Talk Hotkey");
                        if (steamVoicePage.currentTransmissionType === 2) return qsTr("Push-to-Mute Hotkey");
                        return qsTr("Mute Toggle Hotkey");
                    }
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    id: voiceHotkeyBtn
                    width: 180
                    height: 32
                    radius: 6
                    color: steamVoicePage.assigningPTT ? Theme.accentDim : "#05FFFFFF"
                    border.color: steamVoicePage.assigningPTT ? Theme.accent : Theme.border
                    border.width: 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    property string currentPttKey: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["PushToTalkKey"] || "0" : "0"
                    property string currentMuteKey: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["muteToggleHotkey"] || "" : ""
                    property bool hasKey: (currentPttKey !== "0" && currentPttKey !== "") || (currentMuteKey !== "")

                    Text {
                        anchors.left: parent.left
                        anchors.right: clearVoiceHotkeyBtn.visible ? clearVoiceHotkeyBtn.left : parent.right
                        anchors.leftMargin: clearVoiceHotkeyBtn.visible ? 24 : 8
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: {
                            if (steamVoicePage.assigningPTT) {
                                return qsTr("Press any key...");
                            }
                            if (voiceHotkeyBtn.currentMuteKey !== "") {
                                return voiceHotkeyBtn.currentMuteKey;
                            }
                            if (voiceHotkeyBtn.currentPttKey !== "0" && voiceHotkeyBtn.currentPttKey !== "") {
                                return steamVoicePage.getKeyNameFromVkCode(voiceHotkeyBtn.currentPttKey);
                            }
                            return qsTr("None");
                        }
                        color: steamVoicePage.assigningPTT ? Theme.accent : Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    // Clear button
                    Rectangle {
                        id: clearVoiceHotkeyBtn
                        width: 20
                        height: 20
                        radius: 10
                        color: clearVoiceHotkeyMouse.containsMouse ? Qt.rgba(255/255, 255/255, 255/255, 0.1) : "transparent"
                        anchors.right: parent.right
                        anchors.rightMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !steamVoicePage.assigningPTT && voiceHotkeyBtn.hasKey

                        Text {
                            text: "×"
                            color: clearVoiceHotkeyMouse.containsMouse ? Theme.accent : Theme.textSecondary
                            font.pixelSize: 16
                            font.bold: true
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -1
                        }

                        MouseArea {
                            id: clearVoiceHotkeyMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                steamVoicePage.updateVoiceHotkey("0", "");
                            }
                        }
                    }

                    MouseArea {
                        anchors.left: parent.left
                        anchors.right: clearVoiceHotkeyBtn.visible ? clearVoiceHotkeyBtn.left : parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            steamVoicePage.assigningPTT = true;
                            steamVoicePage.forceActiveFocus();
                        }
                        onEntered: {
                            if (!steamVoicePage.assigningPTT) voiceHotkeyBtn.border.color = Theme.accent;
                        }
                        onExited: {
                            if (!steamVoicePage.assigningPTT) voiceHotkeyBtn.border.color = Theme.border;
                        }
                    }
                }
            }

            // Cyrillic Keyboard Layout Warning Card
            Rectangle {
                width: parent.width
                height: steamVoicePage.showCyrillicWarning ? warningTextCol.implicitHeight + 20 : 0
                radius: Theme.radiusSmall
                color: Qt.rgba(232/255, 17/255, 35/255, 0.08)
                border.color: "#E81123"
                border.width: 1
                clip: true
                visible: height > 0
                opacity: steamVoicePage.showCyrillicWarning ? 1.0 : 0.0

                Behavior on height { NumberAnimation { duration: Theme.animFast } }
                Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

                Row {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 12

                    Text {
                        text: "⚠️"
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        id: warningTextCol
                        width: parent.width - 40
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            text: qsTr("Cyrillic hotkeys are not supported!")
                            color: "#FF5555"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                        }

                        Text {
                            text: qsTr("Please switch your keyboard layout to English and try again.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
            }

            // Section: Optimization
            Text {
                text: qsTr("Optimization")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.0
            }

            // Section: Transmission Threshold
            Text {
                text: qsTr("Voice Transmission Threshold")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.0
            }

            Row {
                width: parent.width
                spacing: 8

                Repeater {
                    model: [
                        { id: 0, label: qsTr("Off") },
                        { id: 2, label: qsTr("Medium (Recommended)") },
                        { id: 3, label: qsTr("High") }
                    ]
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

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
            }

            // Section: Advanced settings
            Text {
                text: qsTr("Advanced Settings")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.0
            }

            // Switch 1: Echo cancellation
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_32.implicitHeight + 12)
                color: "transparent"
                Column {
                    id: steamToggleCol_32
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
                Column {
                    id: steamToggleCol_33
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
                Column {
                    id: steamToggleCol_34
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

            // Switch 4: Play short sound
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_PTTSound.implicitHeight + 12)
                color: "transparent"
                Column {
                    id: steamToggleCol_PTTSound
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    anchors.left: parent.left
                    anchors.right: steamToggleSwitch_PTTSound.left
                    anchors.rightMargin: 12
                    Text {
                        text: qsTr("Play short sound on mic activation/deactivation")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Plays a brief chime whenever you begin or end voice transmission.")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                }
                MeguSwitch {
                    id: steamToggleSwitch_PTTSound
                    anchors.right: parent.right
                    steamStyle: true
                    checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["pttSoundsEnabled"] : true
                    anchors.verticalCenter: parent.verticalCenter
                    onToggled: (isChecked) => { root.toggleSteamFriendsSetting("pttSoundsEnabled", isChecked); }
                }
            }

            // Switch 5: Steam Audio Spatialization
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_Spatial.implicitHeight + 12)
                color: "transparent"
                Column {
                    id: steamToggleCol_Spatial
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    anchors.left: parent.left
                    anchors.right: steamToggleSwitch_Spatial.left
                    anchors.rightMargin: 12
                    Text {
                        text: qsTr("Use Steam Audio Spatialization")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Enables binaural spatialization for voice channels using Steam Audio.")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                }
                MeguSwitch {
                    id: steamToggleSwitch_Spatial
                    anchors.right: parent.right
                    steamStyle: true
                    checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["useSteamAudioSpatialization"] : false
                    anchors.verticalCenter: parent.verticalCenter
                    onToggled: (isChecked) => { root.toggleSteamFriendsSetting("useSteamAudioSpatialization", isChecked); }
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

            // Section: Optimization
            Text {
                text: qsTr("Optimization")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.0
            }

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

            // Advanced sections - only enabled if Enable Remote Play is true
            Column {
                width: parent.width
                spacing: 16
                enabled: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["EnableStreaming"] : true
                opacity: enabled ? 1.0 : 0.4
                Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.border
                }

                // Section: Customization
                Text {
                    text: qsTr("Customization")
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 1.0
                }

                // Section: Computers & Devices
                Text {
                    text: qsTr("Computers & Devices")
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 1.0
                }

                // Device List Box
                Rectangle {
                    width: parent.width
                    height: deviceRepeater.count > 0 ? (deviceRepeater.count * 52) + 8 : 72
                    radius: 8
                    color: "#05FFFFFF"
                    border.color: Theme.border
                    border.width: 1
                    clip: true

                    Column {
                        anchors.centerIn: parent
                        spacing: 6
                        visible: deviceRepeater.count === 0

                        Row {
                            spacing: 8
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Item {
                                width: 14
                                height: 14
                                anchors.verticalCenter: parent.verticalCenter
                                Image {
                                    id: noDevicesImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/monitor.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 14
                                    sourceSize.height: 14
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: noDevicesImg
                                    source: noDevicesImg
                                    color: Theme.textSecondary
                                }
                            }
                            Text {
                                text: qsTr("No devices available")
                                color: Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        anchors.top: parent.top
                        anchors.topMargin: 4
                        anchors.bottomMargin: 4
                        spacing: 0

                        Repeater {
                            id: deviceRepeater
                            model: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["RemotePlay_Devices"] : []
                            
                            delegate: Item {
                                width: parent.width
                                height: 50

                                Row {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 16
                                    anchors.right: unpairBtn.left
                                    anchors.rightMargin: 16
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 12

                                    Text {
                                        text: "📱"
                                        color: Theme.textPrimary
                                        font.pixelSize: 16
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 2
                                        Text {
                                            text: modelData.hostname || "Device"
                                            color: Theme.textPrimary
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 11
                                            font.bold: true
                                        }
                                        Text {
                                            text: modelData.ippublic ? "IP: " + modelData.ippublic : qsTr("Authorized")
                                            color: Theme.textSecondary
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 9
                                        }
                                    }
                                }

                                MeguButton {
                                    id: unpairBtn
                                    text: qsTr("Unpair")
                                    anchors.right: parent.right
                                    anchors.rightMargin: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 80
                                    height: 28
                                    onClicked: {
                                        optimizerBackend.unpairSteamDevice(modelData.id);
                                    }
                                }

                                Rectangle {
                                    width: parent.width - 24
                                    height: 1
                                    color: Theme.border
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    visible: index < deviceRepeater.count - 1
                                }
                            }
                        }
                    }
                }

                Text {
                    text: qsTr("To pair a new device (like a phone, tablet, or VR headset) with Steam Remote Play, please open the official Steam client, go to Settings -> Remote Play, and click \"Pair Steam Link\". This handles the secure live network authorization protocol.")
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    width: parent.width
                    wrapMode: Text.WordWrap
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.border
                }

                // Section: Connection Security
                Text {
                    text: qsTr("Connection Security")
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 1.0
                }

                // Dropdown: Allow Direct Connection (P2PScope)
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "transparent"
                    Text {
                        text: qsTr("Allow Direct Connection (IP sharing)")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Rectangle {
                        id: p2pScopeDropdown
                        width: 180
                        height: 32
                        radius: 6
                        color: "#05FFFFFF"
                        border.color: Theme.border
                        border.width: 1
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        property int currentVal: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["RemotePlay_P2PScope"] !== undefined ? optimizerBackend.steamFriendsSettings["RemotePlay_P2PScope"] : 0 : 0

                        readonly property var options: [
                            { id: 0, label: qsTr("Automatic (enabled)") },
                            { id: 1, label: qsTr("Disabled") },
                            { id: 2, label: qsTr("My Devices") },
                            { id: 4, label: qsTr("All Devices") }
                        ]

                        function getLabelForVal(v) {
                            for (var i = 0; i < options.length; i++) {
                                if (options[i].id === v) return options[i].label;
                            }
                            return qsTr("Automatic (enabled)");
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: p2pScopeDropdown.getLabelForVal(p2pScopeDropdown.currentVal)
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                        }
                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: "\u2304"
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: p2pScopeMenu.open()
                            onEntered: p2pScopeDropdown.border.color = Theme.accent
                            onExited: p2pScopeDropdown.border.color = Theme.border
                        }
                        Menu {
                            id: p2pScopeMenu
                            y: p2pScopeDropdown.height + 4
                            width: p2pScopeDropdown.width
                            background: Rectangle {
                                color: Theme.sidebarBg
                                border.color: Theme.border
                                border.width: 1
                                radius: 6
                            }
                            Instantiator {
                                model: p2pScopeDropdown.options
                                onObjectAdded: (index, object) => p2pScopeMenu.insertItem(index, object)
                                onObjectRemoved: (index, object) => p2pScopeMenu.removeItem(object)
                                delegate: MenuItem {
                                    text: modelData.label
                                    width: p2pScopeMenu.width
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
                                        root.toggleSteamFriendsSetting("RemotePlay_P2PScope", modelData.id);
                                    }
                                }
                            }
                        }
                    }
                }

                // PIN pairing code input row
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "transparent"
                    Text {
                        text: qsTr("Connection security PIN")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        Rectangle {
                            width: 120
                            height: 32
                            radius: 6
                            color: "#05FFFFFF"
                            border.color: Theme.border
                            border.width: 1

                            TextInput {
                                id: pinInput
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                verticalAlignment: TextInput.AlignVCenter
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                echoMode: TextInput.Normal
                                validator: IntValidator { bottom: 0; top: 9999 }
                            }

                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                verticalAlignment: Text.AlignVCenter
                                color: Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                text: (optimizerBackend.steamFriendsSettings && optimizerBackend.steamFriendsSettings["RemotePlay_PIN_enabled"]) ? qsTr("PIN is active (***)") : qsTr("Not set")
                                visible: pinInput.text === ""
                            }
                        }

                        MeguButton {
                            text: qsTr("Set PIN")
                            width: 80
                            height: 32
                            onClicked: {
                                if (pinInput.text !== "") {
                                    root.toggleSteamFriendsSetting("RemotePlay_PIN", pinInput.text);
                                    pinInput.text = "";
                                }
                            }
                        }

                        MeguButton {
                            text: qsTr("Clear")
                            width: 60
                            height: 32
                            visible: !!(optimizerBackend.steamFriendsSettings && optimizerBackend.steamFriendsSettings["RemotePlay_PIN_enabled"])
                            onClicked: {
                                root.toggleSteamFriendsSetting("RemotePlay_PIN", "");
                                pinInput.text = "";
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.border
                }

                // Section: Advanced Client Options
                Text {
                    text: qsTr("Advanced Client Options")
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 1.0
                }

                // Switch: Enable Advanced Client Options (RemotePlay_ClientConfigEnabled)
                Rectangle {
                    width: parent.width
                    height: 64
                    color: "transparent"
                    Row {
                        anchors.fill: parent
                        spacing: 12
                        MeguSwitch {
                            steamStyle: true
                            checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["RemotePlay_ClientConfigEnabled"] : false
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => { root.toggleSteamFriendsSetting("RemotePlay_ClientConfigEnabled", isChecked); }
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            width: parent.width - 50
                            Text {
                                text: qsTr("Enable Advanced Client Options")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                            }
                            Text {
                                text: qsTr("To improve performance streaming a game running on another computer, try reducing your game's resolution or adjusting these settings.")
                                color: Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                width: parent.width
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }

                Column {
                    width: parent.width
                    spacing: 16
                    enabled: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["RemotePlay_ClientConfigEnabled"] : false
                    opacity: enabled ? 1.0 : 0.4
                    Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }

                    // Row: Presets (Default, Enhanced 1080p, Enhanced 4K)
                    Row {
                        width: parent.width
                        spacing: 12
                        
                        function getActivePreset() {
                            var settings = optimizerBackend.steamFriendsSettings;
                            if (!settings) return "";
                            
                            var is1080p = (settings["RemotePlay_VideoQuality"] === 3 &&
                                           settings["RemotePlay_ResolutionWidth"] === 1920 &&
                                           settings["RemotePlay_ResolutionHeight"] === 1080 &&
                                           settings["RemotePlay_BandwidthLimit"] === 30000 &&
                                           settings["RemotePlay_Microphone"] === 1 &&
                                           settings["RemotePlay_WindowedMode"] === true &&
                                           settings["RemotePlay_HardwareDecoding"] === true &&
                                           settings["RemotePlay_LowLatencyNetworking"] === true &&
                                           settings["RemotePlay_HEVC"] === true &&
                                           settings["RemotePlay_AV1"] === false &&
                                           settings["RemotePlay_PerformanceOverlay"] === 2);
                                           
                            var is4k = (settings["RemotePlay_VideoQuality"] === 3 &&
                                        settings["RemotePlay_ResolutionWidth"] === 3840 &&
                                        settings["RemotePlay_ResolutionHeight"] === 2160 &&
                                        settings["RemotePlay_BandwidthLimit"] === 50000 &&
                                        settings["RemotePlay_Microphone"] === 1 &&
                                        settings["RemotePlay_WindowedMode"] === true &&
                                        settings["RemotePlay_HardwareDecoding"] === true &&
                                        settings["RemotePlay_LowLatencyNetworking"] === true &&
                                        settings["RemotePlay_HEVC"] === true &&
                                        settings["RemotePlay_AV1"] === false &&
                                        settings["RemotePlay_PerformanceOverlay"] === 2);
                                        
                            var isDefault = (settings["RemotePlay_VideoQuality"] === 2 &&
                                             settings["RemotePlay_ResolutionWidth"] === 0 &&
                                             settings["RemotePlay_ResolutionHeight"] === 0 &&
                                             settings["RemotePlay_BandwidthLimit"] === -1 &&
                                             settings["RemotePlay_Microphone"] === 0 &&
                                             settings["RemotePlay_WindowedMode"] === false &&
                                             settings["RemotePlay_HardwareDecoding"] === true &&
                                             settings["RemotePlay_LowLatencyNetworking"] === false &&
                                             settings["RemotePlay_HEVC"] === true &&
                                             settings["RemotePlay_AV1"] === true &&
                                             settings["RemotePlay_PerformanceOverlay"] === 0);
                                             
                            if (is1080p) return "1080p";
                            if (is4k) return "4k";
                            if (isDefault) return "default";
                            return "";
                        }
                        
                        property string activePreset: getActivePreset()
                        
                        // Button: Default
                        Rectangle {
                            width: (parent.width - 24) / 3
                            height: 36
                            radius: 6
                            color: parent.activePreset === "default" ? Theme.accentDim : (defaultMouse.containsMouse ? "#1AFFFFFF" : "#0DFFFFFF")
                            border.color: parent.activePreset === "default" ? Theme.accent : Theme.border
                            border.width: 1
                            
                            Text {
                                anchors.centerIn: parent
                                text: qsTr("Default")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                            }
                            
                            MouseArea {
                                id: defaultMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { steamSettingsDrawer.applyClientPreset("default"); }
                            }
                        }
                        
                        // Button: Enhanced 1080p
                        Rectangle {
                            width: (parent.width - 24) / 3
                            height: 36
                            radius: 6
                            color: parent.activePreset === "1080p" ? Theme.accentDim : (e1080Mouse.containsMouse ? "#1AFFFFFF" : "#0DFFFFFF")
                            border.color: parent.activePreset === "1080p" ? Theme.accent : Theme.border
                            border.width: 1
                            
                            Text {
                                anchors.centerIn: parent
                                text: qsTr("Enhanced 1080p")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                            }
                            
                            MouseArea {
                                id: e1080Mouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { steamSettingsDrawer.applyClientPreset("1080p"); }
                            }
                        }
                        
                        // Button: Enhanced 4K
                        Rectangle {
                            width: (parent.width - 24) / 3
                            height: 36
                            radius: 6
                            color: parent.activePreset === "4k" ? Theme.accentDim : (e4kMouse.containsMouse ? "#1AFFFFFF" : "#0DFFFFFF")
                            border.color: parent.activePreset === "4k" ? Theme.accent : Theme.border
                            border.width: 1
                            
                            Text {
                                anchors.centerIn: parent
                                text: qsTr("Enhanced 4K")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                            }
                            
                            MouseArea {
                                id: e4kMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { steamSettingsDrawer.applyClientPreset("4k"); }
                            }
                        }
                    }

                // Dropdown: Video Quality (Quality)
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "transparent"
                    Text {
                        text: qsTr("Video Quality")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Rectangle {
                        id: videoQualityDropdown
                        width: 150
                        height: 32
                        radius: 6
                        color: "#05FFFFFF"
                        border.color: Theme.border
                        border.width: 1
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        property int currentVal: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["RemotePlay_VideoQuality"] !== undefined ? optimizerBackend.steamFriendsSettings["RemotePlay_VideoQuality"] : 2 : 2

                        readonly property var options: [
                            { id: 1, label: qsTr("Fast") },
                            { id: 2, label: qsTr("Balanced") },
                            { id: 3, label: qsTr("Beautiful") }
                        ]

                        function getLabelForVal(v) {
                            for (var i = 0; i < options.length; i++) {
                                if (options[i].id === v) return options[i].label;
                            }
                            return qsTr("Balanced");
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: videoQualityDropdown.getLabelForVal(videoQualityDropdown.currentVal)
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                        }
                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: "\u2304"
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: videoQualityMenu.open()
                            onEntered: videoQualityDropdown.border.color = Theme.accent
                            onExited: videoQualityDropdown.border.color = Theme.border
                        }
                        Menu {
                            id: videoQualityMenu
                            y: videoQualityDropdown.height + 4
                            width: videoQualityDropdown.width
                            background: Rectangle {
                                color: Theme.sidebarBg
                                border.color: Theme.border
                                border.width: 1
                                radius: 6
                            }
                            Instantiator {
                                model: videoQualityDropdown.options
                                onObjectAdded: (index, object) => videoQualityMenu.insertItem(index, object)
                                onObjectRemoved: (index, object) => videoQualityMenu.removeItem(object)
                                delegate: MenuItem {
                                    text: modelData.label
                                    width: videoQualityMenu.width
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
                                        root.toggleSteamFriendsSetting("RemotePlay_VideoQuality", modelData.id);
                                    }
                                }
                            }
                        }
                    }
                }

                // Dropdown: Resolution Limit
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "transparent"
                    Text {
                        text: qsTr("Resolution Limit")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Rectangle {
                        id: resolutionLimitDropdown
                        width: 180
                        height: 32
                        radius: 6
                        color: "#05FFFFFF"
                        border.color: Theme.border
                        border.width: 1
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        property int currentW: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["RemotePlay_ResolutionWidth"] || 0 : 0
                        property int currentH: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["RemotePlay_ResolutionHeight"] || 0 : 0

                        readonly property var options: [
                            { width: 0, height: 0, label: qsTr("Automatic") },
                            { width: 852, height: 480, label: "852x480 (480p)" },
                            { width: 1280, height: 720, label: "1280x720 (720p)" },
                            { width: 1600, height: 900, label: "1600x900 (900p)" },
                            { width: 1920, height: 1080, label: "1920x1080 (1080p)" },
                            { width: 2560, height: 1440, label: "2560x1440 (1440p)" },
                            { width: 3840, height: 2160, label: "3840x2160 (4K)" },
                            { width: 7680, height: 4320, label: "7680x4320 (8K)" }
                        ]

                        function getLabelForVal(w, h) {
                            for (var i = 0; i < options.length; i++) {
                                if (options[i].width === w && options[i].height === h) return options[i].label;
                            }
                            return qsTr("Automatic");
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: resolutionLimitDropdown.getLabelForVal(resolutionLimitDropdown.currentW, resolutionLimitDropdown.currentH)
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                        }
                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: "\u2304"
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: resolutionLimitMenu.open()
                            onEntered: resolutionLimitDropdown.border.color = Theme.accent
                            onExited: resolutionLimitDropdown.border.color = Theme.border
                        }
                        Menu {
                            id: resolutionLimitMenu
                            y: resolutionLimitDropdown.height + 4
                            width: resolutionLimitDropdown.width
                            background: Rectangle {
                                color: Theme.sidebarBg
                                border.color: Theme.border
                                border.width: 1
                                radius: 6
                            }
                            Instantiator {
                                model: resolutionLimitDropdown.options
                                onObjectAdded: (index, object) => resolutionLimitMenu.insertItem(index, object)
                                onObjectRemoved: (index, object) => resolutionLimitMenu.removeItem(object)
                                delegate: MenuItem {
                                    text: modelData.label
                                    width: resolutionLimitMenu.width
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
                                        root.toggleSteamFriendsSetting("RemotePlay_ResolutionWidth", modelData.width);
                                        root.toggleSteamFriendsSetting("RemotePlay_ResolutionHeight", modelData.height);
                                    }
                                }
                            }
                        }
                    }
                }

                // Dropdown: Framerate Limit
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "transparent"
                    Text {
                        text: qsTr("Framerate Limit")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Rectangle {
                        id: framerateLimitDropdown
                        width: 150
                        height: 32
                        radius: 6
                        color: "#05FFFFFF"
                        border.color: Theme.border
                        border.width: 1
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        property int currentVal: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["RemotePlay_FramerateLimit"] || 0 : 0

                        readonly property var options: [
                            { id: 0, label: qsTr("Automatic (recommended)") },
                            { id: 3000, label: "30 FPS" },
                            { id: 4975, label: "49.75 FPS" },
                            { id: 5000, label: "50 FPS" },
                            { id: 5975, label: "59.75 FPS" },
                            { id: 6000, label: "60 FPS" },
                            { id: 9000, label: "90 FPS" },
                            { id: 12000, label: "120 FPS" },
                            { id: 14400, label: "144 FPS" },
                            { id: 24000, label: "240 FPS" }
                        ]

                        function getLabelForVal(v) {
                            for (var i = 0; i < options.length; i++) {
                                if (options[i].id === v) return options[i].label;
                            }
                            return qsTr("Automatic (recommended)");
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: framerateLimitDropdown.getLabelForVal(framerateLimitDropdown.currentVal)
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                        }
                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: "\u2304"
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: framerateLimitMenu.open()
                            onEntered: framerateLimitDropdown.border.color = Theme.accent
                            onExited: framerateLimitDropdown.border.color = Theme.border
                        }
                        Menu {
                            id: framerateLimitMenu
                            y: framerateLimitDropdown.height + 4
                            width: framerateLimitDropdown.width
                            background: Rectangle {
                                color: Theme.sidebarBg
                                border.color: Theme.border
                                border.width: 1
                                radius: 6
                            }
                            Instantiator {
                                model: framerateLimitDropdown.options
                                onObjectAdded: (index, object) => framerateLimitMenu.insertItem(index, object)
                                onObjectRemoved: (index, object) => framerateLimitMenu.removeItem(object)
                                delegate: MenuItem {
                                    text: modelData.label
                                    width: framerateLimitMenu.width
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
                                        root.toggleSteamFriendsSetting("RemotePlay_FramerateLimit", modelData.id);
                                    }
                                }
                            }
                        }
                    }
                }

                // Dropdown: Bandwidth Limit
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "transparent"
                    Text {
                        text: qsTr("Bandwidth Limit")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Rectangle {
                        id: bandwidthLimitDropdown
                        width: 150
                        height: 32
                        radius: 6
                        color: "#05FFFFFF"
                        border.color: Theme.border
                        border.width: 1
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        property int currentVal: optimizerBackend.steamFriendsSettings ? (optimizerBackend.steamFriendsSettings["RemotePlay_BandwidthLimit"] !== undefined ? optimizerBackend.steamFriendsSettings["RemotePlay_BandwidthLimit"] : -1) : -1

                        readonly property var options: [
                            { id: -1, label: qsTr("Automatic") },
                            { id: 3000, label: "3 Mbps" },
                            { id: 5000, label: "5 Mbps" },
                            { id: 10000, label: "10 Mbps" },
                            { id: 15000, label: "15 Mbps" },
                            { id: 20000, label: "20 Mbps" },
                            { id: 25000, label: "25 Mbps" },
                            { id: 30000, label: "30 Mbps" },
                            { id: 50000, label: "50 Mbps" },
                            { id: 75000, label: "75 Mbps" },
                            { id: 0, label: qsTr("Unlimited") }
                        ]

                        function getLabelForVal(v) {
                            for (var i = 0; i < options.length; i++) {
                                if (options[i].id === v) return options[i].label;
                            }
                            return qsTr("Automatic");
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: bandwidthLimitDropdown.getLabelForVal(bandwidthLimitDropdown.currentVal)
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                        }
                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: "\u2304"
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: bandwidthLimitMenu.open()
                            onEntered: bandwidthLimitDropdown.border.color = Theme.accent
                            onExited: bandwidthLimitDropdown.border.color = Theme.border
                        }
                        Menu {
                            id: bandwidthLimitMenu
                            y: bandwidthLimitDropdown.height + 4
                            width: bandwidthLimitDropdown.width
                            background: Rectangle {
                                color: Theme.sidebarBg
                                border.color: Theme.border
                                border.width: 1
                                radius: 6
                            }
                            Instantiator {
                                model: bandwidthLimitDropdown.options
                                onObjectAdded: (index, object) => bandwidthLimitMenu.insertItem(index, object)
                                onObjectRemoved: (index, object) => bandwidthLimitMenu.removeItem(object)
                                delegate: MenuItem {
                                    text: modelData.label
                                    width: bandwidthLimitMenu.width
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
                                        root.toggleSteamFriendsSetting("RemotePlay_BandwidthLimit", modelData.id);
                                    }
                                }
                            }
                        }
                    }
                }

                // Volume Slider
                Rectangle {
                    width: parent.width
                    height: 80
                    radius: 8
                    color: "#05FFFFFF"
                    border.color: Theme.border
                    border.width: 1

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        spacing: 8

                        RowLayout {
                            width: parent.width
                            Text {
                                text: qsTr("Volume")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                                Layout.fillWidth: true
                            }
                            Text {
                                text: Math.round(audioVolumeSlider.value) + "%"
                                color: Theme.accent
                                font.family: Theme.fontFamily
                                font.pixelSize: 14
                                font.bold: true
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        Slider {
                            id: audioVolumeSlider
                            width: parent.width
                            from: 0
                            to: 100
                            value: optimizerBackend.steamFriendsSettings ? (optimizerBackend.steamFriendsSettings["RemotePlay_AudioVolume"] !== undefined ? optimizerBackend.steamFriendsSettings["RemotePlay_AudioVolume"] : 100) : 100
                            stepSize: 1
                            live: true
                            onMoved: {
                                root.toggleSteamFriendsSetting("RemotePlay_AudioVolume", Math.round(value));
                            }

                            background: Rectangle {
                                x: audioVolumeSlider.leftPadding
                                y: audioVolumeSlider.topPadding + audioVolumeSlider.availableHeight / 2 - height / 2
                                implicitWidth: 200
                                implicitHeight: 4
                                width: audioVolumeSlider.availableWidth
                                height: implicitHeight
                                radius: 2
                                color: Theme.border

                                Rectangle {
                                    width: audioVolumeSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: Theme.accent
                                    radius: 2
                                }
                            }

                            handle: Rectangle {
                                x: audioVolumeSlider.leftPadding + audioVolumeSlider.visualPosition * (audioVolumeSlider.availableWidth - width)
                                y: audioVolumeSlider.topPadding + audioVolumeSlider.availableHeight / 2 - height / 2
                                implicitWidth: 16
                                implicitHeight: 16
                                radius: 8
                                color: audioVolumeSlider.pressed ? Theme.accent : Theme.textPrimary
                                border.color: Theme.accent
                                border.width: audioVolumeSlider.hovered ? 2 : 0

                                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                                Behavior on scale { NumberAnimation { duration: Theme.animFast } }
                                scale: audioVolumeSlider.pressed ? 1.2 : (audioVolumeSlider.hovered ? 1.1 : 1.0)
                            }
                        }
                    }
                }

                // Dropdown: Performance Overlay
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "transparent"
                    Text {
                        text: qsTr("Performance Overlay")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Rectangle {
                        id: perfOverlayDropdown
                        width: 150
                        height: 32
                        radius: 6
                        color: "#05FFFFFF"
                        border.color: Theme.border
                        border.width: 1
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        property int currentVal: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["RemotePlay_PerformanceOverlay"] || 0 : 0

                        readonly property var options: [
                            { id: 0, label: qsTr("Disabled") },
                            { id: 1, label: qsTr("Show Icons") },
                            { id: 2, label: qsTr("Show Details") }
                        ]

                        function getLabelForVal(v) {
                            for (var i = 0; i < options.length; i++) {
                                if (options[i].id === v) return options[i].label;
                            }
                            return qsTr("Disabled");
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: perfOverlayDropdown.getLabelForVal(perfOverlayDropdown.currentVal)
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                        }
                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: "\u2304"
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: perfOverlayMenu.open()
                            onEntered: perfOverlayDropdown.border.color = Theme.accent
                            onExited: perfOverlayDropdown.border.color = Theme.border
                        }
                        Menu {
                            id: perfOverlayMenu
                            y: perfOverlayDropdown.height + 4
                            width: perfOverlayDropdown.width
                            background: Rectangle {
                                color: Theme.sidebarBg
                                border.color: Theme.border
                                border.width: 1
                                radius: 6
                            }
                            Instantiator {
                                model: perfOverlayDropdown.options
                                onObjectAdded: (index, object) => perfOverlayMenu.insertItem(index, object)
                                onObjectRemoved: (index, object) => perfOverlayMenu.removeItem(object)
                                delegate: MenuItem {
                                    text: modelData.label
                                    width: perfOverlayMenu.width
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
                                        root.toggleSteamFriendsSetting("RemotePlay_PerformanceOverlay", modelData.id);
                                    }
                                }
                            }
                        }
                    }
                }

                // Dropdown: Controller Activation Button (Field 16)
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "transparent"
                    Text {
                        text: qsTr("Controller Overlay")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Rectangle {
                        id: controllerButtonDropdown
                        width: 150
                        height: 32
                        radius: 6
                        color: "#05FFFFFF"
                        border.color: Theme.border
                        border.width: 1
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        property string currentVal: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["RemotePlay_ControllerButton"] || "auto" : "auto"

                        readonly property var options: [
                            { id: "auto", label: qsTr("Default Button") },
                            { id: "start", label: qsTr("Start Button") },
                            { id: "back", label: qsTr("Back Button") },
                            { id: "guide", label: qsTr("Guide Button") },
                            { id: "y", label: qsTr("Y Button") },
                            { id: "none", label: qsTr("Disabled") }
                        ]

                        function getLabelForVal(v) {
                            for (var i = 0; i < options.length; i++) {
                                if (options[i].id === v) return options[i].label;
                            }
                            return qsTr("Default Button");
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: controllerButtonDropdown.getLabelForVal(controllerButtonDropdown.currentVal)
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                        }
                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: "\u2304"
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: controllerButtonMenu.open()
                            onEntered: controllerButtonDropdown.border.color = Theme.accent
                            onExited: controllerButtonDropdown.border.color = Theme.border
                        }
                        Menu {
                            id: controllerButtonMenu
                            y: controllerButtonDropdown.height + 4
                            width: controllerButtonDropdown.width
                            background: Rectangle {
                                color: Theme.sidebarBg
                                border.color: Theme.border
                                border.width: 1
                                radius: 6
                            }
                            Instantiator {
                                model: controllerButtonDropdown.options
                                onObjectAdded: (index, object) => controllerButtonMenu.insertItem(index, object)
                                onObjectRemoved: (index, object) => controllerButtonMenu.removeItem(object)
                                delegate: MenuItem {
                                    text: modelData.label
                                    width: controllerButtonMenu.width
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
                                        root.toggleSteamFriendsSetting("RemotePlay_ControllerButton", modelData.id);
                                    }
                                }
                            }
                        }
                    }
                }


                // Switch: Record my microphone
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "transparent"
                    Row {
                        anchors.fill: parent
                        spacing: 12
                        MeguSwitch {
                            steamStyle: true
                            checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["RemotePlay_Microphone"] : false
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => { root.toggleSteamFriendsSetting("RemotePlay_Microphone", isChecked ? 1 : 0); }
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            width: parent.width - 50
                            Text {
                                text: qsTr("Microphone")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                    }
                }

                // Switch: Play in window
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "transparent"
                    Row {
                        anchors.fill: parent
                        spacing: 12
                        MeguSwitch {
                            steamStyle: true
                            checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["RemotePlay_WindowedMode"] : false
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => { root.toggleSteamFriendsSetting("RemotePlay_WindowedMode", isChecked); }
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            width: parent.width - 50
                            Text {
                                text: qsTr("Windowed Mode")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                    }
                }

                // Switch: Enable hardware decoding
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "transparent"
                    Row {
                        anchors.fill: parent
                        spacing: 12
                        MeguSwitch {
                            steamStyle: true
                            checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["RemotePlay_HardwareDecoding"] : true
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => { root.toggleSteamFriendsSetting("RemotePlay_HardwareDecoding", isChecked); }
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            width: parent.width - 50
                            Text {
                                text: qsTr("Enable hardware decoding")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                    }
                }

                // Switch: Low Latency Networking
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "transparent"
                    Row {
                        anchors.fill: parent
                        spacing: 12
                        MeguSwitch {
                            steamStyle: true
                            checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["RemotePlay_LowLatencyNetworking"] : true
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => { root.toggleSteamFriendsSetting("RemotePlay_LowLatencyNetworking", isChecked); }
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            width: parent.width - 50
                            Text {
                                text: qsTr("Low latency networking")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                    }
                }

                // Switch: HEVC Video
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "transparent"
                    Row {
                        anchors.fill: parent
                        spacing: 12
                        MeguSwitch {
                            steamStyle: true
                            checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["RemotePlay_HEVC"] : true
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => { root.toggleSteamFriendsSetting("RemotePlay_HEVC", isChecked); }
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            width: parent.width - 50
                            Text {
                                text: qsTr("HEVC video")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                    }
                }

                // Switch: AV1 Video
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "transparent"
                    Row {
                        anchors.fill: parent
                        spacing: 12
                        MeguSwitch {
                            steamStyle: true
                            checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["RemotePlay_AV1"] : true
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => { root.toggleSteamFriendsSetting("RemotePlay_AV1", isChecked); }
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            width: parent.width - 50
                            Text {
                                text: qsTr("AV1 video")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
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

                // Section: Advanced Host Options
                Text {
                    text: qsTr("Advanced Host Options")
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 1.0
                }

                // Switch: Enable Advanced Host Options (Host_ServerConfigEnabled)
                Rectangle {
                    width: parent.width
                    height: 64
                    color: "transparent"
                    Row {
                        anchors.fill: parent
                        spacing: 12
                        MeguSwitch {
                            steamStyle: true
                            checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["Host_ServerConfigEnabled"] : false
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => { root.toggleSteamFriendsSetting("Host_ServerConfigEnabled", isChecked); }
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            width: parent.width - 50
                            Text {
                                text: qsTr("Enable Advanced Host Options")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                            }
                            Text {
                                text: qsTr("To improve performance streaming a game running on this computer, try reducing your game's resolution or adjusting these settings.")
                                color: Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                width: parent.width
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }

                Column {
                    width: parent.width
                    spacing: 16
                    enabled: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["Host_ServerConfigEnabled"] : false
                    opacity: enabled ? 1.0 : 0.4
                    Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }

                    // Switch: Change desktop resolution to match streaming client (Host_ChangeDesktopResolution)
                    Rectangle {
                        width: parent.width
                        height: 50
                        color: "transparent"
                        Row {
                            anchors.fill: parent
                            spacing: 12
                            MeguSwitch {
                                steamStyle: true
                                checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["Host_ChangeDesktopResolution"] : true
                                anchors.verticalCenter: parent.verticalCenter
                                onToggled: (isChecked) => { root.toggleSteamFriendsSetting("Host_ChangeDesktopResolution", isChecked); }
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2
                                width: parent.width - 50
                                Text {
                                    text: qsTr("Change desktop resolution to match streaming client")
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 12
                                    font.bold: true
                                }
                            }
                        }
                    }

                // Switch: Play audio on host
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "transparent"
                    Row {
                        anchors.fill: parent
                        spacing: 12
                        MeguSwitch {
                            steamStyle: true
                            checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["Host_PlayAudio"] : true
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => { root.toggleSteamFriendsSetting("Host_PlayAudio", isChecked); }
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            width: parent.width - 50
                            Text {
                                text: qsTr("Play audio on host")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                    }
                }

                // Dropdown: Display Resolution Limit (Host_DisplayResolutionSetting)
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "transparent"
                    Text {
                        text: qsTr("Display Resolution Limit")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Rectangle {
                        id: hostResolutionDropdown
                        width: 250
                        height: 32
                        radius: 6
                        color: "#05FFFFFF"
                        border.color: Theme.border
                        border.width: 1
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        property int currentVal: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["Host_DisplayResolutionSetting"] || 0 : 0

                        readonly property var options: [
                            { id: 0, label: qsTr("Display Resolution") },
                            { id: 2, label: qsTr("Limit to client resolution") }
                        ]

                        function getLabelForVal(v) {
                            for (var i = 0; i < options.length; i++) {
                                if (options[i].id === v) return options[i].label;
                            }
                            return qsTr("Display Resolution");
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: hostResolutionDropdown.getLabelForVal(hostResolutionDropdown.currentVal)
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                        }
                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: "\u2304"
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: hostResolutionMenu.open()
                            onEntered: hostResolutionDropdown.border.color = Theme.accent
                            onExited: hostResolutionDropdown.border.color = Theme.border
                        }
                        Menu {
                            id: hostResolutionMenu
                            y: hostResolutionDropdown.height + 4
                            width: hostResolutionDropdown.width
                            background: Rectangle {
                                color: Theme.sidebarBg
                                border.color: Theme.border
                                border.width: 1
                                radius: 6
                            }
                            Instantiator {
                                model: hostResolutionDropdown.options
                                onObjectAdded: (index, object) => hostResolutionMenu.insertItem(index, object)
                                onObjectRemoved: (index, object) => hostResolutionMenu.removeItem(object)
                                delegate: MenuItem {
                                    text: modelData.label
                                    width: hostResolutionMenu.width
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
                                        root.toggleSteamFriendsSetting("Host_DisplayResolutionSetting", modelData.id);
                                    }
                                }
                            }
                        }
                    }
                }

                // Switch: Enable NVFBC Capture
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "transparent"
                    Row {
                        anchors.fill: parent
                        spacing: 12
                        MeguSwitch {
                            steamStyle: true
                            checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["Host_EnableCaptureNVFBC"] : true
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => { root.toggleSteamFriendsSetting("Host_EnableCaptureNVFBC", isChecked); }
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            width: parent.width - 50
                            Text {
                                text: qsTr("Enable NVFBC capture on NVIDIA GPU")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                    }
                }

                // Switch: Enable hardware encoding
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "transparent"
                    Row {
                        anchors.fill: parent
                        spacing: 12
                        MeguSwitch {
                            steamStyle: true
                            checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["Host_EnableHardwareEncoding"] : true
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => { root.toggleSteamFriendsSetting("Host_EnableHardwareEncoding", isChecked); }
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            width: parent.width - 50
                            Text {
                                text: qsTr("Enable hardware encoding")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                    }
                }

                // Dropdown: Software encoding threads (Host_SoftwareEncodingThreadCount)
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "transparent"
                    Text {
                        text: qsTr("Number of software encoding threads")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Rectangle {
                        id: hostThreadsDropdown
                        width: 150
                        height: 32
                        radius: 6
                        color: "#05FFFFFF"
                        border.color: Theme.border
                        border.width: 1
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        property int currentVal: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["Host_SoftwareEncodingThreadCount"] !== undefined ? optimizerBackend.steamFriendsSettings["Host_SoftwareEncodingThreadCount"] : -1 : -1

                        readonly property var options: [
                            { id: -1, label: qsTr("Automatic") },
                            { id: 2, label: "2" },
                            { id: 3, label: "3" },
                            { id: 4, label: "4" },
                            { id: 6, label: "6" },
                            { id: 8, label: "8" }
                        ]

                        function getLabelForVal(v) {
                            for (var i = 0; i < options.length; i++) {
                                if (options[i].id === v) return options[i].label;
                            }
                            return qsTr("Automatic");
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: hostThreadsDropdown.getLabelForVal(hostThreadsDropdown.currentVal)
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                        }
                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: "\u2304"
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: hostThreadsMenu.open()
                            onEntered: hostThreadsDropdown.border.color = Theme.accent
                            onExited: hostThreadsDropdown.border.color = Theme.border
                        }
                        Menu {
                            id: hostThreadsMenu
                            y: hostThreadsDropdown.height + 4
                            width: hostThreadsDropdown.width
                            background: Rectangle {
                                color: Theme.sidebarBg
                                border.color: Theme.border
                                border.width: 1
                                radius: 6
                            }
                            Instantiator {
                                model: hostThreadsDropdown.options
                                onObjectAdded: (index, object) => hostThreadsMenu.insertItem(index, object)
                                onObjectRemoved: (index, object) => hostThreadsMenu.removeItem(object)
                                delegate: MenuItem {
                                    text: modelData.label
                                    width: hostThreadsMenu.width
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
                                        root.toggleSteamFriendsSetting("Host_SoftwareEncodingThreadCount", modelData.id);
                                    }
                                }
                            }
                        }
                    }
                }

                // Switch: Prioritize network traffic
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "transparent"
                    Row {
                        anchors.fill: parent
                        spacing: 12
                        MeguSwitch {
                            steamStyle: true
                            checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["Host_EnableTrafficPriority"] : true
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => { root.toggleSteamFriendsSetting("Host_EnableTrafficPriority", isChecked); }
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            width: parent.width - 50
                            Text {
                                text: qsTr("Prioritize network traffic")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
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

            // Header: Optimization
            Text {
                text: qsTr("Optimization")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.0
            }

            // Toggle: Pause music when starting an application
            Rectangle {
                width: parent.width
                height: 64
                color: "transparent"
                Row {
                    anchors.fill: parent
                    spacing: 12
                    MeguSwitch {
                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["PauseOnAppStartedProcess"] : true
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("PauseOnAppStartedProcess", isChecked); }
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        width: parent.width - 50
                        Text {
                            text: qsTr("Pause music when starting an application")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Pause music playback automatically when starting a game or application.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }

            // Toggle: Pause music when voice chatting
            Rectangle {
                width: parent.width
                height: 64
                color: "transparent"
                Row {
                    anchors.fill: parent
                    spacing: 12
                    MeguSwitch {
                        steamStyle: true
                        checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["PauseOnVoiceChat"] : true
                        anchors.verticalCenter: parent.verticalCenter
                        onToggled: (isChecked) => { root.toggleSteamFriendsSetting("PauseOnVoiceChat", isChecked); }
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        width: parent.width - 50
                        Text {
                            text: qsTr("Pause music when voice chatting")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Pause music playback automatically when starting or joining a voice chat.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }

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

            // Header: Customization
            Text {
                text: qsTr("Customization")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.0
            }

            // Volume Slider
            Rectangle {
                width: parent.width
                height: 80
                radius: 8
                color: "#05FFFFFF"
                border.color: Theme.border
                border.width: 1

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    spacing: 8

                    RowLayout {
                        width: parent.width

                        Text {
                            text: qsTr("Volume")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                            Layout.fillWidth: true
                        }

                        Text {
                            text: Math.round(musicVolumeSlider.value)
                            color: Theme.accent
                            font.family: Theme.fontFamily
                            font.pixelSize: 14
                            font.bold: true
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    Slider {
                        id: musicVolumeSlider
                        width: parent.width
                        from: 0
                        to: 100
                        value: optimizerBackend.steamFriendsSettings ? (optimizerBackend.steamFriendsSettings["MusicVolume"] !== undefined ? optimizerBackend.steamFriendsSettings["MusicVolume"] : 10) : 10
                        stepSize: 1
                        live: true
                        onMoved: {
                            root.toggleSteamFriendsSetting("MusicVolume", Math.round(value));
                        }

                        background: Rectangle {
                            x: musicVolumeSlider.leftPadding
                            y: musicVolumeSlider.topPadding + musicVolumeSlider.availableHeight / 2 - height / 2
                            implicitWidth: 200
                            implicitHeight: 4
                            width: musicVolumeSlider.availableWidth
                            height: implicitHeight
                            radius: 2
                            color: Theme.border

                            Rectangle {
                                width: musicVolumeSlider.visualPosition * parent.width
                                height: parent.height
                                color: Theme.accent
                                radius: 2
                            }
                        }

                        handle: Rectangle {
                            x: musicVolumeSlider.leftPadding + musicVolumeSlider.visualPosition * (musicVolumeSlider.availableWidth - width)
                            y: musicVolumeSlider.topPadding + musicVolumeSlider.availableHeight / 2 - height / 2
                            implicitWidth: 16
                            implicitHeight: 16
                            radius: 8
                            color: musicVolumeSlider.pressed ? Theme.accent : Theme.textPrimary
                            border.color: Theme.accent
                            border.width: musicVolumeSlider.hovered ? 2 : 0

                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                            Behavior on scale { NumberAnimation { duration: Theme.animFast } }
                            scale: musicVolumeSlider.pressed ? 1.2 : (musicVolumeSlider.hovered ? 1.1 : 1.0)
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

            // Downloads Header
            Text {
                text: qsTr("Downloads")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 13
                font.bold: true
            }

            // Download Region Dropdown
            Rectangle {
                width: parent.width
                height: 50
                color: "transparent"
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    anchors.left: parent.left
                    anchors.right: regionDropdown.left
                    anchors.rightMargin: 12
                    Text {
                        text: qsTr("Download region")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Select the download region closest to your physical location.")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                }
                Rectangle {
                    id: regionDropdown
                    width: 220
                    height: 32
                    radius: 6
                    color: "#05FFFFFF"
                    border.color: Theme.border
                    border.width: 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    property int currentVal: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["DownloadRegionCellID"] || 0 : 0
                    property var options: []

                    Component.onCompleted: {
                        regionDropdown.options = optimizerBackend.getSteamDownloadRegions();
                    }

                    function getLabelForVal(v) {
                        for (var i = 0; i < options.length; i++) {
                            if (options[i].id === v) return options[i].name;
                        }
                        return qsTr("Default / Auto");
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: regionDropdown.getLabelForVal(regionDropdown.currentVal)
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                    }
                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\u2304"
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: regionMenu.open()
                        onEntered: regionDropdown.border.color = Theme.accent
                        onExited: regionDropdown.border.color = Theme.border
                    }
                    Menu {
                        id: regionMenu
                        y: regionDropdown.height + 4
                        width: regionDropdown.width
                        height: Math.min(300, contentHeight)
                        background: Rectangle {
                            color: Theme.sidebarBg
                            border.color: Theme.border
                            border.width: 1
                            radius: 6
                        }
                        Instantiator {
                            model: regionDropdown.options
                            onObjectAdded: (index, object) => regionMenu.insertItem(index, object)
                            onObjectRemoved: (index, object) => regionMenu.removeItem(object)
                            delegate: MenuItem {
                                text: modelData.name
                                width: regionMenu.width
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
                                    root.toggleSteamFriendsSetting("DownloadRegionCellID", modelData.id);
                                }
                            }
                        }
                    }
                }
            }

            // Limit Download Speed Toggle
            Rectangle {
                width: parent.width
                height: Math.max(50, limitSpeedCol.implicitHeight + 12)
                color: "transparent"
                Column {
                    id: limitSpeedCol
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    anchors.left: parent.left
                    anchors.right: limitSpeedSwitch.left
                    anchors.rightMargin: 12
                    Text {
                        text: qsTr("Limit download speed")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Limit the bandwidth Steam is permitted to use for downloading updates and games.")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                }
                MeguSwitch {
                    id: limitSpeedSwitch
                    anchors.right: parent.right
                    steamStyle: true
                    checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bLimitDownloadSpeed"] : false
                    anchors.verticalCenter: parent.verticalCenter
                    onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bLimitDownloadSpeed", isChecked); }
                }
            }

            // Limit Download Speed Value Input Row
            Rectangle {
                width: parent.width
                height: visible ? 50 : 0
                color: "transparent"
                visible: limitSpeedSwitch.checked

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    anchors.left: parent.left
                    anchors.right: limitInputRow.left
                    anchors.rightMargin: 12
                    Text {
                        text: qsTr("Enter limit in kilobytes per second")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                }

                Row {
                    id: limitInputRow
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    TextField {
                        id: limitSpeedInput
                        width: 130
                        height: 32
                        text: optimizerBackend.steamFriendsSettings ? (optimizerBackend.steamFriendsSettings["nDownloadThrottleKbps"] || 1250) : 1250
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        verticalAlignment: TextInput.AlignVCenter
                        leftPadding: 12
                        rightPadding: 12
                        selectByMouse: true
                        background: Rectangle {
                            color: "#05FFFFFF"
                            border.color: limitSpeedInput.activeFocus ? Theme.accent : Theme.border
                            border.width: 1
                            radius: 6
                        }
                        validator: IntValidator { bottom: 0; top: 99999999 }
                        onEditingFinished: {
                            root.toggleSteamFriendsSetting("nDownloadThrottleKbps", parseInt(text) || 0);
                        }
                    }

                    Text {
                        text: qsTr("KB/s")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // Game Updates Header
            Text {
                text: qsTr("Game Updates")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 13
                font.bold: true
            }

            // Game Update Timing Dropdown
            Rectangle {
                width: parent.width
                height: 50
                color: "transparent"
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    anchors.left: parent.left
                    anchors.right: timingDropdown.left
                    anchors.rightMargin: 12
                    Text {
                        text: qsTr("Game update timing")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("To set exceptions for individual games, go to your Library > Game > Properties.")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                }
                Rectangle {
                    id: timingDropdown
                    width: 220
                    height: 32
                    radius: 6
                    color: "#05FFFFFF"
                    border.color: Theme.border
                    border.width: 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    property int currentVal: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["nGameUpdateTiming"] || 0 : 0

                    readonly property var options: [
                        { id: 0, label: qsTr("Let Steam decide when to update") },
                        { id: 1, label: qsTr("Wait to update until the game is launched") }
                    ]

                    function getLabelForVal(v) {
                        for (var i = 0; i < options.length; i++) {
                            if (options[i].id === v) return options[i].label;
                        }
                        return qsTr("Let Steam decide when to update");
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: timingDropdown.getLabelForVal(timingDropdown.currentVal)
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                    }
                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\u2304"
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: timingMenu.open()
                        onEntered: timingDropdown.border.color = Theme.accent
                        onExited: timingDropdown.border.color = Theme.border
                    }
                    Menu {
                        id: timingMenu
                        y: timingDropdown.height + 4
                        width: timingDropdown.width
                        background: Rectangle {
                            color: Theme.sidebarBg
                            border.color: Theme.border
                            border.width: 1
                            radius: 6
                        }
                        Instantiator {
                            model: timingDropdown.options
                            onObjectAdded: (index, object) => timingMenu.insertItem(index, object)
                            onObjectRemoved: (index, object) => timingMenu.removeItem(object)
                            delegate: MenuItem {
                                text: modelData.label
                                width: timingMenu.width
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
                                    root.toggleSteamFriendsSetting("nGameUpdateTiming", modelData.id);
                                }
                            }
                        }
                    }
                }
            }

            // Schedule Auto-updates Toggle
            Rectangle {
                width: parent.width
                height: visible ? Math.max(50, scheduleCol.implicitHeight + 12) : 0
                color: "transparent"
                visible: timingDropdown.currentVal === 0
                Column {
                    id: scheduleCol
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    anchors.left: parent.left
                    anchors.right: scheduleSwitch.left
                    anchors.rightMargin: 12
                    Text {
                        text: qsTr("Schedule auto-updates")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Only auto-update games during a specific time window.")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                }
                MeguSwitch {
                    id: scheduleSwitch
                    anchors.right: parent.right
                    steamStyle: true
                    checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["bScheduleAutoUpdates"] : false
                    anchors.verticalCenter: parent.verticalCenter
                    onToggled: (isChecked) => { root.toggleSteamFriendsSetting("bScheduleAutoUpdates", isChecked); }
                }
            }

            // Schedule Auto-updates Hours (Restrict updates to between)
            Rectangle {
                width: parent.width
                height: visible ? 50 : 0
                color: "transparent"
                visible: scheduleSwitch.visible && scheduleSwitch.checked

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 12

                    Text {
                        text: qsTr("Restrict updates to between")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Start Hour Dropdown
                    Rectangle {
                        id: startHourDropdown
                        width: 80
                        height: 32
                        radius: 6
                        color: "#05FFFFFF"
                        border.color: Theme.border
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter

                        property int currentVal: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["nAutoUpdateWindowStart"] || 0 : 0

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: startHourDropdown.currentVal + ":00"
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                        }
                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: "\u2304"
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: startHourMenu.open()
                            onEntered: startHourDropdown.border.color = Theme.accent
                            onExited: startHourDropdown.border.color = Theme.border
                        }
                        Menu {
                            id: startHourMenu
                            y: startHourDropdown.height + 4
                            width: startHourDropdown.width
                            height: Math.min(250, contentHeight)
                            background: Rectangle {
                                color: Theme.sidebarBg
                                border.color: Theme.border
                                border.width: 1
                                radius: 6
                            }
                            Instantiator {
                                model: 24
                                onObjectAdded: (index, object) => startHourMenu.insertItem(index, object)
                                onObjectRemoved: (index, object) => startHourMenu.removeItem(object)
                                delegate: MenuItem {
                                    text: modelData + ":00"
                                    width: startHourMenu.width
                                    height: 28
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
                                        root.toggleSteamFriendsSetting("nAutoUpdateWindowStart", modelData);
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        text: qsTr("and")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // End Hour Dropdown
                    Rectangle {
                        id: endHourDropdown
                        width: 80
                        height: 32
                        radius: 6
                        color: "#05FFFFFF"
                        border.color: Theme.border
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter

                        property int currentVal: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["nAutoUpdateWindowEnd"] || 0 : 0

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: endHourDropdown.currentVal + ":00"
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                        }
                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: "\u2304"
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: endHourMenu.open()
                            onEntered: endHourDropdown.border.color = Theme.accent
                            onExited: endHourDropdown.border.color = Theme.border
                        }
                        Menu {
                            id: endHourMenu
                            y: endHourDropdown.height + 4
                            width: endHourDropdown.width
                            height: Math.min(250, contentHeight)
                            background: Rectangle {
                                color: Theme.sidebarBg
                                border.color: Theme.border
                                border.width: 1
                                radius: 6
                            }
                            Instantiator {
                                model: 24
                                onObjectAdded: (index, object) => endHourMenu.insertItem(index, object)
                                onObjectRemoved: (index, object) => endHourMenu.removeItem(object)
                                delegate: MenuItem {
                                    text: modelData + ":00"
                                    width: endHourMenu.width
                                    height: 28
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
                                        root.toggleSteamFriendsSetting("nAutoUpdateWindowEnd", modelData);
                                    }
                                }
                            }
                        }
                    }
                }
            }

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

            // Allow transfers from this device to dropdown
            Rectangle {
                width: parent.width
                height: 50
                color: "transparent"
                visible: steamToggleSwitch_46.checked
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    anchors.left: parent.left
                    anchors.right: transferDropdown.left
                    anchors.rightMargin: 12
                    Text {
                        text: qsTr("Allow transfers from this device to")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Allow other users on your local network to download game files from this PC.")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                }
                Rectangle {
                    id: transferDropdown
                    width: 180
                    height: 32
                    radius: 6
                    color: "#05FFFFFF"
                    border.color: Theme.border
                    border.width: 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    property int currentVal: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["nTransferFilterMode"] || 3 : 3

                    readonly property var options: [
                        { id: 1, label: qsTr("Only me") },
                        { id: 2, label: qsTr("Friends") },
                        { id: 3, label: qsTr("Anyone") }
                    ]

                    function getLabelForVal(v) {
                        for (var i = 0; i < options.length; i++) {
                            if (options[i].id === v) return options[i].label;
                        }
                        return qsTr("Anyone");
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: transferDropdown.getLabelForVal(transferDropdown.currentVal)
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                    }
                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\u2304"
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: transferMenu.open()
                        onEntered: transferDropdown.border.color = Theme.accent
                        onExited: transferDropdown.border.color = Theme.border
                    }
                    Menu {
                        id: transferMenu
                        y: transferDropdown.height + 4
                        width: transferDropdown.width
                        background: Rectangle {
                            color: Theme.sidebarBg
                            border.color: Theme.border
                            border.width: 1
                            radius: 6
                        }
                        Instantiator {
                            model: transferDropdown.options
                            onObjectAdded: (index, object) => transferMenu.insertItem(index, object)
                            onObjectRemoved: (index, object) => transferMenu.removeItem(object)
                            delegate: MenuItem {
                                text: modelData.label
                                width: transferMenu.width
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
                                    root.toggleSteamFriendsSetting("nTransferFilterMode", modelData.id);
                                }
                            }
                        }
                    }
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

        property int selectedLibraryIndex: 0

        property var driveInfo: (optimizerBackend.steamLibraryPaths && selectedLibraryIndex < optimizerBackend.steamLibraryPaths.length) ? optimizerBackend.steamLibraryPaths[selectedLibraryIndex] : null
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

        onSelectedLibraryIndexChanged: {
            populateGamesModel();
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

        // Drive selection box (interactive dropdown)
        Rectangle {
            id: driveSelectDropdown
            width: parent.width
            height: 40
            color: "#161920"
            border.color: driveSelectMouse.containsMouse ? Theme.accent : Theme.border
            border.width: 1
            radius: Theme.radiusSmall

            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

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

                    Text {
                        text: "⌵"
                        color: Theme.textSecondary
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

            MouseArea {
                id: driveSelectMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    driveMenu.open();
                }
            }

            Menu {
                id: driveMenu
                y: driveSelectDropdown.height + 4
                width: driveSelectDropdown.width
                
                background: Rectangle {
                    color: Theme.sidebarBg
                    border.color: Theme.border
                    border.width: 1
                    radius: 6
                }

                Instantiator {
                    model: optimizerBackend.steamLibraryPaths
                    onObjectAdded: (index, object) => driveMenu.insertItem(index, object)
                    onObjectRemoved: (index, object) => driveMenu.removeItem(object)

                    delegate: MenuItem {
                        text: {
                            var name = modelData.name ? modelData.name : qsTr("Local Disk");
                            var letter = modelData.letter ? modelData.letter : "C";
                            var free = modelData.freeSize ? modelData.freeSize.toFixed(1) : "0.0";
                            var total = modelData.totalSize ? modelData.totalSize.toFixed(1) : "0.0";
                            return name + " (" + letter + ":)   -   " + free + " GB Free / " + total + " GB Total";
                        }
                        width: driveMenu.width
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
                            steamStoragePage.selectedLibraryIndex = index;
                        }
                    }
                }
            }
        }

        // Plain Text Path
        Text {
            text: (steamStoragePage.driveInfo && steamStoragePage.driveInfo.path ? steamStoragePage.driveInfo.path : optimizerBackend.steamPath).toUpperCase()
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

    // PAGE 15: Broadcasting Sub-Page
    Column {
        id: steamBroadcastPage
        width: parent.width
        spacing: 20
        visible: steamSettingsDrawer.subPage === "broadcast"

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
                text: qsTr("Broadcast customization")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 16
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Global Overlay Disabled Warning
        Rectangle {
            width: parent.width
            height: warningRow.implicitHeight + 20
            radius: Theme.radiusSmall
            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.05)
            border.color: Theme.accent
            border.width: 1
            visible: !optimizerBackend.steamOverlayActive

            Row {
                id: warningRow
                anchors.fill: parent
                anchors.margins: 10
                spacing: 12

                Item {
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    Image {
                        id: warnImg
                        source: "qrc:/MeguPackOptimizer/src/resources/warning.svg"
                        anchors.fill: parent
                        sourceSize.width: 24
                        sourceSize.height: 24
                        visible: false
                    }
                    ColorOverlay {
                        anchors.fill: warnImg
                        source: warnImg
                        color: Theme.accent
                    }
                }

                Text {
                    text: qsTr("Steam Overlay is globally disabled. Broadcasting settings are locked until it is enabled.")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    width: parent.width - 80
                    wrapMode: Text.WordWrap
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item {
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    Image {
                        id: eyeImg
                        source: "qrc:/MeguPackOptimizer/src/resources/eye.svg"
                        anchors.fill: parent
                        sourceSize.width: 24
                        sourceSize.height: 24
                        visible: false
                    }
                    ColorOverlay {
                        anchors.fill: eyeImg
                        source: eyeImg
                        color: eyeMouse.containsMouse ? Theme.accent : Theme.textSecondary
                    }
                    MouseArea {
                        id: eyeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            steamSettingsDrawer.subPage = "ingame"
                        }
                    }
                }
            }
        }

        // Settings items
        Column {
            width: parent.width
            spacing: 12
            enabled: optimizerBackend.steamOverlayActive
            opacity: enabled ? 1.0 : 0.4

            Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }

            // 1. Privacy setting (Permissions)
            Rectangle {
                width: parent.width
                height: 50
                color: "transparent"

                Text {
                    text: qsTr("Privacy setting")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    id: privacyDropdown
                    width: 250
                    height: 32
                    radius: 6
                    color: "#05FFFFFF"
                    border.color: Theme.border
                    border.width: 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    property int currentVal: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["BroadcastPermissions"] !== undefined ? optimizerBackend.steamFriendsSettings["BroadcastPermissions"] : 1 : 1

                    readonly property var options: [
                        { id: 0, label: qsTr("Broadcasting disabled") },
                        { id: 1, label: qsTr("Friends can request to watch my games") },
                        { id: 2, label: qsTr("Friends can watch my games") },
                        { id: 3, label: qsTr("Anyone can watch my games") }
                    ]

                    function getLabelForVal(v) {
                        for (var i = 0; i < options.length; i++) {
                            if (options[i].id === v) return options[i].label;
                        }
                        return qsTr("Friends can request to watch my games");
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: privacyDropdown.getLabelForVal(privacyDropdown.currentVal)
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
                        onClicked: privacyMenu.open()
                        onEntered: privacyDropdown.border.color = Theme.accent
                        onExited: privacyDropdown.border.color = Theme.border
                    }

                    Menu {
                        id: privacyMenu
                        y: privacyDropdown.height + 4
                        width: privacyDropdown.width
                        background: Rectangle {
                            color: Theme.sidebarBg
                            border.color: Theme.border
                            border.width: 1
                            radius: 6
                        }
                        Instantiator {
                            model: privacyDropdown.options
                            onObjectAdded: (index, object) => privacyMenu.insertItem(index, object)
                            onObjectRemoved: (index, object) => privacyMenu.removeItem(object)
                            delegate: MenuItem {
                                text: modelData.label
                                width: privacyMenu.width
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
                                    root.toggleSteamFriendsSetting("BroadcastPermissions", modelData.id);
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

            // Always show Live status (Visible only when Anyone can watch my games, i.e., BroadcastPermissions = 3)
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_b1.implicitHeight + 12)
                color: "transparent"
                visible: (optimizerBackend.steamFriendsSettings && optimizerBackend.steamFriendsSettings["BroadcastPermissions"] === 3)

                Column {
                    id: steamToggleCol_b1
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    anchors.left: parent.left
                    anchors.right: steamToggleSwitch_b1.left
                    anchors.rightMargin: 12
                    Text {
                        text: qsTr("Always show Live status")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                }

                MeguSwitch {
                    id: steamToggleSwitch_b1
                    anchors.right: parent.right
                    steamStyle: true
                    checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["BroadcastShowReminder"] : false
                    anchors.verticalCenter: parent.verticalCenter
                    onToggled: (isChecked) => { root.toggleSteamFriendsSetting("BroadcastShowReminder", isChecked); }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
                visible: (optimizerBackend.steamFriendsSettings && optimizerBackend.steamFriendsSettings["BroadcastPermissions"] === 3)
            }

            // 2. Video Dimensions
            Rectangle {
                width: parent.width
                height: 50
                color: "transparent"

                Text {
                    text: qsTr("Video Dimensions")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    id: dimsDropdown
                    width: 250
                    height: 32
                    radius: 6
                    color: "#05FFFFFF"
                    border.color: Theme.border
                    border.width: 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    property int currentW: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["BroadcastOutputWidth"] !== undefined ? optimizerBackend.steamFriendsSettings["BroadcastOutputWidth"] : 854 : 854
                    property int currentH: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["BroadcastOutputHeight"] !== undefined ? optimizerBackend.steamFriendsSettings["BroadcastOutputHeight"] : 480 : 480

                    readonly property var options: [
                        { w: 1920, h: 1080, label: qsTr("1920x1080 (1080p)") },
                        { w: 1280, h: 720, label: qsTr("1280x720 (720p)") },
                        { w: 854, h: 480, label: qsTr("854x480 (480p)") },
                        { w: 640, h: 360, label: qsTr("640x360 (360p)") }
                    ]

                    function getLabelForVal(w, h) {
                        for (var i = 0; i < options.length; i++) {
                            if (options[i].w === w && options[i].h === h) return options[i].label;
                        }
                        return w + "x" + h;
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: dimsDropdown.getLabelForVal(dimsDropdown.currentW, dimsDropdown.currentH)
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
                        onClicked: dimsMenu.open()
                        onEntered: dimsDropdown.border.color = Theme.accent
                        onExited: dimsDropdown.border.color = Theme.border
                    }

                    Menu {
                        id: dimsMenu
                        y: dimsDropdown.height + 4
                        width: dimsDropdown.width
                        background: Rectangle {
                            color: Theme.sidebarBg
                            border.color: Theme.border
                            border.width: 1
                            radius: 6
                        }
                        Instantiator {
                            model: dimsDropdown.options
                            onObjectAdded: (index, object) => dimsMenu.insertItem(index, object)
                            onObjectRemoved: (index, object) => dimsMenu.removeItem(object)
                            delegate: MenuItem {
                                text: modelData.label
                                width: dimsMenu.width
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
                                    root.toggleSteamFriendsSetting("BroadcastOutputWidth", modelData.w);
                                    root.toggleSteamFriendsSetting("BroadcastOutputHeight", modelData.h);
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

            // 3. Maximum Bitrate
            Rectangle {
                width: parent.width
                height: 50
                color: "transparent"

                Text {
                    text: qsTr("Maximum Bitrate")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    id: bitrateDropdown
                    width: 250
                    height: 32
                    radius: 6
                    color: "#05FFFFFF"
                    border.color: Theme.border
                    border.width: 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    property int currentVal: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["BroadcastMaxKbps"] !== undefined ? optimizerBackend.steamFriendsSettings["BroadcastMaxKbps"] : 1000 : 1000

                    readonly property var options: [
                        { id: 3500, label: qsTr("3500 Kbps") },
                        { id: 3000, label: qsTr("3000 Kbps") },
                        { id: 2500, label: qsTr("2500 Kbps") },
                        { id: 2000, label: qsTr("2000 Kbps") },
                        { id: 1500, label: qsTr("1500 Kbps") },
                        { id: 1000, label: qsTr("1000 Kbps") },
                        { id: 750, label: qsTr("750 Kbps") }
                    ]

                    function getLabelForVal(v) {
                        for (var i = 0; i < options.length; i++) {
                            if (options[i].id === v) return options[i].label;
                        }
                        return v + " Kbps";
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: bitrateDropdown.getLabelForVal(bitrateDropdown.currentVal)
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
                        onClicked: bitrateMenu.open()
                        onEntered: bitrateDropdown.border.color = Theme.accent
                        onExited: bitrateDropdown.border.color = Theme.border
                    }

                    Menu {
                        id: bitrateMenu
                        y: bitrateDropdown.height + 4
                        width: bitrateDropdown.width
                        background: Rectangle {
                            color: Theme.sidebarBg
                            border.color: Theme.border
                            border.width: 1
                            radius: 6
                        }
                        Instantiator {
                            model: bitrateDropdown.options
                            onObjectAdded: (index, object) => bitrateMenu.insertItem(index, object)
                            onObjectRemoved: (index, object) => bitrateMenu.removeItem(object)
                            delegate: MenuItem {
                                text: modelData.label
                                width: bitrateMenu.width
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
                                    root.toggleSteamFriendsSetting("BroadcastMaxKbps", modelData.id);
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

            // 4. Optimize encoding for
            Rectangle {
                width: parent.width
                height: 50
                color: "transparent"

                Text {
                    text: qsTr("Optimize encoding for")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    id: encoderDropdown
                    width: 250
                    height: 32
                    radius: 6
                    color: "#05FFFFFF"
                    border.color: Theme.border
                    border.width: 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    property int currentVal: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["BroadcastEncoderSetting"] !== undefined ? optimizerBackend.steamFriendsSettings["BroadcastEncoderSetting"] : 0 : 0

                    readonly property var options: [
                        { id: 0, label: qsTr("Best Quality") },
                        { id: 1, label: qsTr("Best Performance") }
                    ]

                    function getLabelForVal(v) {
                        for (var i = 0; i < options.length; i++) {
                            if (options[i].id === v) return options[i].label;
                        }
                        return qsTr("Best Quality");
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: encoderDropdown.getLabelForVal(encoderDropdown.currentVal)
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
                        onClicked: encoderMenu.open()
                        onEntered: encoderDropdown.border.color = Theme.accent
                        onExited: encoderDropdown.border.color = Theme.border
                    }

                    Menu {
                        id: encoderMenu
                        y: encoderDropdown.height + 4
                        width: encoderDropdown.width
                        background: Rectangle {
                            color: Theme.sidebarBg
                            border.color: Theme.border
                            border.width: 1
                            radius: 6
                        }
                        Instantiator {
                            model: encoderDropdown.options
                            onObjectAdded: (index, object) => encoderMenu.insertItem(index, object)
                            onObjectRemoved: (index, object) => encoderMenu.removeItem(object)
                            delegate: MenuItem {
                                text: modelData.label
                                width: encoderMenu.width
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
                                    root.toggleSteamFriendsSetting("BroadcastEncoderSetting", modelData.id);
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

            // 5. Show viewers' chat in game
            Rectangle {
                width: parent.width
                height: 50
                color: "transparent"

                Text {
                    text: qsTr("Show viewers' chat in game")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    id: showChatDropdown
                    width: 250
                    height: 32
                    radius: 6
                    color: "#05FFFFFF"
                    border.color: Theme.border
                    border.width: 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    property int currentVal: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["BroadcastShowChat"] !== undefined ? optimizerBackend.steamFriendsSettings["BroadcastShowChat"] : 3 : 3

                    readonly property var options: [
                        { id: 0, label: qsTr("Off") },
                        { id: 1, label: qsTr("Top-left") },
                        { id: 2, label: qsTr("Top-center") },
                        { id: 3, label: qsTr("Top-right") },
                        { id: 4, label: qsTr("Bottom-right") },
                        { id: 5, label: qsTr("Bottom-center") },
                        { id: 6, label: qsTr("Bottom-left") }
                    ]

                    function getLabelForVal(v) {
                        for (var i = 0; i < options.length; i++) {
                            if (options[i].id === v) return options[i].label;
                        }
                        return qsTr("Top-right");
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: showChatDropdown.getLabelForVal(showChatDropdown.currentVal)
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
                        onClicked: showChatMenu.open()
                        onEntered: showChatDropdown.border.color = Theme.accent
                        onExited: showChatDropdown.border.color = Theme.border
                    }

                    Menu {
                        id: showChatMenu
                        y: showChatDropdown.height + 4
                        width: showChatDropdown.width
                        background: Rectangle {
                            color: Theme.sidebarBg
                            border.color: Theme.border
                            border.width: 1
                            radius: 6
                        }
                        Instantiator {
                            model: showChatDropdown.options
                            onObjectAdded: (index, object) => showChatMenu.insertItem(index, object)
                            onObjectRemoved: (index, object) => showChatMenu.removeItem(object)
                            delegate: MenuItem {
                                text: modelData.label
                                width: showChatMenu.width
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
                                    root.toggleSteamFriendsSetting("BroadcastShowChat", modelData.id);
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

            // Toggles
            // Toggle 1: Record video from all applications on this machine
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_b2.implicitHeight + 12)
                color: "transparent"

                Column {
                    id: steamToggleCol_b2
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    anchors.left: parent.left
                    anchors.right: steamToggleSwitch_b2.left
                    anchors.rightMargin: 12
                    Text {
                        text: qsTr("Record video from all applications on this machine")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                }

                MeguSwitch {
                    id: steamToggleSwitch_b2
                    anchors.right: parent.right
                    steamStyle: true
                    checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["BroadcastIncludeDesktop"] : false
                    anchors.verticalCenter: parent.verticalCenter
                    onToggled: (isChecked) => { root.toggleSteamFriendsSetting("BroadcastIncludeDesktop", isChecked); }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
            }

            // Toggle 2: Record audio from all applications on this machine
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_b3.implicitHeight + 12)
                color: "transparent"

                Column {
                    id: steamToggleCol_b3
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    anchors.left: parent.left
                    anchors.right: steamToggleSwitch_b3.left
                    anchors.rightMargin: 12
                    Text {
                        text: qsTr("Record audio from all applications on this machine")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                }

                MeguSwitch {
                    id: steamToggleSwitch_b3
                    anchors.right: parent.right
                    steamStyle: true
                    checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["BroadcastRecordSystemAudio"] : false
                    anchors.verticalCenter: parent.verticalCenter
                    onToggled: (isChecked) => { root.toggleSteamFriendsSetting("BroadcastRecordSystemAudio", isChecked); }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
            }

            // Toggle 3: Record my microphone
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_b4.implicitHeight + 12)
                color: "transparent"

                Column {
                    id: steamToggleCol_b4
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    anchors.left: parent.left
                    anchors.right: steamToggleSwitch_b4.left
                    anchors.rightMargin: 12
                    Text {
                        text: qsTr("Record my microphone")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                }

                MeguSwitch {
                    id: steamToggleSwitch_b4
                    anchors.right: parent.right
                    steamStyle: true
                    checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["BroadcastRecordMic"] : false
                    anchors.verticalCenter: parent.verticalCenter
                    onToggled: (isChecked) => { root.toggleSteamFriendsSetting("BroadcastRecordMic", isChecked); }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
            }

            // Toggle 4: Show upload stats
            Rectangle {
                width: parent.width
                height: Math.max(50, steamToggleCol_b5.implicitHeight + 12)
                color: "transparent"

                Column {
                    id: steamToggleCol_b5
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    anchors.left: parent.left
                    anchors.right: steamToggleSwitch_b5.left
                    anchors.rightMargin: 12
                    Text {
                        text: qsTr("Show upload stats")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                }

                MeguSwitch {
                    id: steamToggleSwitch_b5
                    anchors.right: parent.right
                    steamStyle: true
                    checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["BroadcastShowDebugInfo"] : false
                    anchors.verticalCenter: parent.verticalCenter
                    onToggled: (isChecked) => { root.toggleSteamFriendsSetting("BroadcastShowDebugInfo", isChecked); }
                }
            }
        }

        // Bottom Optimization Recommendation Warning
        Rectangle {
            width: parent.width
            height: optWarningRow.implicitHeight + 20
            radius: Theme.radiusSmall
            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.03)
            border.color: Theme.border
            border.width: 1
            visible: optimizerBackend.steamOverlayActive

            Row {
                id: optWarningRow
                anchors.fill: parent
                anchors.margins: 10
                spacing: 12

                Item {
                    width: 20
                    height: 20
                    anchors.verticalCenter: parent.verticalCenter
                    Image {
                        id: infoImg
                        source: "qrc:/MeguPackOptimizer/src/resources/info.svg"
                        anchors.fill: parent
                        sourceSize.width: 20
                        sourceSize.height: 20
                        visible: false
                    }
                    ColorOverlay {
                        anchors.fill: infoImg
                        source: infoImg
                        color: Theme.accent
                    }
                }

                Text {
                    text: qsTr("Recommended to turn off for optimization. To do this, turn off the Steam Overlay.")
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    width: parent.width - 76
                    wrapMode: Text.WordWrap
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item {
                    width: 20
                    height: 20
                    anchors.verticalCenter: parent.verticalCenter
                    Image {
                        id: optEyeImg
                        source: "qrc:/MeguPackOptimizer/src/resources/eye.svg"
                        anchors.fill: parent
                        sourceSize.width: 20
                        sourceSize.height: 20
                        visible: false
                    }
                    ColorOverlay {
                        anchors.fill: optEyeImg
                        source: optEyeImg
                        color: optEyeMouse.containsMouse ? Theme.accent : Theme.textSecondary
                    }
                    MouseArea {
                        id: optEyeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            steamSettingsDrawer.subPage = "ingame"
                        }
                    }
                }
            }
        }
    }

    // PAGE 16: Controller Customization Sub-Page
    Column {
        id: steamControllerPage
        width: parent.width
        spacing: 20
        visible: steamSettingsDrawer.subPage === "controller"

        property var connectedGamepadsList: []

        function refreshControllers() {
            connectedGamepadsList = optimizerBackend.getConnectedGamepads();
        }

        onVisibleChanged: {
            if (visible) {
                refreshControllers();
            }
        }

        Timer {
            id: controllerRefreshTimer
            interval: 3000
            running: steamSettingsDrawer.subPage === "controller" && steamSettingsDrawer.opened
            repeat: true
            onTriggered: {
                steamControllerPage.refreshControllers();
            }
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
                text: qsTr("Controller customization")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 16
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Row {
            spacing: 10
            width: parent.width
            Text {
                text: qsTr("EXTERNAL GAMEPAD SETTINGS")
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

            // Dropdown: Idle Gamepad Shutdown Timeout
            Rectangle {
                width: parent.width
                height: 50
                color: "transparent"
                Column {
                    id: timeoutCol
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    anchors.left: parent.left
                    anchors.right: timeoutDropdown.left
                    anchors.rightMargin: 12
                    Text {
                        text: qsTr("Idle Gamepad Shutdown Timeout")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Automatically turn off controllers after a period of inactivity.")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                }
                Rectangle {
                    id: timeoutDropdown
                    width: 150
                    height: 32
                    radius: 6
                    color: "#05FFFFFF"
                    border.color: Theme.border
                    border.width: 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    property string currentVal: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["Controller_Timeout"] || "15" : "15"

                    readonly property var options: [
                        { id: "0", label: qsTr("Never") },
                        { id: "5", label: qsTr("5 Minutes") },
                        { id: "10", label: qsTr("10 Minutes") },
                        { id: "15", label: qsTr("15 Minutes") },
                        { id: "30", label: qsTr("30 Minutes") },
                        { id: "60", label: qsTr("1 Hour") }
                    ]

                    function getLabelForVal(v) {
                        for (var i = 0; i < options.length; i++) {
                            if (options[i].id === v) return options[i].label;
                        }
                        return qsTr("15 Minutes");
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: timeoutDropdown.getLabelForVal(timeoutDropdown.currentVal)
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                    }
                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\u2304"
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: timeoutMenu.open()
                        onEntered: timeoutDropdown.border.color = Theme.accent
                        onExited: timeoutDropdown.border.color = Theme.border
                    }
                    Menu {
                        id: timeoutMenu
                        y: timeoutDropdown.height + 4
                        width: timeoutDropdown.width
                        background: Rectangle {
                            color: Theme.sidebarBg
                            border.color: Theme.border
                            border.width: 1
                            radius: 6
                        }
                        Instantiator {
                            model: timeoutDropdown.options
                            onObjectAdded: (index, object) => timeoutMenu.insertItem(index, object)
                            onObjectRemoved: (index, object) => timeoutMenu.removeItem(object)
                            delegate: MenuItem {
                                text: modelData.label
                                width: timeoutMenu.width
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
                                    root.toggleSteamFriendsSetting("Controller_Timeout", modelData.id);
                                }
                            }
                        }
                    }
                }
            }

            // Xbox
            Rectangle {
                width: parent.width
                height: Math.max(50, xboxCol.implicitHeight + 12)
                color: "transparent"
                Column {
                    id: xboxCol
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    anchors.left: parent.left
                    anchors.right: xboxSwitch.left
                    anchors.rightMargin: 12
                    Text {
                        text: qsTr("Xbox Controller Support")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Enable Steam Input for Xbox controllers to configure mappings and options.")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                }
                MeguSwitch {
                    id: xboxSwitch
                    anchors.right: parent.right
                    steamStyle: true
                    checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["Controller_XBoxSupport"] : false
                    anchors.verticalCenter: parent.verticalCenter
                    onToggled: (isChecked) => { root.toggleSteamFriendsSetting("Controller_XBoxSupport", isChecked); }
                }
            }

            // PlayStation
            Rectangle {
                width: parent.width
                height: 50
                color: "transparent"
                Column {
                    id: psCol
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    anchors.left: parent.left
                    anchors.right: psDropdown.left
                    anchors.rightMargin: 12
                    Text {
                        text: qsTr("PlayStation Controller Support")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Enable Steam Input for PlayStation controllers to customize buttons and lightbars.")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                }
                Rectangle {
                    id: psDropdown
                    width: 180
                    height: 32
                    radius: 6
                    color: "#05FFFFFF"
                    border.color: Theme.border
                    border.width: 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    property string currentVal: optimizerBackend.steamFriendsSettings ? optimizerBackend.steamFriendsSettings["Controller_PSSupport"] || "1" : "1"

                    readonly property var options: [
                        { id: "0", label: qsTr("Disabled") },
                        { id: "1", label: qsTr("Enabled in Games w/o Support") },
                        { id: "2", label: qsTr("Enabled") }
                    ]

                    function getLabelForVal(v) {
                        for (var i = 0; i < options.length; i++) {
                            if (options[i].id === v) return options[i].label;
                        }
                        return qsTr("Enabled in Games w/o Support");
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: psDropdown.getLabelForVal(psDropdown.currentVal)
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                    }
                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\u2304"
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: psMenu.open()
                        onEntered: psDropdown.border.color = Theme.accent
                        onExited: psDropdown.border.color = Theme.border
                    }
                    Menu {
                        id: psMenu
                        y: psDropdown.height + 4
                        width: psDropdown.width
                        background: Rectangle {
                            color: Theme.sidebarBg
                            border.color: Theme.border
                            border.width: 1
                            radius: 6
                        }
                        Instantiator {
                            model: psDropdown.options
                            onObjectAdded: (index, object) => psMenu.insertItem(index, object)
                            onObjectRemoved: (index, object) => psMenu.removeItem(object)
                            delegate: MenuItem {
                                text: modelData.label
                                width: psMenu.width
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
                                    root.toggleSteamFriendsSetting("Controller_PSSupport", modelData.id);
                                }
                            }
                        }
                    }
                }
            }

            // Switch Pro
            Rectangle {
                width: parent.width
                height: Math.max(50, switchCol.implicitHeight + 12)
                color: "transparent"
                Column {
                    id: switchCol
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    anchors.left: parent.left
                    anchors.right: switchSwitch.left
                    anchors.rightMargin: 12
                    Text {
                        text: qsTr("Switch Pro Controller Support")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Enable Steam Input for Nintendo Switch Pro controllers.")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                }
                MeguSwitch {
                    id: switchSwitch
                    anchors.right: parent.right
                    steamStyle: true
                    checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["Controller_SwitchSupport"] : false
                    anchors.verticalCenter: parent.verticalCenter
                    onToggled: (isChecked) => { root.toggleSteamFriendsSetting("Controller_SwitchSupport", isChecked); }
                }
            }

            // Generic Controller
            Rectangle {
                width: parent.width
                height: Math.max(50, genericCol.implicitHeight + 12)
                color: "transparent"
                Column {
                    id: genericCol
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    anchors.left: parent.left
                    anchors.right: genericSwitch.left
                    anchors.rightMargin: 12
                    Text {
                        text: qsTr("Enable Steam Input for generic controllers")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Enable Steam Input for generic/directinput gamepads.")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                }
                MeguSwitch {
                    id: genericSwitch
                    anchors.right: parent.right
                    steamStyle: true
                    checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["Controller_GenericSupport"] : false
                    anchors.verticalCenter: parent.verticalCenter
                    onToggled: (isChecked) => { root.toggleSteamFriendsSetting("Controller_GenericSupport", isChecked); }
                }
            }

            // Turn off controllers when exiting Big Picture Mode
            Rectangle {
                width: parent.width
                height: Math.max(50, turnOffBPCol.implicitHeight + 12)
                color: "transparent"
                Column {
                    id: turnOffBPCol
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    anchors.left: parent.left
                    anchors.right: turnOffBPSwitch.left
                    anchors.rightMargin: 12
                    Text {
                        text: qsTr("Turn off controllers when exiting Big Picture Mode")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Automatically shut down wireless gamepads when exiting Big Picture Mode.")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                }
                MeguSwitch {
                    id: turnOffBPSwitch
                    anchors.right: parent.right
                    steamStyle: true
                    checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["Controller_TurnOffBigPicture"] : false
                    anchors.verticalCenter: parent.verticalCenter
                    onToggled: (isChecked) => { root.toggleSteamFriendsSetting("Controller_TurnOffBigPicture", isChecked); }
                }
            }


        }

        Row {
            spacing: 10
            width: parent.width
            Text {
                text: qsTr("GENERAL CONTROLLER SETTINGS")
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

            // Guide Button focuses Steam
            Rectangle {
                width: parent.width
                height: Math.max(50, guideCol.implicitHeight + 12)
                color: "transparent"
                Column {
                    id: guideCol
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    anchors.left: parent.left
                    anchors.right: guideSwitch.left
                    anchors.rightMargin: 12
                    Text {
                        text: qsTr("Guide button focuses Steam")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Pressing the controller Guide button will bring Steam window to the front.")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                }
                MeguSwitch {
                    id: guideSwitch
                    anchors.right: parent.right
                    steamStyle: true
                    checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["Controller_GuideButton"] : false
                    anchors.verticalCenter: parent.verticalCenter
                    onToggled: (isChecked) => { root.toggleSteamFriendsSetting("Controller_GuideButton", isChecked); }
                }
            }

            // Guide Button Chord Configuration
            Rectangle {
                width: parent.width
                height: Math.max(50, chordCol.implicitHeight + 12)
                color: "transparent"
                Column {
                    id: chordCol
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    anchors.left: parent.left
                    anchors.right: chordSwitch.left
                    anchors.rightMargin: 12
                    Text {
                        text: qsTr("Guide Button Chord Configuration")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Enable custom combinations using the controller Guide button.")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                }
                MeguSwitch {
                    id: chordSwitch
                    anchors.right: parent.right
                    steamStyle: true
                    checked: optimizerBackend.steamFriendsSettings ? !!optimizerBackend.steamFriendsSettings["Controller_EnableChord"] : false
                    anchors.verticalCenter: parent.verticalCenter
                    onToggled: (isChecked) => { root.toggleSteamFriendsSetting("Controller_EnableChord", isChecked); }
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
            }

            // Section Header: Connected Controllers
            Item {
                width: parent.width
                height: 24
                
                Text {
                    text: qsTr("CONNECTED CONTROLLERS")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    font.bold: true
                    font.letterSpacing: 1.5
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                MeguButton {
                    text: qsTr("Scan")
                    width: 70
                    height: 24
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: steamControllerPage.refreshControllers()
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
            }

            // List of connected controllers
            Column {
                width: parent.width
                spacing: 12

                Text {
                    text: qsTr("No connected controllers found.")
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    visible: steamControllerPage.connectedGamepadsList.length === 0
                }

                Repeater {
                    model: steamControllerPage.connectedGamepadsList
                    delegate: Rectangle {
                        width: parent.width
                        height: 50
                        radius: Theme.radiusSmall
                        color: "#05FFFFFF"
                        border.color: Theme.border
                        border.width: 1

                        // Gamepad Icon (Canvas)
                        Item {
                            id: gamepadIconContainer
                            width: 24
                            height: 24
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter

                            Canvas {
                                id: gamepadCanvas
                                anchors.centerIn: parent
                                width: 22
                                height: 14
                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.reset();
                                    ctx.strokeStyle = modelData.isConnected ? Theme.accent : Theme.textSecondary;
                                    ctx.lineWidth = 1.5;
                                    
                                    // Draw the gamepad body (rounded capsule shape with left/right ears)
                                    ctx.beginPath();
                                    ctx.arc(6, 7, 5, Math.PI * 0.5, Math.PI * 1.5);
                                    ctx.lineTo(16, 2);
                                    ctx.arc(16, 7, 5, Math.PI * 1.5, Math.PI * 0.5);
                                    ctx.lineTo(6, 12);
                                    ctx.closePath();
                                    ctx.stroke();

                                    // D-Pad (cross on the left)
                                    ctx.fillStyle = modelData.isConnected ? Theme.accent : Theme.textSecondary;
                                    ctx.fillRect(4, 6, 4, 2);
                                    ctx.fillRect(5, 5, 2, 4);

                                    // Action Buttons (dots on the right)
                                    ctx.beginPath();
                                    ctx.arc(15, 6, 0.7, 0, Math.PI * 2);
                                    ctx.arc(17, 7, 0.7, 0, Math.PI * 2);
                                    ctx.arc(15, 8, 0.7, 0, Math.PI * 2);
                                    ctx.arc(13, 7, 0.7, 0, Math.PI * 2);
                                    ctx.fill();
                                }
                                onWidthChanged: requestPaint()
                            }
                        }

                        // Controller Name and Info
                        Column {
                            id: infoColumn
                            anchors.left: gamepadIconContainer.right
                            anchors.leftMargin: 12
                            anchors.right: forgetBtn.left
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: modelData.name
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                                elide: Text.ElideRight
                                width: parent.width
                            }

                            Text {
                                text: {
                                    var conn = modelData.isBluetooth ? qsTr("Bluetooth") : qsTr("USB");
                                    var status = modelData.isConnected ? qsTr("Connected") : qsTr("Paired (Offline)");
                                    var details = modelData.vidPid ? " (" + modelData.vidPid + ")" : "";
                                    return conn + " • " + status + details;
                                }
                                color: Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                elide: Text.ElideRight
                                width: parent.width
                            }
                        }

                        // Forget / Delete Button
                        MeguButton {
                            id: forgetBtn
                            text: qsTr("Forget")
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            width: 80
                            height: 28
                            onClicked: {
                                var res = optimizerBackend.forgetGamepad(modelData.id, modelData.btAddress, modelData.vidPid);
                                if (res) {
                                    steamControllerPage.refreshControllers();
                                }
                            }
                        }
                    }
                }
            }
        }
    }

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

    // (Removed pairSteamLinkDialog)

    Item {
        id: hotkeyGrabber
        anchors.fill: parent
        visible: steamGameRecordingPage.recordingKeyName !== ""
        focus: visible

        onVisibleChanged: {
            if (visible) {
                forceActiveFocus();
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            preventStealing: true
            onClicked: steamGameRecordingPage.recordingKeyName = ""
        }

        Rectangle {
            anchors.fill: parent
            color: "#B0000000"
            
            Column {
                anchors.centerIn: parent
                spacing: 12
                
                Text {
                    text: qsTr("Press a key combination...")
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 16
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: qsTr("Press ESC to cancel")
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape) {
                steamGameRecordingPage.recordingKeyName = "";
                event.accepted = true;
                return;
            }
            if (event.key === Qt.Key_Control || event.key === Qt.Key_Shift || event.key === Qt.Key_Alt || event.key === Qt.Key_Meta) {
                event.accepted = true;
                return;
            }
            var vdfStr = steamGameRecordingPage.keyEventToSteamString(event);
            if (vdfStr !== "") {
                root.toggleSteamFriendsSetting(steamGameRecordingPage.recordingKeyName, vdfStr);
                steamGameRecordingPage.recordingKeyName = "";
            }
            event.accepted = true;
        }
    }
}

