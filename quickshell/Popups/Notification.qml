import QtQuick
import Quickshell
import Quickshell.Widgets

import qs.Common

Item {
    id: root

    property var notification

    implicitWidth: 380
    implicitHeight: popup.implicitHeight

    opacity: 1
    scale: 1

    // =========================================================
    // Icon / image handling
    // =========================================================

    function resolvePath(path) {
        if (!path || path === "")
            return ""

        if (
            path.startsWith("file://") ||
            path.startsWith("http://") ||
            path.startsWith("https://") ||
            path.startsWith("data:")
        ) {
            return path
        }

        if (path.startsWith("~/")) {
            return "file://" +
                   Quickshell.env("HOME") +
                   path.substring(1)
        }

        if (path.startsWith("/"))
            return "file://" + path

        return ""
    }

    function isFilePath(path) {
        if (!path || path === "")
            return false

        return (
            path.startsWith("/") ||
            path.startsWith("~/") ||
            path.startsWith("file://") ||
            path.startsWith("http://") ||
            path.startsWith("https://")
        )
    }

    readonly property string rawIcon: {
        if (!root.notification)
            return ""

        // Prefer notification image.
        if (
            root.notification.image &&
            root.notification.image !== ""
        ) {
            return root.notification.image
        }

        // Fall back to the application icon.
        if (
            root.notification.appIcon &&
            root.notification.appIcon !== ""
        ) {
            return root.notification.appIcon
        }

        return ""
    }

    readonly property bool iconIsPath:
        isFilePath(rawIcon)

    readonly property string iconPath:
        iconIsPath
            ? resolvePath(rawIcon)
            : ""

    readonly property string iconName:
        !iconIsPath
            ? rawIcon
            : ""

    // =========================================================
    // Timeout
    // =========================================================

    Timer {
        id: expirationTimer

        interval: 5000

        repeat: false

        running:
            root.notification !== null

        onTriggered: {
            root.dismiss()
        }
    }

    NumberAnimation {
        id: expirationProgress

        target: expirationBar

        property: "width"

        from: popup.width

        to: 0

        duration: 5000

        easing.type:
            Easing.Linear
    }

    Component.onCompleted: {
        opacity = 0
        scale = 0.96

        enterAnimation.start()

        expirationProgress.start()

        expirationTimer.restart()
    }

    // =========================================================
    // Enter animation
    // =========================================================

    ParallelAnimation {
        id: enterAnimation

        NumberAnimation {
            target: root

            property: "opacity"

            to: 1

            duration: 200

            easing.type:
                Easing.OutCubic
        }

        NumberAnimation {
            target: root

            property: "scale"

            to: 1

            duration: 250

            easing.type:
                Easing.OutCubic
        }
    }

    // =========================================================
    // Dismiss
    // =========================================================

    function dismiss() {
        if (!root.notification)
            return

        expirationTimer.stop()

        expirationProgress.stop()

        exitAnimation.start()
    }

    ParallelAnimation {
        id: exitAnimation

        NumberAnimation {
            target: root

            property: "opacity"

            to: 0

            duration: 150

            easing.type:
                Easing.InCubic
        }

        NumberAnimation {
            target: root

            property: "scale"

            to: 0.96

            duration: 150

            easing.type:
                Easing.InCubic
        }

        onFinished: {
            if (root.notification)
                root.notification.dismiss()
        }
    }

    // =========================================================
    // Notification
    // =========================================================

    ClippingRectangle {
        id: popup

        anchors.fill: parent

        implicitHeight:
            content.implicitHeight + 30

        radius: 17.5

        color:
            "#e5e5e5"

        ClippingRectangle {
            id: notificationBody

            anchors {
                fill: parent

                margins: 1

                bottomMargin: 3
            }

            radius: 16.5

            color:
                "white"

            Item {
                id: content

                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top

                    margins: 13
                }

                implicitHeight:
                    Math.max(
                        appIcon.height,
                        textColumn.implicitHeight
                    )

                // =================================================
                // Icon
                // =================================================

                ClippingRectangle {
                    id: appIcon

                    width: 42
                    height: 42

                    anchors {
                        left: parent.left
                        top: parent.top
                    }

                    radius: 10

                    color:
                        "#eeeeee"

                    // ---------------------------------------------
                    // Image/file icon
                    // ---------------------------------------------

                    Image {
                        id: fileIcon

                        anchors.fill:
                            parent

                        source:
                            root.iconIsPath
                                ? root.iconPath
                                : ""

                        fillMode:
                            Image.PreserveAspectFit

                        asynchronous:
                            true

                        cache:
                            true

                        visible:
                            root.iconIsPath &&
                            status === Image.Ready

                        onStatusChanged: {
                            if (
                                status === Image.Error ||
                                status === Image.Null
                            ) {
                                visible = false
                            }
                        }
                    }

                    // ---------------------------------------------
                    // Normal application icon
                    // ---------------------------------------------

                    IconImage {
                        id: applicationIcon

                        anchors.fill:
                            parent

                        visible:
                            !root.iconIsPath &&
                            root.iconName !== ""

                        source:
                            !root.iconIsPath &&
                            root.iconName !== ""
                                ? root.iconName
                                : ""

                        asynchronous:
                            true

                        onStatusChanged: {
                            if (
                                status === Image.Error ||
                                status === Image.Null
                            ) {
                                visible = false
                            }
                        }
                    }

                    // ---------------------------------------------
                    // Bell fallback
                    // ---------------------------------------------

                    Text {
                        id: bellIcon

                        anchors.centerIn:
                            parent

                        text:
                            "󰂚"

                        font.family:
                            "Symbols Nerd Font"

                        font.pointSize:
                            20

                        color:
                            "#555555"

                        visible:
                            !fileIcon.visible &&
                            !applicationIcon.visible
                    }
                }

                // =================================================
                // Text
                // =================================================

                Column {
                    id: textColumn

                    anchors {
                        left:
                            appIcon.right

                        right:
                            closeButton.left

                        top:
                            parent.top

                        leftMargin: 12

                        rightMargin: 10
                    }

                    spacing: 3

                    Text {
                        width:
                            parent.width

                        text:
                            root.notification
                                ? root.notification.appName
                                : ""

                        font.pointSize:
                            9

                        font.weight:
                            Font.Medium

                        font.family:
                            Theme.fonts.monospace

                        color:
                            "#777777"

                        elide:
                            Text.ElideRight
                    }

                    Text {
                        width:
                            parent.width

                        text:
                            root.notification
                                ? root.notification.summary
                                : ""

                        font.pointSize:
                            12

                        font.weight:
                            Font.Medium

                        font.family:
                            Theme.fonts.monospace

                        color:
                            "#202020"

                        wrapMode:
                            Text.Wrap

                        maximumLineCount:
                            2

                        elide:
                            Text.ElideRight
                    }

                    Text {
                        width:
                            parent.width

                        text:
                            root.notification
                                ? root.notification.body
                                : ""

                        font.pointSize:
                            10

                        font.family:
                            Theme.fonts.monospace

                        color:
                            "#555555"

                        wrapMode:
                            Text.Wrap

                        maximumLineCount:
                            4

                        elide:
                            Text.ElideRight

                        visible:
                            text !== ""
                    }
                }

                // =================================================
                // Close button
                // =================================================

                Item {
                    id: closeButton

                    width: 26
                    height: 26

                    anchors {
                        right:
                            parent.right

                        top:
                            parent.top
                    }

                    z: 2

                    Text {
                        anchors.centerIn:
                            parent

                        text:
                            "󰅖"

                        font.family:
                            "Symbols Nerd Font"

                        font.pointSize:
                            14

                        color:
                            closeMouse.containsMouse
                                ? "#202020"
                                : "#888888"

                        scale:
                            closeMouse.pressed
                                ? 0.9
                                : closeMouse.containsMouse
                                    ? 1.1
                                    : 1.0

                        Behavior on scale {
                            NumberAnimation {
                                duration: 100

                                easing.type:
                                    Easing.OutCubic
                            }
                        }
                    }

                    MouseArea {
                        id: closeMouse

                        anchors.fill:
                            parent

                        hoverEnabled:
                            true

                        onClicked: {
                            root.dismiss()
                        }
                    }
                }
            }

            // =====================================================
            // Click notification to dismiss
            // =====================================================

            MouseArea {
                anchors.fill:
                    parent

                z: 0

                onClicked: {
                    if (root.notification)
                        root.dismiss()
                }
            }
        }

        // =========================================================
        // Expiration bar
        // =========================================================

        Rectangle {
            id: expirationBar

            anchors {
                left:
                    parent.left

                bottom:
                    parent.bottom
            }

            width:
                popup.width

            height:
                3

            radius:
                1.5

            color:
                "#303030"

            z: 10
        }
    }
}