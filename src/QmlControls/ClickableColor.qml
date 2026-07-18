import QtQuick
import QtQuick.Dialogs

// Uses QtQuick.Dialogs' ColorDialog (QML-only implementation) rather than
// Qt.labs.platform's, which requires a native Qt Widgets backend that isn't
// linked into mobile builds -- there it silently fails to open at all
// ("No native ColorDialog implementation available").
Rectangle {
    id:             _root
    width:          80
    height:         20
    border.width:   1
    border.color:   "black"

    signal colorSelected(var color)

    ColorDialog {
        id:            colorDialog
        selectedColor: _root.color
        onAccepted:    _root.colorSelected(selectedColor)
    }

    MouseArea {
        anchors.fill: parent

        onClicked: {
            colorDialog.selectedColor = _root.color
            colorDialog.open()
        }
    }
}
