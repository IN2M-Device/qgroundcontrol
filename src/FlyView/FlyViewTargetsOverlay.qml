import QtQuick

import QGroundControl
import QGroundControl.Controls

// Fixed target reticle overlay for FlyView. Reticles are not draggable -- position
// and style are set only via the Targets settings page (Settings > Fly View > Targets).
// Positions are persisted as fractions (0-1) of this item's size so they stay
// put relative to the viewport across window resizes.
//
// Built entirely from Rectangle primitives rather than Canvas: QtQuick Canvas's
// FBO/texture allocation was found to silently fail (blank output, no error) on
// some GL backends (reproduced on an Android emulator using GPU passthrough),
// so it's not a reliable choice for a widget that must always render.
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

        Item {
            id:     reticle
            width:  ScreenTools.defaultFontPixelHeight * 2.5
            height: width
            x:      (_root._posXFact(index).value * _root.width)  - (width  / 2)
            y:      (_root._posYFact(index).value * _root.height) - (height / 2)

            readonly property color _targetColor: _root._colorFact(index).value
            readonly property real  _lineWidth:   Math.max(1, width * 0.06)
            readonly property real  _outerR:      width / 2 * 0.8

            readonly property int  _style: _root._reticleStyleFact(index).value

            // Number of concentric rings, whether the crosshair has a gap at the
            // ring, whether a center dot is shown, and any style-specific extras.
            readonly property int  _ringCount: {
                switch (_style) {
                case 0: return 2 // Bullseye Dot
                case 2: return 2 // Bullseye Marks
                case 3: return 2 // Double Ring
                case 7: return 3 // Concentric
                case 8: return 2 // Focus Brackets
                default: return 1
                }
            }
            readonly property bool _gapped:    _style === 1 || _style === 4 || _style === 5 || _style === 8
            readonly property bool _showDot:   _style !== 2 && _style !== 7
            readonly property bool _offsetDot: _style === 5
            readonly property bool _endCaps:   _style === 4
            readonly property bool _brackets:  _style === 8

            // Concentric rings
            Repeater {
                model: reticle._ringCount

                Rectangle {
                    readonly property real _scale: 1.0 - (index * 0.35)
                    anchors.centerIn: parent
                    width:            reticle._outerR * 2 * _scale
                    height:           width
                    radius:           width / 2
                    color:            "transparent"
                    border.color:     reticle._targetColor
                    border.width:     reticle._lineWidth
                }
            }

            // Full crosshair, edge to edge through the rings
            Rectangle {
                visible:                  !reticle._gapped
                anchors.verticalCenter:   parent.verticalCenter
                width:                    reticle.width
                height:                   reticle._lineWidth
                color:                    reticle._targetColor
            }
            Rectangle {
                visible:                  !reticle._gapped
                anchors.horizontalCenter: parent.horizontalCenter
                width:                    reticle._lineWidth
                height:                   reticle.height
                color:                    reticle._targetColor
            }

            // Gapped crosshair: four short segments from the outer ring to the edge
            Rectangle { // left
                visible: reticle._gapped
                x:       0
                y:       reticle.height / 2 - reticle._lineWidth / 2
                width:   reticle.width / 2 - reticle._outerR
                height:  reticle._lineWidth
                color:   reticle._targetColor
            }
            Rectangle { // right
                visible: reticle._gapped
                x:       reticle.width / 2 + reticle._outerR
                y:       reticle.height / 2 - reticle._lineWidth / 2
                width:   reticle.width / 2 - reticle._outerR
                height:  reticle._lineWidth
                color:   reticle._targetColor
            }
            Rectangle { // top
                visible: reticle._gapped
                x:       reticle.width / 2 - reticle._lineWidth / 2
                y:       0
                width:   reticle._lineWidth
                height:  reticle.height / 2 - reticle._outerR
                color:   reticle._targetColor
            }
            Rectangle { // bottom
                visible: reticle._gapped
                x:       reticle.width / 2 - reticle._lineWidth / 2
                y:       reticle.height / 2 + reticle._outerR
                width:   reticle._lineWidth
                height:  reticle.height / 2 - reticle._outerR
                color:   reticle._targetColor
            }

            // Perpendicular end-caps at the outer tips (Cross Ends style)
            Rectangle { // left cap
                visible: reticle._endCaps
                x:       0
                y:       reticle.height / 2 - reticle._lineWidth * 2
                width:   reticle._lineWidth
                height:  reticle._lineWidth * 4
                color:   reticle._targetColor
            }
            Rectangle { // right cap
                visible: reticle._endCaps
                x:       reticle.width - reticle._lineWidth
                y:       reticle.height / 2 - reticle._lineWidth * 2
                width:   reticle._lineWidth
                height:  reticle._lineWidth * 4
                color:   reticle._targetColor
            }
            Rectangle { // top cap
                visible: reticle._endCaps
                x:       reticle.width / 2 - reticle._lineWidth * 2
                y:       0
                width:   reticle._lineWidth * 4
                height:  reticle._lineWidth
                color:   reticle._targetColor
            }
            Rectangle { // bottom cap
                visible: reticle._endCaps
                x:       reticle.width / 2 - reticle._lineWidth * 2
                y:       reticle.height - reticle._lineWidth
                width:   reticle._lineWidth * 4
                height:  reticle._lineWidth
                color:   reticle._targetColor
            }

            // Center dot (optionally offset off-axis for the Offset Dot style)
            Rectangle {
                visible:                reticle._showDot
                width:                  reticle.width * 0.12
                height:                 width
                radius:                 width / 2
                color:                  reticle._targetColor
                anchors.verticalCenter: parent.verticalCenter
                x:                      reticle.width / 2 - (width / 2) + (reticle._offsetDot ? reticle.width * 0.15 : 0)
            }

            // Camera-style corner brackets (Focus Brackets style)
            Repeater {
                model: reticle._brackets ? 4 : 0

                Item {
                    readonly property bool isRight:  index === 1 || index === 2
                    readonly property bool isBottom: index === 2 || index === 3
                    x:      isRight  ? reticle.width  - width  : 0
                    y:      isBottom ? reticle.height - height : 0
                    width:  reticle.width * 0.22
                    height: width

                    Rectangle { // horizontal arm
                        x:      0
                        y:      parent.isBottom ? parent.height - height : 0
                        width:  parent.width
                        height: reticle._lineWidth
                        color:  reticle._targetColor
                    }
                    Rectangle { // vertical arm
                        x:      parent.isRight ? parent.width - width : 0
                        y:      0
                        width:  reticle._lineWidth
                        height: parent.height
                        color:  reticle._targetColor
                    }
                }
            }
        }
    }
}
