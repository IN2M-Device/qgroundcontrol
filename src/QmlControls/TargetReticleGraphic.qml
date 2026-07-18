import QtQuick

// Renders a single target reticle (one of the 9 styles used by FlyView's Targets
// feature) for a given color. Shared between the actual Fly View overlay
// (FlyViewTargetsOverlay.qml) and the style preview swatches in the Targets
// settings page (FlyViewTargetsSettings.qml), so both stay visually identical.
//
// Built entirely from Rectangle primitives rather than Canvas: QtQuick Canvas's
// FBO/texture allocation was found to silently fail (blank output, no error) on
// some GL backends (reproduced on an Android emulator using GPU passthrough),
// so it's not a reliable choice for a widget that must always render.
Item {
    id: reticle

    property int   style:         6 // Classic
    property color reticleColor:  "red"

    readonly property real _lineWidth: Math.max(1, width * 0.06)
    readonly property real _outerR:    width / 2 * 0.8

    // Number of concentric rings, whether the crosshair has a gap at the ring,
    // whether a center dot is shown, and any style-specific extras.
    readonly property int  _ringCount: {
        switch (style) {
        case 0: return 2 // Bullseye Dot
        case 2: return 2 // Bullseye Marks
        case 3: return 2 // Double Ring
        case 7: return 3 // Concentric
        case 8: return 2 // Focus Brackets
        default: return 1
        }
    }
    readonly property bool _gapped:    style === 1 || style === 4 || style === 5 || style === 8
    readonly property bool _showDot:   style !== 2 && style !== 7
    readonly property bool _offsetDot: style === 5
    readonly property bool _endCaps:   style === 4
    readonly property bool _brackets:  style === 8

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
            border.color:     reticle.reticleColor
            border.width:     reticle._lineWidth
        }
    }

    // Full crosshair, edge to edge through the rings
    Rectangle {
        visible:                  !reticle._gapped
        anchors.verticalCenter:   parent.verticalCenter
        width:                    reticle.width
        height:                   reticle._lineWidth
        color:                    reticle.reticleColor
    }
    Rectangle {
        visible:                  !reticle._gapped
        anchors.horizontalCenter: parent.horizontalCenter
        width:                    reticle._lineWidth
        height:                   reticle.height
        color:                    reticle.reticleColor
    }

    // Gapped crosshair: four short segments from the outer ring to the edge
    Rectangle { // left
        visible: reticle._gapped
        x:       0
        y:       reticle.height / 2 - reticle._lineWidth / 2
        width:   reticle.width / 2 - reticle._outerR
        height:  reticle._lineWidth
        color:   reticle.reticleColor
    }
    Rectangle { // right
        visible: reticle._gapped
        x:       reticle.width / 2 + reticle._outerR
        y:       reticle.height / 2 - reticle._lineWidth / 2
        width:   reticle.width / 2 - reticle._outerR
        height:  reticle._lineWidth
        color:   reticle.reticleColor
    }
    Rectangle { // top
        visible: reticle._gapped
        x:       reticle.width / 2 - reticle._lineWidth / 2
        y:       0
        width:   reticle._lineWidth
        height:  reticle.height / 2 - reticle._outerR
        color:   reticle.reticleColor
    }
    Rectangle { // bottom
        visible: reticle._gapped
        x:       reticle.width / 2 - reticle._lineWidth / 2
        y:       reticle.height / 2 + reticle._outerR
        width:   reticle._lineWidth
        height:  reticle.height / 2 - reticle._outerR
        color:   reticle.reticleColor
    }

    // Perpendicular end-caps at the outer tips (Cross Ends style)
    Rectangle { // left cap
        visible: reticle._endCaps
        x:       0
        y:       reticle.height / 2 - reticle._lineWidth * 2
        width:   reticle._lineWidth
        height:  reticle._lineWidth * 4
        color:   reticle.reticleColor
    }
    Rectangle { // right cap
        visible: reticle._endCaps
        x:       reticle.width - reticle._lineWidth
        y:       reticle.height / 2 - reticle._lineWidth * 2
        width:   reticle._lineWidth
        height:  reticle._lineWidth * 4
        color:   reticle.reticleColor
    }
    Rectangle { // top cap
        visible: reticle._endCaps
        x:       reticle.width / 2 - reticle._lineWidth * 2
        y:       0
        width:   reticle._lineWidth * 4
        height:  reticle._lineWidth
        color:   reticle.reticleColor
    }
    Rectangle { // bottom cap
        visible: reticle._endCaps
        x:       reticle.width / 2 - reticle._lineWidth * 2
        y:       reticle.height - reticle._lineWidth
        width:   reticle._lineWidth * 4
        height:  reticle._lineWidth
        color:   reticle.reticleColor
    }

    // Center dot (optionally offset off-axis for the Offset Dot style)
    Rectangle {
        visible:                reticle._showDot
        width:                  reticle.width * 0.12
        height:                 width
        radius:                 width / 2
        color:                  reticle.reticleColor
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
                color:  reticle.reticleColor
            }
            Rectangle { // vertical arm
                x:      parent.isRight ? parent.width - width : 0
                y:      0
                width:  reticle._lineWidth
                height: parent.height
                color:  reticle.reticleColor
            }
        }
    }
}
