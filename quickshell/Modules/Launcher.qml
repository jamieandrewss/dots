import QtQuick
import QtQuick.Controls

import Quickshell
import Quickshell.Io
import Quickshell.Widgets

import qs.Common
import qs.Services

Item {
    id: launcher

    property bool open: false

    property string searchText: ""

    property int selectedIndex: 0

    readonly property var allApplications:
        DesktopEntries.applications.values

    property var filteredApplications: []

    anchors.fill: parent

    visible: open

    function updateApplications() {
        const query =
            searchText.trim().toLowerCase()

        if (query === "") {
            filteredApplications =
                [...allApplications].sort(
                    function(a, b) {
                        return a.name.localeCompare(b.name)
                    }
                )

            return
        }

        filteredApplications =
            [...allApplications]
            .filter(function(app) {
                const name =
                    (app.name || "").toLowerCase()

                const generic =
                    (app.genericName || "").toLowerCase()

                const comment =
                    (app.comment || "").toLowerCase()

                const keywords =
                    (app.keywords || [])
                    .join(" ")
                    .toLowerCase()

                return (
                    name.includes(query) ||
                    generic.includes(query) ||
                    comment.includes(query) ||
                    keywords.includes(query)
                )
            })
            .sort(function(a, b) {
                const aName =
                    a.name.toLowerCase()

                const bName =
                    b.name.toLowerCase()

                const aStarts =
                    aName.startsWith(query)

                const bStarts =
                    bName.startsWith(query)

                if (aStarts !== bStarts)
                    return aStarts ? -1 : 1

                return aName.localeCompare(bName)
            })
    }

    function openLauncher() {
        searchText = ""
        selectedIndex = 0

        searchInput.text = ""

        updateApplications()

        open = true

        Qt.callLater(function() {
            searchInput.forceActiveFocus()
        })
    }

    function closeLauncher() {
        open = false

        searchText = ""
        selectedIndex = 0
    }

    function toggleLauncher() {
        if (open)
            closeLauncher()
        else
            openLauncher()
    }

    function moveSelection(amount) {
        if (filteredApplications.length === 0)
            return

        selectedIndex =
            Math.max(
                0,
                Math.min(
                    filteredApplications.length - 1,
                    selectedIndex + amount
                )
            )

        applicationList.positionViewAtIndex(
            selectedIndex,
            ListView.Contain
        )
    }

    function launchSelected() {
        if (
            selectedIndex < 0 ||
            selectedIndex >= filteredApplications.length
        )
            return

        const app =
            filteredApplications[selectedIndex]

        if (!app)
            return

        app.execute()

        closeLauncher()
    }

    onSearchTextChanged: {
        selectedIndex = 0
        updateApplications()
    }

    Component.onCompleted: {
        updateApplications()
    }

    IpcHandler {
        target: "launcher"

        function open(): void {
            launcher.openLauncher()
        }

        function close(): void {
            launcher.closeLauncher()
        }

        function toggle(): void {
            launcher.toggleLauncher()
        }
    }

    Rectangle {
        id: launcherBackground

        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }

        width: Math.min(
            parent.width,
            520
        )

        height: parent.height

        radius: 17.5

        color: "white"

        clip: true

        // =====================================================
        // Search box
        // =====================================================

        Rectangle {
            id: searchBox

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top

                leftMargin: 14
                rightMargin: 14
                topMargin: 14
            }

            height: 48

            radius: 12

            color: "#eeeeee"

            Text {
                id: searchIcon

                anchors {
                    left: parent.left
                    verticalCenter:
                        parent.verticalCenter

                    leftMargin: 14
                }

                text: "󰍉"

                font.family:
                    "Symbols Nerd Font"

                font.pointSize: 18

                color: "#505050"
            }

            TextInput {
                id: searchInput

                anchors {
                    left: searchIcon.right
                    right: clearButton.left
                    verticalCenter:
                        parent.verticalCenter

                    leftMargin: 12
                    rightMargin: 8
                }

                height: parent.height

                focus: launcher.open

                activeFocusOnTab: true

                text: launcher.searchText

                verticalAlignment:
                    TextInput.AlignVCenter

                font.family:
                    Theme.fonts.monospace

                font.pointSize: 11

                color: "#202020"

                cursorVisible: launcher.open

                selectByMouse: true

                onTextChanged: {
                    if (
                        launcher.searchText !== text
                    ) {
                        launcher.searchText = text
                    }
                }

                Keys.onPressed:
                    function(event) {
                        if (
                            event.key === Qt.Key_Down
                        ) {
                            launcher.moveSelection(1)
                            event.accepted = true
                            return
                        }

                        if (
                            event.key === Qt.Key_Up
                        ) {
                            launcher.moveSelection(-1)
                            event.accepted = true
                            return
                        }

                        if (
                            event.key === Qt.Key_Return ||
                            event.key === Qt.Key_Enter
                        ) {
                            launcher.launchSelected()
                            event.accepted = true
                            return
                        }

                        if (
                            event.key === Qt.Key_Escape
                        ) {
                            launcher.closeLauncher()
                            event.accepted = true
                            return
                        }
                    }
            }

            Text {
                visible:
                    searchInput.text.length === 0

                anchors {
                    left: searchInput.left
                    verticalCenter:
                        searchInput.verticalCenter
                }

                text:
                    "Search applications..."

                font.family:
                    Theme.fonts.monospace

                font.pointSize: 11

                color: "#888888"
            }

            Text {
                id: clearButton

                visible:
                    searchInput.text.length > 0

                anchors {
                    right: parent.right
                    verticalCenter:
                        parent.verticalCenter

                    rightMargin: 14
                }

                text: "󰅖"

                font.family:
                    "Symbols Nerd Font"

                font.pointSize: 15

                color: "#707070"

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        searchInput.text = ""
                        searchInput.forceActiveFocus()
                    }
                }
            }
        }

        // =====================================================
        // Application list
        // =====================================================

        ListView {
            id: applicationList

            anchors {
                left: parent.left
                right: parent.right
                top: searchBox.bottom
                bottom: parent.bottom

                leftMargin: 14
                rightMargin: 14
                topMargin: 10
                bottomMargin: 14
            }

            clip: true

            spacing: 4

            model:
                launcher.filteredApplications

            currentIndex:
                launcher.selectedIndex

            delegate: Rectangle {
                required property var modelData
                required property int index

                width:
                    applicationList.width

                height: 56

                radius: 11

                color:
                    index === launcher.selectedIndex
                        ? "#e8e8e8"
                        : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: 100
                    }
                }

                IconImage {
                    id: appIcon

                    anchors {
                        left: parent.left
                        verticalCenter:
                            parent.verticalCenter

                        leftMargin: 10
                    }

                    width: 36
                    height: 36

                    source:
                        modelData.icon !== ""
                            ? Quickshell.iconPath(
                                modelData.icon,
                                true
                            )
                            : ""
                }

                Rectangle {
                    visible:
                        appIcon.source === ""

                    anchors {
                        left: appIcon.left
                        top: appIcon.top
                    }

                    width: appIcon.width
                    height: appIcon.height

                    radius: 9

                    color: "#d9d9d9"

                    Text {
                        anchors.centerIn: parent

                        text:
                            modelData.name
                                .charAt(0)
                                .toUpperCase()

                        font.family:
                            Theme.fonts.monospace

                        font.pointSize: 14

                        font.weight:
                            Font.Medium

                        color: "#555555"
                    }
                }

                Column {
                    anchors {
                        left: appIcon.right
                        right: parent.right
                        verticalCenter:
                            parent.verticalCenter

                        leftMargin: 12
                        rightMargin: 12
                    }

                    spacing: 2

                    Text {
                        width: parent.width

                        text:
                            modelData.name

                        font.family:
                            Theme.fonts.monospace

                        font.pointSize: 10

                        font.weight:
                            Font.Medium

                        color: "#202020"

                        elide:
                            Text.ElideRight
                    }

                    Text {
                        visible:
                            modelData.genericName !== ""

                        width: parent.width

                        text:
                            modelData.genericName

                        font.family:
                            Theme.fonts.monospace

                        font.pointSize: 7

                        color: "#777777"

                        elide:
                            Text.ElideRight
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    hoverEnabled: true

                    onEntered: {
                        launcher.selectedIndex =
                            index
                    }

                    onClicked: {
                        launcher.selectedIndex =
                            index

                        launcher.launchSelected()
                    }
                }
            }

            ScrollBar.vertical:
                ScrollBar {
                    policy:
                        applicationList.contentHeight >
                        applicationList.height
                            ? ScrollBar.AsNeeded
                            : ScrollBar.AlwaysOff
                }

            Text {
                visible:
                    launcher.filteredApplications.length === 0

                anchors.centerIn: parent

                text:
                    launcher.searchText.length > 0
                        ? "No applications found"
                        : "No applications available"

                font.family:
                    Theme.fonts.monospace

                font.pointSize: 10

                color: "#888888"
            }
        }
    }

    onOpenChanged: {
        if (open) {
            Qt.callLater(function() {
                searchInput.forceActiveFocus()
            })
        }
    }
}