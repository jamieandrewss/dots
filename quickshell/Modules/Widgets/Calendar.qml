import QtQuick
import Quickshell

import qs.Common

Item {
    id: root

    implicitWidth: 320
    implicitHeight: 290

    property date displayedDate: new Date()

    property int displayedMonth: displayedDate.getMonth()
    property int displayedYear: displayedDate.getFullYear()

    function daysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate()
    }

    function firstDayOfMonth(year, month) {
        // JavaScript:
        // Sunday = 0
        // Monday = 1
        // ...
        //
        // Convert to:
        // Monday = 0
        // ...
        // Sunday = 6

        return (new Date(year, month, 1).getDay() + 6) % 7
    }

    function isToday(day) {
        const now = new Date()

        return (
            now.getFullYear() === displayedYear &&
            now.getMonth() === displayedMonth &&
            now.getDate() === day
        )
    }

    function previousMonth() {
        if (displayedMonth === 0) {
            displayedMonth = 11
            displayedYear--
        } else {
            displayedMonth--
        }
    }

    function nextMonth() {
        if (displayedMonth === 11) {
            displayedMonth = 0
            displayedYear++
        } else {
            displayedMonth++
        }
    }

    function goToToday() {
        const now = new Date()

        displayedYear = now.getFullYear()
        displayedMonth = now.getMonth()
    }

    function monthName(month) {
        const names = [
            "January",
            "February",
            "March",
            "April",
            "May",
            "June",
            "July",
            "August",
            "September",
            "October",
            "November",
            "December"
        ]

        return names[month]
    }

    Timer {
        interval: 60000
        running: true
        repeat: true

        onTriggered: {
            const now = new Date()

            if (
                now.getDate() !==
                root.displayedDate.getDate()
            ) {
                root.displayedDate = now
            }
        }
    }

    Rectangle {
        id: calendar

        anchors.fill: parent

        radius: 17.5
        color: "white"

        Column {
            anchors {
                fill: parent
                margins: 16
            }

            spacing: 12

            // Header
            Item {
                width: parent.width
                height: 30

                Text {
                    id: monthTitle

                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }

                    text:
                        root.monthName(root.displayedMonth)
                        + " "
                        + root.displayedYear

                    font.family: Theme.fonts.monospace
                    font.pointSize: 13
                    font.weight: Font.Medium

                    color: "#202020"
                }

                Row {
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }

                    spacing: 4

                    Rectangle {
                        width: 28
                        height: 28

                        radius: 8

                        color: previousMouse.containsMouse
                            ? "#eeeeee"
                            : "transparent"

                        Text {
                            anchors.centerIn: parent

                            text: "󰒮"

                            font.family: "Symbols Nerd Font"
                            font.pointSize: 13

                            color: "#303030"
                        }

                        MouseArea {
                            id: previousMouse

                            anchors.fill: parent

                            hoverEnabled: true

                            onClicked: {
                                root.previousMonth()
                            }
                        }
                    }

                    Rectangle {
                        width: 28
                        height: 28

                        radius: 8

                        color: todayMouse.containsMouse
                            ? "#eeeeee"
                            : "transparent"

                        Text {
                            anchors.centerIn: parent

                            text: "󰑐"

                            font.family: "Symbols Nerd Font"
                            font.pointSize: 13

                            color: "#303030"
                        }

                        MouseArea {
                            id: todayMouse

                            anchors.fill: parent

                            hoverEnabled: true

                            onClicked: {
                                root.goToToday()
                            }
                        }
                    }

                    Rectangle {
                        width: 28
                        height: 28

                        radius: 8

                        color: nextMouse.containsMouse
                            ? "#eeeeee"
                            : "transparent"

                        Text {
                            anchors.centerIn: parent

                            text: "󰒭"

                            font.family: "Symbols Nerd Font"
                            font.pointSize: 13

                            color: "#303030"
                        }

                        MouseArea {
                            id: nextMouse

                            anchors.fill: parent

                            hoverEnabled: true

                            onClicked: {
                                root.nextMonth()
                            }
                        }
                    }
                }
            }

            // Weekday labels
            Row {
                width: parent.width
                height: 22

                Repeater {
                    model: [
                        "MON",
                        "TUE",
                        "WED",
                        "THU",
                        "FRI",
                        "SAT",
                        "SUN"
                    ]

                    delegate: Item {
                        width: parent.width / 7
                        height: 22

                        Text {
                            anchors.centerIn: parent

                            text: modelData

                            font.family: Theme.fonts.monospace
                            font.pointSize: 8
                            font.weight: Font.Medium

                            color: "#888888"
                        }
                    }
                }
            }

            // Calendar grid
            Grid {
                id: calendarGrid

                width: parent.width
                height: 168

                columns: 7
                rows: 6

                property int firstDay:
                    root.firstDayOfMonth(
                        root.displayedYear,
                        root.displayedMonth
                    )

                property int monthDays:
                    root.daysInMonth(
                        root.displayedYear,
                        root.displayedMonth
                    )

                Repeater {
                    model: 42

                    delegate: Item {
                        width: calendarGrid.width / 7
                        height: calendarGrid.height / 6

                        property int dayNumber:
                            index -
                            calendarGrid.firstDay +
                            1

                        property bool validDay:
                            dayNumber >= 1 &&
                            dayNumber <= calendarGrid.monthDays

                        Rectangle {
                            anchors.centerIn: parent

                            width: 30
                            height: 30

                            radius: 10

                            color: {
                                if (
                                    validDay &&
                                    root.isToday(dayNumber)
                                ) {
                                    return "#303030"
                                }

                                if (
                                    validDay &&
                                    dayMouse.containsMouse
                                ) {
                                    return "#eeeeee"
                                }

                                return "transparent"
                            }

                            Text {
                                anchors.centerIn: parent

                                text: validDay
                                    ? dayNumber
                                    : ""

                                font.family:
                                    Theme.fonts.monospace

                                font.pointSize: 10

                                font.weight:
                                    root.isToday(dayNumber)
                                        ? Font.Medium
                                        : Font.Normal

                                color:
                                    root.isToday(dayNumber)
                                        ? "white"
                                        : "#303030"
                            }

                            MouseArea {
                                id: dayMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                enabled: validDay
                            }
                        }
                    }
                }
            }
        }
    }
}