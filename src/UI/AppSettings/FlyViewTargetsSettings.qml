import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FactControls

SettingsGroupLayout {
    id: _root

    heading: qsTr("Targets")

    readonly property var _flyViewSettings: QGroundControl.settingsManager.flyViewSettings

    function _colorFact(index) {
        switch (index) {
        case 0:  return _flyViewSettings.target1Color
        case 1:  return _flyViewSettings.target2Color
        case 2:  return _flyViewSettings.target3Color
        default: return _flyViewSettings.target4Color
        }
    }

    function _reticleStyleFact(index) {
        switch (index) {
        case 0:  return _flyViewSettings.target1ReticleStyle
        case 1:  return _flyViewSettings.target2ReticleStyle
        case 2:  return _flyViewSettings.target3ReticleStyle
        default: return _flyViewSettings.target4ReticleStyle
        }
    }

    function _posXFact(index) {
        switch (index) {
        case 0:  return _flyViewSettings.target1PosX
        case 1:  return _flyViewSettings.target2PosX
        case 2:  return _flyViewSettings.target3PosX
        default: return _flyViewSettings.target4PosX
        }
    }

    function _posYFact(index) {
        switch (index) {
        case 0:  return _flyViewSettings.target1PosY
        case 1:  return _flyViewSettings.target2PosY
        case 2:  return _flyViewSettings.target3PosY
        default: return _flyViewSettings.target4PosY
        }
    }

    // Each active target must have a distinct color. Returns true if colorString
    // (a "#rrggbb" string) is already in use by a different active target.
    function _isColorDuplicate(index, colorString) {
        var newColor = colorString.toString().toLowerCase()
        for (var i = 0; i < _flyViewSettings.targetCount.value; i++) {
            if (i !== index && _colorFact(i).value.toString().toLowerCase() === newColor) {
                return true
            }
        }
        return false
    }

    readonly property var _defaultColorPalette: ["#FF0000", "#00FF00", "#0000FF", "#FFFF00"]

    // A target hidden by a lower targetCount can't be edited, so it can silently
    // end up matching a color later chosen for a still-visible target. Whenever
    // the active set changes (including a target becoming visible again), re-scan
    // and reassign any now-visible duplicate to the next unused palette color.
    function _resolveDuplicateColors() {
        var used = []
        for (var i = 0; i < _flyViewSettings.targetCount.value; i++) {
            var fact = _colorFact(i)
            var current = fact.value.toString().toLowerCase()
            if (used.indexOf(current) !== -1) {
                for (var p = 0; p < _defaultColorPalette.length; p++) {
                    var candidate = _defaultColorPalette[p].toLowerCase()
                    if (used.indexOf(candidate) === -1) {
                        fact.value = _defaultColorPalette[p]
                        current = candidate
                        break
                    }
                }
            }
            used.push(current)
        }
    }

    Component.onCompleted: _resolveDuplicateColors()

    Connections {
        target: _root._flyViewSettings.targetCount
        function onValueChanged() { _root._resolveDuplicateColors() }
    }

    QGCPalette { id: qgcPal }

    FactCheckBoxSlider {
        Layout.fillWidth: true
        text:             qsTr("Show Targets Button")
        fact:             _root._flyViewSettings.showTargetsButton
    }

    LabelledFactIncrementer {
        Layout.fillWidth: true
        label:            qsTr("Number of Targets")
        fact:             _root._flyViewSettings.targetCount
        step:             1
    }

    Repeater {
        model: _root._flyViewSettings.targetCount.value

        ColumnLayout {
            id:      targetRow
            Layout.fillWidth: true
            spacing: ScreenTools.defaultFontPixelHeight / 4

            property bool duplicateColor: false

            RowLayout {
                Layout.fillWidth: true
                spacing:          ScreenTools.defaultFontPixelWidth

                QGCLabel {
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
                    text:                  qsTr("Target %1").arg(index + 1)
                }

                ClickableColor {
                    color: _root._colorFact(index).value
                    onColorSelected: (c) => {
                        if (_root._isColorDuplicate(index, c)) {
                            targetRow.duplicateColor = true
                        } else {
                            targetRow.duplicateColor = false
                            _root._colorFact(index).value = c.toString()
                        }
                    }
                }

                QGCLabel { text: qsTr("Style:") }

                FactComboBox {
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 16
                    sizeToContents:        true
                    fact:                  _root._reticleStyleFact(index)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing:          ScreenTools.defaultFontPixelWidth

                Item { Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 } // align under "Target N"

                QGCLabel { text: qsTr("X:") }

                QGCTextField {
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 6
                    numericValuesOnly:     true
                    validator:              IntValidator { bottom: 0; top: 100 }
                    text:                   Math.round(_root._posXFact(index).value * 100)
                    onEditingFinished:      _root._posXFact(index).value = parseInt(text) / 100
                }

                QGCLabel { text: qsTr("%") }

                QGCLabel { text: qsTr("Y:") }

                QGCTextField {
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 6
                    numericValuesOnly:     true
                    validator:              IntValidator { bottom: 0; top: 100 }
                    text:                   Math.round(_root._posYFact(index).value * 100)
                    onEditingFinished:      _root._posYFact(index).value = parseInt(text) / 100
                }

                QGCLabel { text: qsTr("%") }
            }

            QGCLabel {
                Layout.fillWidth:   true
                visible:            targetRow.duplicateColor
                text:               qsTr("That color is already used by another target. Choose a different color.")
                color:              qgcPal.colorRed
                font.pointSize:     ScreenTools.smallFontPointSize
                wrapMode:           Text.WordWrap
            }
        }
    }
}
