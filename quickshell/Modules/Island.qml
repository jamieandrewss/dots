import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

import qs.Common
import qs.Services

PanelWindow {
    id: islandWindow

    WlrLayershell.layer: WlrLayer.Overlay
    visible: !ScreenState.isFullscreen(monitor)

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)

    exclusiveZone: Layout.exclusive

    anchors { top: true; left: true; right: true }

    margins { top: 10 }

    implicitHeight: root.implicitHeight

    color: "#00000000"

    mask: Region { item: root }

    // Main Island
    Rectangle {
        id: root

        property int currentWidget: 0

        // Direction of the most recent swipe.
        // -1 = left
        //  1 = right
        property int transitionDirection: 0

        // Used to trigger the widget animation.
        property int transitionId: 0

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

        // =====================================================
        // Island resizing
        // =====================================================

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

        // =====================================================
        // Widget container
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

                // -------------------------------------------------
                // Fade
                // -------------------------------------------------

                Behavior on opacity {
                    NumberAnimation {
                        duration: 180

                        easing.type: Easing.OutCubic
                    }
                }

                // -------------------------------------------------
                // Scale
                // -------------------------------------------------

                Behavior on scale {
                    NumberAnimation {
                        duration: 250

                        easing.type: Easing.OutCubic
                    }
                }

                // -------------------------------------------------
                // Slide
                // -------------------------------------------------

                Behavior on x {
                    NumberAnimation {
                        duration: 300

                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        // =====================================================
        // Swipe detection
        // =====================================================

        MouseArea {
            anchors.fill: parent

            property real sx: 0
            property real sy: 0

            onPressed: function(mouse) {
                sx = mouse.x
                sy = mouse.y
            }

            onReleased: function(mouse) {
                const dx = mouse.x - sx
                const dy = mouse.y - sy

                // Ignore small movements.
                if (Math.abs(dx) < 50)
                    return

                // Ignore mostly vertical swipes.
                if (Math.abs(dx) < Math.abs(dy))
                    return

                const oldWidget =
                    root.currentWidget

                let newWidget

                // -------------------------------------------------
                // Swipe left
                // -------------------------------------------------

                if (dx < 0) {
                    newWidget =
                        WidgetLoader.nextIndex(
                            root.currentWidget
                        )

                    root.transitionDirection = -1
                }

                // -------------------------------------------------
                // Swipe right
                // -------------------------------------------------

                else {
                    newWidget =
                        WidgetLoader.previousIndex(
                            root.currentWidget
                        )

                    root.transitionDirection = 1
                }

                if (newWidget < 0)
                    return

                if (newWidget === oldWidget)
                    return

                // -------------------------------------------------
                // Animate the current widget out
                // -------------------------------------------------

                widgetLoader.opacity = 0
                widgetLoader.scale = 0.96

                widgetTranslation.x =
                    root.transitionDirection * 35

                // -------------------------------------------------
                // Change widget
                // -------------------------------------------------

                root.currentWidget = newWidget

                // -------------------------------------------------
                // Animate new widget in from the opposite side
                // -------------------------------------------------

                Qt.callLater(function() {
                    widgetLoader.opacity = 1
                    widgetLoader.scale = 1

                    widgetTranslation.x =
                        0
                })
            }
        }
    }

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
                family: "JetBrainsMono Nerd Font"
                pointSize: 12
                weight: Font.Bold
            }

            color: "black"
        }

        Behavior on width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }
}