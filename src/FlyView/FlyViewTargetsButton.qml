import QGroundControl

ToolStripAction {
    id:         action
    text:       qsTr("Targets")
    iconSource: "/InstrumentValueIcons/target.svg"
    visible:    QGroundControl.settingsManager.flyViewSettings.showTargetsButton.value

    onTriggered: {
        var fact = QGroundControl.settingsManager.flyViewSettings.showTargetsOverlay
        fact.value = !fact.value
    }
}
