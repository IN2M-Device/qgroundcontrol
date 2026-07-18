import QtQuick

import QGroundControl
import QGroundControl.Controls

// Fixed target reticle overlay for FlyView. Reticles are not draggable -- position
// and style are set only via the Targets settings page (Settings > Fly View > Targets).
// Positions are persisted as fractions (0-1) of this item's size so they stay
// put relative to the viewport across window resizes.
Item {
    id: _root

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

    Repeater {
        model: _flyViewSettings.targetCount.value

        TargetReticleGraphic {
            width:        ScreenTools.defaultFontPixelHeight * 2.5
            height:       width
            x:            (_root._posXFact(index).value * _root.width)  - (width  / 2)
            y:            (_root._posYFact(index).value * _root.height) - (height / 2)
            style:        _root._reticleStyleFact(index).value
            reticleColor: _root._colorFact(index).value
        }
    }
}
