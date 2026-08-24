pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

QtObject {
    id: root

    readonly property NotificationServer server: NotificationServer {
        bodySupported: true
        bodyMarkupSupported: false
        bodyImagesSupported: true
        imageSupported: true
        actionsSupported: true
        actionIconsSupported: true

        // Keep notifications alive when Quickshell reloads.
        keepOnReload: true

        onNotification: function(notification) {
            notification.tracked = true
        }
    }

    readonly property var notifications:
        server.trackedNotifications
}