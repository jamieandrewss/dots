import QtQuick
import Quickshell
import Quickshell.Hyprland

import qs.Common

// Workspace Identifier
Rectangle {
    id: workspaceIndicator

    width: Layout.islandMinHeight
    height: 40

    radius: 25

    anchors {
        right: root.left
        rightMargin: 8
        top: root.top
    }

    color: "white"

    Text {
        anchors.centerIn: parent

        text: Hyprland.focusedWorkspace?.id ?? ""

        font {
            family: Theme.fonts.monospace
            pointSize: 12
            weight: 700
        }

        color: "black"
    }
}