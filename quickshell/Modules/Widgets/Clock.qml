import QtQuick
import Quickshell

import qs.Common

Item {
    id: root

    implicitHeight: clockText.height
    implicitWidth: clockText.width

    Text {
        id: clockText

        anchors { centerIn: parent }
        
        text: Qt.formatDateTime(clock.date, "hh:mm")

        font {
            family: Theme.fonts.monospace
            pointSize: 14
            weight: 700
        }

    }

    SystemClock { id: clock; precision: SystemClock.Seconds }
}