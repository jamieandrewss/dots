import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import qs.Common
import qs.Services

PanelWindow {
    id: islandWindow

    WlrLayershell.layer: WlrLayer.Overlay
    visible: !ScreenState.isFullscreen(monitor)

    readonly property HyprlandMonitor monitor:
        Hyprland.monitorFor(screen)

    exclusiveZone: Layout.exclusive

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: 10
    }

    implicitHeight: root.implicitHeight

    color: "#00000000"

    mask: Region {
        item: root
    }

    Rectangle {
        id: root

        /*
         * Clock is always widget 0.
         */
        property int currentWidget: 0

        property int transitionDirection: 0

        property bool transitioning: false

        /*
         * Time before automatically returning to the clock.
         */
        property int widgetTimeout: 30000

        implicitWidth: Math.min(
            Math.max(
                widgetLoader.item?.implicitWidth ?? 0,
                Layout.islandMinWidth
            ),
            Layout.islandMaxWidth
        )

        implicitHeight: Math.min(
            Math.max(
                widgetLoader.item?.implicitHeight ?? 0,
                Layout.islandMinHeight
            ),
            Layout.islandMaxHeight
        )

        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }

        radius: 17.5

        color: "white"

        clip: true

        Behavior on implicitWidth {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        Behavior on implicitHeight {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        /*
         * Inactivity timer.
         *
         * This is restarted whenever the user interacts
         * with the island.
         */
        Timer {
            id: widgetTimeoutTimer

            interval: root.widgetTimeout
            repeat: false

            onTriggered: {
                if (root.currentWidget !== 0) {
                    root.switchWidget(0, 1)
                }
            }
        }

        /*
         * Restart the timeout countdown.
         */
        function resetWidgetTimeout() {
            widgetTimeoutTimer.stop()

            if (root.currentWidget !== 0)
                widgetTimeoutTimer.start()
        }

        Item {
            id: widgetContainer

            anchors.fill: parent

            clip: true

            Loader {
                id: widgetLoader

                anchors.centerIn: parent

                sourceComponent:
                    WidgetLoader.getComponent(
                        root.currentWidget
                    )

                opacity: 1
                scale: 1

                transform: Translate {
                    id: widgetTranslation

                    x: 0
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on x {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        function switchWidget(index, direction) {
            if (root.transitioning)
                return

            if (index < 0 || index >= WidgetLoader.count)
                return

            if (index === root.currentWidget) {
                root.resetWidgetTimeout()
                return
            }

            root.transitioning = true
            root.transitionDirection = direction

            /*
             * Any widget switch counts as interaction.
             */
            root.resetWidgetTimeout()

            widgetLoader.opacity = 0
            widgetLoader.scale = 0.96

            widgetTranslation.x =
                root.transitionDirection * 35

            root.currentWidget = index

            /*
             * If we switched to the clock, there is no
             * reason for the timeout timer to remain active.
             */
            if (root.currentWidget === 0)
                widgetTimeoutTimer.stop()

            Qt.callLater(function() {
                widgetLoader.opacity = 1
                widgetLoader.scale = 1

                widgetTranslation.x = 0

                root.transitioning = false
            })
        }

        function nextWidget() {
            root.switchWidget(
                WidgetLoader.nextIndex(
                    root.currentWidget
                ),
                -1
            )
        }

        function previousWidget() {
            root.switchWidget(
                WidgetLoader.previousIndex(
                    root.currentWidget
                ),
                1
            )
        }

        /*
         * IPC
         */
        IpcHandler {
            target: "island"

            function nextWidget(): void {
                root.nextWidget()
            }

            function previousWidget(): void {
                root.previousWidget()
            }

            function setWidget(index: int): void {
                root.switchWidget(index, -1)
            }
        }

        /*
         * Swipe Logic
         */
        MouseArea {
            anchors.fill: parent
            z: -1

            property real sx: 0
            property real sy: 0

            onPressed: function(mouse) {
                sx = mouse.x
                sy = mouse.y

                /*
                 * Pressing the island counts as activity.
                 */
                root.resetWidgetTimeout()
            }

            onReleased: function(mouse) {
                const dx = mouse.x - sx
                const dy = mouse.y - sy

                /*
                 * Ignore small movements.
                 */
                if (Math.abs(dx) < 50) {
                    root.resetWidgetTimeout()
                    return
                }

                /*
                 * Ignore mostly vertical swipes.
                 */
                if (Math.abs(dx) < Math.abs(dy)) {
                    root.resetWidgetTimeout()
                    return
                }

                if (dx < 0) {
                    root.nextWidget()
                } else {
                    root.previousWidget()
                }
            }
        }
    }

    Workspace {
        id: workspace
    }
}