import QtQuick

import QGroundControl
import QGroundControl.Controls

// Standalone pip container for a single always-visible video stream.
// Mirrors PipView's resize and collapse/expand behaviour without the two-item swap.
Item {
    id: _root

    property bool show: true

    width:   _pipSize
    height:  _pipSize * (9/16)
    visible: show

    property real _pipSize:    parent ? parent.width * 0.2 : 200
    property real _maxSize:    0.75
    property real _minSize:    0.10
    property bool _isExpanded: true

    default property alias contents: pipContent.data

    Item {
        id:             pipContent
        anchors.fill:   parent
        visible:        _isExpanded
        clip:           true
    }

    // Hover detection for showing controls
    MouseArea {
        id:              hoverArea
        anchors.fill:    parent
        hoverEnabled:    true
        enabled:         _isExpanded
        acceptedButtons: Qt.NoButton
    }

    // Drag-to-resize handle
    MouseArea {
        id:              pipResize
        anchors.fill:    pipResizeIcon
        preventStealing: true
        cursorShape:     Qt.PointingHandCursor

        property real initialX:     0
        property real initialWidth: 0

        onPressed: (mouse) => {
            pipResize.anchors.fill = undefined
            pipResize.initialX = mouse.x
            pipResize.initialWidth = _root.width
        }
        onReleased: pipResize.anchors.fill = pipResizeIcon
        onPositionChanged: (mouse) => {
            if (pipResize.pressed) {
                var newWidth = pipResize.initialWidth + mouse.x - pipResize.initialX
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
        visible:           _isExpanded && (ScreenTools.isMobile || hoverArea.containsMouse)
    }

    Image {
        source:            "/qmlimages/pipHide.svg"
        fillMode:          Image.PreserveAspectFit
        mipmap:            true
        anchors.left:      parent.left
        anchors.bottom:    parent.bottom
        height:            ScreenTools.defaultFontPixelHeight * 2.5
        width:             ScreenTools.defaultFontPixelHeight * 2.5
        sourceSize.height: height
        visible:           _isExpanded && (ScreenTools.isMobile || hoverArea.containsMouse)
        MouseArea {
            anchors.fill: parent
            onClicked:    _root._isExpanded = false
        }
    }

    Rectangle {
        anchors.left:   parent.left
        anchors.bottom: parent.bottom
        height:         ScreenTools.defaultFontPixelHeight * 2
        width:          ScreenTools.defaultFontPixelHeight * 2
        radius:         ScreenTools.defaultFontPixelHeight / 3
        visible:        !_isExpanded
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

    // Keep pip size within min/max when the parent is resized
    Connections {
        target: _root.parent
        function onWidthChanged() {
            var parentWidth = _root.parent.width
            if (_root.width > parentWidth * _maxSize) {
                _pipSize = parentWidth * _maxSize
            } else if (_root.width < parentWidth * _minSize) {
                _pipSize = parentWidth * _minSize
            }
        }
    }
}
