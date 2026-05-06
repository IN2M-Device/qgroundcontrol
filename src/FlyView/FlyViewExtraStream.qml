import QtQuick

import QGroundControl
import QGroundControl.Controls

// Pip + full-screen overlay for streams 2/3/4.
//
// Behaviour mirrors stream 1's PipView exactly:
//   • Drag the top-right icon to resize independently.
//   • Click the bottom-left hide icon (on hover) to collapse to a small button.
//   • Click that button to expand again.
//   • Click the pip thumbnail to go full-screen (video fills mapHolder).
//   • When full, the pip shows a live ShaderEffectSource of the map — identical
//     to how stream 1 shows the map in its pip when video1 is full.
//   • Clicking the pip-map preview or the full-screen video returns to pip.
//
// The pip CONTAINER (_root) always stays at its anchored position.
// Only videoContent expands/collapses via ParentChange + AnchorChanges so
// the anchor chain to adjacent pips is never disrupted.
Item {
    id: _root

    property int  streamIndex:  2
    property bool isFullScreen: false
    property bool decoding:     false
    property Item mapItem:      null    // mapControl, passed from FlyView.qml

    signal activated()    // pip clicked while not full
    signal deactivated()  // pip-map or full-screen video clicked

    // ── Size / collapse ───────────────────────────────────────────────────────
    width:  _pipSize
    height: _pipSize * (9/16)

    property real _pipSize:    parent ? parent.width * 0.2 : 200
    property real _maxSize:    0.75
    property real _minSize:    0.10
    property bool _isExpanded: true

    // ── Pip content (hidden when collapsed) ───────────────────────────────────
    Item {
        id:             pipContent
        anchors.fill:   parent
        visible:        _root._isExpanded
        clip:           true

        // Live map preview – rendered in the pip while video is full-screen.
        // hideSource: false keeps mapControl rendering normally in mapHolder.
        ShaderEffectSource {
            anchors.fill: parent
            sourceItem:   _root.mapItem
            live:         true
            hideSource:   false
            visible:      _root.isFullScreen && _root.mapItem !== null
        }

        // Video content: thumbnail in pip, or fills mapHolder when full-screen.
        Item {
            id:           videoContent
            anchors.fill: parent   // fills pip by default; state overrides when full

            states: State {
                name: "full"
                when: _root.isFullScreen
                ParentChange {
                    target: videoContent
                    parent: _root.parent   // mapHolder
                }
                AnchorChanges {
                    target:         videoContent
                    anchors.top:    _root.parent.top
                    anchors.bottom: _root.parent.bottom
                    anchors.left:   _root.parent.left
                    anchors.right:  _root.parent.right
                }
                PropertyChanges {
                    target: videoContent
                    // z=1: above map/video1 (z=0), below widgetLayer (z=2) and pip controls
                    z: 1
                }
            }

            Rectangle { anchors.fill: parent; color: "black" }

            Loader {
                anchors.fill:       parent
                visible:            _root.decoding
                sourceComponent:    QGroundControl.videoManager.gstreamerD3D11Sink   ? _d3d11
                                    : QGroundControl.videoManager.gstreamerAppleSink ? _metal
                                    : _gl
            }

            Item {
                anchors.fill: parent
                visible:      !_root.decoding
                Image {
                    anchors.fill: parent
                    source:       "/res/NoVideoBackground.jpg"
                    fillMode:     Image.PreserveAspectCrop
                }
                QGCLabel {
                    anchors.centerIn: parent
                    text:             qsTr("WAITING FOR VIDEO")
                    font.bold:        true
                    color:            "white"
                    font.pointSize:   ScreenTools.smallFontPointSize
                }
            }

            QGCLabel {
                anchors.top:     parent.top
                anchors.left:    parent.left
                anchors.margins: ScreenTools.defaultFontPixelWidth * 0.4
                text:            qsTr("CAM %1").arg(_root.streamIndex)
                color:           "white"
                font.bold:       true
                font.pointSize:  ScreenTools.smallFontPointSize
                z:               1
            }

            // Click the full-screen video to return to pip
            MouseArea {
                anchors.fill: parent
                enabled:      _root.isFullScreen
                onClicked:    _root.deactivated()
            }

            Component { id: _gl;    QGCVideoBackground      { objectName: "videoContent" + _root.streamIndex } }
            Component { id: _d3d11; QGCVideoBackgroundD3D11 { objectName: "videoContent" + _root.streamIndex } }
            Component { id: _metal; FlightDisplayViewMetal   { objectName: "videoContent" + _root.streamIndex } }
        }
    }

    // ── Pip click + hover detection for controls ───────────────────────────────
    // Single area: handles click-to-activate / click-to-deactivate and provides
    // containsMouse for showing the resize/hide icons (same as PipView).
    MouseArea {
        id:              pipArea
        anchors.fill:    parent
        hoverEnabled:    true
        enabled:         _root._isExpanded
        preventStealing: true
        onClicked: {
            if (_root.isFullScreen) _root.deactivated()
            else                    _root.activated()
        }
    }

    // ── Drag-to-resize (mirrors PipView exactly) ───────────────────────────────
    MouseArea {
        id:              pipResize
        anchors.fill:    pipResizeIcon
        preventStealing: true
        cursorShape:     Qt.PointingHandCursor

        property real initialX:     0
        property real initialWidth: 0

        onPressed: (mouse) => {
            pipResize.anchors.fill = undefined
            pipResize.initialX     = mouse.x
            pipResize.initialWidth = _root.width
        }
        onReleased: pipResize.anchors.fill = pipResizeIcon
        onPositionChanged: (mouse) => {
            if (pipResize.pressed) {
                var newWidth    = pipResize.initialWidth + mouse.x - pipResize.initialX
                var parentWidth = _root.parent.width
                if (newWidth < parentWidth * _maxSize && newWidth > parentWidth * _minSize) {
                    _pipSize = newWidth
                }
            }
        }
    }

    Image {
        id:                pipResizeIcon
        source:            "/qmlimages/pipResize.svg"
        fillMode:          Image.PreserveAspectFit
        mipmap:            true
        anchors.right:     parent.right
        anchors.top:       parent.top
        height:            ScreenTools.defaultFontPixelHeight * 2.5
        width:             ScreenTools.defaultFontPixelHeight * 2.5
        sourceSize.height: height
        visible:           _root._isExpanded && (ScreenTools.isMobile || pipArea.containsMouse)
    }

    // ── Hide button ───────────────────────────────────────────────────────────
    Image {
        source:            "/qmlimages/pipHide.svg"
        fillMode:          Image.PreserveAspectFit
        mipmap:            true
        anchors.left:      parent.left
        anchors.bottom:    parent.bottom
        height:            ScreenTools.defaultFontPixelHeight * 2.5
        width:             ScreenTools.defaultFontPixelHeight * 2.5
        sourceSize.height: height
        visible:           _root._isExpanded && (ScreenTools.isMobile || pipArea.containsMouse)
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (_root.isFullScreen) _root.deactivated()
                _root._isExpanded = false
            }
        }
    }

    // ── Show button (when collapsed) ──────────────────────────────────────────
    Rectangle {
        anchors.left:   parent.left
        anchors.bottom: parent.bottom
        height:         ScreenTools.defaultFontPixelHeight * 2
        width:          ScreenTools.defaultFontPixelHeight * 2
        radius:         ScreenTools.defaultFontPixelHeight / 3
        visible:        !_root._isExpanded
        color:          Qt.rgba(0, 0, 0, 0.75)
        Image {
            width:             parent.width  * 0.75
            height:            parent.height * 0.75
            sourceSize.height: height
            source:            "/res/buttonRight.svg"
            mipmap:            true
            fillMode:          Image.PreserveAspectFit
            anchors.centerIn:  parent
        }
        MouseArea {
            anchors.fill: parent
            onClicked:    _root._isExpanded = true
        }
    }

    // ── Keep _pipSize within bounds when the parent window is resized ─────────
    Connections {
        target: _root.parent
        function onWidthChanged() {
            var parentWidth = _root.parent.width
            if (_root._pipSize > parentWidth * _maxSize)      _pipSize = parentWidth * _maxSize
            else if (_root._pipSize < parentWidth * _minSize) _pipSize = parentWidth * _minSize
        }
    }
}
