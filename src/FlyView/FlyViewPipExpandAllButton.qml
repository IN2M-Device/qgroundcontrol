import QGroundControl

ToolStripAction {
    id:         action
    text:       qsTr("Cams")
    iconSource: "/res/chevron-double-left.svg"
    enabled:    QGroundControl.videoManager.hasVideo   ||
                QGroundControl.videoManager.hasVideo2  ||
                QGroundControl.videoManager.hasVideo3  ||
                QGroundControl.videoManager.hasVideo4
}
