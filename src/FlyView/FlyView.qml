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

        // ── Extra video streams (2, 3, 4) — each in its own resizable/collapsible pip ──

        FlyViewStreamPip {
            id:                     _pipView2
            anchors.left:           _pipView.right
            anchors.leftMargin:     _toolsMargin
            anchors.bottom:         parent.bottom
            anchors.bottomMargin:   _toolsMargin
            show:                   QGroundControl.videoManager.hasVideo2 && !QGroundControl.videoManager.fullScreen
            z:                      QGroundControl.zOrderWidgets

            Rectangle { anchors.fill: parent; color: "black" }
            Loader {
                anchors.fill:       parent
                visible:            QGroundControl.videoManager.decoding2
                sourceComponent:    QGroundControl.videoManager.gstreamerD3D11Sink   ? _s2D3D11
                                    : QGroundControl.videoManager.gstreamerAppleSink ? _s2Metal
                                    : _s2GL
            }
            Item {
                anchors.fill:   parent
                visible:        !QGroundControl.videoManager.decoding2
                Image { anchors.fill: parent; source: "/res/NoVideoBackground.jpg"; fillMode: Image.PreserveAspectCrop }
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
                text:            qsTr("CAM 2")
                color:           "white"
                font.bold:       true
                font.pointSize:  ScreenTools.smallFontPointSize
                z:               1
            }
            Component { id: _s2GL;    QGCVideoBackground      { objectName: "videoContent2" } }
            Component { id: _s2D3D11; QGCVideoBackgroundD3D11 { objectName: "videoContent2" } }
            Component { id: _s2Metal; FlightDisplayViewMetal   { objectName: "videoContent2" } }
        }

        FlyViewStreamPip {
            id:                     _pipView3
            anchors.left:           _pipView2.right
            anchors.leftMargin:     _toolsMargin
            anchors.bottom:         parent.bottom
            anchors.bottomMargin:   _toolsMargin
            show:                   QGroundControl.videoManager.hasVideo3 && !QGroundControl.videoManager.fullScreen
            z:                      QGroundControl.zOrderWidgets

            Rectangle { anchors.fill: parent; color: "black" }
            Loader {
                anchors.fill:       parent
                visible:            QGroundControl.videoManager.decoding3
                sourceComponent:    QGroundControl.videoManager.gstreamerD3D11Sink   ? _s3D3D11
                                    : QGroundControl.videoManager.gstreamerAppleSink ? _s3Metal
                                    : _s3GL
            }
            Item {
                anchors.fill:   parent
                visible:        !QGroundControl.videoManager.decoding3
                Image { anchors.fill: parent; source: "/res/NoVideoBackground.jpg"; fillMode: Image.PreserveAspectCrop }
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
                text:            qsTr("CAM 3")
                color:           "white"
                font.bold:       true
                font.pointSize:  ScreenTools.smallFontPointSize
                z:               1
            }
            Component { id: _s3GL;    QGCVideoBackground      { objectName: "videoContent3" } }
            Component { id: _s3D3D11; QGCVideoBackgroundD3D11 { objectName: "videoContent3" } }
            Component { id: _s3Metal; FlightDisplayViewMetal   { objectName: "videoContent3" } }
        }

        FlyViewStreamPip {
            id:                     _pipView4
            anchors.left:           _pipView3.right
            anchors.leftMargin:     _toolsMargin
            anchors.bottom:         parent.bottom
            anchors.bottomMargin:   _toolsMargin
            show:                   QGroundControl.videoManager.hasVideo4 && !QGroundControl.videoManager.fullScreen
            z:                      QGroundControl.zOrderWidgets

            Rectangle { anchors.fill: parent; color: "black" }
            Loader {
                anchors.fill:       parent
                visible:            QGroundControl.videoManager.decoding4
                sourceComponent:    QGroundControl.videoManager.gstreamerD3D11Sink   ? _s4D3D11
                                    : QGroundControl.videoManager.gstreamerAppleSink ? _s4Metal
                                    : _s4GL
            }
            Item {
                anchors.fill:   parent
                visible:        !QGroundControl.videoManager.decoding4
                Image { anchors.fill: parent; source: "/res/NoVideoBackground.jpg"; fillMode: Image.PreserveAspectCrop }
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
                text:            qsTr("CAM 4")
                color:           "white"
                font.bold:       true
                font.pointSize:  ScreenTools.smallFontPointSize
                z:               1
            }
            Component { id: _s4GL;    QGCVideoBackground      { objectName: "videoContent4" } }
            Component { id: _s4D3D11; QGCVideoBackgroundD3D11 { objectName: "videoContent4" } }
            Component { id: _s4Metal; FlightDisplayViewMetal   { objectName: "videoContent4" } }
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
