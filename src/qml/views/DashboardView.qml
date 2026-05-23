import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import MeguPackOptimizer 1.0
import "../components"

Item {
    id: root
    
    // File and folder selection dialogs
    FolderDialog {
        id: folderDialog
        title: qsTr("Select Resource Pack Directory")
        onAccepted: {
            optimizerBackend.loadPack(selectedFolder.toString());
        }
    }
    
    FileDialog {
        id: fileDialog
        title: qsTr("Select Resource Pack Archive")
        nameFilters: [ qsTr("ZIP Archives (*.zip *.jar)") ]
        onAccepted: {
            optimizerBackend.loadPack(selectedFile.toString());
        }
    }
    
    // JS helper to format file sizes
    function formatBytes(bytes) {
        if (bytes <= 0) return "0 Bytes";
        const k = 1024;
        const sizes = ["Bytes", "KB", "MB", "GB"];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i];
    }
    
    // Outer Drop Area
    DropArea {
        id: dropArea
        anchors.fill: parent
        onDropped: (drag) => {
            if (drag.hasUrls && drag.urls.length > 0) {
                optimizerBackend.loadPack(drag.urls[0]);
            }
        }
    }
    
    Row {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20
        
        // Left Column: Control Panel & Target Selector
        Column {
            width: (parent.width * 0.55) - 10
            height: parent.height
            spacing: 16
            
            // Selector / Drag Area
            AcrylicPanel {
                width: parent.width
                height: 190
                
                Rectangle {
                    anchors.fill: parent
                    color: dropArea.containsDrag ? "#25FFBF00" : "transparent"
                    radius: Theme.radiusNormal
                    border.color: dropArea.containsDrag ? Theme.accent : "transparent"
                    border.width: 2
                    
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 12
                        width: parent.width - 40
                        
                        Image {
                            source: "qrc:/MeguPackOptimizer/src/resources/folder.svg"
                            width: 48; height: 48
                            anchors.horizontalCenter: parent.horizontalCenter
                            opacity: dropArea.containsDrag ? 1.0 : 0.7
                        }
                        
                        Text {
                            text: dropArea.containsDrag ? qsTr("Drop Pack Here!") : qsTr("Drag & Drop Resource Pack Folder or Zip")
                            color: dropArea.containsDrag ? Theme.accent : Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                            font.bold: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            text: qsTr("or choose one of the browse options below")
                            color: Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: !dropArea.containsDrag
                        }
                        
                        Row {
                            spacing: 12
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: !dropArea.containsDrag && !optimizerBackend.isProcessing
                            
                            MeguButton {
                                text: qsTr("Browse Folder")
                                iconSource: "qrc:/MeguPackOptimizer/src/resources/folder.svg"
                                onClicked: folderDialog.open()
                            }
                            
                            MeguButton {
                                text: qsTr("Browse ZIP Archive")
                                iconSource: "qrc:/MeguPackOptimizer/src/resources/folder.svg"
                                onClicked: fileDialog.open()
                            }
                        }
                    }
                }
            }
            
            // Action Panel (Start / Progress / Results)
            AcrylicPanel {
                width: parent.width
                height: parent.height - 190 - 16
                
                // State 1: No Pack Loaded
                Column {
                    anchors.centerIn: parent
                    spacing: 10
                    visible: optimizerBackend.packPath === ""
                    width: parent.width - 40
                    
                    Image {
                        source: "qrc:/MeguPackOptimizer/src/resources/info.svg"
                        width: 32; height: 32
                        anchors.horizontalCenter: parent.horizontalCenter
                        opacity: 0.5
                    }
                    
                    Text {
                        text: qsTr("No Pack Loaded")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: qsTr("Load a game resource pack to start analysis and run optimizations.")
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
                
                // State 2: Pack Loaded & Ready
                Column {
                    anchors.fill: parent
                    spacing: 14
                    visible: optimizerBackend.packPath !== "" && !optimizerBackend.isProcessing
                    
                    Text {
                        text: qsTr("Optimizer Control Panel")
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
                    
                    Text {
                        text: qsTr("Ready to optimize '%1'.").arg(optimizerBackend.packName)
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                    }
                    
                    Text {
                        text: qsTr("Verify configuration settings in the 'Settings' tab before running. Press the button below to initiate optimization operations.")
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                    
                    Item {
                        width: parent.width
                        height: 20
                    }
                    
                    // Large pulsing Zune Amber CTA button
                    MeguButton {
                        text: qsTr("START OPTIMIZATION")
                        iconSource: "qrc:/MeguPackOptimizer/src/resources/play.svg"
                        accented: true
                        anchors.horizontalCenter: parent.horizontalCenter
                        implicitWidth: parent.width - 40
                        implicitHeight: 46
                        onClicked: optimizerBackend.startOptimization()
                    }
                }
                
                // State 3: Active Optimization Process
                Column {
                    anchors.fill: parent
                    spacing: 14
                    visible: optimizerBackend.isProcessing
                    
                    Text {
                        text: qsTr("Optimizing Pack...")
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
                    
                    Text {
                        text: qsTr("Processing: %1").arg(optimizerBackend.packName)
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        elide: Text.ElideRight
                    }
                    
                    Item {
                        width: parent.width
                        height: 10
                    }
                    
                    // Reactive Progress bar
                    MeguProgressBar {
                        width: parent.width
                        value: optimizerBackend.progress
                        statusText: optimizerBackend.progress < 0.15 ? qsTr("Backing up pack...") : 
                                    optimizerBackend.progress < 0.50 ? qsTr("Compressing texture files...") : 
                                    optimizerBackend.progress < 0.70 ? qsTr("Minifying JSON documents...") : 
                                    optimizerBackend.progress < 0.90 ? qsTr("Optimizing sound assets...") : qsTr("Finalizing build...")
                    }
                    
                    Item {
                        width: parent.width
                        height: 10
                    }
                    
                    MeguButton {
                        text: qsTr("CANCEL PROCESS")
                        iconSource: "qrc:/MeguPackOptimizer/src/resources/close.svg"
                        anchors.horizontalCenter: parent.horizontalCenter
                        implicitWidth: 160
                        onClicked: optimizerBackend.cancelOptimization()
                    }
                }
            }
        }
        
        // Right Column: Pack Info & Statistics
        Column {
            width: (parent.width * 0.45) - 10
            height: parent.height
            spacing: 16
            
            // Statistics Card
            AcrylicPanel {
                width: parent.width
                height: 250
                
                Column {
                    anchors.fill: parent
                    spacing: 12
                    
                    Text {
                        text: qsTr("Pack Assets Information")
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
                    
                    // Grid of parsed properties
                    Grid {
                        width: parent.width
                        columns: 2
                        rowSpacing: 10
                        columnSpacing: 10
                        
                        // Row 1
                        Text { text: qsTr("Pack Name:"); color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 11; width: 100 }
                        Text { text: optimizerBackend.packName !== "" ? optimizerBackend.packName : "-"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 12; font.bold: true; elide: Text.ElideRight; width: parent.width - 110 }
                        
                        // Row 2
                        Text { text: qsTr("Total Size:"); color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 11; width: 100 }
                        Text { text: optimizerBackend.packPath !== "" ? root.formatBytes(optimizerBackend.packSize) : "-"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 12; font.bold: true }
                        
                        // Row 3
                        Text { text: qsTr("Texture Files:"); color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 11; width: 100 }
                        Text { text: optimizerBackend.packPath !== "" ? optimizerBackend.imageCount.toString() : "-"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 12; font.bold: true }
                        
                        // Row 4
                        Text { text: qsTr("JSON & Meta:"); color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 11; width: 100 }
                        Text { text: optimizerBackend.packPath !== "" ? optimizerBackend.jsonCount.toString() : "-"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 12; font.bold: true }
                        
                        // Row 5
                        Text { text: qsTr("Sound Assets:"); color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 11; width: 100 }
                        Text { text: optimizerBackend.packPath !== "" ? optimizerBackend.soundCount.toString() : "-"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 12; font.bold: true }
                        
                        // Row 6
                        Text { text: qsTr("Other Files:"); color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 11; width: 100 }
                        Text { text: optimizerBackend.packPath !== "" ? optimizerBackend.otherCount.toString() : "-"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 12; font.bold: true }
                    }
                }
            }
            
            // Info / Guide panel
            AcrylicPanel {
                width: parent.width
                height: parent.height - 250 - 16
                
                Column {
                    anchors.fill: parent
                    spacing: 12
                    
                    Text {
                        text: qsTr("Optimization Guide")
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
                    
                    ScrollView {
                        width: parent.width
                        height: parent.height - 35
                        clip: true
                        
                        Text {
                            width: parent.width - 10
                            text: qsTr("• <b>Images</b>: PNG files will be optimized by shrinking the color palettes or downscaling resolutions if they exceed maximum limits. Transformed files can be compressed using WebP format to reduce sizes.<br/><br/>" +
                                       "• <b>JSONs</b>: Unnecessary whitespace and comments are removed to compress layout configuration and model definitions.<br/><br/>" +
                                       "• <b>Audio</b>: High bitrate sound files downsampled and converted into compressed Vorbis OGG tracks to save significant disk space.<br/><br/>" +
                                       "• <b>ZIP output</b>: The resulting folder will be compacted back into an optimized ZIP archive ready to use.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            wrapMode: Text.WordWrap
                            textFormat: Text.RichText
                        }
                    }
                }
            }
        }
    }
}
