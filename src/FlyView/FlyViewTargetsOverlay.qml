import QtQuick

import QGroundControl
import QGroundControl.Controls

// Target reticle overlay for FlyView. Position and style default to the Targets
// settings page (Settings > Fly View > Targets), but a reticle can also be
// repositioned directly on screen with a long-press-then-drag gesture -- a plain
// tap or short drag never moves it, avoiding accidental repositioning while
// panning/interacting with the map or video underneath. Positions are persisted
// as fractions (0-1) of this item's size so they stay put relative to the
// viewport across window resizes.
Item {
    id: _root

    readonly property var _flyViewSettings: QGroundControl.settingsManager.flyViewSettings

    QGCPalette { id: _qgcPal }

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
            id:     reticleHandle
            width:  ScreenTools.defaultFontPixelHeight * 2.5
            height: width

            // True only from a confirmed long-press until release/cancel. While true,
            // x/y follow _dragX/_dragY (updated imperatively by the drag); while false,
            // they follow the settings Fact. x/y themselves are never assigned directly
            // -- only this ternary binding ever drives them -- so the binding never gets
            // permanently severed the way a plain imperative "x = ..." assignment would.
            property bool dragging: false
            property real _dragX
            property real _dragY
            property real _pressStartX
            property real _pressStartY

            readonly property real _boundX: (_root._posXFact(index).value * _root.width)  - (width  / 2)
            readonly property real _boundY: (_root._posYFact(index).value * _root.height) - (height / 2)

            x: dragging ? _dragX : _boundX
            y: dragging ? _dragY : _boundY

            // Press/drag scale feedback lives on this child rather than on reticleHandle
            // itself: scaling reticleHandle would also scale dragArea's local coordinate
            // space below, distorting reported mouse.x/y deltas.
            Item {
                id:           visual
                anchors.fill: parent
                scale:        dragArea.pressed ? (reticleHandle.dragging ? 1.18 : 1.1) : 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }

                Rectangle {
                    anchors.fill:   parent
                    anchors.margins: -ScreenTools.defaultFontPixelWidth * 0.25
                    radius:         width / 2
                    color:          "transparent"
                    border.width:   ScreenTools.defaultFontPixelHeight * 0.08
                    border.color:   _qgcPal.colorBlue
                    visible:        reticleHandle.dragging
                }

                TargetReticleGraphic {
                    anchors.fill: parent
                    style:        _root._reticleStyleFact(index).value
                    reticleColor: _root._colorFact(index).value
                }
            }

            MouseArea {
                id:                   dragArea
                anchors.fill:         parent
                anchors.margins:      -ScreenTools.defaultFontPixelWidth * 0.5
                pressAndHoldInterval: 600

                // Press/move points are mapped into _root's coordinate space (which never
                // moves) rather than used as dragArea's own local mouse.x/y. dragArea is a
                // child of reticleHandle, which is itself repositioned by this drag -- using
                // dragArea-local coordinates as the delta source would make the reference
                // frame move together with the item being dragged, halving the effective
                // drag distance (each reposition shifts the very coordinate space the next
                // delta is measured against).

                onPressed: (mouse) => {
                    const p = dragArea.mapToItem(_root, mouse.x, mouse.y)
                    reticleHandle._pressStartX = p.x
                    reticleHandle._pressStartY = p.y
                    reticleHandle._dragX       = reticleHandle.x
                    reticleHandle._dragY       = reticleHandle.y
                }

                onPressAndHold: {
                    reticleHandle.dragging = true
                }

                onPositionChanged: (mouse) => {
                    if (!reticleHandle.dragging) {
                        return
                    }
                    const p = dragArea.mapToItem(_root, mouse.x, mouse.y)
                    const deltaX = p.x - reticleHandle._pressStartX
                    const deltaY = p.y - reticleHandle._pressStartY
                    reticleHandle._dragX = Math.max(-reticleHandle.width  / 2, Math.min(_root.width  - reticleHandle.width  / 2, reticleHandle._boundX + deltaX))
                    reticleHandle._dragY = Math.max(-reticleHandle.height / 2, Math.min(_root.height - reticleHandle.height / 2, reticleHandle._boundY + deltaY))
                }

                onReleased: {
                    if (reticleHandle.dragging) {
                        const fractionX = (reticleHandle._dragX + reticleHandle.width  / 2) / _root.width
                        const fractionY = (reticleHandle._dragY + reticleHandle.height / 2) / _root.height
                        _root._posXFact(index).value = Math.max(0.0, Math.min(1.0, fractionX))
                        _root._posYFact(index).value = Math.max(0.0, Math.min(1.0, fractionY))
                    }
                    reticleHandle.dragging = false
                }

                onCanceled: {
                    reticleHandle.dragging = false
                }
            }
        }
    }
}
