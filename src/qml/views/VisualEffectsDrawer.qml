import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects
import "../components"

Column {
id: visualEffectsColumn
width: parent.width
spacing: 20


Text {
    text: qsTr("Visual Effects Preset:")
    color: Theme.textSecondary
    font.family: Theme.fontFamily
    font.pixelSize: 11
    font.bold: true
}

Flow {
    width: parent.width
    spacing: 6

    Repeater {
        model: [
            { id: 0, text: qsTr("Let Windows choose") },
            { id: 1, text: qsTr("Best appearance") },
            { id: 2, text: qsTr("Best performance") },
            { id: 3, text: qsTr("Custom") }
        ]
        delegate: Rectangle {
            height: 28
            width: presetText.contentWidth + 24
            radius: 14
            color: (root.visualEffectsPreset === modelData.id) ? Theme.accentDim : (presetMouse.containsMouse ? "#0CFFFFFF" : "#05FFFFFF")
            border.color: (root.visualEffectsPreset === modelData.id) ? Theme.accent : Theme.border
            border.width: 1

            Behavior on color { ColorAnimation { duration: Theme.animFast } }
            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

            Text {
                id: presetText
                text: modelData.text
                color: (root.visualEffectsPreset === modelData.id) ? Theme.accent : Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                anchors.centerIn: parent
            }

            MouseArea {
                id: presetMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.setPreset(modelData.id);
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

Text {
    text: qsTr("Individual Settings:")
    color: Theme.textSecondary
    font.family: Theme.fontFamily
    font.pixelSize: 11
    font.bold: true
}

Column {
    width: parent.width
    spacing: 12

    MeguSwitch {
        text: qsTr("Animate controls and elements inside windows")
        checked: optimizerBackend.visualEffects ? !!optimizerBackend.visualEffects["animateControls"] : false
        onToggled: (isChecked) => { root.toggleVisualEffect("animateControls", isChecked); }
    }
    MeguSwitch {
        text: qsTr("Animate windows when minimizing and maximizing")
        checked: optimizerBackend.visualEffects ? !!optimizerBackend.visualEffects["animateWindows"] : false
        onToggled: (isChecked) => { root.toggleVisualEffect("animateWindows", isChecked); }
    }
    MeguSwitch {
        text: qsTr("Animations in the taskbar")
        checked: optimizerBackend.visualEffects ? !!optimizerBackend.visualEffects["animateTaskbar"] : false
        onToggled: (isChecked) => { root.toggleVisualEffect("animateTaskbar", isChecked); }
    }
    MeguSwitch {
        text: qsTr("Enable Peek")
        checked: optimizerBackend.visualEffects ? !!optimizerBackend.visualEffects["enablePeek"] : false
        onToggled: (isChecked) => { root.toggleVisualEffect("enablePeek", isChecked); }
    }
    MeguSwitch {
        text: qsTr("Fade or slide menus into view")
        checked: optimizerBackend.visualEffects ? !!optimizerBackend.visualEffects["fadeMenus"] : false
        onToggled: (isChecked) => { root.toggleVisualEffect("fadeMenus", isChecked); }
    }
    MeguSwitch {
        text: qsTr("Fade or slide ToolTips into view")
        checked: optimizerBackend.visualEffects ? !!optimizerBackend.visualEffects["fadeTooltips"] : false
        onToggled: (isChecked) => { root.toggleVisualEffect("fadeTooltips", isChecked); }
    }
    MeguSwitch {
        text: qsTr("Fade out menu items after clicking")
        checked: optimizerBackend.visualEffects ? !!optimizerBackend.visualEffects["fadeMenuSelection"] : false
        onToggled: (isChecked) => { root.toggleVisualEffect("fadeMenuSelection", isChecked); }
    }
    MeguSwitch {
        text: qsTr("Save taskbar thumbnail previews")
        checked: optimizerBackend.visualEffects ? !!optimizerBackend.visualEffects["saveThumbnails"] : false
        onToggled: (isChecked) => { root.toggleVisualEffect("saveThumbnails", isChecked); }
    }
    MeguSwitch {
        text: qsTr("Show shadows under mouse pointer")
        checked: optimizerBackend.visualEffects ? !!optimizerBackend.visualEffects["shadowPointer"] : false
        onToggled: (isChecked) => { root.toggleVisualEffect("shadowPointer", isChecked); }
    }
    MeguSwitch {
        text: qsTr("Show shadows under windows")
        checked: optimizerBackend.visualEffects ? !!optimizerBackend.visualEffects["shadowWindows"] : false
        onToggled: (isChecked) => { root.toggleVisualEffect("shadowWindows", isChecked); }
    }
    MeguSwitch {
        text: qsTr("Show thumbnails instead of icons")
        checked: optimizerBackend.visualEffects ? !!optimizerBackend.visualEffects["showThumbnails"] : false
        onToggled: (isChecked) => { root.toggleVisualEffect("showThumbnails", isChecked); }
    }
    MeguSwitch {
        text: qsTr("Show translucent selection rectangle")
        checked: optimizerBackend.visualEffects ? !!optimizerBackend.visualEffects["translucentSelection"] : false
        onToggled: (isChecked) => { root.toggleVisualEffect("translucentSelection", isChecked); }
    }
    MeguSwitch {
        text: qsTr("Show window contents while dragging")
        checked: optimizerBackend.visualEffects ? !!optimizerBackend.visualEffects["dragContents"] : false
        onToggled: (isChecked) => { root.toggleVisualEffect("dragContents", isChecked); }
    }
    MeguSwitch {
        text: qsTr("Slide open combo boxes")
        checked: optimizerBackend.visualEffects ? !!optimizerBackend.visualEffects["slideComboBoxes"] : false
        onToggled: (isChecked) => { root.toggleVisualEffect("slideComboBoxes", isChecked); }
    }
    MeguSwitch {
        text: qsTr("Smooth edges of screen fonts")
        checked: optimizerBackend.visualEffects ? !!optimizerBackend.visualEffects["smoothFonts"] : false
        onToggled: (isChecked) => { root.toggleVisualEffect("smoothFonts", isChecked); }
    }
    MeguSwitch {
        text: qsTr("Smooth-scroll list boxes")
        checked: optimizerBackend.visualEffects ? !!optimizerBackend.visualEffects["smoothScroll"] : false
        onToggled: (isChecked) => { root.toggleVisualEffect("smoothScroll", isChecked); }
    }
    MeguSwitch {
        text: qsTr("Use drop shadows for icon labels on the desktop")
        checked: optimizerBackend.visualEffects ? !!optimizerBackend.visualEffects["dropShadowsDesktop"] : false
        onToggled: (isChecked) => { root.toggleVisualEffect("dropShadowsDesktop", isChecked); }
    }
}
}

