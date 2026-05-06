import QtQuick

import QGroundControl
import QGroundControl.Controls

// Generic video stream component for streams 2/3/4.
// Works identically to FlyViewVideo (stream 1): has its own PipState so
// the parent PipView can swap it between pip thumbnail and full-screen.
Item {
    id: _root

    property Item pipView
    property Item pipState: _pipState
    property int  streamIndex: 2
    property bool decoding:    false

    PipState {
        id:      _pipState
        pipView: _root.pipView
        isDark:  true
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

    Component {
        id: _gl
        QGCVideoBackground { objectName: "videoContent" + _root.streamIndex }
    }
    Component {
        id: _d3d11
        QGCVideoBackgroundD3D11 { objectName: "videoContent" + _root.streamIndex }
    }
    Component {
        id: _metal
        FlightDisplayViewMetal { objectName: "videoContent" + _root.streamIndex }
    }
}
