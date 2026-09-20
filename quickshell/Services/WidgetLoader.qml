pragma Singleton

import QtQuick
import Qt.labs.folderlistmodel

QtObject {
    id: root

    readonly property url widgetsPath:
        Qt.resolvedUrl("../Modules/Widgets/")

    readonly property FolderListModel widgets: FolderListModel {
        folder: root.widgetsPath

        nameFilters: ["*.qml"]

        showDirs: false
        showFiles: true
    }

    readonly property int count: widgets.count

    function getWidgetIndex(fileName) {
        for (let i = 0; i < widgets.count; i++) {
            if (widgets.get(i, "fileBaseName") === fileName)
                return i
        }

        return -1
    }

    /*
     * Virtual widget ordering:
     *
     * 0 = Clock
     * 1 = MusicController
     * 2+ = Everything else
     */
    function getSourceIndex(index) {
        const clockIndex =
            getWidgetIndex("Clock")

        const musicIndex =
            getWidgetIndex("MusicController")

        /*
         * Clock is always virtual index 0.
         */
        if (index === 0) {
            return clockIndex
        }

        /*
         * MusicController is always virtual index 1.
         */
        if (index === 1) {
            return musicIndex
        }

        /*
         * Everything after Clock and MusicController
         * comes from the remaining widgets.
         */
        let remainingIndex = index - 2

        for (let i = 0; i < widgets.count; i++) {
            const name =
                widgets.get(i, "fileBaseName")

            if (name === "Clock")
                continue

            if (name === "MusicController")
                continue

            if (remainingIndex === 0)
                return i

            remainingIndex--
        }

        return -1
    }

    function getComponent(index) {
        if (index < 0 || index >= count)
            return null

        const sourceIndex =
            getSourceIndex(index)

        if (
            sourceIndex < 0 ||
            sourceIndex >= widgets.count
        ) {
            return null
        }

        return Qt.createComponent(
            widgets.get(
                sourceIndex,
                "fileUrl"
            )
        )
    }

    function getName(index) {
        if (index < 0 || index >= count)
            return ""

        if (index === 0)
            return "Clock"

        if (index === 1)
            return "MusicController"

        const sourceIndex =
            getSourceIndex(index)

        if (
            sourceIndex < 0 ||
            sourceIndex >= widgets.count
        ) {
            return ""
        }

        return widgets.get(
            sourceIndex,
            "fileBaseName"
        )
    }

    function nextIndex(index) {
        if (count === 0)
            return -1

        return (index + 1) % count
    }

    function previousIndex(index) {
        if (count === 0)
            return -1

        return (index - 1 + count) % count
    }
}