import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets

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

    // =========================================================
    // Spotify metadata
    // =========================================================

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

                // playerctl reports position/length in microseconds
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

    // =========================================================
    // Spotify controls
    // =========================================================

    Process {
        id: playPauseProcess

        command: [
            "playerctl",
            "--player=spotify",
            "play-pause"
        ]
    }

    Process {
        id: previousProcess

        command: [
            "playerctl",
            "--player=spotify",
            "previous"
        ]
    }

    Process {
        id: nextProcess

        command: [
            "playerctl",
            "--player=spotify",
            "next"
        ]
    }

    Process {
        id: seekProcess

        command: [
            "playerctl",
            "--player=spotify",
            "position",
            "0"
        ]
    }

    // =========================================================
    // Music controller
    // =========================================================

    Rectangle {
        id: musicControls

        implicitWidth: 450
        implicitHeight: 170

        radius: 17.5
        color: "white"

        // =====================================================
        // Album artwork
        // =====================================================

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

        // =====================================================
        // Track information
        // =====================================================

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

            // -------------------------------------------------
            // Title
            // -------------------------------------------------

            Text {
                id: title

                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    topMargin: 34
                }

                text: root.title

                font.pointSize: 13
                font.weight: Font.Medium
                font.family: "JetBrainsMono NF"

                color: "black"

                elide: Text.ElideRight
            }

            // -------------------------------------------------
            // Artist
            // -------------------------------------------------

            Text {
                id: artist

                anchors {
                    left: parent.left
                    right: parent.right
                    top: title.bottom
                    topMargin: 5
                }

                text: root.artist

                font.pointSize: 11
                font.family: "JetBrainsMono NF"

                color: "gray"

                elide: Text.ElideRight
            }

            // -------------------------------------------------
            // Progress bar
            // -------------------------------------------------

            Rectangle {
                id: progressBar

                anchors {
                    left: parent.left
                    right: parent.right
                    top: artist.bottom
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
                        const newPosition =
                            percentage * root.length

                        seekProcess.command = [
                            "playerctl",
                            "--player=spotify",
                            "position",
                            newPosition.toString()
                        ]

                        seekProcess.running = true
                    }
                }
            }

            // =================================================
            // Playback controls
            // =================================================

            Row {
                id: controls

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: progressBar.bottom
                    topMargin: 5
                }

                spacing: 18

                // -------------------------------------------------
                // Previous
                // -------------------------------------------------

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
                            previousProcess.running = true
                        }
                    }
                }

                // -------------------------------------------------
                // Play / Pause
                // -------------------------------------------------

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
                            playPauseProcess.running = true
                        }
                    }
                }

                // -------------------------------------------------
                // Next
                // -------------------------------------------------

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
                            nextProcess.running = true
                        }
                    }
                }
            }
        }
    }

    // =========================================================
    // Helpers
    // =========================================================

    function formatTime(seconds) {
        if (!isFinite(seconds) || seconds < 0)
            return "0:00"

        const totalSeconds = Math.floor(seconds)

        const minutes = Math.floor(totalSeconds / 60)
        const remaining = totalSeconds % 60

        return minutes + ":" +
            (remaining < 10 ? "0" : "") +
            remaining
    }
}