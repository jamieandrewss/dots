import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets

import qs.Common

Item {
    id: root

    implicitWidth: musicControls.implicitWidth
    implicitHeight: musicControls.implicitHeight

    property string title: "Nothing Playing"
    property string artist: ""
    property string artwork: ""
    property string status: "Stopped"
    property real position: 0
    property real length: 0

    Process {
        id: metadataProcess

        command: [
            "playerctl",
            "--player=spotify",
            "metadata",
            "--format",
            "{{title}}|{{artist}}|{{mpris:artUrl}}|{{status}}|{{position}}|{{mpris:length}}"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const output = this.text.trim()

                if (!output)
                    return

                const parts = output.split("|")

                if (parts.length < 6)
                    return

                root.title = parts[0] || "Nothing Playing"
                root.artist = parts[1] || ""
                root.artwork = parts[2] || ""
                root.status = parts[3] || "Stopped"
                root.position = (parseFloat(parts[4]) || 0) / 1000000
                root.length = (parseFloat(parts[5]) || 0) / 1000000
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            if (!metadataProcess.running)
                metadataProcess.running = true
        }
    }

    Process {
        id: playerctlProcess
    }

    function playerctl(action) {
        playerctlProcess.exec([
            "playerctl",
            "--player=spotify",
            action
        ])
    }

    Process {
        id: seekProcess
    }

    Rectangle {
        id: musicControls

        implicitWidth: 450
        implicitHeight: 170
        radius: 17.5
        color: "white"

        ClippingRectangle {
            id: albumArtwork

            width: 138
            height: 138

            anchors {
                left: parent.left
                top: parent.top
                leftMargin: 15
                topMargin: 15
            }

            radius: 12
            color: "#d9d9d9"

            Image {
                anchors.fill: parent

                source: root.artwork

                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
            }
        }

        Item {
            id: trackInfo

            anchors {
                left: albumArtwork.right
                right: parent.right
                top: parent.top
                bottom: parent.bottom
                leftMargin: 27
                rightMargin: 28
            }

            // --- Title: clips to the widget, marquees when the text overflows ---
            Item {
                id: titleClip

                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    topMargin: 34
                }

                height: title.implicitHeight
                clip: true

                Text {
                    id: title

                    text: root.title

                    font.pointSize: 13
                    font.weight: Font.Medium
                    font.family: Theme.fonts.monospace

                    color: "black"

                    property bool overflowing: implicitWidth > titleClip.width

                    function resetMarquee() {
                        titleMarquee.stop()
                        title.x = 0
                        if (title.overflowing)
                            titleMarquee.start()
                    }

                    onTextChanged: resetMarquee()
                    onOverflowingChanged: resetMarquee()
                    Component.onCompleted: resetMarquee()

                    SequentialAnimation {
                        id: titleMarquee

                        loops: Animation.Infinite

                        PauseAnimation { duration: 400 }
                        NumberAnimation {
                            target: title
                            property: "x"
                            to: titleClip.width - title.implicitWidth
                            duration: Math.max(400, (title.implicitWidth - titleClip.width) * 15)
                            easing.type: Easing.InOutQuad
                        }
                        PauseAnimation { duration: 400 }
                        NumberAnimation {
                            target: title
                            property: "x"
                            to: 0
                            duration: Math.max(400, (title.implicitWidth - titleClip.width) * 15)
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            // --- Artist: same treatment as title ---
            Item {
                id: artistClip

                anchors {
                    left: parent.left
                    right: parent.right
                    top: titleClip.bottom
                    topMargin: 5
                }

                height: artist.implicitHeight
                clip: true

                Text {
                    id: artist

                    text: root.artist

                    font.pointSize: 11
                    font.family: Theme.fonts.monospace

                    color: "gray"

                    property bool overflowing: implicitWidth > artistClip.width

                    function resetMarquee() {
                        artistMarquee.stop()
                        artist.x = 0
                        if (artist.overflowing)
                            artistMarquee.start()
                    }

                    onTextChanged: resetMarquee()
                    onOverflowingChanged: resetMarquee()
                    Component.onCompleted: resetMarquee()

                    SequentialAnimation {
                        id: artistMarquee

                        loops: Animation.Infinite

                        PauseAnimation { duration: 400 }
                        NumberAnimation {
                            target: artist
                            property: "x"
                            to: artistClip.width - artist.implicitWidth
                            duration: Math.max(400, (artist.implicitWidth - artistClip.width) * 15)
                            easing.type: Easing.InOutQuad
                        }
                        PauseAnimation { duration: 400 }
                        NumberAnimation {
                            target: artist
                            property: "x"
                            to: 0
                            duration: Math.max(400, (artist.implicitWidth - artistClip.width) * 15)
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            Rectangle {
                id: progressBar

                anchors {
                    left: parent.left
                    right: parent.right
                    top: artistClip.bottom
                    topMargin: 8
                }

                height: 6
                radius: height / 2
                color: "white"

                Rectangle {
                    id: progress

                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }

                    width: root.length > 0
                        ? parent.width * Math.min(
                            root.position / root.length,
                            1
                        )
                        : 0

                    radius: height / 2
                    color: "black"

                    Behavior on width {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                }

                MouseArea {
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                        topMargin: -8
                        bottomMargin: -8
                    }

                    onClicked: function(mouse) {
                        if (root.length <= 0)
                            return

                        const percentage = mouse.x / width
                        const newPosition = percentage * root.length

                        seekProcess.exec([
                            "playerctl",
                            "--player=spotify",
                            "position",
                            newPosition.toString()
                        ])
                    }
                }
            }

            Row {
                id: controls

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: progressBar.bottom
                    topMargin: 5
                }

                spacing: 18

                // Previous
                Item {
                    width: 38
                    height: 32

                    Text {
                        anchors.centerIn: parent

                        text: "󰒮"

                        font.family: "Symbols Nerd Font"
                        font.pointSize: 16
                        color: "#303030"

                        scale: previousMouse.pressed
                            ? 0.9
                            : previousMouse.containsMouse
                                ? 1.1
                                : 1.0

                        Behavior on scale {
                            NumberAnimation {
                                duration: 100
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    MouseArea {
                        id: previousMouse

                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            root.playerctl("previous")
                        }
                    }
                }

                // Play / Pause
                Item {
                    width: 42
                    height: 32

                    Text {
                        anchors.centerIn: parent

                        text: root.status === "Playing"
                            ? "󰏤"
                            : "󰐊"

                        font.family: "Symbols Nerd Font"
                        font.pointSize: 20
                        color: "#303030"

                        scale: playPauseMouse.pressed
                            ? 0.9
                            : playPauseMouse.containsMouse
                                ? 1.1
                                : 1.0

                        Behavior on scale {
                            NumberAnimation {
                                duration: 100
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    MouseArea {
                        id: playPauseMouse

                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            root.playerctl("play-pause")
                        }
                    }
                }

                // Next
                Item {
                    width: 38
                    height: 32

                    Text {
                        anchors.centerIn: parent

                        text: "󰒭"

                        font.family: "Symbols Nerd Font"
                        font.pointSize: 16
                        color: "#303030"

                        scale: nextMouse.pressed
                            ? 0.9
                            : nextMouse.containsMouse
                                ? 1.1
                                : 1.0

                        Behavior on scale {
                            NumberAnimation {
                                duration: 100
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    MouseArea {
                        id: nextMouse

                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            root.playerctl("next")
                        }
                    }
                }
            }
        }
    }
}
