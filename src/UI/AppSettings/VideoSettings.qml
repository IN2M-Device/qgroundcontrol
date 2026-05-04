import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.FactControls
import QGroundControl.Controls

SettingsPage {
    property real _stringFieldWidth: ScreenTools.defaultFontPixelWidth * 30

    property var autoStreamConfig: QGroundControl.videoManager.autoStreamConfigured
    property var isStreamSource:   QGroundControl.videoManager.isStreamSource
    property var isGST:            QGroundControl.videoManager.gstreamerEnabled

    // Per-stream source raw values for visibility logic
    property string _src1: QGroundControl.settingsManager.videoSettings.videoSource.rawValue
    property string _src2: QGroundControl.settingsManager.videoSettings.videoSource2.rawValue
    property string _src3: QGroundControl.settingsManager.videoSettings.videoSource3.rawValue
    property string _src4: QGroundControl.settingsManager.videoSettings.videoSource4.rawValue

    property string _disabledSrc: QGroundControl.settingsManager.videoSettings.disabledVideoSource
    property string _rtspSrc:     QGroundControl.settingsManager.videoSettings.rtspVideoSource
    property string _tcpSrc:      QGroundControl.settingsManager.videoSettings.tcpVideoSource
    property string _udp264Src:   QGroundControl.settingsManager.videoSettings.udp264VideoSource
    property string _udp265Src:   QGroundControl.settingsManager.videoSettings.udp265VideoSource
    property string _mpegtsSrc:   QGroundControl.settingsManager.videoSettings.mpegtsVideoSource

    function _isRtsp(src)   { return src === _rtspSrc }
    function _isTcp(src)    { return src === _tcpSrc }
    function _isUdp(src)    { return src === _udp264Src || src === _udp265Src || src === _mpegtsSrc }
    function _isDisabled(src) { return src === _disabledSrc }

    // -------------------------------------------------------------------------
    // Stream tabs
    // -------------------------------------------------------------------------

    TabBar {
        id:               videoTabBar
        Layout.fillWidth: true

        TabButton { text: qsTr("Video 1") }
        TabButton { text: qsTr("Video 2") }
        TabButton { text: qsTr("Video 3") }
        TabButton { text: qsTr("Video 4") }
    }

    // ---- Video 1 ----

    SettingsGroupLayout {
        Layout.fillWidth: true
        heading:             qsTr("Video Source")
        headingDescription:  autoStreamConfig ? qsTr("Mavlink camera stream is automatically configured") : ""
        visible:             videoTabBar.currentIndex === 0
        enabled:             !autoStreamConfig

        ColumnLayout {
            Layout.fillWidth: true
            spacing: ScreenTools.defaultFontPixelHeight / 4
            visible: QGroundControl.settingsManager.videoSettings.videoSource.userVisible

            LabelledFactComboBox {
                label:            fact.label
                Layout.fillWidth: true
                fact:             QGroundControl.settingsManager.videoSettings.videoSource
                indexModel:       false
            }

            QGCLabel {
                Layout.fillWidth: true
                text:             QGroundControl.settingsManager.videoSettings.videoSource.shortDescription
                visible:          text !== ""
                font.pointSize:   ScreenTools.smallFontPointSize
                wrapMode:         Text.WordWrap
            }
        }
    }

    SettingsGroupLayout {
        Layout.fillWidth: true
        heading: qsTr("Connection")
        visible: videoTabBar.currentIndex === 0 && !_isDisabled(_src1) && !autoStreamConfig

        ColumnLayout {
            Layout.fillWidth: true
            spacing: ScreenTools.defaultFontPixelHeight / 4
            visible: _isRtsp(_src1) && QGroundControl.settingsManager.videoSettings.rtspUrl.userVisible

            LabelledFactTextField {
                label:                    fact.label
                Layout.fillWidth:         true
                fact:                     QGroundControl.settingsManager.videoSettings.rtspUrl
                textFieldPreferredWidth:  _stringFieldWidth
            }

            QGCLabel {
                Layout.fillWidth: true
                text:           QGroundControl.settingsManager.videoSettings.rtspUrl.shortDescription
                visible:        text !== ""
                font.pointSize: ScreenTools.smallFontPointSize
                wrapMode:       Text.WordWrap
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: ScreenTools.defaultFontPixelHeight / 4
            visible: _isTcp(_src1) && QGroundControl.settingsManager.videoSettings.tcpUrl.userVisible

            LabelledFactTextField {
                label:                    fact.label
                Layout.fillWidth:         true
                fact:                     QGroundControl.settingsManager.videoSettings.tcpUrl
                textFieldPreferredWidth:  _stringFieldWidth
            }

            QGCLabel {
                Layout.fillWidth: true
                text:           QGroundControl.settingsManager.videoSettings.tcpUrl.shortDescription
                visible:        text !== ""
                font.pointSize: ScreenTools.smallFontPointSize
                wrapMode:       Text.WordWrap
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: ScreenTools.defaultFontPixelHeight / 4
            visible: _isUdp(_src1) && QGroundControl.settingsManager.videoSettings.udpUrl.userVisible

            LabelledFactTextField {
                label:                    fact.label
                Layout.fillWidth:         true
                fact:                     QGroundControl.settingsManager.videoSettings.udpUrl
                textFieldPreferredWidth:  _stringFieldWidth
            }

            QGCLabel {
                Layout.fillWidth: true
                text:           QGroundControl.settingsManager.videoSettings.udpUrl.shortDescription
                visible:        text !== ""
                font.pointSize: ScreenTools.smallFontPointSize
                wrapMode:       Text.WordWrap
            }
        }
    }

    // ---- Video 2 ----

    SettingsGroupLayout {
        Layout.fillWidth: true
        heading:  qsTr("Video Source")
        visible:  videoTabBar.currentIndex === 1

        ColumnLayout {
            Layout.fillWidth: true
            spacing: ScreenTools.defaultFontPixelHeight / 4
            visible: QGroundControl.settingsManager.videoSettings.videoSource2.userVisible

            LabelledFactComboBox {
                label:            fact.label
                Layout.fillWidth: true
                fact:             QGroundControl.settingsManager.videoSettings.videoSource2
                indexModel:       false
            }

            QGCLabel {
                Layout.fillWidth: true
                text:           QGroundControl.settingsManager.videoSettings.videoSource2.shortDescription
                visible:        text !== ""
                font.pointSize: ScreenTools.smallFontPointSize
                wrapMode:       Text.WordWrap
            }
        }
    }

    SettingsGroupLayout {
        Layout.fillWidth: true
        heading: qsTr("Connection")
        visible: videoTabBar.currentIndex === 1 && !_isDisabled(_src2)

        ColumnLayout {
            Layout.fillWidth: true
            spacing: ScreenTools.defaultFontPixelHeight / 4
            visible: _isRtsp(_src2) && QGroundControl.settingsManager.videoSettings.rtspUrl2.userVisible

            LabelledFactTextField {
                label:                    fact.label
                Layout.fillWidth:         true
                fact:                     QGroundControl.settingsManager.videoSettings.rtspUrl2
                textFieldPreferredWidth:  _stringFieldWidth
            }

            QGCLabel {
                Layout.fillWidth: true
                text:           QGroundControl.settingsManager.videoSettings.rtspUrl2.shortDescription
                visible:        text !== ""
                font.pointSize: ScreenTools.smallFontPointSize
                wrapMode:       Text.WordWrap
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: ScreenTools.defaultFontPixelHeight / 4
            visible: _isTcp(_src2) && QGroundControl.settingsManager.videoSettings.tcpUrl2.userVisible

            LabelledFactTextField {
                label:                    fact.label
                Layout.fillWidth:         true
                fact:                     QGroundControl.settingsManager.videoSettings.tcpUrl2
                textFieldPreferredWidth:  _stringFieldWidth
            }

            QGCLabel {
                Layout.fillWidth: true
                text:           QGroundControl.settingsManager.videoSettings.tcpUrl2.shortDescription
                visible:        text !== ""
                font.pointSize: ScreenTools.smallFontPointSize
                wrapMode:       Text.WordWrap
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: ScreenTools.defaultFontPixelHeight / 4
            visible: _isUdp(_src2) && QGroundControl.settingsManager.videoSettings.udpUrl2.userVisible

            LabelledFactTextField {
                label:                    fact.label
                Layout.fillWidth:         true
                fact:                     QGroundControl.settingsManager.videoSettings.udpUrl2
                textFieldPreferredWidth:  _stringFieldWidth
            }

            QGCLabel {
                Layout.fillWidth: true
                text:           QGroundControl.settingsManager.videoSettings.udpUrl2.shortDescription
                visible:        text !== ""
                font.pointSize: ScreenTools.smallFontPointSize
                wrapMode:       Text.WordWrap
            }
        }
    }

    // ---- Video 3 ----

    SettingsGroupLayout {
        Layout.fillWidth: true
        heading: qsTr("Video Source")
        visible: videoTabBar.currentIndex === 2

        ColumnLayout {
            Layout.fillWidth: true
            spacing: ScreenTools.defaultFontPixelHeight / 4
            visible: QGroundControl.settingsManager.videoSettings.videoSource3.userVisible

            LabelledFactComboBox {
                label:            fact.label
                Layout.fillWidth: true
                fact:             QGroundControl.settingsManager.videoSettings.videoSource3
                indexModel:       false
            }

            QGCLabel {
                Layout.fillWidth: true
                text:           QGroundControl.settingsManager.videoSettings.videoSource3.shortDescription
                visible:        text !== ""
                font.pointSize: ScreenTools.smallFontPointSize
                wrapMode:       Text.WordWrap
            }
        }
    }

    SettingsGroupLayout {
        Layout.fillWidth: true
        heading: qsTr("Connection")
        visible: videoTabBar.currentIndex === 2 && !_isDisabled(_src3)

        ColumnLayout {
            Layout.fillWidth: true
            spacing: ScreenTools.defaultFontPixelHeight / 4
            visible: _isRtsp(_src3) && QGroundControl.settingsManager.videoSettings.rtspUrl3.userVisible

            LabelledFactTextField {
                label:                    fact.label
                Layout.fillWidth:         true
                fact:                     QGroundControl.settingsManager.videoSettings.rtspUrl3
                textFieldPreferredWidth:  _stringFieldWidth
            }

            QGCLabel {
                Layout.fillWidth: true
                text:           QGroundControl.settingsManager.videoSettings.rtspUrl3.shortDescription
                visible:        text !== ""
                font.pointSize: ScreenTools.smallFontPointSize
                wrapMode:       Text.WordWrap
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: ScreenTools.defaultFontPixelHeight / 4
            visible: _isTcp(_src3) && QGroundControl.settingsManager.videoSettings.tcpUrl3.userVisible

            LabelledFactTextField {
                label:                    fact.label
                Layout.fillWidth:         true
                fact:                     QGroundControl.settingsManager.videoSettings.tcpUrl3
                textFieldPreferredWidth:  _stringFieldWidth
            }

            QGCLabel {
                Layout.fillWidth: true
                text:           QGroundControl.settingsManager.videoSettings.tcpUrl3.shortDescription
                visible:        text !== ""
                font.pointSize: ScreenTools.smallFontPointSize
                wrapMode:       Text.WordWrap
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: ScreenTools.defaultFontPixelHeight / 4
            visible: _isUdp(_src3) && QGroundControl.settingsManager.videoSettings.udpUrl3.userVisible

            LabelledFactTextField {
                label:                    fact.label
                Layout.fillWidth:         true
                fact:                     QGroundControl.settingsManager.videoSettings.udpUrl3
                textFieldPreferredWidth:  _stringFieldWidth
            }

            QGCLabel {
                Layout.fillWidth: true
                text:           QGroundControl.settingsManager.videoSettings.udpUrl3.shortDescription
                visible:        text !== ""
                font.pointSize: ScreenTools.smallFontPointSize
                wrapMode:       Text.WordWrap
            }
        }
    }

    // ---- Video 4 ----

    SettingsGroupLayout {
        Layout.fillWidth: true
        heading: qsTr("Video Source")
        visible: videoTabBar.currentIndex === 3

        ColumnLayout {
            Layout.fillWidth: true
            spacing: ScreenTools.defaultFontPixelHeight / 4
            visible: QGroundControl.settingsManager.videoSettings.videoSource4.userVisible

            LabelledFactComboBox {
                label:            fact.label
                Layout.fillWidth: true
                fact:             QGroundControl.settingsManager.videoSettings.videoSource4
                indexModel:       false
            }

            QGCLabel {
                Layout.fillWidth: true
                text:           QGroundControl.settingsManager.videoSettings.videoSource4.shortDescription
                visible:        text !== ""
                font.pointSize: ScreenTools.smallFontPointSize
                wrapMode:       Text.WordWrap
            }
        }
    }

    SettingsGroupLayout {
        Layout.fillWidth: true
        heading: qsTr("Connection")
        visible: videoTabBar.currentIndex === 3 && !_isDisabled(_src4)

        ColumnLayout {
            Layout.fillWidth: true
            spacing: ScreenTools.defaultFontPixelHeight / 4
            visible: _isRtsp(_src4) && QGroundControl.settingsManager.videoSettings.rtspUrl4.userVisible

            LabelledFactTextField {
                label:                    fact.label
                Layout.fillWidth:         true
                fact:                     QGroundControl.settingsManager.videoSettings.rtspUrl4
                textFieldPreferredWidth:  _stringFieldWidth
            }

            QGCLabel {
                Layout.fillWidth: true
                text:           QGroundControl.settingsManager.videoSettings.rtspUrl4.shortDescription
                visible:        text !== ""
                font.pointSize: ScreenTools.smallFontPointSize
                wrapMode:       Text.WordWrap
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: ScreenTools.defaultFontPixelHeight / 4
            visible: _isTcp(_src4) && QGroundControl.settingsManager.videoSettings.tcpUrl4.userVisible

            LabelledFactTextField {
                label:                    fact.label
                Layout.fillWidth:         true
                fact:                     QGroundControl.settingsManager.videoSettings.tcpUrl4
                textFieldPreferredWidth:  _stringFieldWidth
            }

            QGCLabel {
                Layout.fillWidth: true
                text:           QGroundControl.settingsManager.videoSettings.tcpUrl4.shortDescription
                visible:        text !== ""
                font.pointSize: ScreenTools.smallFontPointSize
                wrapMode:       Text.WordWrap
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: ScreenTools.defaultFontPixelHeight / 4
            visible: _isUdp(_src4) && QGroundControl.settingsManager.videoSettings.udpUrl4.userVisible

            LabelledFactTextField {
                label:                    fact.label
                Layout.fillWidth:         true
                fact:                     QGroundControl.settingsManager.videoSettings.udpUrl4
                textFieldPreferredWidth:  _stringFieldWidth
            }

            QGCLabel {
                Layout.fillWidth: true
                text:           QGroundControl.settingsManager.videoSettings.udpUrl4.shortDescription
                visible:        text !== ""
                font.pointSize: ScreenTools.smallFontPointSize
                wrapMode:       Text.WordWrap
            }
        }
    }

    // -------------------------------------------------------------------------
    // Common settings (always visible, not per-stream)
    // -------------------------------------------------------------------------

    SettingsGroupLayout {
        Layout.fillWidth: true
        heading: qsTr("Settings")
        visible: !_isDisabled(_src1) &&
                 (QGroundControl.settingsManager.videoSettings.aspectRatio.userVisible ||
                  QGroundControl.settingsManager.videoSettings.disableWhenDisarmed.userVisible ||
                  QGroundControl.settingsManager.videoSettings.lowLatencyMode.userVisible ||
                  QGroundControl.settingsManager.videoSettings.forceVideoDecoder.userVisible)

        ColumnLayout {
            Layout.fillWidth: true
            spacing: ScreenTools.defaultFontPixelHeight / 4
            visible: (!autoStreamConfig && isStreamSource) && QGroundControl.settingsManager.videoSettings.aspectRatio.userVisible

            LabelledFactTextField {
                label:            fact.label
                Layout.fillWidth: true
                fact:             QGroundControl.settingsManager.videoSettings.aspectRatio
            }

            QGCLabel {
                Layout.fillWidth: true
                text:           QGroundControl.settingsManager.videoSettings.aspectRatio.shortDescription
                visible:        text !== ""
                font.pointSize: ScreenTools.smallFontPointSize
                wrapMode:       Text.WordWrap
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: ScreenTools.defaultFontPixelHeight / 4
            visible: (!autoStreamConfig && isStreamSource) && QGroundControl.settingsManager.videoSettings.disableWhenDisarmed.userVisible

            FactCheckBoxSlider {
                Layout.fillWidth: true
                text:             fact.label
                fact:             QGroundControl.settingsManager.videoSettings.disableWhenDisarmed
            }

            QGCLabel {
                Layout.fillWidth: true
                text:           QGroundControl.settingsManager.videoSettings.disableWhenDisarmed.shortDescription
                visible:        text !== ""
                font.pointSize: ScreenTools.smallFontPointSize
                wrapMode:       Text.WordWrap
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: ScreenTools.defaultFontPixelHeight / 4
            visible: (!autoStreamConfig && isStreamSource && isGST) && QGroundControl.settingsManager.videoSettings.lowLatencyMode.userVisible

            FactCheckBoxSlider {
                Layout.fillWidth: true
                text:             fact.label
                fact:             QGroundControl.settingsManager.videoSettings.lowLatencyMode
            }

            QGCLabel {
                Layout.fillWidth: true
                text:           QGroundControl.settingsManager.videoSettings.lowLatencyMode.shortDescription
                visible:        text !== ""
                font.pointSize: ScreenTools.smallFontPointSize
                wrapMode:       Text.WordWrap
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: ScreenTools.defaultFontPixelHeight / 4
            visible: QGroundControl.settingsManager.videoSettings.forceVideoDecoder.userVisible

            LabelledFactComboBox {
                label:            fact.label
                Layout.fillWidth: true
                fact:             QGroundControl.settingsManager.videoSettings.forceVideoDecoder
                indexModel:       false
            }

            QGCLabel {
                Layout.fillWidth: true
                text:           QGroundControl.settingsManager.videoSettings.forceVideoDecoder.shortDescription
                visible:        text !== ""
                font.pointSize: ScreenTools.smallFontPointSize
                wrapMode:       Text.WordWrap
            }
        }
    }

    SettingsGroupLayout {
        Layout.fillWidth: true
        heading: qsTr("Local Video Storage")
        visible: QGroundControl.settingsManager.videoSettings.recordingFormat.userVisible ||
                 QGroundControl.settingsManager.videoSettings.enableStorageLimit.userVisible ||
                 QGroundControl.settingsManager.videoSettings.maxVideoSize.userVisible

        ColumnLayout {
            Layout.fillWidth: true
            spacing: ScreenTools.defaultFontPixelHeight / 4
            visible: QGroundControl.settingsManager.videoSettings.recordingFormat.userVisible

            LabelledFactComboBox {
                label:            fact.label
                Layout.fillWidth: true
                fact:             QGroundControl.settingsManager.videoSettings.recordingFormat
                indexModel:       false
            }

            QGCLabel {
                Layout.fillWidth: true
                text:           QGroundControl.settingsManager.videoSettings.recordingFormat.shortDescription
                visible:        text !== ""
                font.pointSize: ScreenTools.smallFontPointSize
                wrapMode:       Text.WordWrap
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: ScreenTools.defaultFontPixelHeight / 4
            visible: QGroundControl.settingsManager.videoSettings.enableStorageLimit.userVisible

            FactCheckBoxSlider {
                Layout.fillWidth: true
                text:             fact.label
                fact:             QGroundControl.settingsManager.videoSettings.enableStorageLimit
            }

            QGCLabel {
                Layout.fillWidth: true
                text:           QGroundControl.settingsManager.videoSettings.enableStorageLimit.shortDescription
                visible:        text !== ""
                font.pointSize: ScreenTools.smallFontPointSize
                wrapMode:       Text.WordWrap
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: ScreenTools.defaultFontPixelHeight / 4
            visible: QGroundControl.settingsManager.videoSettings.maxVideoSize.userVisible

            LabelledFactTextField {
                label:            fact.label
                Layout.fillWidth: true
                fact:             QGroundControl.settingsManager.videoSettings.maxVideoSize
                enabled:          QGroundControl.settingsManager.videoSettings.enableStorageLimit.rawValue
            }

            QGCLabel {
                Layout.fillWidth: true
                text:           QGroundControl.settingsManager.videoSettings.maxVideoSize.shortDescription
                visible:        text !== ""
                font.pointSize: ScreenTools.smallFontPointSize
                wrapMode:       Text.WordWrap
            }
        }
    }
}
