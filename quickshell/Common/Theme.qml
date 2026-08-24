pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    readonly property Fonts fonts: Fonts {}
    readonly property Colour colour: Colour {}

    component Fonts: QtObject {
        readonly property string sserif:    "Noto Sans"
        readonly property string monospace: "AnnotationM Nerd Font Mono"
    }

    component Colour: QtObject {
        readonly property string bg:            "#FFF5F7"
        readonly property string surface:       "#FFE9EE"
        readonly property string surface_alt:   "#FFDDE5"
        readonly property string primary:       "#EFA3B5"
        readonly property string primary_alt:   "#D9869D"
        readonly property string accent:        "#C96F88"
        readonly property string text:          "#4A343B"
        readonly property string text_muted:    "#80656D"
        readonly property string border:        "#EFC5CE"
        readonly property string success:       "#A8D5BA"
        readonly property string warning:       "#F2D49B"
        readonly property string error:         "#E9A0A0"
    }
}