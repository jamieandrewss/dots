import QtQuick
import Quickshell

Item {
    id: root

    implicitHeight: clockText.height
    implicitWidth: clockText.width

    Text {
        id: clockText

        anchors { centerIn: parent }
        
        text: Qt.formatDateTime(clock.date, "hh:mm")

        font {
            family: "JetBrainsMono NF"
            pointSize: 14
            weight: 600
        }

    }

    SystemClock { id: clock; precision: SystemClock.Seconds }
}