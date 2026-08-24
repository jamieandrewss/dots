import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.Common
import qs.Services

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: notificationWindow

        required property var modelData

        screen: modelData

        WlrLayershell.layer: WlrLayer.Overlay

        color: "#00000000"

        anchors {
            top: true
            right: true
        }

        margins {
            top: Layout.exclusive + 10
            right: 15
        }

        implicitWidth: 380

        implicitHeight: notificationColumn.implicitHeight

        exclusiveZone: 0

        mask: Region {
            item: notificationColumn
        }

        Column {
            id: notificationColumn

            width: 380

            spacing: 10

            Repeater {
                model: Notifications.notifications

                delegate: Notification {
                    required property var modelData

                    width: 380

                    notification: modelData
                }
            }
        }
    }
}