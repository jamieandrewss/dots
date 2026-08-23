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

    function getComponent(index) {
        if (index < 0 || index >= widgets.count)
            return null

        return Qt.createComponent(
            widgets.get(index, "fileUrl")
        )
    }

    function getName(index) {
        if (index < 0 || index >= widgets.count)
            return ""

        return widgets.get(index, "fileBaseName")
    }

    function nextIndex(index) {
        if (widgets.count === 0)
            return -1

        return (index + 1) % widgets.count
    }

    function previousIndex(index) {
        if (widgets.count === 0)
            return -1

        return (index - 1 + widgets.count) % widgets.count
    }
}