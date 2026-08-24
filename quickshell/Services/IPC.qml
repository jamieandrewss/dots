pragma Singleton

import QtQuick

QtObject {
    id: root

    signal nextWidget()
    signal previousWidget()
    signal setWidget(int index)
}