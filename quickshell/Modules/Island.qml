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

    visible:
        !ScreenState.isFullscreen(monitor)

    readonly property HyprlandMonitor monitor:
        Hyprland.monitorFor(screen)

    exclusiveZone:
        Layout.exclusive

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: 10
    }

    implicitHeight:
        root.implicitHeight

    color:
        "#00000000"

    mask: Region {
        item: root
    }

    // =========================================================
    // Main Dynamic Island
    // =========================================================

    Rectangle {
        id: root

        property int currentWidget: 0

        // Direction of the most recent transition.
        // -1 = left
        //  1 = right
        property int transitionDirection: 0

        property bool transitioning: false

        implicitWidth:
            Math.min(
                Math.max(
                    widgetLoader.item?.implicitWidth ?? 0,
                    Layout.islandMinWidth
                ),
                Layout.islandMaxWidth
            )

        implicitHeight:
            Math.min(
                Math.max(
                    widgetLoader.item?.implicitHeight ?? 0,
                    Layout.islandMinHeight
                ),
                Layout.islandMaxHeight
            )

        anchors {
            top: parent.top
            horizontalCenter:
                parent.horizontalCenter
        }

        radius: 17.5

        color:
            "white"

        clip: true

        // =====================================================
        // Island Animations
        // =====================================================

        Behavior on implicitWidth {
            NumberAnimation {
                duration: 300
                easing.type:
                    Easing.OutCubic
            }
        }

        Behavior on implicitHeight {
            NumberAnimation {
                duration: 300
                easing.type:
                    Easing.OutCubic
            }
        }

        // =====================================================
        // Widget Container
        // =====================================================

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
                        easing.type:
                            Easing.OutCubic
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 250
                        easing.type:
                            Easing.OutCubic
                    }
                }

                Behavior on x {
                    NumberAnimation {
                        duration: 300
                        easing.type:
                            Easing.OutCubic
                    }
                }
            }
        }

        // =====================================================
        // Widget Switching
        // =====================================================

        function switchWidget(index, direction) {
            if (root.transitioning)
                return

            if (
                index < 0 ||
                index >= WidgetLoader.count
            )
                return

            if (index === root.currentWidget)
                return

            root.transitioning = true

            root.transitionDirection =
                direction

            widgetLoader.opacity = 0
            widgetLoader.scale = 0.96

            widgetTranslation.x =
                root.transitionDirection * 35

            root.currentWidget =
                index

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

        // =====================================================
        // IPC
        // =====================================================

        IpcHandler {
            target:
                "island"

            function nextWidget(): void {
                root.nextWidget()
            }

            function previousWidget(): void {
                root.previousWidget()
            }

            function setWidget(index: int): void {
                root.switchWidget(
                    index,
                    -1
                )
            }
        }

        // =====================================================
        // Swipe Logic
        // =====================================================

        MouseArea {
            anchors.fill: parent

            property real sx: 0
            property real sy: 0

            onPressed:
                function(mouse) {
                    sx = mouse.x
                    sy = mouse.y
                }

            onReleased:
                function(mouse) {
                    const dx =
                        mouse.x - sx

                    const dy =
                        mouse.y - sy

                    // Ignore small movements.
                    if (Math.abs(dx) < 50)
                        return

                    // Ignore mostly vertical swipes.
                    if (
                        Math.abs(dx) <
                        Math.abs(dy)
                    )
                        return

                    if (dx < 0) {
                        root.nextWidget()
                    } else {
                        root.previousWidget()
                    }
                }
        }
    }

    // =========================================================
    // Workspace
    // =========================================================

    Workspace {
        id: workspace
    }
}