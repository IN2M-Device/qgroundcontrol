import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import QtLocation
import QtPositioning
import QtQuick.Window
import QtQml.Models

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlyView
import QGroundControl.FlightMap
import QGroundControl.Toolbar
import QGroundControl.Viewer3D

Item {
    id: _root

    readonly property bool _is3DMode: QGCViewer3DManager.displayMode === QGCViewer3DManager.View3D

    // These should only be used by MainRootWindow
    property var planController:    _planController
    property var guidedController:  _guidedController

    PlanMasterController {
        id:                     _planController
        flyView:                true
        Component.onCompleted:  start()
    }

    property bool   _mainWindowIsMap:       mapControl.pipState.state === mapControl.pipState.fullState
    property bool   _isFullWindowItemDark:  _mainWindowIsMap ? mapControl.isSatelliteMap : true
    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property var    _missionController:     _planController.missionController
    property var    _geoFenceController:    _planController.geoFenceController
    property var    _rallyPointController:  _planController.rallyPointController
    property real   _margins:               ScreenTools.defaultFontPixelWidth / 2
    property var    _guidedController:      guidedActionsController
    property var    _guidedValueSlider:     guidedValueSlider
    property var    _widgetLayer:           widgetLayer
    property real   _toolsMargin:           ScreenTools.defaultFontPixelWidth * 0.75
    property rect   _centerViewport:        Qt.rect(0, 0, width, height)
    property real   _rightPanelWidth:       ScreenTools.defaultFontPixelWidth * 30
    property var    _mapControl:            mapControl
    property real   _widgetMargin:          ScreenTools.defaultFontPixelWidth * 0.75

    property real   _fullItemZorder:    0
    property real   _pipItemZorder:     QGroundControl.zOrderWidgets

    function _calcCenterViewPort() {
        var newToolInset = Qt.rect(0, 0, width, height)
        toolstrip.adjustToolInset(newToolInset)
    }

    function dropMainStatusIndicatorTool() {
        toolbar.dropMainStatusIndicatorTool();
    }

    QGCToolInsets {
        id:                     _toolInsets
        topEdgeLeftInset:       toolbar.height
        topEdgeCenterInset:     topEdgeLeftInset
        topEdgeRightInset:      topEdgeLeftInset
        leftEdgeBottomInset:    _pipView.leftEdgeBottomInset
        bottomEdgeLeftInset:    _pipView.bottomEdgeLeftInset
    }

    Item {
        id:                 mapHolder
        anchors.fill:       parent

        FlyViewMap {
            id:                     mapControl
            planMasterController:   _planController
            rightPanelWidth:        ScreenTools.defaultFontPixelHeight * 9
            pipView:                _pipView
            pipMode:                !_mainWindowIsMap
            toolInsets:             customOverlay.totalToolInsets
            mapName:                "FlightDisplayView"
            enabled:                !_is3DMode
            visible:                !_is3DMode
        }

        FlyViewVideo {
            id:         videoControl
            pipView:    _pipView
        }

        PipView {
            id:                     _pipView
            anchors.left:           parent.left
            anchors.bottom:         parent.bottom
            anchors.margins:        _toolsMargin
            item1IsFullSettingsKey: "MainFlyWindowIsMap"
            item1:                  mapControl
            item2:                  QGroundControl.videoManager.hasVideo ? videoControl : null
            show:                   QGroundControl.videoManager.hasVideo && !QGroundControl.videoManager.fullScreen &&
                                        (videoControl.pipState.state === videoControl.pipState.pipState || mapControl.pipState.state === mapControl.pipState.pipState)
            z:                      QGroundControl.zOrderWidgets

            property real leftEdgeBottomInset: visible ? width + anchors.margins : 0
            property real bottomEdgeLeftInset: visible ? height + anchors.margins : 0
        }

        // ── Extra video streams (2, 3, 4) — each with its own PipView ──
        // Clicking a pip thumbnail swaps that stream between pip and full-screen,
        // identical to the map ↔ video1 swap of stream 1.
        //
        // Each PipView uses an invisible placeholder as item1. When item1 (placeholder)
        // is "full" it fills the screen transparently, revealing the map behind it.
        // When item1 is in pip, the "CAM N" label shows so the user knows that stream
        // is currently the full item and can click to return to pip mode.

        FlyViewVideoStream {
            id:          _videoStream2
            pipView:     _pipView2
            streamIndex: 2
            decoding:    QGroundControl.videoManager.decoding2
        }

        Item {
            id:      _stream2Placeholder
            enabled: false
            property var pipState: _ph2
            PipState { id: _ph2; pipView: _pipView2; isDark: false }
            Rectangle {
                anchors.fill: parent
                color:        "black"
                visible:      _ph2.state === _ph2.pipState
                QGCLabel {
                    anchors.centerIn: parent
                    text:             qsTr("CAM 2")
                    color:            "white"
                    font.bold:        true
                    font.pointSize:   ScreenTools.smallFontPointSize
                }
            }
        }

        PipView {
            id:                     _pipView2
            anchors.left:           _pipView.right
            anchors.leftMargin:     _toolsMargin
            anchors.bottom:         parent.bottom
            anchors.bottomMargin:   _toolsMargin
            item1IsFullSettingsKey: "FlyViewStream2PlaceholderFull"
            item1:                  _stream2Placeholder
            item2:                  QGroundControl.videoManager.hasVideo2 ? _videoStream2 : null
            show:                   QGroundControl.videoManager.hasVideo2 && !QGroundControl.videoManager.fullScreen
            z:                      QGroundControl.zOrderWidgets
        }

        FlyViewVideoStream {
            id:          _videoStream3
            pipView:     _pipView3
            streamIndex: 3
            decoding:    QGroundControl.videoManager.decoding3
        }

        Item {
            id:      _stream3Placeholder
            enabled: false
            property var pipState: _ph3
            PipState { id: _ph3; pipView: _pipView3; isDark: false }
            Rectangle {
                anchors.fill: parent
                color:        "black"
                visible:      _ph3.state === _ph3.pipState
                QGCLabel {
                    anchors.centerIn: parent
                    text:             qsTr("CAM 3")
                    color:            "white"
                    font.bold:        true
                    font.pointSize:   ScreenTools.smallFontPointSize
                }
            }
        }

        PipView {
            id:                     _pipView3
            anchors.left:           _pipView2.right
            anchors.leftMargin:     _toolsMargin
            anchors.bottom:         parent.bottom
            anchors.bottomMargin:   _toolsMargin
            item1IsFullSettingsKey: "FlyViewStream3PlaceholderFull"
            item1:                  _stream3Placeholder
            item2:                  QGroundControl.videoManager.hasVideo3 ? _videoStream3 : null
            show:                   QGroundControl.videoManager.hasVideo3 && !QGroundControl.videoManager.fullScreen
            z:                      QGroundControl.zOrderWidgets
        }

        FlyViewVideoStream {
            id:          _videoStream4
            pipView:     _pipView4
            streamIndex: 4
            decoding:    QGroundControl.videoManager.decoding4
        }

        Item {
            id:      _stream4Placeholder
            enabled: false
            property var pipState: _ph4
            PipState { id: _ph4; pipView: _pipView4; isDark: false }
            Rectangle {
                anchors.fill: parent
                color:        "black"
                visible:      _ph4.state === _ph4.pipState
                QGCLabel {
                    anchors.centerIn: parent
                    text:             qsTr("CAM 4")
                    color:            "white"
                    font.bold:        true
                    font.pointSize:   ScreenTools.smallFontPointSize
                }
            }
        }

        PipView {
            id:                     _pipView4
            anchors.left:           _pipView3.right
            anchors.leftMargin:     _toolsMargin
            anchors.bottom:         parent.bottom
            anchors.bottomMargin:   _toolsMargin
            item1IsFullSettingsKey: "FlyViewStream4PlaceholderFull"
            item1:                  _stream4Placeholder
            item2:                  QGroundControl.videoManager.hasVideo4 ? _videoStream4 : null
            show:                   QGroundControl.videoManager.hasVideo4 && !QGroundControl.videoManager.fullScreen
            z:                      QGroundControl.zOrderWidgets
        }

        FlyViewWidgetLayer {
            id:                     widgetLayer
            anchors.top:            parent.top
            anchors.bottom:         parent.bottom
            anchors.left:           parent.left
            anchors.right:          guidedValueSlider.visible ? guidedValueSlider.left : parent.right
            anchors.margins:        _widgetMargin
            anchors.topMargin:      toolbar.height + _widgetMargin
            z:                      _fullItemZorder + 2
            parentToolInsets:       _toolInsets
            mapControl:             _mapControl
            visible:                !QGroundControl.videoManager.fullScreen
        }

        FlyViewCustomLayer {
            id:                 customOverlay
            anchors.fill:       widgetLayer
            z:                  _fullItemZorder + 2
            parentToolInsets:   widgetLayer.totalToolInsets
            mapControl:         _mapControl
            visible:            !QGroundControl.videoManager.fullScreen
        }

        // Development tool for visualizing the insets for a paticular layer, show if needed
        FlyViewInsetViewer {
            id:                     widgetLayerInsetViewer
            anchors.top:            parent.top
            anchors.bottom:         parent.bottom
            anchors.left:           parent.left
            anchors.right:          guidedValueSlider.visible ? guidedValueSlider.left : parent.right
            z:                      widgetLayer.z + 1
            insetsToView:           widgetLayer.totalToolInsets
            visible:                false
        }

        GuidedActionsController {
            id:                 guidedActionsController
            missionController:  _missionController
            guidedValueSlider:     _guidedValueSlider
        }

        //-- Guided value slider (e.g. altitude)
        GuidedValueSlider {
            id:                 guidedValueSlider
            anchors.right:      parent.right
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            anchors.topMargin:  toolbar.height
            z:                  QGroundControl.zOrderTopMost
            visible:            false
        }

        Loader {
            id:             viewer3DLoader
            z:              1
            anchors.fill:   parent
            active:         _is3DMode

            onActiveChanged: {
                if (active) {
                    setSource("qrc:/qml/QGroundControl/Viewer3D/Models3D/Viewer3DModel.qml",
)
                }
            }
        }
    }

    FlyViewToolBar {
        id:                 toolbar
        guidedValueSlider:  _guidedValueSlider
        visible:            !QGroundControl.videoManager.fullScreen
    }
}
