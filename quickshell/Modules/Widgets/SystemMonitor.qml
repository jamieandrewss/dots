import QtQuick
import Quickshell
import Quickshell.Io

import qs.Common

Item {
    id: root

    implicitWidth: 360
    implicitHeight: 190

    property real cpuUsage: 0
    property real ramUsage: 0
    property real gpuUsage: 0
    property real cpuTemp: 0
    property real gpuTemp: 0

    property real previousCpuIdle: 0
    property real previousCpuTotal: 0

    Process {
        id: procStats

        command: [
            "sh",
            "-c",
            "cat /proc/stat | head -n 1; free -b"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")

                if (lines.length < 2)
                    return

                const cpu = lines[0].trim().split(/\s+/)

                if (cpu.length >= 5) {
                    const user = parseFloat(cpu[1]) || 0
                    const nice = parseFloat(cpu[2]) || 0
                    const system = parseFloat(cpu[3]) || 0
                    const idle = parseFloat(cpu[4]) || 0
                    const iowait = parseFloat(cpu[5]) || 0
                    const irq = parseFloat(cpu[6]) || 0
                    const softirq = parseFloat(cpu[7]) || 0
                    const steal = parseFloat(cpu[8]) || 0

                    const total =
                        user +
                        nice +
                        system +
                        idle +
                        iowait +
                        irq +
                        softirq +
                        steal

                    const idleTotal =
                        idle +
                        iowait

                    if (root.previousCpuTotal > 0) {
                        const totalDelta =
                            total -
                            root.previousCpuTotal

                        const idleDelta =
                            idleTotal -
                            root.previousCpuIdle

                        if (totalDelta > 0) {
                            root.cpuUsage =
                                Math.max(
                                    0,
                                    Math.min(
                                        100,
                                        100 *
                                        (1 -
                                        idleDelta /
                                        totalDelta)
                                    )
                                )
                        }
                    }

                    root.previousCpuTotal = total
                    root.previousCpuIdle = idleTotal
                }

                for (let i = 1; i < lines.length; i++) {
                    if (!lines[i].startsWith("Mem:"))
                        continue

                    const mem =
                        lines[i].trim().split(/\s+/)

                    if (mem.length >= 3) {
                        const total =
                            parseFloat(mem[1]) || 0

                        const used =
                            parseFloat(mem[2]) || 0

                        if (total > 0) {
                            root.ramUsage =
                                Math.max(
                                    0,
                                    Math.min(
                                        100,
                                        used / total * 100
                                    )
                                )
                        }
                    }

                    break
                }
            }
        }
    }

    Process {
        id: gpuUsageProcess

        command: [
            "sh",
            "-c",
            "for f in /sys/class/drm/card*/device/gpu_busy_percent; do " +
            "cat \"$f\" 2>/dev/null && exit; " +
            "done"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const value =
                    parseFloat(text.trim())

                if (!isNaN(value)) {
                    root.gpuUsage =
                        Math.max(
                            0,
                            Math.min(100, value)
                        )
                }
            }
        }
    }

    Process {
        id: gpuTempProcess

        command: [
            "sh",
            "-c",
            "for f in /sys/class/drm/card*/device/hwmon/hwmon*/temp1_input; do " +
            "cat \"$f\" 2>/dev/null && exit; " +
            "done"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const value =
                    parseFloat(text.trim())

                if (!isNaN(value)) {
                    root.gpuTemp = value / 1000
                }
            }
        }
    }

    Process {
        id: cpuTempProcess

        command: [
            "sh",
            "-c",
            "sensors -j 2>/dev/null"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text)

                    const temperature =
                        findCpuTemperature(data)

                    if (temperature >= 0)
                        root.cpuTemp = temperature
                } catch (e) {
                }
            }
        }
    }

    function findCpuTemperature(object) {
        if (!object || typeof object !== "object")
            return -1

        for (const key in object) {
            const value = object[key]

            if (
                typeof value === "object" &&
                value !== null
            ) {
                const lowerKey =
                    key.toLowerCase()

                if (
                    lowerKey.includes("package") ||
                    lowerKey.includes("tctl") ||
                    lowerKey.includes("tdie")
                ) {
                    for (const tempKey in value) {
                        if (
                            tempKey
                                .toLowerCase()
                                .includes("input")
                        ) {
                            const temp =
                                parseFloat(
                                    value[tempKey]
                                )

                            if (!isNaN(temp))
                                return temp
                        }
                    }
                }

                const result =
                    findCpuTemperature(value)

                if (result >= 0)
                    return result
            }
        }

        return -1
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            if (!procStats.running)
                procStats.running = true

            if (!gpuUsageProcess.running)
                gpuUsageProcess.running = true

            if (!gpuTempProcess.running)
                gpuTempProcess.running = true

            if (!cpuTempProcess.running)
                cpuTempProcess.running = true
        }
    }

    Rectangle {
        id: monitor

        anchors.fill: parent

        radius: 17.5
        color: "white"

        Column {
            anchors {
                fill: parent
                margins: 16
            }

            spacing: 10

            Text {
                text: "System Monitor"

                font.family: Theme.fonts.monospace
                font.pointSize: 13
                font.weight: Font.Medium

                color: "#202020"
            }

            Row {
                width: parent.width
                height: 38

                spacing: 12

                UsageItem {
                    width: (parent.width - 12) / 2

                    label: "CPU"
                    value: root.cpuUsage
                }

                UsageItem {
                    width: (parent.width - 12) / 2

                    label: "GPU"
                    value: root.gpuUsage
                }
            }

            UsageItem {
                width: parent.width

                label: "RAM"
                value: root.ramUsage
            }

            Row {
                width: parent.width
                height: 22

                spacing: 12

                TemperatureItem {
                    width: (parent.width - 12) / 2

                    label: "CPU"
                    temperature: root.cpuTemp
                }

                TemperatureItem {
                    width: (parent.width - 12) / 2

                    label: "GPU"
                    temperature: root.gpuTemp
                }
            }
        }
    }

    component UsageItem: Item {
        property string label: ""
        property real value: 0

        height: 38

        Column {
            anchors.fill: parent

            spacing: 4

            Item {
                width: parent.width
                height: 15

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    text: label

                    font.family:
                        Theme.fonts.monospace

                    font.pointSize: 9
                    font.weight: Font.Medium

                    color: "#555555"
                }

                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    text:
                        Math.round(value) + "%"

                    font.family:
                        Theme.fonts.monospace

                    font.pointSize: 9
                    font.weight: Font.Medium

                    color: "#202020"
                }
            }

            Rectangle {
                width: parent.width
                height: 6

                radius: 3

                color: "#eeeeee"

                Rectangle {
                    width:
                        parent.width *
                        Math.min(
                            1,
                            Math.max(
                                0,
                                value / 100
                            )
                        )

                    height: parent.height

                    radius: 3

                    color: "#303030"

                    Behavior on width {
                        NumberAnimation {
                            duration: 250

                            easing.type:
                                Easing.OutCubic
                        }
                    }
                }
            }
        }
    }

    component TemperatureItem: Item {
        property string label: ""
        property real temperature: 0

        height: 22

        Item {
            anchors.fill: parent

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                text: label

                font.family:
                    Theme.fonts.monospace

                font.pointSize: 9
                font.weight: Font.Medium

                color: "#777777"
            }

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                text:
                    temperature > 0
                        ? Math.round(temperature) + "°C"
                        : "--°C"

                font.family:
                    Theme.fonts.monospace

                font.pointSize: 10
                font.weight: Font.Medium

                color: "#202020"
            }
        }
    }
}