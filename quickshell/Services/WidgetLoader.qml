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
     * Clock is ALWAYS index 0.
     *
     * All other widgets are shifted down by one.
     */
    function getSourceIndex(index) {
        if (index === 0)
            return getWidgetIndex("Clock")

        let clockIndex = getWidgetIndex("Clock")

        if (clockIndex === -1)
            return index

        /*
         * Since Clock occupies our virtual index 0,
         * skip over its real FolderListModel index.
         */
        let realIndex = index - 1

        if (realIndex >= clockIndex)
            realIndex++

        return realIndex
    }

    function getComponent(index) {
        if (index < 0 || index >= count)
            return null

        let realIndex = getSourceIndex(index)

        if (realIndex < 0 || realIndex >= widgets.count)
            return null

        return Qt.createComponent(
            widgets.get(realIndex, "fileUrl")
        )
    }

    function getName(index) {
        if (index < 0 || index >= count)
            return ""

        if (index === 0)
            return "Clock"

        let realIndex = getSourceIndex(index)

        if (realIndex < 0 || realIndex >= widgets.count)
            return ""

        return widgets.get(
            realIndex,
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