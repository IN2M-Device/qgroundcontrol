#pragma once

#include <QtQmlIntegration/QtQmlIntegration>

#include "SettingsGroup.h"

class FlyViewSettings : public SettingsGroup
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("")
public:
    FlyViewSettings(QObject* parent = nullptr);

    DEFINE_SETTING_NAME_GROUP()

    DEFINE_SETTINGFACT(guidedMinimumAltitude)
    DEFINE_SETTINGFACT(guidedMaximumAltitude)
    DEFINE_SETTINGFACT(showLogReplayStatusBar)
    DEFINE_SETTINGFACT(showAdditionalIndicatorsCompass)
    DEFINE_SETTINGFACT(lockNoseUpCompass)
    DEFINE_SETTINGFACT(maxGoToLocationDistance)
    DEFINE_SETTINGFACT(forwardFlightGoToLocationLoiterRad)
    DEFINE_SETTINGFACT(goToLocationRequiresConfirmInGuided)
    DEFINE_SETTINGFACT(keepMapCenteredOnVehicle)
    DEFINE_SETTINGFACT(showSimpleCameraControl)
    DEFINE_SETTINGFACT(showObstacleDistanceOverlay)
    DEFINE_SETTINGFACT(updateHomePosition)
    DEFINE_SETTINGFACT(instrumentQmlFile2)
    DEFINE_SETTINGFACT(requestControlAllowTakeover)
    DEFINE_SETTINGFACT(requestControlTimeout)
    DEFINE_SETTINGFACT(enableAutomaticMissionPopups)

    DEFINE_SETTINGFACT(showTargetsOverlay)
    DEFINE_SETTINGFACT(showTargetsButton)
    DEFINE_SETTINGFACT(targetCount)
    DEFINE_SETTINGFACT(target1Color)
    DEFINE_SETTINGFACT(target1ReticleStyle)
    DEFINE_SETTINGFACT(target1PosX)
    DEFINE_SETTINGFACT(target1PosY)
    DEFINE_SETTINGFACT(target2Color)
    DEFINE_SETTINGFACT(target2ReticleStyle)
    DEFINE_SETTINGFACT(target2PosX)
    DEFINE_SETTINGFACT(target2PosY)
    DEFINE_SETTINGFACT(target3Color)
    DEFINE_SETTINGFACT(target3ReticleStyle)
    DEFINE_SETTINGFACT(target3PosX)
    DEFINE_SETTINGFACT(target3PosY)
    DEFINE_SETTINGFACT(target4Color)
    DEFINE_SETTINGFACT(target4ReticleStyle)
    DEFINE_SETTINGFACT(target4PosX)
    DEFINE_SETTINGFACT(target4PosY)
};
