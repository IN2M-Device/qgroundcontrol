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

    // 0 = no extra stream full; 2/3/4 = that stream's video fills the screen
    property int    _fullExtraStream:   0

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

        // ── Extra video streams (2, 3, 4) ────────────────────────────────────────
        // Each pip container stays fixed at the bottom.  Only the video content
        // item expands/collapses to full-screen via ParentChange + AnchorChanges,
        // so the anchor chain between pips is never disrupted.
        //
        // When a stream goes full:
        //   • Its video content fills mapHolder (z=1, above map, below widgets/pips).
        //   • A live ShaderEffectSource of the map fills that pip — identical to how
        //     stream 1 shows the map in its pip when video1 is full.
        //
        // _fullExtraStream tracks which stream (0=none) is currently full-screen.
        // The binding isFullScreen = (_fullExtraStream === N) coordinates all pips
        // automatically: setting _fullExtraStream to N collapses any previous stream.

        FlyViewExtraStream {
            id:           _stream2
            streamIndex:  2
            isFullScreen: _fullExtraStream === 2
            decoding:     QGroundControl.videoManager.decoding2
            mapItem:      mapControl
            visible:      QGroundControl.videoManager.hasVideo2 && !QGroundControl.videoManager.fullScreen
            z:            QGroundControl.zOrderWidgets

            anchors.left:         _pipView.right
            anchors.leftMargin:   _toolsMargin
            anchors.bottom:       parent.bottom
            anchors.bottomMargin: _toolsMargin

            onVisibleChanged: if (!visible) _fullExtraStream = 0
            onActivated: {
                if (videoControl.pipState.state === videoControl.pipState.fullState) _pipView._swapPip()
                _fullExtraStream = 2
            }
            onDeactivated: _fullExtraStream = 0
        }

        FlyViewExtraStream {
            id:           _stream3
            streamIndex:  3
            isFullScreen: _fullExtraStream === 3
            decoding:     QGroundControl.videoManager.decoding3
            mapItem:      mapControl
            visible:      QGroundControl.videoManager.hasVideo3 && !QGroundControl.videoManager.fullScreen
            z:            QGroundControl.zOrderWidgets

            anchors.left:         _stream2.right
            anchors.leftMargin:   _toolsMargin
            anchors.bottom:       parent.bottom
            anchors.bottomMargin: _toolsMargin

            onVisibleChanged: if (!visible) _fullExtraStream = 0
            onActivated: {
                if (videoControl.pipState.state === videoControl.pipState.fullState) _pipView._swapPip()
                _fullExtraStream = 3
            }
            onDeactivated: _fullExtraStream = 0
        }

        FlyViewExtraStream {
            id:           _stream4
            streamIndex:  4
            isFullScreen: _fullExtraStream === 4
            decoding:     QGroundControl.videoManager.decoding4
            mapItem:      mapControl
            visible:      QGroundControl.videoManager.hasVideo4 && !QGroundControl.videoManager.fullScreen
            z:            QGroundControl.zOrderWidgets

            anchors.left:         _stream3.right
            anchors.leftMargin:   _toolsMargin
            anchors.bottom:       parent.bottom
            anchors.bottomMargin: _toolsMargin

            onVisibleChanged: if (!visible) _fullExtraStream = 0
            onActivated: {
                if (videoControl.pipState.state === videoControl.pipState.fullState) _pipView._swapPip()
                _fullExtraStream = 4
            }
            onDeactivated: _fullExtraStream = 0
        }

        // When stream 1 (video1) goes full via its own PipView, collapse any extra stream
        Connections {
            target: videoControl.pipState
            function onStateChanged() {
                if (videoControl.pipState.state === videoControl.pipState.fullState) {
                    _fullExtraStream = 0
                }
            }
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
